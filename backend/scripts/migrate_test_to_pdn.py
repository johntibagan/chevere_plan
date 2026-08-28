#!/usr/bin/env python3
"""Aplica migraciones baseline en el proyecto PDN (beta).

  python scripts/migrate_test_to_pdn.py

Requiere SUPABASE_DB_URL_PDN en backend/.env.
La copia de datos TEST→PDN fue one-shot (2026); no se repite desde aquí.

No ejecutar (ni MCP SQL contra PDN) salvo permiso explícito del dueño
(p. ej. al publicar versión). Desarrollo = solo TEST.
"""

from __future__ import annotations

import os
import sys
from pathlib import Path

import psycopg2

ROOT = Path(__file__).resolve().parents[1]
MIGRATIONS = ROOT / "supabase" / "migrations"


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


def connect(url: str):
    return psycopg2.connect(url, connect_timeout=120)


def apply_migrations(dst) -> None:
    order = sorted(MIGRATIONS.glob("*.sql"))
    if not order:
        raise SystemExit(f"No hay migraciones en {MIGRATIONS}")
    for path in order:
        print(f"  migración {path.name}…", flush=True)
        dst.execute(path.read_text(encoding="utf-8"))


def main() -> int:
    env = load_env(ROOT / ".env")
    dst_url = env.get("SUPABASE_DB_URL_PDN") or os.environ.get("SUPABASE_DB_URL_PDN")
    if not dst_url:
        print("Falta SUPABASE_DB_URL_PDN", file=sys.stderr)
        return 1

    print("Aplicando esquema en PDN…", flush=True)
    dst_conn = connect(dst_url)
    dst_conn.autocommit = False
    try:
        with dst_conn.cursor() as dst:
            apply_migrations(dst)
        dst_conn.commit()
    except Exception:
        dst_conn.rollback()
        raise
    finally:
        dst_conn.close()

    print("Esquema listo.", flush=True)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
