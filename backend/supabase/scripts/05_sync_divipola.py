#!/usr/bin/env python3
"""Sincroniza DIVIPOLA (DANE / datos.gov.co) hacia Supabase.

Fuente: https://www.datos.gov.co/resource/gdxc-w37w.json
(dataset de municipios; los departamentos se deducen por distinct).

Uso:
  python 05_sync_divipola.py --sql -o 05_sync_divipola.sql

El reset (`backend/reset_all.py`) aplica ese SQL después de las migraciones.
No llama la API desde la app.
"""

from __future__ import annotations

import argparse
import json
import sys
import unicodedata
import urllib.request
from pathlib import Path

DATASET = "gdxc-w37w"
BASE = f"https://www.datos.gov.co/resource/{DATASET}.json"
PAGE = 1000
SMALL = {"de", "del", "la", "las", "los", "y", "da", "do", "e"}


def fold(s: str) -> str:
    t = unicodedata.normalize("NFD", s.strip().lower())
    return "".join(c for c in t if unicodedata.category(c) != "Mn")


def title_es(raw: str) -> str:
    words = raw.strip().split()
    out = []
    for i, w in enumerate(words):
        compact = fold(w).replace(" ", "").replace(".", "")
        if compact in {"dc"}:
            out.append("D.C.")
            continue
        low = w.lower()
        if i > 0 and fold(low) in SMALL and "." not in w:
            out.append(low)
        else:
            out.append(w.capitalize())
    return " ".join(out)


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def fetch_all() -> list[dict]:
    rows: list[dict] = []
    offset = 0
    while True:
        url = f"{BASE}?$limit={PAGE}&$offset={offset}&$order=cod_mpio"
        req = urllib.request.Request(
            url,
            headers={"Accept": "application/json", "User-Agent": "CheverePlan-divipola-sync/1.0"},
        )
        with urllib.request.urlopen(req, timeout=60) as res:
            chunk = json.loads(res.read().decode("utf-8"))
        if not isinstance(chunk, list) or not chunk:
            break
        rows.extend(chunk)
        if len(chunk) < PAGE:
            break
        offset += PAGE
    return rows


def build_sql(rows: list[dict]) -> str:
    depts: dict[str, str] = {}
    cities: list[tuple[str, str, str, str]] = []
    for r in rows:
        d_code = str(r.get("cod_dpto") or "").zfill(2)
        d_name = title_es(str(r.get("dpto") or ""))
        c_code = str(r.get("cod_mpio") or "")
        c_name = title_es(str(r.get("nom_mpio") or ""))
        kind = str(r.get("tipo_municipio") or "").strip() or "Municipio"
        if not d_code or not d_name or not c_code or not c_name:
            continue
        depts[d_code] = d_name
        cities.append((d_code, c_code, c_name, kind))

    lines = [
        "-- Generado por 05_sync_divipola.py desde datos.gov.co/resource/gdxc-w37w",
        "-- Idempotente: upsert por código DIVIPOLA. Desactiva filas CO ausentes en esta corrida.",
        "",
        "insert into public.countries (code, name) values ('CO', 'Colombia')",
        "on conflict (code) do update set name = excluded.name, is_active = true;",
        "",
    ]

    for code, name in sorted(depts.items()):
        lines.append(
            "insert into public.departments (country_code, code, name, name_norm, is_active)"
        )
        lines.append(
            f"values ('CO', {sql_str(code)}, {sql_str(name)}, {sql_str(fold(name))}, true)"
        )
        lines.append(
            "on conflict (country_code, code) do update set "
            "name = excluded.name, name_norm = excluded.name_norm, "
            "is_active = true, updated_at = now();"
        )
        lines.append("")

    d_codes_sql = ", ".join(sql_str(c) for c in sorted(depts))
    lines.append(
        "update public.departments set is_active = false, updated_at = now() "
        f"where country_code = 'CO' and code not in ({d_codes_sql});"
    )
    lines.append("")

    for d_code, c_code, c_name, kind in cities:
        lines.append("insert into public.cities (department_id, code, name, name_norm, kind, is_active)")
        lines.append("select d.id, " + ", ".join([
            sql_str(c_code),
            sql_str(c_name),
            sql_str(fold(c_name)),
            sql_str(kind),
            "true",
        ]))
        lines.append("from public.departments d")
        lines.append(f"where d.country_code = 'CO' and d.code = {sql_str(d_code)}")
        lines.append("on conflict (department_id, code) do update set")
        lines.append(
            "  name = excluded.name, name_norm = excluded.name_norm, "
            "kind = excluded.kind, is_active = true, updated_at = now();"
        )
        lines.append("")

    lines.append("-- Desactivar municipios CO que ya no vienen en DIVIPOLA")
    lines.append("update public.cities c set is_active = false, updated_at = now()")
    lines.append("from public.departments d")
    lines.append("where c.department_id = d.id and d.country_code = 'CO'")
    lines.append("  and not exists (")
    lines.append("    select 1 from (values")
    value_rows = [f"      ({sql_str(d)}, {sql_str(c)})" for d, c, _, _ in cities]
    lines.append(",\n".join(value_rows))
    lines.append("    ) as keep(d_code, c_code)")
    lines.append("    where keep.d_code = d.code and keep.c_code = c.code")
    lines.append("  );")
    lines.append("")
    return "\n".join(lines)


def main() -> int:
    p = argparse.ArgumentParser()
    p.add_argument("--sql", action="store_true", help="Escribe SQL upsert a stdout o -o")
    p.add_argument("-o", "--output", type=Path)
    args = p.parse_args()
    if not args.sql:
        print("Usa --sql (ver docstring).", file=sys.stderr)
        return 2
    rows = fetch_all()
    if len(rows) < 1000:
        print(f"Pocos registros ({len(rows)}); abortando.", file=sys.stderr)
        return 1
    sql = build_sql(rows)
    if args.output:
        args.output.write_text(sql, encoding="utf-8")
        print(f"OK {len(rows)} filas → {args.output}", file=sys.stderr)
    else:
        sys.stdout.write(sql)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
