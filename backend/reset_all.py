#!/usr/bin/env python3
"""Borra datos de la app, reaplica migraciones + DIVIPOLA, deja root.

  cd C:\\workspace\\chevere_plan\\backend
  python reset_all.py
"""

from __future__ import annotations

import os
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SUPA = ROOT / "supabase"
MIGRATIONS = SUPA / "migrations"
SCRIPTS = SUPA / "scripts"
ROOT_EMAIL = "johnftmovil@gmail.com"


def _load_dotenv(path: Path) -> None:
    if not path.is_file():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        key = key.strip()
        val = val.strip().strip('"').strip("'")
        if key and key not in os.environ:
            os.environ[key] = val


def _ensure_psycopg():
    try:
        import psycopg  # noqa: F401
        return
    except ImportError:
        pass
    print("Instalando psycopg...", flush=True)
    import subprocess

    subprocess.check_call(
        [sys.executable, "-m", "pip", "install", "psycopg[binary]"],
    )


def iter_sql_statements(script: str):
    i = 0
    n = len(script)
    start = 0
    while i < n:
        c = script[i]
        nxt = script[i + 1] if i + 1 < n else ""
        if c == "-" and nxt == "-":
            i = script.find("\n", i)
            if i < 0:
                break
            continue
        if c == "/" and nxt == "*":
            j = script.find("*/", i + 2)
            if j < 0:
                raise ValueError("comentario /* */ sin cerrar")
            i = j + 2
            continue
        if c == "'":
            i += 1
            while i < n:
                if script[i] == "'":
                    if i + 1 < n and script[i + 1] == "'":
                        i += 2
                        continue
                    i += 1
                    break
                i += 1
            continue
        if c == '"':
            i += 1
            while i < n:
                if script[i] == '"':
                    i += 1
                    break
                i += 1
            continue
        if c == "$":
            j = i + 1
            while j < n and (script[j].isalnum() or script[j] == "_"):
                j += 1
            if j < n and script[j] == "$":
                tag = script[i : j + 1]
                k = script.find(tag, j + 1)
                if k < 0:
                    raise ValueError(f"dollar-quote {tag} sin cerrar")
                i = k + len(tag)
                continue
        if c == ";":
            stmt = script[start:i].strip()
            if stmt:
                yield stmt
            i += 1
            start = i
            continue
        i += 1
    tail = script[start:].strip()
    if tail:
        yield tail


def _ipv4_addrs(host: str) -> list[str]:
    import re
    import socket
    import subprocess

    ips: list[str] = []
    try:
        for *_, sa in socket.getaddrinfo(host, 5432, socket.AF_INET):
            ips.append(sa[0])
    except OSError:
        pass
    if not ips:
        try:
            out = subprocess.check_output(
                ["nslookup", host],
                text=True,
                timeout=8,
                stderr=subprocess.STDOUT,
            )
            for ip in re.findall(r"\b(\d+\.\d+\.\d+\.\d+)\b", out):
                if ip.startswith("127.") or ip.startswith("192.168."):
                    continue
                ips.append(ip)
        except (OSError, subprocess.SubprocessError):
            pass
    seen: set[str] = set()
    uniq: list[str] = []
    for ip in ips:
        if ip not in seen:
            seen.add(ip)
            uniq.append(ip)
    return uniq


