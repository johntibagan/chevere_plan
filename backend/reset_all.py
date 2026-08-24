#!/usr/bin/env python3
"""Reset de datos Chevere Plan.

Solo datos de usuario (rápido):
  python reset_all.py
  Conserva DIVIPOLA + sitios de carga masiva (external_id).
  Root único: johnftm.proyectos@gmail.com

Cero absoluto + reseeding (lento):
  python reset_all.py --full
  Nuke schema → migraciones en orden (schema, seed, storage + posteriores) → regenera/aplica DIVIPOLA →
  carga masiva de sitios (JSON actual) → root único.
"""

from __future__ import annotations

import argparse
import os
import subprocess
import sys
import time
from pathlib import Path

ROOT = Path(__file__).resolve().parent
SUPA = ROOT / "supabase"
MIGRATIONS = SUPA / "migrations"
SCRIPTS = SUPA / "scripts"
REPO = ROOT.parent

ROOT_EMAIL = "johnftm.proyectos@gmail.com"
CATALOG_OWNER_EMAIL = ROOT_EMAIL
CATALOG_JSON = REPO / "docs" / "data" / "colombia_departamentos_municipios_sitios.json"


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


def _ensure_psycopg() -> None:
    try:
        import psycopg  # noqa: F401
        return
    except ImportError:
        pass
    print("Instalando psycopg...", flush=True)
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
    """Resuelve A records IPv4. En esta red getaddrinfo/nslookup a veces fallan;
    PowerShell Resolve-DnsName suele funcionar."""
    import re
    import socket

    def _is_usable(ip: str) -> bool:
        if ip.startswith("127.") or ip.startswith("0."):
            return False
        # Respuestas basura del router (.bbrouter → 192.168.x).
        if ip.startswith("192.168.") or ip.startswith("10."):
            return False
        if ip.startswith("169.254."):
            return False
        return True

    ips: list[str] = []

    try:
        for *_, sa in socket.getaddrinfo(host, 5432, socket.AF_INET):
            if _is_usable(sa[0]):
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
                if _is_usable(ip):
                    ips.append(ip)
        except (OSError, subprocess.SubprocessError):
            pass

    if not ips and sys.platform.startswith("win"):
        try:
            # Evita search-domain del router que rompe nslookup/getaddrinfo.
            ps = (
                f"(Resolve-DnsName -Name '{host}' -Type A "
                f"-ErrorAction Stop).IPAddress"
            )
            out = subprocess.check_output(
                ["powershell", "-NoProfile", "-Command", ps],
                text=True,
                timeout=15,
                stderr=subprocess.STDOUT,
            )
            for ip in re.findall(r"\b(\d+\.\d+\.\d+\.\d+)\b", out):
                if _is_usable(ip):
                    ips.append(ip)
        except (OSError, subprocess.SubprocessError):
            pass

    if not ips:
        # DNS-over-HTTPS (Cloudflare) como último recurso.
        try:
            import json
            import urllib.request

            req = urllib.request.Request(
                f"https://cloudflare-dns.com/dns-query?name={host}&type=A",
                headers={"Accept": "application/dns-json"},
            )
            with urllib.request.urlopen(req, timeout=10) as resp:
                data = json.loads(resp.read().decode("utf-8"))
            for ans in data.get("Answer") or []:
                if ans.get("type") == 1:
                    ip = str(ans.get("data") or "")
                    if _is_usable(ip):
                        ips.append(ip)
        except Exception:
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
        if addrs:
            print(f"  DNS {h} -> {', '.join(addrs)}", flush=True)
        # Siempre preferir hostaddr IPv4: evita que psycopg vuelva a fallar
        # en getaddrinfo del hostname.
        targets = [dict(cfg, hostaddr=ip) for ip in addrs]
        if not targets:
            targets = [cfg]
        for t in targets:
            try:
                conninfo = make_conninfo(
                    **{k: str(v) for k, v in t.items() if v is not None}
                )
                return psycopg.connect(
                    conninfo, autocommit=False, connect_timeout=15
                )
            except psycopg.Error as exc:
                last_exc = exc
                continue

    print(
        "No pude conectar a Postgres (falló DNS/resolución IPv4 del pooler).\n"
        "Prueba: Session pooler en SUPABASE_DB_URL (backend/.env).\n"
        "Si persiste: cambia DNS del PC a 1.1.1.1 o 8.8.8.8 y reintenta.\n"
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
    url = (
        os.environ.get("SUPABASE_DB_URL") or os.environ.get("DATABASE_URL") or ""
    ).strip()
    if not url:
        print(
            "Falta SUPABASE_DB_URL en backend/.env "
            "(URI directa, puerto 5432).",
            file=sys.stderr,
        )
        sys.exit(2)
    return url


def _assign_sole_root(conn, email: str) -> None:
    """Solo [email] queda root; cualquier otro root pasa a user."""
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
            set role = 'user'
            where role = 'root'
              and id <> coalesce(
                (select id from auth.users where email = %s),
                '00000000-0000-0000-0000-000000000000'::uuid
              )
            """,
            (email,),
        )
        demoted = cur.rowcount
        cur.execute(
            """
            update public.profiles
            set role = 'root'
            where id = (select id from auth.users where email = %s)
            """,
            (email,),
        )
        if cur.rowcount == 0:
            print(
                f"  aviso: {email} aun no esta en Auth. Entra con Google y vuelve a correr.",
                flush=True,
            )
        else:
            print(f"  root unico = {email}", flush=True)
        if demoted:
            print(f"  otros root degradados a user: {demoted}", flush=True)


def _reassign_catalog_owner(conn, email: str) -> None:
    with conn.cursor() as cur:
        cur.execute("select id from auth.users where email = %s", (email,))
        row = cur.fetchone()
        if row is None:
            print(
                f"  aviso: no reasigne catalogo; {email} no esta en Auth.",
                flush=True,
            )
            return
        owner_id = row[0]
        cur.execute(
            """
            update public.sites
            set created_by = %s, updated_at = now()
            where external_id is not null
              and created_by is distinct from %s
            """,
            (owner_id, owner_id),
        )
        print(
            f"  catalogo created_by -> {email} ({cur.rowcount} filas)",
            flush=True,
        )


def _refresh_divipola_sql() -> Path:
    """Regenera 05_sync_divipola.sql desde datos.gov.co; si falla, usa el existente."""
    out = SCRIPTS / "05_sync_divipola.sql"
    py = SCRIPTS / "05_sync_divipola.py"
    print("> regenerando DIVIPOLA desde datos.gov.co ...", flush=True)
    try:
        subprocess.check_call(
            [sys.executable, str(py), "--sql", "-o", str(out)],
            cwd=str(SCRIPTS),
        )
        print("  DIVIPOLA SQL regenerado", flush=True)
    except Exception as exc:
        print(
            f"  aviso: no se regenero desde API ({exc}); uso SQL existente",
            flush=True,
        )
    if not out.is_file():
        raise SystemExit(f"Falta {out}")
    return out


def _import_mass_sites(conn) -> None:
    """Carga masiva en la misma conexión (evita reconectar al pooler)."""
    if not CATALOG_JSON.is_file():
        raise SystemExit(f"Falta dataset: {CATALOG_JSON}")
    import importlib.util

    importer = SCRIPTS / "06_import_public_sites.py"
    spec = importlib.util.spec_from_file_location(
        "import_public_sites", importer
    )
    if spec is None or spec.loader is None:
        raise SystemExit(f"No se pudo cargar {importer}")
    mod = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(mod)
    print(f"> carga masiva sitios desde {CATALOG_JSON.name} ...", flush=True)
    mod.run_import(conn, CATALOG_JSON, owner_email=CATALOG_OWNER_EMAIL)


def _plan_user_data() -> list[tuple[str, Path]]:
    return [("wipe user data", SCRIPTS / "01_wipe_user_data.sql")]


def _plan_full() -> list[tuple[str, Path]]:
    files: list[tuple[str, Path]] = [
        ("nuke", SCRIPTS / "00_nuke.sql"),
    ]
    for p in sorted(MIGRATIONS.glob("*.sql")):
        files.append((f"mig {p.name}", p))
    # DIVIPOLA path se inserta en main tras regenerar
    return files


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

    parser = argparse.ArgumentParser(
        description=(
            "Reset Chevere Plan. Default=solo usuarios; "
            "--full=cero + DIVIPOLA + carga masiva."
        ),
    )
    parser.add_argument(
        "--full",
        action="store_true",
        help=(
            "Nuke total + migraciones + actualiza DIVIPOLA + "
            "carga masiva de sitios + root unico."
        ),
    )
    args = parser.parse_args()

    _load_dotenv(ROOT / ".env")
    plan = _plan_full() if args.full else _plan_user_data()

    if args.full:
        print(
            "Reset FULL (cero): nuke + migraciones + DIVIPOLA + "
            f"carga masiva + root={ROOT_EMAIL}"
        )
    else:
        print(
            "Reset usuarios: borra sitios/planes/saves/fotos de usuarios; "
            "conserva DIVIPOLA + sitios masivos; "
            f"root={ROOT_EMAIL}"
        )

    for label, path in plan:
        if not path.is_file():
            print(f"  FALTA {path}", file=sys.stderr)
            return 1
        print(f"  - {label}")
    if args.full:
        print("  - divipola (regenerar + aplicar)")
        print(f"  - import masivo ({CATALOG_JSON.name})")

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

        if args.full:
            # Misma conexión para DIVIPOLA + import: no cerrar/reconectar
            # (el pooler a veces falla DNS/IPv6 en un segundo connect).
            div_path = _refresh_divipola_sql()
            print("> aplicando DIVIPOLA ...", flush=True)
            n = _run_file(conn, div_path)
            conn.commit()
            print(f"  ok ({n})", flush=True)
            _import_mass_sites(conn)

        print(f"> root unico {ROOT_EMAIL} ...", flush=True)
        _assign_sole_root(conn, ROOT_EMAIL)
        print(f"> catalogo owner {CATALOG_OWNER_EMAIL} ...", flush=True)
        _reassign_catalog_owner(conn, CATALOG_OWNER_EMAIL)
        conn.commit()

        with conn.cursor() as cur:
            cur.execute("notify pgrst, 'reload schema'")
        conn.commit()
    finally:
        try:
            conn.close()
        except Exception:
            pass

    print(f"Listo en {time.time() - t0:.1f}s. Cierra sesion en la app.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
