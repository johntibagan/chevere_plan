#!/usr/bin/env python3
"""Sincroniza esquema PDN con TEST/baseline (al decir «publica»).

  python scripts/migrate_test_to_pdn.py

Requiere SUPABASE_DB_URL_PDN en backend/.env.

Orden:
  1. Parches pendientes en migrations/ (cualquier .sql que no sea baseline)
  2. 20260808000001_schema.sql + 20260808000003_storage.sql
  3. Borra los parches aplicados (solo en disco; baseline ya los incluye)

No toca seed ni datos de usuario. SQL idempotente obligatorio en baseline y parches.
"""

from __future__ import annotations

import os
import subprocess
import sys
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS = ROOT / "supabase" / "migrations"

BASELINE = frozenset(
    {
        "20260808000001_schema.sql",
        "20260808000002_seed.sql",
        "20260808000003_storage.sql",
    }
)

PDN_APPLY = (
    MIGRATIONS / "20260808000001_schema.sql",
    MIGRATIONS / "20260808000003_storage.sql",
)


def load_env(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.is_file():
        return out
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        k, v = line.split("=", 1)
        out[k.strip()] = v.strip().strip('"').strip("'")
    return out


def pending_patches() -> list[Path]:
    if not MIGRATIONS.is_dir():
        return []
    return sorted(
        p
        for p in MIGRATIONS.glob("*.sql")
        if p.name not in BASELINE and not p.name.endswith("_test.sql")
    )


def apply_sql_psycopg2(url: str, sql: str, label: str) -> None:
    import psycopg2

    conn = psycopg2.connect(url, connect_timeout=120)
    conn.autocommit = False
    try:
        with conn.cursor() as cur:
            cur.execute(sql)
        conn.commit()
    except Exception:
        conn.rollback()
        raise
    finally:
        conn.close()
    print(f"  OK {label}", flush=True)


def apply_sql_docker_psql(url: str, sql: str, label: str) -> None:
    proc = subprocess.run(
        ["docker", "run", "--rm", "-i", "postgres:17", "psql", url, "-v", "ON_ERROR_STOP=1"],
        input=sql,
        capture_output=True,
        text=True,
        encoding="utf-8",
    )
    if proc.returncode != 0:
        err = (proc.stderr or proc.stdout or "").strip()
        raise RuntimeError(f"{label} falló (psql):\n{err[-3000:]}")
    print(f"  OK {label} (docker psql)", flush=True)


def apply_sql(url: str, sql: str, label: str) -> None:
    try:
        apply_sql_psycopg2(url, sql, label)
    except Exception as exc:
        msg = str(exc).lower()
        if "could not translate host name" in msg or "name or service not known" in msg:
            print(f"  pooler DNS falló; reintento con docker psql…", flush=True)
            apply_sql_docker_psql(url, sql, label)
        else:
            raise


def apply_file(url: str, path: Path) -> None:
    apply_sql(url, path.read_text(encoding="utf-8"), path.name)


def main() -> int:
    env = load_env(ROOT / ".env")
    url = env.get("SUPABASE_DB_URL_PDN") or os.environ.get("SUPABASE_DB_URL_PDN")
    if not url:
        print("Falta SUPABASE_DB_URL_PDN", file=sys.stderr)
        return 1

    missing = [p for p in PDN_APPLY if not p.is_file()]
    if missing:
        print("Faltan baseline:", ", ".join(p.name for p in missing), file=sys.stderr)
        return 1

    patches = pending_patches()
    print("Sincronizando esquema PDN…", flush=True)
    if patches:
        print(f"  Parches pendientes ({len(patches)}):", flush=True)
        for path in patches:
            print(f"    → {path.name}", flush=True)
            apply_file(url, path)
    else:
        print("  Sin parches pendientes.", flush=True)

    for path in PDN_APPLY:
        print(f"  Baseline {path.name}…", flush=True)
        apply_file(url, path)

    apply_sql(url, "DROP INDEX IF EXISTS public.beta_feedback_ticket_no_uidx;", "cleanup uidx")

    for path in patches:
        path.unlink()
        print(f"  Eliminado parche {path.name}", flush=True)

    print("PDN esquema = baseline TEST. Listo para publicar.", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