def _connect(url: str):
    import psycopg
    from psycopg.conninfo import conninfo_to_dict, make_conninfo

    if "sslmode=" not in url:
        url += ("&" if "?" in url else "?") + "sslmode=require"

    d = conninfo_to_dict(url)
    host = d.get("host") or ""
    candidates: list[dict] = [dict(d)]

    if host.startswith("db.") and host.endswith(".supabase.co"):
        ref = host.split(".")[1]
        region = os.environ.get("SUPABASE_REGION", "us-east-2")
        user = d.get("user") or "postgres"
        if "." not in user:
            user = f"{user}.{ref}"
        for cluster in (0, 1):
            alt = dict(d)
            alt["user"] = user
            alt["host"] = f"aws-{cluster}-{region}.pooler.supabase.com"
            alt["port"] = "5432"
            candidates.append(alt)

    last_exc: Exception | None = None
    for cfg in candidates:
        h = cfg.get("host") or ""
        addrs = _ipv4_addrs(h)
        targets = [dict(cfg, hostaddr=ip) for ip in addrs] or [cfg]
        for t in targets:
            try:
                conninfo = make_conninfo(**{k: str(v) for k, v in t.items() if v is not None})
                return psycopg.connect(conninfo, autocommit=False, connect_timeout=15)
            except psycopg.Error as exc:
                last_exc = exc
                continue

    print(
        "No pude conectar a Postgres (esta red no tiene IPv6).\n"
        "En Supabase: Project Settings → Database → Connect → Session pooler\n"
        "Copia la URI y pégala en backend/.env como SUPABASE_DB_URL\n"
        "Luego: powershell -File C:\\workspace\\chevere_plan\\backend\\reset_all.ps1",
        file=sys.stderr,
    )
    if last_exc:
        raise last_exc
    raise SystemExit(2)


def _run_file(conn, path: Path) -> int:
    sql = path.read_text(encoding="utf-8")
    statements = list(iter_sql_statements(sql))
    n = 0
    with conn.transaction():
        with conn.cursor() as cur:
            for stmt in statements:
                cur.execute(stmt)
                n += 1
    return n


def _db_url() -> str:
    url = (os.environ.get("SUPABASE_DB_URL") or os.environ.get("DATABASE_URL") or "").strip()
    if not url:
        print(
            "Falta SUPABASE_DB_URL en backend/.env "
            "(URI directa, puerto 5432).",
            file=sys.stderr,
        )
        sys.exit(2)
    return url


def _assign_root(conn, email: str) -> None:
    with conn.cursor() as cur:
        cur.execute(
            """
            insert into public.profiles (id, display_name, role)
            select id,
                   coalesce(raw_user_meta_data->>'full_name', email),
                   'user'
            from auth.users
            on conflict (id) do nothing
            """
        )
        cur.execute(
            """
            update public.profiles
            set role = 'root'
            where id = (select id from auth.users where email = %s)
            """,
            (email,),
        )
        updated = cur.rowcount
    if updated == 0:
        print(
            f"  aviso: {email} aún no está en Auth. Entra con Google y vuelve a correr este script.",
            flush=True,
        )
    else:
        print(f"  root = {email}", flush=True)


def _plan() -> list[tuple[str, Path]]:
    files: list[tuple[str, Path]] = [
        ("nuke", SCRIPTS / "00_nuke.sql"),
    ]
    for p in sorted(MIGRATIONS.glob("*.sql")):
        files.append((f"mig {p.name}", p))
    div = SCRIPTS / "05_sync_divipola.sql"
    if div.is_file():
        files.append(("divipola", div))
    return files


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass
    _load_dotenv(ROOT / ".env")
    plan = _plan()
    print("Reset: borra datos, remigra, DIVIPOLA, root.")
    for label, path in plan:
        if not path.is_file():
            print(f"  FALTA {path}", file=sys.stderr)
            return 1
        print(f"  - {label}")

    _ensure_psycopg()
    url = _db_url()
    t0 = time.time()
    print("Conectando...", flush=True)
    conn = _connect(url)
    try:
        for label, path in plan:
            print(f"> {label} ...", flush=True)
            n = _run_file(conn, path)
            conn.commit()
            print(f"  ok ({n})", flush=True)

        print(f"> root {ROOT_EMAIL} ...", flush=True)
        _assign_root(conn, ROOT_EMAIL)
        conn.commit()

        with conn.cursor() as cur:
            cur.execute("notify pgrst, 'reload schema';")
        conn.commit()
    finally:
        conn.close()

    print(f"Listo en {time.time() - t0:.1f}s. Cierra sesión en la app.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
