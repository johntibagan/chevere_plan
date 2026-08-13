#!/usr/bin/env python3
"""Importa sitios públicos desde el JSON del dataset Colombia.

Lee:
  - sites[]           → atractivos (external_id del JSON)
  - municipalities[]  → cada municipio como sitio público "pueblo/ciudad"
                        (external_id = co-muni-{divipola_code})
                        para que búsquedas como "Tunja" funcionen.

departments[] no se insertan: ya viven en DIVIPOLA.

Uso:
  cd backend
  python supabase/scripts/06_import_public_sites.py ../docs/data/colombia_departamentos_municipios_sitios.json
  python ... --dry-run
  python ... --sites-only          # solo atractivos, sin municipios
  python ... --municipalities-only # solo municipios
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import unicodedata
from pathlib import Path

ROOT = Path(__file__).resolve().parents[2]

SMALL = {"de", "del", "la", "las", "los", "y", "da", "do", "e"}
CONF_RANK = {"high": 3, "medium": 2, "low": 1}


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


def fold(s: str) -> str:
    t = unicodedata.normalize("NFD", (s or "").strip().lower())
    return "".join(c for c in t if unicodedata.category(c) != "Mn")


def title_es(raw: str) -> str:
    words = (raw or "").strip().split()
    out: list[str] = []
    for i, w in enumerate(words):
        compact = fold(w).replace(" ", "").replace(".", "")
        if compact in {"dc"}:
            out.append("D.C.")
            continue
        low = w.lower()
        if i > 0 and fold(low) in SMALL and "." not in w:
            out.append(low)
        else:
            out.append(w[:1].upper() + w[1:].lower() if w else w)
    return " ".join(out)


def _ensure_psycopg() -> None:
    try:
        import psycopg  # noqa: F401
    except ImportError:
        import subprocess

        subprocess.check_call(
            [sys.executable, "-m", "pip", "install", "psycopg[binary]"],
        )


sys.path.insert(0, str(ROOT))
from reset_all import _connect, _db_url  # noqa: E402


def resolve_path(raw: Path) -> Path:
    if raw.is_file():
        return raw
    for alt in (ROOT.parent / raw, ROOT / raw):
        if alt.is_file():
            return alt
    raise SystemExit(f"No existe {raw}")


def load_dataset(path: Path) -> tuple[list[dict], list[dict]]:
    text = path.read_text(encoding="utf-8").strip()
    if not text:
        return [], []
    if path.suffix.lower() == ".jsonl":
        sites: list[dict] = []
        for i, line in enumerate(text.splitlines(), 1):
            line = line.strip()
            if not line:
                continue
            try:
                sites.append(json.loads(line))
            except json.JSONDecodeError as e:
                raise SystemExit(f"JSONL inválido línea {i}: {e}") from e
        return sites, []

    data = json.loads(text)
    if isinstance(data, list):
        return data, []
    if isinstance(data, dict):
        sites = data.get("sites") if isinstance(data.get("sites"), list) else []
        munis = (
            data.get("municipalities")
            if isinstance(data.get("municipalities"), list)
            else []
        )
        return sites, munis
    raise SystemExit("Formato no soportado")


def municipalities_as_sites(munis: list[dict]) -> list[dict]:
    """Convierte filas DIVIPOLA del JSON a sitios públicos pueblo-ciudad."""
    out: list[dict] = []
    for m in munis:
        code = str(m.get("divipola_code") or "").strip()
        raw_name = str(m.get("name") or "").strip()
        dept = str(m.get("department_name") or "").strip()
        try:
            lat = float(m["latitude"])
            lng = float(m["longitude"])
        except (KeyError, TypeError, ValueError):
            continue
        if not code or not raw_name:
            continue
        name = title_es(raw_name)
        dept_name = title_es(dept)
        # Sitio = punto emblemático del municipio (Maps abre por nombre, no pin crudo).
        place_name = f'Plaza / parque principal de {name}'
        out.append(
            {
                "external_id": f"co-muni-{code}",
                "name": place_name,
                "lat": lat,
                "lng": lng,
                "address_line": f'{name}, {dept_name}',
                "department_name": dept_name,
                "city_name": name,
                "country_code": "CO",
                "category_slugs": ["plaza-principal", "pueblo-ciudad"],
                "is_physical_place": True,
                "estimated_price_amount": None,
                "currency_code": "COP",
                "confidence": "high",
            }
        )
    return out


def pick_city(
    cities_by_dept: dict[str, list[tuple[str, str]]],
    all_cities: list[tuple[str, str, str]],
    dept_id: str | None,
    city_name: str,
) -> tuple[str | None, str | None]:
    want = fold(city_name)
    if not want:
        return None, None
    pool: list[tuple[str, str]]
    if dept_id and dept_id in cities_by_dept:
        pool = cities_by_dept[dept_id]
    else:
        pool = [(cid, cname) for cid, cname, _ in all_cities]
    for cid, cname in pool:
        if fold(cname) == want:
            return cid, cname
    soft = [
        (cid, cname)
        for cid, cname in pool
        if want in fold(cname) or fold(cname) in want
    ]
    if len(soft) == 1:
        return soft[0]
    return None, None


def ensure_schema(cur) -> None:
    cur.execute("alter table public.sites add column if not exists external_id text")
    cur.execute(
        """
        do $$
        begin
          if not exists (
            select 1 from pg_constraint
            where conname = 'sites_external_id_key'
              and conrelid = 'public.sites'::regclass
          ) then
            alter table public.sites
              add constraint sites_external_id_key unique (external_id);
          end if;
        end
        $$;
        """
    )
    cur.execute(
        "alter table public.sites add column if not exists google_place_id text"
    )


def ensure_external_id_column(cur) -> None:
    ensure_schema(cur)


def upsert_batch(
    conn,
    *,
    rows: list[dict],
    dry_run: bool,
    owner_id,
    dept_by_norm: dict[str, tuple[str, str]],
    cities_by_dept: dict[str, list[tuple[str, str]]],
    all_cities: list[tuple[str, str, str]],
    cat_by_slug: dict[str, object],
    label: str,
) -> tuple[int, int, int, list[str], set[str]]:
    inserted = updated = skipped = 0
    unmatched: list[str] = []
    missing_cats: set[str] = set()

    for s in rows:
        ext = (s.get("external_id") or "").strip()
        name = (s.get("name") or "").strip()
        if not ext or not name:
            skipped += 1
            continue
        try:
            lat_f = float(s["lat"])
            lng_f = float(s["lng"])
        except (KeyError, TypeError, ValueError):
            skipped += 1
            unmatched.append(f"{ext}: sin coords")
            continue

        dept_name = (s.get("department_name") or "").strip()
        city_name = (s.get("city_name") or "").strip()
        dept_hit = dept_by_norm.get(fold(dept_name))
        dept_id = dept_hit[0] if dept_hit else None
        dept_label = dept_hit[1] if dept_hit else (dept_name or None)
        city_id, city_label = pick_city(
            cities_by_dept, all_cities, dept_id, city_name
        )
        if city_id is None:
            unmatched.append(f"{ext}: sin match '{city_name}' / '{dept_name}'")
        city_label = city_label or (city_name or None)

        slugs = s.get("category_slugs") if isinstance(s.get("category_slugs"), list) else []
        cat_ids = []
        for slug in slugs:
            cid = cat_by_slug.get(str(slug).strip())
            if cid is None:
                missing_cats.add(str(slug))
            else:
                cat_ids.append(cid)
        if not cat_ids and cat_by_slug.get("pueblo-ciudad"):
            cat_ids.append(cat_by_slug["pueblo-ciudad"])
        if not cat_ids and cat_by_slug.get("otro"):
            cat_ids.append(cat_by_slug["otro"])

        address = s.get("address_line")
        address = str(address).strip() if address else None
        price = s.get("estimated_price_amount")
        currency = (s.get("currency_code") or "COP").strip() or "COP"
        is_physical = bool(s.get("is_physical_place", True))
        place_id = s.get("google_place_id")
        place_id = str(place_id).strip() if place_id else None

        if dry_run:
            if inserted < 5 or "tunja" in fold(name):
                print(
                    f"  [dry {label}] {ext} | {name} | {dept_label}/{city_label} | "
                    f"geo={'ok' if city_id else 'MISS'}"
                )
            inserted += 1
            continue

        with conn.cursor() as cur:
            cur.execute(
                """
                insert into public.sites (
                  external_id, name, status, is_public, is_physical_place,
                  address_line, city, department, country_code,
                  city_id, department_id,
                  estimated_price_amount, currency_code,
                  google_place_id,
                  created_by, location
                ) values (
                  %s, %s, 'complete', true, %s,
                  %s, %s, %s, 'CO',
                  %s, %s,
                  %s, %s,
                  %s,
                  %s,
                  st_setsrid(st_makepoint(%s, %s), 4326)::geography
                )
                on conflict (external_id) do update set
                  name = excluded.name,
                  status = 'complete',
                  is_public = true,
                  is_physical_place = excluded.is_physical_place,
                  address_line = excluded.address_line,
                  city = excluded.city,
                  department = excluded.department,
                  city_id = excluded.city_id,
                  department_id = excluded.department_id,
                  estimated_price_amount = excluded.estimated_price_amount,
                  currency_code = excluded.currency_code,
                  google_place_id = coalesce(
                    excluded.google_place_id, public.sites.google_place_id
                  ),
                  location = excluded.location,
                  updated_at = now()
                returning id, (xmax = 0) as is_insert
                """,
                (
                    ext,
                    name,
                    is_physical,
                    address,
                    city_label,
                    dept_label,
                    city_id,
                    dept_id,
                    price,
                    currency,
                    place_id,
                    owner_id,
                    lng_f,
                    lat_f,
                ),
            )
            site_id, is_insert = cur.fetchone()
            if is_insert:
                inserted += 1
            else:
                updated += 1

            cur.execute(
                "delete from public.site_categories where site_id = %s",
                (site_id,),
            )
            for cid in cat_ids:
                cur.execute(
                    """
                    insert into public.site_categories
                      (site_id, category_id, added_by)
                    values (%s, %s, %s)
                    on conflict do nothing
                    """,
                    (site_id, cid, owner_id),
                )
        if (inserted + updated) % 200 == 0:
            conn.commit()
            print(f"  … {label}: {inserted + updated}", flush=True)
    if not dry_run:
        conn.commit()
    return inserted, updated, skipped, unmatched, missing_cats



def run_import(
    conn,
    path: Path,
    *,
    owner_email: str = "johnftm.proyectos@gmail.com",
    dry_run: bool = False,
    sites_only: bool = False,
    municipalities_only: bool = False,
    min_confidence: str = "medium",
) -> int:
    """Importa sitios usando una conexion ya abierta (p. ej. reset --full)."""
    path = path if path.is_file() else resolve_path(path)
    sites_raw, munis_raw = load_dataset(path)
    min_rank = CONF_RANK[min_confidence]
    sites = [
        s
        for s in sites_raw
        if CONF_RANK.get(str(s.get("confidence") or "medium").lower(), 0) >= min_rank
    ]
    muni_sites = [] if sites_only else municipalities_as_sites(munis_raw)
    if municipalities_only:
        sites = []

    print(f"Archivo: {path}")
    print(f"Atractivos (sites[]): {len(sites)}")
    print(f"Municipios → sitios: {len(muni_sites)} (ej. Tunja = co-muni-15001)")
    print("departments[] del JSON no se importan (ya viven en DIVIPOLA)")

    with conn.cursor() as cur:
        ensure_external_id_column(cur)
        conn.commit()

        cur.execute(
            "select id from auth.users where email = %s",
            (owner_email,),
        )
        row = cur.fetchone()
        owner_id = row[0] if row else None
        if owner_id is None:
            print(f"aviso: {owner_email} no en Auth")
        else:
            cur.execute(
                """
                insert into public.profiles (id, display_name, role)
                select id,
                       coalesce(raw_user_meta_data->>'full_name', email),
                       'user'
                from auth.users
                where id = %s
                on conflict (id) do nothing
                """,
                (owner_id,),
            )
            print(f"owner = {owner_email}")
        conn.commit()

        cur.execute(
            """
            select id, name, name_norm from public.departments
            where country_code = 'CO' and is_active
            """
        )
        depts = list(cur.fetchall())
        dept_by_norm: dict[str, tuple[str, str]] = {}
        for did, name, name_norm in depts:
            dept_by_norm[fold(name)] = (str(did), name)
            dept_by_norm[fold(name_norm)] = (str(did), name)

        cur.execute(
            """
            select c.id, c.name, c.department_id
            from public.cities c
            join public.departments d on d.id = c.department_id
            where c.is_active and d.country_code = 'CO'
            """
        )
        all_cities: list[tuple[str, str, str]] = []
        cities_by_dept: dict[str, list[tuple[str, str]]] = {}
        for cid, cname, did in cur.fetchall():
            cid_s, did_s = str(cid), str(did)
            all_cities.append((cid_s, cname, did_s))
            cities_by_dept.setdefault(did_s, []).append((cid_s, cname))

        cur.execute("select id, slug from public.categories where is_active")
        cat_by_slug = {slug: cid for cid, slug in cur.fetchall()}

    total_i = total_u = total_s = 0
    all_unmatched: list[str] = []
    all_missing: set[str] = set()

    for label, rows in (("atractivos", sites), ("municipios", muni_sites)):
        if not rows:
            continue
        print(f"> importando {label} ({len(rows)}) ...", flush=True)
        i, u, sk, unmatched, missing = upsert_batch(
            conn,
            rows=rows,
            dry_run=dry_run,
            owner_id=owner_id,
            dept_by_norm=dept_by_norm,
            cities_by_dept=cities_by_dept,
            all_cities=all_cities,
            cat_by_slug=cat_by_slug,
            label=label,
        )
        print(f"  {label}: insert={i} update={u} skip={sk}")
        total_i += i
        total_u += u
        total_s += sk
        all_unmatched.extend(unmatched)
        all_missing |= missing

    print(f"Listo total: insert={total_i} update={total_u} skip={total_s}")
    if all_missing:
        print(f"Slugs desconocidos: {sorted(all_missing)}")
    if all_unmatched:
        print(f"Geo sin match ({len(all_unmatched)}), muestra:")
        for line in all_unmatched[:20]:
            print(f"  - {line}")
    if dry_run:
        print("(dry-run: no se escribió nada)")
    else:
        with conn.cursor() as cur:
            cur.execute(
                """
                select name, city, department from public.sites
                where external_id = 'co-muni-15001'
                limit 3
                """
            )
            print("check Tunja:", cur.fetchall())
    return 0


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

    parser = argparse.ArgumentParser(description="Import sitios + municipios públicos")
    parser.add_argument("path", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    parser.add_argument("--sites-only", action="store_true")
    parser.add_argument("--municipalities-only", action="store_true")
    parser.add_argument(
        "--min-confidence",
        choices=("high", "medium", "low"),
        default="medium",
    )
    parser.add_argument(
        "--owner-email",
        default="johnftm.proyectos@gmail.com",
        help="created_by de sitios masivos",
    )
    args = parser.parse_args()

    _load_dotenv(ROOT / ".env")
    path = resolve_path(args.path)
    _ensure_psycopg()
    conn = _connect(_db_url())
    try:
        return run_import(
            conn,
            path,
            owner_email=args.owner_email,
            dry_run=args.dry_run,
            sites_only=args.sites_only,
            municipalities_only=args.municipalities_only,
            min_confidence=args.min_confidence,
        )
    finally:
        conn.close()


if __name__ == "__main__":
    raise SystemExit(main())
