"""Genera SQL de categorías desde frontend/categorias-propuesta-simplificada.csv."""
from __future__ import annotations

import csv
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
CSV_PATH = ROOT / "frontend" / "categorias-propuesta-simplificada.csv"
SCRIPT_OUT = Path(__file__).with_name("04_reseed_categories_simplified.sql")
SEED_OUT = (
    Path(__file__).resolve().parents[1]
    / "migrations"
    / "20260808000002_ciclo1_seed.sql"
)
M10_OUT = (
    Path(__file__).resolve().parents[1]
    / "migrations"
    / "20260808000010_ciclo8_categories_keywords.sql"
)

ROOT_META = {
    "gastronomia": (
        "coffee",
        "#FF8C42",
        ["comida", "comer", "restaurante", "beber", "gastro", "food"],
    ),
    "alojamiento": (
        "bed",
        "#8B7FFF",
        ["hotel", "hospedaje", "dormir", "quedarse", "hospedar", "lodging"],
    ),
    "naturaleza": (
        "trees",
        "#00D68F",
        ["aire libre", "outdoor", "naturaleza", "campo", "verde", "ecologia"],
    ),
    "deporte": (
        "sport",
        "#2ECC71",
        [
            "deporte",
            "deportivo",
            "ejercicio",
            "cancha",
            "juego",
            "actividad fisica",
        ],
    ),
    "cultura": (
        "palette",
        "#E84393",
        ["cultura", "historia", "patrimonio", "turismo cultural", "monumentos"],
    ),
    "entretenimiento": (
        "music",
        "#FFBB33",
        [
            "plan",
            "planes",
            "diversion",
            "ocio",
            "recreacion",
            "entretenimiento",
            "salir",
        ],
    ),
    "compras": (
        "shopping",
        "#00C9A7",
        ["comprar", "shopping", "tienda", "mercado", "souvenir"],
    ),
    "otros": (
        "more",
        "#9E9E9E",
        ["otro", "otros", "varios", "terminal", "transporte"],
    ),
}


def sql_str(s: str) -> str:
    return "'" + s.replace("'", "''") + "'"


def sql_json_es(name: str) -> str:
    return sql_str(json.dumps({"es": name}, ensure_ascii=False)) + "::jsonb"


def sql_text_array(items: list[str]) -> str:
    if not items:
        return "'{}'::text[]"
    parts = ",".join(sql_str(x) for x in items)
    return f"array[{parts}]::text[]"


def main() -> None:
    rows = list(csv.DictReader(CSV_PATH.open(encoding="utf-8")))
    roots: dict[str, dict] = {}
    for r in rows:
        slug = r["category_slug"]
        if slug not in roots:
            roots[slug] = {
                "order": int(r["cat_order"]),
                "name": r["category_name"],
                "active": r["category_active"].lower() == "true",
            }

    # --- reseed script ---
    lines: list[str] = [
        "-- =============================================================================",
        "-- RESEED categorías (propuesta simplificada)",
        "-- Fuente: frontend/categorias-propuesta-simplificada.csv",
        "--",
        "-- Requisitos: site_categories vacío (p. ej. tras 00_reset_public.sql).",
        "-- Ejecutar en: Supabase SQL Editor.",
        "--",
        "-- Tras aplicar: cerrar sesión en la app (limpia caché de categorías).",
        "-- =============================================================================",
        "",
        "truncate table public.site_categories restart identity cascade;",
        "truncate table public.categories restart identity cascade;",
        "",
        "-- Raíces",
        "insert into public.categories "
        "(slug, name_i18n, sort_order, icon_key, color_hex, is_active, "
        "age_restricted, keywords)",
        "values",
    ]
    root_vals = []
    for slug, info in sorted(roots.items(), key=lambda x: x[1]["order"]):
        icon, color, kws = ROOT_META[slug]
        root_vals.append(
            f"  ({sql_str(slug)}, {sql_json_es(info['name'])}, {info['order']}, "
            f"{sql_str(icon)}, {sql_str(color)}, {str(info['active']).lower()}, "
            f"false, {sql_text_array(kws)})"
        )
    lines.append(",\n".join(root_vals) + ";")
    lines += [
        "",
        "-- Subcategorías",
        "insert into public.categories "
        "(parent_id, slug, name_i18n, sort_order, is_active, age_restricted, keywords)",
        "select p.id, v.slug, v.name_i18n, v.sort_order, v.is_active, "
        "v.age_restricted, v.keywords",
        "from public.categories p",
        "join (",
        "  values",
    ]
    sub_vals = []
    for r in rows:
        kw = json.loads(r["keywords"])
        sub_vals.append(
            f"    ({sql_str(r['category_slug'])}, {sql_str(r['subcategory_slug'])}, "
            f"{sql_json_es(r['subcategory_name'])}, {int(r['sub_order'])}, "
            f"{r['subcategory_active'].lower()}, {r['age_restricted'].lower()}, "
            f"{sql_text_array(kw)})"
        )
    lines.append(",\n".join(sub_vals))
    lines += [
        ") as v(parent_slug, slug, name_i18n, sort_order, is_active, "
        "age_restricted, keywords)",
        "  on p.slug = v.parent_slug and p.parent_id is null;",
        "",
        "-- Verificación rápida",
        "select coalesce(p.name_i18n->>'es', p.slug) as category,",
        "       count(c.id) as subcategories",
        "from public.categories p",
        "left join public.categories c on c.parent_id = p.id",
        "where p.parent_id is null",
        "group by p.id, p.name_i18n, p.slug, p.sort_order",
        "order by p.sort_order;",
        "",
    ]
    SCRIPT_OUT.write_text("\n".join(lines), encoding="utf-8")

    # --- seed migration (categories + keep transport from previous file) ---
    seed_cat: list[str] = [
        "-- Seed categorías (propuesta simplificada; "
        "frontend/categorias-propuesta-simplificada.csv)",
        "-- + keywords para autocomplete. Idempotente.",
        "",
        "insert into public.categories "
        "(slug, name_i18n, sort_order, icon_key, color_hex, age_restricted, keywords)",
        "select v.slug, v.name_i18n, v.sort_order, v.icon_key, v.color_hex, "
        "false, v.keywords",
        "from (",
        "  values",
    ]
    root_vals2 = []
    for slug, info in sorted(roots.items(), key=lambda x: x[1]["order"]):
        icon, color, kws = ROOT_META[slug]
        root_vals2.append(
            f"    ({sql_str(slug)}, {sql_json_es(info['name'])}, {info['order']}, "
            f"{sql_str(icon)}, {sql_str(color)}, {sql_text_array(kws)})"
        )
    seed_cat.append(",\n".join(root_vals2))
    seed_cat += [
        ") as v(slug, name_i18n, sort_order, icon_key, color_hex, keywords)",
        "where not exists (",
        "  select 1 from public.categories c "
        "where c.parent_id is null and c.slug = v.slug",
        ");",
        "",
        "insert into public.categories "
        "(parent_id, slug, name_i18n, sort_order, age_restricted, keywords)",
        "select p.id, v.slug, v.name_i18n, v.sort_order, v.age_restricted, "
        "v.keywords",
        "from public.categories p",
        "join (",
        "  values",
    ]
    sub_vals2 = []
    for r in rows:
        kw = json.loads(r["keywords"])
        sub_vals2.append(
            f"    ({sql_str(r['category_slug'])}, {sql_str(r['subcategory_slug'])}, "
            f"{sql_json_es(r['subcategory_name'])}, {int(r['sub_order'])}, "
            f"{r['age_restricted'].lower()}, {sql_text_array(kw)})"
        )
    seed_cat.append(",\n".join(sub_vals2))
    seed_cat += [
        ") as v(parent_slug, slug, name_i18n, sort_order, age_restricted, keywords)",
        "  on p.slug = v.parent_slug and p.parent_id is null",
        "where not exists (",
        "  select 1 from public.categories c",
        "  where c.parent_id = p.id and c.slug = v.slug",
        ");",
        "",
    ]

    old = SEED_OUT.read_text(encoding="utf-8")
    marker = "insert into public.transport_types"
    transport = old[old.index(marker) :]
    SEED_OUT.write_text("\n".join(seed_cat) + "\n" + transport, encoding="utf-8")

    M10_OUT.write_text(
        "-- Ciclo 8+: keywords GIN index "
        "(categorías en seed 000002 simplificado).\n"
        "-- Idempotente: no reintroduce el árbol antiguo.\n\n"
        "alter table public.categories\n"
        "  add column if not exists keywords text[] not null default '{}'::text[];\n\n"
        "create index if not exists categories_keywords_gin\n"
        "  on public.categories using gin (keywords);\n",
        encoding="utf-8",
    )

    print(f"Wrote {SCRIPT_OUT}")
    print(f"Updated {SEED_OUT}")
    print(f"Updated {M10_OUT}")
    print(f"roots={len(roots)} subs={len(rows)}")


if __name__ == "__main__":
    main()
