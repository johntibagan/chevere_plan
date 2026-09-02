#!/usr/bin/env python3
"""Fotos de catálogo: multi-fuente EN PARALELO (one-shot).

Base: copia `_wikidata_photos_report.base.json`. Si faltan city/department/lat/lng,
los lee de TEST una vez y los deja en ese JSON (no se usan al aplicar fotos).

Para cada sitio, fuentes EN PARALELO; hasta 2 fotos (la de más probabilidad
primero). Conserva la del reporte Wikidata si ya había una.

  cd backend
  python supabase/scripts/09_import_catalog_photos_parallel.py
"""

from __future__ import annotations

import argparse
import concurrent.futures
import html
import json
import math
import os
import random
import re
import sys
import threading
import time
import unicodedata
import urllib.error
import urllib.parse
import urllib.request
from dataclasses import asdict, dataclass, field
from difflib import SequenceMatcher
from pathlib import Path
from typing import Any, Callable

ROOT = Path(__file__).resolve().parents[2]
REPORT_PATH = Path(__file__).resolve().parent / "_parallel_photos_report.json"
BASE_REPORT_PATH = Path(__file__).resolve().parent / "_wikidata_photos_report.base.json"
OWNER_EMAIL = "johnftm.proyectos@gmail.com"
PDN_REF = "kzueceextyuoixatwztw"
USER_AGENT = (
    "CheverePlan/1.0 (catalog-parallel-photos; johnftm.proyectos@gmail.com)"
)

WD_API = "https://www.wikidata.org/w/api.php"
COMMONS_API = "https://commons.wikimedia.org/w/api.php"
ES_WIKI_API = "https://es.wikipedia.org/w/api.php"
OVERPASS_API = "https://overpass-api.de/api/interpreter"
Q_COLOMBIA = "Q739"

ALMOST = 0.90
SIMILAR = 0.72
HIGH_KM = 1.0
MED_KM = 2.0
SEARCH_LIMIT = 5
THUMB_WIDTH = 1280

MUNI_PREFIX = "co-muni-"
OSM_RADIUS_M = 400
GEOSEARCH_RADIUS_M = 700
CATEGORY_MEMBERS_LIMIT = 20

TEST_SAMPLE_SIZE = 100
TEST_HIT_RATE_THRESHOLD = 0.90
DEFAULT_OUTER_WORKERS = 8   # sitios en paralelo
DEFAULT_INNER_WORKERS = 6   # fuentes en paralelo, por sitio

# Pausa mínima entre llamadas por servidor (thread-safe). Overpass pide más
# cortesía que las APIs de Wikimedia.
MIN_INTERVAL = {
    WD_API: 0.15,
    COMMONS_API: 0.15,
    ES_WIKI_API: 0.15,
    OVERPASS_API: 1.0,
}

# Nombres comunes de plaza/parque principal en Colombia. Se prueban
# combinados con la ciudad porque no sabemos el nombre real de cada una.
CANDIDATE_PLAZA_NAMES = [
    "Plaza de Bolívar",
    "Parque Bolívar",
    "Parque Santander",
    "Parque Principal",
    "Parque Central",
]

BAD_FILENAME_HINTS = (
    "bandera", "flag", "escudo", "shield", "coat_of_arms", "logo",
    "mapa", "map", "ubicacion", "location_map", "localizacion",
)
PLAZA_KEYWORDS = (
    "parque", "plaza", "bolivar", "bolívar", "santander", "iglesia",
    "catedral", "centro", "panoramica", "panorámica", "panorama",
    "casco_urbano", "vista", "municipio", "pueblo", "alcaldia", "alcaldía",
)

# Prioridad para elegir la mejor entre varias respuestas del mismo sitio.
# Menor número = se prefiere primero.
ORIGIN_PRIORITY = {
    "osm_overpass": 0,
    "wikidata": 1,
    "wikipedia_plaza": 2,
    "commons_category_plaza": 3,
    "wikipedia_municipio": 4,
    "commons_category_ciudad": 5,
    "commons_geosearch": 6,
}

SMALL = {"de", "del", "la", "las", "los", "y", "da", "do", "e"}
MUNI_NAME_PREFIX = "plaza / parque principal de "


def _load_dotenv(path: Path) -> None:
    if not path.is_file():
        return
    for raw in path.read_text(encoding="utf-8").splitlines():
        line = raw.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, _, val = line.partition("=")
        key, val = key.strip(), val.strip().strip('"').strip("'")
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


def city_from_site_name(name: str) -> str | None:
    folded = fold(name)
    if folded.startswith(MUNI_NAME_PREFIX):
        rest = (name or "").strip()
        idx = fold(rest).find(MUNI_NAME_PREFIX)
        if idx >= 0:
            raw = rest[idx + len(MUNI_NAME_PREFIX):].strip()
            return raw or None
    return None


def name_ratio(a: str, b: str) -> float:
    fa, fb = fold(a), fold(b)
    if not fa or not fb:
        return 0.0
    return SequenceMatcher(None, fa, fb).ratio()


TAG_RE = re.compile(r"<[^>]+>")


def dist_km(
    lat1: float | None, lng1: float | None,
    lat2: float | None, lng2: float | None,
) -> float | None:
    if None in (lat1, lng1, lat2, lng2):
        return None
    r = 6371.0
    p1, p2 = math.radians(lat1), math.radians(lat2)  # type: ignore[arg-type]
    dphi = math.radians(lat2 - lat1)  # type: ignore[operator]
    dlmb = math.radians(lng2 - lng1)  # type: ignore[operator]
    a = (
        math.sin(dphi / 2) ** 2
        + math.cos(p1) * math.cos(p2) * math.sin(dlmb / 2) ** 2
    )
    return 2 * r * math.asin(min(1.0, math.sqrt(a)))


def strip_tags(raw: str) -> str:
    text = TAG_RE.sub("", html.unescape(raw or ""))
    return re.sub(r"\s+", " ", text).strip()


def is_bad_filename(filename: str) -> bool:
    f = fold(filename)
    if f.endswith(".svg"):
        return True
    return any(h in f for h in BAD_FILENAME_HINTS)


def has_plaza_keyword(filename: str) -> bool:
    f = fold(filename)
    return any(k in f for k in PLAZA_KEYWORDS)


def _stopword_tokens(name: str) -> set[str]:
    stop = {
        "de", "la", "el", "los", "las", "del", "y", "a", "en", "san", "santa",
        "sitio", "parque", "plaza", "principal", "natural",
    }
    return {t for t in fold(name).split() if len(t) > 3 and t not in stop}


def has_token_overlap(filename: str, tokens: set[str]) -> bool:
    f = fold(filename)
    return any(t in f for t in tokens)


def _ensure_psycopg() -> None:
    try:
        import psycopg  # noqa: F401
    except ImportError:
        import subprocess
        subprocess.check_call([sys.executable, "-m", "pip", "install", "psycopg[binary]"])


sys.path.insert(0, str(ROOT))
from reset_all import _connect, _db_url  # noqa: E402


@dataclass
class SiteRow:
    id: str
    name: str
    external_id: str
    city: str | None
    department: str | None
    lat: float | None
    lng: float | None

    @property
    def is_muni(self) -> bool:
        return self.external_id.startswith(MUNI_PREFIX)


@dataclass
class Decision:
    site_id: str
    site_name: str
    external_id: str
    confidence: str  # alta | media | skip
    origin: str = "skip"
    reason: str = ""
    query_used: str | None = None
    ratio: float | None = None
    dist_km: float | None = None
    image_url: str | None = None
    attribution: str | None = None
    filename: str | None = None
    candidates_found: int = 0  # cuántas fuentes distintas encontraron algo
    photos: list[dict[str, Any]] = field(default_factory=list)
    city: str | None = None
    department: str | None = None
    lat: float | None = None
    lng: float | None = None


def _skip(site: SiteRow, reason: str, candidates_found: int = 0) -> Decision:
    return Decision(
        site_id=site.id, site_name=site.name, external_id=site.external_id,
        confidence="skip", origin="skip", reason=reason,
        candidates_found=candidates_found,
    )


class RateLimiter:
    """Pausa mínima entre llamadas, segura para hilos, por host."""

    def __init__(self) -> None:
        self._lock = threading.Lock()
        self._last: dict[str, float] = {}

    def wait(self, host: str) -> None:
        interval = MIN_INTERVAL.get(host, 0.2)
        while True:
            with self._lock:
                last = self._last.get(host, 0.0)
                now = time.monotonic()
                wait_s = interval - (now - last)
                if wait_s <= 0:
                    self._last[host] = now
                    return
            time.sleep(wait_s)


class WikiClient:
    """Cliente HTTP simple, seguro para usarse desde varios hilos a la vez."""

    def __init__(self, limiter: RateLimiter) -> None:
        self.limiter = limiter

    def get_json(self, url: str, params: dict[str, str]) -> dict[str, Any]:
        self.limiter.wait(url)
        q = urllib.parse.urlencode(params)
        req = urllib.request.Request(
            f"{url}?{q}",
            headers={"User-Agent": USER_AGENT, "Accept": "application/json"},
        )
        last_err: Exception | None = None
        for attempt in range(4):
            try:
                with urllib.request.urlopen(req, timeout=30) as res:
                    body = res.read().decode("utf-8", errors="replace")
                data = json.loads(body)
                return data if isinstance(data, dict) else {}
            except urllib.error.HTTPError as e:
                last_err = e
                if e.code in {429, 500, 502, 503, 504}:
                    time.sleep(1.5 * (attempt + 1))
                    continue
                return {}
            except Exception as e:
                last_err = e
                time.sleep(1.0 * (attempt + 1))
        if last_err:
            print(f"  aviso API ({url}): {last_err}", flush=True)
        return {}

    def search_wikidata(self, query: str) -> list[dict[str, Any]]:
        data = self.get_json(WD_API, {
            "action": "wbsearchentities", "search": query, "language": "es",
            "uselang": "es", "type": "item", "limit": str(SEARCH_LIMIT),
            "format": "json", "origin": "*",
        })
        hits = data.get("search")
        return hits if isinstance(hits, list) else []

    def entities(self, qids: list[str]) -> dict[str, Any]:
        ids = [q for q in qids if q.startswith("Q")]
        if not ids:
            return {}
        data = self.get_json(WD_API, {
            "action": "wbgetentities", "ids": "|".join(ids),
            "props": "labels|claims", "languages": "es|en", "format": "json",
        })
        ents = data.get("entities")
        return ents if isinstance(ents, dict) else {}

    def commons_file(self, filename: str) -> tuple[str | None, str | None]:
        title = filename.strip()
        if not title.lower().startswith("file:"):
            title = f"File:{title}"
        data = self.get_json(COMMONS_API, {
            "action": "query", "titles": title, "prop": "imageinfo",
            "iiprop": "url|mime|extmetadata", "iiurlwidth": str(THUMB_WIDTH),
            "format": "json",
        })
        pages = (data.get("query") or {}).get("pages") or {}
        if not isinstance(pages, dict):
            return None, None
        for page in pages.values():
            if not isinstance(page, dict):
                continue
            infos = page.get("imageinfo")
            if not isinstance(infos, list) or not infos:
                continue
            info = infos[0] if isinstance(infos[0], dict) else {}
            url = info.get("thumburl") or info.get("url")
            if not isinstance(url, str) or not url.strip():
                url = None
            meta = info.get("extmetadata") if isinstance(info.get("extmetadata"), dict) else {}
            artist = _meta_value(meta, "Artist")
            license_name = _meta_value(meta, "LicenseShortName") or _meta_value(meta, "UsageTerms")
            parts = ["Wikimedia Commons"]
            if artist:
                parts.append(artist)
            if license_name:
                parts.append(license_name)
            return url, ("Foto: " + ", ".join(parts)) if url else None
        return None, None

    def wikipedia_pageimage(
        self, title: str
    ) -> tuple[str | None, tuple[float, float] | None, str | None]:
        data = self.get_json(ES_WIKI_API, {
            "action": "query", "titles": title,
            "prop": "pageimages|coordinates", "piprop": "name",
            "redirects": "1", "format": "json",
        })
        pages = (data.get("query") or {}).get("pages") or {}
        if not isinstance(pages, dict):
            return None, None, None
        for pid, page in pages.items():
            if not isinstance(page, dict) or pid == "-1":
                continue
            filename = page.get("pageimage")
            coords = None
            raw_coords = page.get("coordinates")
            if isinstance(raw_coords, list) and raw_coords:
                c0 = raw_coords[0]
                if isinstance(c0, dict):
                    try:
                        coords = (float(c0.get("lat")), float(c0.get("lon")))
                    except (TypeError, ValueError):
                        coords = None
            canonical = page.get("title") if isinstance(page.get("title"), str) else None
            if isinstance(filename, str) and filename.strip():
                return filename.strip(), coords, canonical
            return None, coords, canonical
        return None, None, None

    def commons_category_files(self, category: str) -> list[str]:
        data = self.get_json(COMMONS_API, {
            "action": "query", "list": "categorymembers",
            "cmtitle": f"Category:{category}", "cmtype": "file",
            "cmlimit": str(CATEGORY_MEMBERS_LIMIT), "format": "json",
        })
        members = (data.get("query") or {}).get("categorymembers")
        if not isinstance(members, list):
            return []
        out = []
        for m in members:
            if isinstance(m, dict):
                t = m.get("title")
                if isinstance(t, str) and t.lower().startswith("file:"):
                    out.append(t[len("file:"):])
        return out

    def commons_geosearch(self, lat: float, lng: float, radius_m: int) -> list[str]:
        data = self.get_json(COMMONS_API, {
            "action": "query", "list": "geosearch",
            "gscoord": f"{lat}|{lng}", "gsradius": str(radius_m),
            "gsnamespace": "6", "gslimit": "15", "format": "json",
        })
        hits = (data.get("query") or {}).get("geosearch")
        if not isinstance(hits, list):
            return []
        out = []
        for h in hits:
            if isinstance(h, dict):
                t = h.get("title")
                if isinstance(t, str) and t.lower().startswith("file:"):
                    out.append(t[len("file:"):])
        return out

    def overpass_wikimedia_near(self, lat: float, lng: float, radius_m: int) -> list[str]:
        query = f"""
        [out:json][timeout:25];
        (
          node(around:{radius_m},{lat},{lng})["wikimedia_commons"];
          way(around:{radius_m},{lat},{lng})["wikimedia_commons"];
        );
        out tags;
        """
        self.limiter.wait(OVERPASS_API)
        req = urllib.request.Request(
            OVERPASS_API,
            data=urllib.parse.urlencode({"data": query}).encode("utf-8"),
            headers={"User-Agent": USER_AGENT},
        )
        try:
            with urllib.request.urlopen(req, timeout=30) as res:
                data = json.loads(res.read().decode("utf-8", errors="replace"))
        except Exception as e:
            print(f"  aviso Overpass: {e}", flush=True)
            return []
        out = []
        for el in data.get("elements", []):
            if isinstance(el, dict):
                val = (el.get("tags") or {}).get("wikimedia_commons")
                if isinstance(val, str) and val.strip():
                    out.append(val.strip())
        return out


def _meta_value(meta: dict[str, Any], key: str) -> str | None:
    raw = meta.get(key)
    if isinstance(raw, dict):
        val = raw.get("value")
        if isinstance(val, str) and val.strip():
            cleaned = strip_tags(val)
            return cleaned[:240] if cleaned else None
    return None


def _claim_values(entity: dict[str, Any], pid: str) -> list[Any]:
    claims = entity.get("claims")
    if not isinstance(claims, dict):
        return []
    rows = claims.get(pid)
    if not isinstance(rows, list):
        return []
    out: list[Any] = []
    for row in rows:
        if not isinstance(row, dict):
            continue
        snak = row.get("mainsnak")
        if not isinstance(snak, dict):
            continue
        dv = snak.get("datavalue")
        if not isinstance(dv, dict):
            continue
        out.append(dv.get("value"))
    return out


def _p18_filename(entity: dict[str, Any]) -> str | None:
    for v in _claim_values(entity, "P18"):
        if isinstance(v, str) and v.strip():
            return v.strip()
    return None


def _p625(entity: dict[str, Any]) -> tuple[float | None, float | None]:
    for v in _claim_values(entity, "P625"):
        if isinstance(v, dict):
            try:
                return float(v.get("latitude")), float(v.get("longitude"))
            except (TypeError, ValueError):
                continue
    return None, None


def _p17_ids(entity: dict[str, Any]) -> set[str]:
    out: set[str] = set()
    for v in _claim_values(entity, "P17"):
        if isinstance(v, dict):
            qid = v.get("id")
            if isinstance(qid, str):
                out.add(qid)
    return out


def _label(entity: dict[str, Any]) -> str:
    labels = entity.get("labels")
    if not isinstance(labels, dict):
        return ""
    for lang in ("es", "en"):
        row = labels.get(lang)
        if isinstance(row, dict):
            val = row.get("value")
            if isinstance(val, str) and val.strip():
                return val.strip()
    return ""


# --------------------------------------------------------------------------
# Evaluadores de una sola fuente. Cada uno recibe (site, client, query) y
# devuelve un Decision o None si no encontró nada usable.
# --------------------------------------------------------------------------

def eval_wikidata(site: SiteRow, client: WikiClient, query: str) -> Decision | None:
    hits = client.search_wikidata(query)
    if not hits:
        return None
    qids, search_label = [], {}
    for h in hits:
        if not isinstance(h, dict):
            continue
        qid = str(h.get("id") or "")
        if not qid.startswith("Q"):
            continue
        qids.append(qid)
        lab = ""
        raw_label = h.get("label")
        if isinstance(raw_label, str):
            lab = raw_label.strip()
        if not lab:
            match = h.get("match")
            if isinstance(match, dict) and match.get("text"):
                lab = str(match.get("text")).strip()
        search_label[qid] = lab or qid

    ents = client.entities(qids)
    scored = []
    for qid in qids:
        ent = ents.get(qid)
        if not isinstance(ent, dict) or ent.get("missing") is not None:
            continue
        if not _p18_filename(ent):
            continue
        countries = _p17_ids(ent)
        wd_lat, wd_lng = _p625(ent)
        d = dist_km(site.lat, site.lng, wd_lat, wd_lng)
        if countries and Q_COLOMBIA not in countries:
            if d is None or d > MED_KM:
                continue
        label = _label(ent) or search_label.get(qid, "")
        ratio = max(name_ratio(query, label), name_ratio(query, search_label.get(qid, "")))
        scored.append((ratio, qid, ent, d))

    if not scored:
        return None
    scored.sort(key=lambda t: (-t[0], t[3] if t[3] is not None else 999))
    almost = [t for t in scored if t[0] >= ALMOST]
    ambiguous = len(almost) >= 2

    for ratio, qid, ent, d in scored:
        if ratio < SIMILAR:
            continue
        if d is not None and d > MED_KM:
            continue
        strong = ratio >= ALMOST and not ambiguous and (d is None or d <= HIGH_KM)
        filename = _p18_filename(ent)
        if not filename or is_bad_filename(filename):
            continue
        image_url, attr = client.commons_file(filename)
        if not image_url:
            continue
        reason = f"ratio={ratio:.2f} query={query}"
        if d is not None:
            reason += f" dist_km={d:.2f}"
        return Decision(
            site_id=site.id, site_name=site.name, external_id=site.external_id,
            confidence="alta" if strong else "media", origin="wikidata",
            reason=reason, query_used=query, ratio=round(ratio, 4),
            dist_km=None if d is None else round(d, 3),
            image_url=image_url, attribution=attr, filename=filename,
        )
    return None


def eval_osm(site: SiteRow, client: WikiClient) -> Decision | None:
    if site.lat is None or site.lng is None:
        return None
    tags = client.overpass_wikimedia_near(site.lat, site.lng, OSM_RADIUS_M)
    for tag in tags:
        if tag.lower().startswith("file:"):
            filename = tag[len("File:"):]
            if is_bad_filename(filename):
                continue
            image_url, attr = client.commons_file(filename)
            if image_url:
                return Decision(
                    site_id=site.id, site_name=site.name, external_id=site.external_id,
                    confidence="alta", origin="osm_overpass", reason="osm_tag=File",
                    image_url=image_url, attribution=attr, filename=filename,
                )
        else:
            cat = tag[len("Category:"):] if tag.lower().startswith("category:") else tag
            files = [f for f in client.commons_category_files(cat) if not is_bad_filename(f)]
            if not files:
                continue
            files.sort(key=lambda f: 0 if has_plaza_keyword(f) else 1)
            filename = files[0]
            image_url, attr = client.commons_file(filename)
            if image_url:
                return Decision(
                    site_id=site.id, site_name=site.name, external_id=site.external_id,
                    confidence="alta", origin="osm_overpass",
                    reason=f"osm_categoria={cat}",
                    image_url=image_url, attribution=attr, filename=filename,
                )
    return None


def eval_commons_category(
    site: SiteRow, client: WikiClient, category: str, *,
    confidence: str, origin: str, require_tokens: set[str] | None = None,
) -> Decision | None:
    files = [f for f in client.commons_category_files(category) if not is_bad_filename(f)]
    if not files:
        return None
    if require_tokens:
        matched = [f for f in files if has_token_overlap(f, require_tokens)]
        files = matched or files  # si nada matchea, igual se usa lo que haya (nivel medio)
    files.sort(key=lambda f: 0 if has_plaza_keyword(f) else 1)
    filename = files[0]
    image_url, attr = client.commons_file(filename)
    if not image_url:
        return None
    return Decision(
        site_id=site.id, site_name=site.name, external_id=site.external_id,
        confidence=confidence, origin=origin, reason=f"commons_categoria={category}",
        query_used=category, image_url=image_url, attribution=attr, filename=filename,
    )


def eval_wikipedia_article(
    site: SiteRow, client: WikiClient, title: str, *,
    confidence: str, origin: str, max_km: float | None,
) -> Decision | None:
    filename, coords, canonical = client.wikipedia_pageimage(title)
    if not filename or is_bad_filename(filename):
        return None
    d = None
    if coords is not None:
        d = dist_km(site.lat, site.lng, coords[0], coords[1])
        if max_km is not None and d is not None and d > max_km:
            return None
    image_url, attr = client.commons_file(filename)
    if not image_url:
        return None
    reason = f"wikipedia_titulo={canonical or title}"
    if d is not None:
        reason += f" dist_km={d:.1f}"
    return Decision(
        site_id=site.id, site_name=site.name, external_id=site.external_id,
        confidence=confidence, origin=origin, reason=reason, query_used=title,
        dist_km=None if d is None else round(d, 3),
        image_url=image_url, attribution=attr, filename=filename,
    )


def eval_commons_geosearch(site: SiteRow, client: WikiClient) -> Decision | None:
    if site.lat is None or site.lng is None:
        return None
    tokens = set() if site.is_muni else _stopword_tokens(site.name)
    files = [f for f in client.commons_geosearch(site.lat, site.lng, GEOSEARCH_RADIUS_M)
             if not is_bad_filename(f)]
    strong = [f for f in files if has_plaza_keyword(f) or (tokens and has_token_overlap(f, tokens))]
    if not strong:
        return None
    filename = strong[0]
    image_url, attr = client.commons_file(filename)
    if not image_url:
        return None
    return Decision(
        site_id=site.id, site_name=site.name, external_id=site.external_id,
        confidence="media", origin="commons_geosearch",
        reason=f"geosearch_radius_m={GEOSEARCH_RADIUS_M}",
        image_url=image_url, attribution=attr, filename=filename,
    )


def build_tasks(site: SiteRow, include_geosearch: bool) -> list[Callable[[WikiClient], Decision | None]]:
    """Arma la lista de tareas a correr EN PARALELO para este sitio."""
    tasks: list[Callable[[WikiClient], Decision | None]] = []

    if site.is_muni and site.city:
        city = site.city
        dept = site.department or ""
        for candidate in CANDIDATE_PLAZA_NAMES:
            q_wd = f"{candidate} {city}"
            tasks.append(lambda c, q=q_wd: eval_wikidata(site, c, q))
            cat1 = f"{candidate}, {city}"
            tasks.append(lambda c, cat=cat1: eval_commons_category(
                site, c, cat, confidence="alta", origin="commons_category_plaza",
            ))
            cat2 = f"{candidate} de {city}"
            tasks.append(lambda c, cat=cat2: eval_commons_category(
                site, c, cat, confidence="alta", origin="commons_category_plaza",
            ))
            title1 = f"{candidate} ({city})"
            tasks.append(lambda c, t=title1: eval_wikipedia_article(
                site, c, t, confidence="alta", origin="wikipedia_plaza", max_km=MED_KM,
            ))
        tasks.append(lambda c: eval_osm(site, c))
        # Respaldo genérico del pueblo — SOLO si nada arriba encuentra algo.
        # Se lanza igual en paralelo (más rápido); la prioridad al elegir
        # ya se encarga de preferir siempre lo exacto sobre esto.
        for title in (city, f"{city} ({dept})", f"{city}, {dept}"):
            tasks.append(lambda c, t=title: eval_wikipedia_article(
                site, c, t, confidence="media", origin="wikipedia_municipio",
                max_km=60.0,
            ))
        tasks.append(lambda c: eval_commons_category(
            site, c, city, confidence="media", origin="commons_category_ciudad",
        ))
    else:
        name = site.name
        tasks.append(lambda c, q=name: eval_wikidata(site, c, q))
        tasks.append(lambda c: eval_commons_category(
            site, c, name, confidence="alta", origin="commons_category_plaza",
            require_tokens=_stopword_tokens(name),
        ))
        tasks.append(lambda c, t=name: eval_wikipedia_article(
            site, c, t, confidence="alta", origin="wikipedia_plaza", max_km=MED_KM,
        ))
        tasks.append(lambda c: eval_osm(site, c))

    if include_geosearch:
        tasks.append(lambda c: eval_commons_geosearch(site, c))

    return tasks


def photo_dict(d: Decision) -> dict[str, Any]:
    return {
        "confidence": d.confidence,
        "origin": d.origin,
        "reason": d.reason,
        "query_used": d.query_used,
        "ratio": d.ratio,
        "dist_km": d.dist_km,
        "image_url": d.image_url,
        "attribution": d.attribution,
        "filename": d.filename,
    }


def canon_photo_url(url: str | None, filename: str | None = None) -> str:
    """Misma imagen Commons (thumb vs original, con o sin query) = misma clave."""
    if filename and str(filename).strip():
        fn = str(filename).strip()
        if fn.lower().startswith("file:"):
            fn = fn[5:].lstrip()
        return "fn:" + fold(fn)
    raw = (url or "").strip()
    if not raw:
        return ""
    try:
        raw = urllib.parse.unquote(raw)
    except Exception:
        pass
    path = raw.split("#")[0].split("?")[0].rstrip("/")
    lower = path.lower()
    marker = "/commons/"
    if marker in lower:
        rest = path[lower.index(marker) + len(marker) :]
        parts = rest.split("/")
        if parts and parts[0].lower() == "thumb":
            parts = parts[1:]
        if len(parts) >= 3:
            name = parts[2]
            low = name.lower()
            if "px-" in low:
                name = name[low.index("px-") + 3 :]
            return "fn:" + fold(name)
        if parts:
            return "fn:" + fold(parts[-1])
    return fold(path)


def photo_key(d: Decision) -> str:
    return canon_photo_url(d.image_url, d.filename)


def unique_photo_dicts(photos: list[dict[str, Any]]) -> list[dict[str, Any]]:
    out: list[dict[str, Any]] = []
    seen: set[str] = set()
    for p in photos:
        url = p.get("image_url")
        if not url:
            continue
        key = canon_photo_url(str(url), p.get("filename"))
        if not key or key in seen:
            continue
        seen.add(key)
        out.append(p)
        if len(out) >= 2:
            break
    return out


def rank_key(d: Decision) -> tuple[int, int]:
    tier = 0 if d.confidence == "alta" else 1
    return (tier, ORIGIN_PRIORITY.get(d.origin, 99))


def pick_top(found: list[Decision], n: int = 2) -> list[Decision]:
    usable = [d for d in found if d.image_url and d.confidence in {"alta", "media"}]
    usable.sort(key=rank_key)
    out: list[Decision] = []
    seen: set[str] = set()
    for d in usable:
        key = photo_key(d)
        if not key or key in seen:
            continue
        seen.add(key)
        out.append(d)
        if len(out) >= n:
            break
    return out


def normalize_prior(row: dict[str, Any]) -> Decision | None:
    url = row.get("image_url")
    conf = row.get("confidence")
    mapped = {"high": "alta", "medium": "media", "alta": "alta", "media": "media"}.get(
        str(conf or "")
    )
    if not url or not mapped:
        return None
    return Decision(
        site_id=str(row.get("site_id") or ""),
        site_name=str(row.get("site_name") or ""),
        external_id=str(row.get("external_id") or ""),
        confidence=mapped,
        origin=str(row.get("origin") or "wikidata"),
        reason=str(row.get("reason") or "prior_wikidata"),
        query_used=row.get("query_used"),
        ratio=row.get("ratio"),
        dist_km=row.get("dist_km"),
        image_url=str(url),
        attribution=row.get("attribution"),
        filename=row.get("filename"),
    )


def evaluate_site(
    site: SiteRow,
    client: WikiClient,
    inner_workers: int,
    include_geosearch: bool,
    prior: Decision | None = None,
) -> Decision:
    tasks = build_tasks(site, include_geosearch)
    found: list[Decision] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=inner_workers) as ex:
        futures = [ex.submit(t, client) for t in tasks]
        for fut in concurrent.futures.as_completed(futures):
            try:
                res = fut.result()
            except Exception as e:
                print(f"  aviso tarea ({site.external_id}): {e}", flush=True)
                res = None
            if res is not None:
                found.append(res)

    if prior is not None:
        found.append(prior)

    ranked = pick_top(found, 2)
    if not ranked:
        skip = _skip(site, "sin_candidato_ninguna_fuente", candidates_found=len(found))
        skip.photos = []
        _stamp_geo(skip, site)
        return skip

    best = ranked[0]
    best.candidates_found = len(found)
    best.photos = [photo_dict(d) for d in ranked]
    _stamp_geo(best, site)
    return best


def _stamp_geo(d: Decision, site: SiteRow) -> None:
    d.city = site.city
    d.department = site.department
    d.lat = site.lat
    d.lng = site.lng


# --------------------------------------------------------------------------
# DB / CLI (mismo patrón que los scripts anteriores)
# --------------------------------------------------------------------------

def fetch_site_geo(conn) -> dict[str, dict[str, Any]]:
    with conn.cursor() as cur:
        cur.execute(
            """
            select
              s.id::text,
              s.city,
              s.department,
              st_y(s.location::geometry) as lat,
              st_x(s.location::geometry) as lng
            from public.sites s
            where s.external_id is not null
              and length(trim(s.external_id)) > 0
            """
        )
        out: dict[str, dict[str, Any]] = {}
        for r in cur.fetchall():
            out[r[0]] = {
                "city": r[1],
                "department": r[2],
                "lat": float(r[3]) if r[3] is not None else None,
                "lng": float(r[4]) if r[4] is not None else None,
            }
        return out


def ensure_geo_in_report(path: Path) -> None:
    """Completa city/department/lat/lng desde TEST y los deja en el JSON."""
    data = json.loads(path.read_text(encoding="utf-8"))
    raw = data.get("decisions") if isinstance(data, dict) else None
    if not isinstance(raw, list):
        raise SystemExit(f"Reporte inválido: {path}")
    missing = [
        row for row in raw
        if isinstance(row, dict) and (row.get("lat") is None or row.get("city") is None)
    ]
    if not missing:
        print(f"Geo ya está en {path.name} ({len(raw)} filas).", flush=True)
        return
    env_name = (os.environ.get("CHEVERE_DB_ENV") or "").strip().lower()
    if env_name and env_name != "test":
        raise SystemExit("CHEVERE_DB_ENV debe ser test (no PDN).")
    _ensure_psycopg()
    db_url = _db_url()
    if PDN_REF in db_url:
        raise SystemExit("Este script solo corre contra TEST, no PDN.")
    print(f"Completando geo desde TEST ({len(missing)} filas sin lat/ciudad)…", flush=True)
    conn = _connect(db_url)
    try:
        geo = fetch_site_geo(conn)
    finally:
        conn.close()
    n = 0
    for row in raw:
        if not isinstance(row, dict):
            continue
        g = geo.get(str(row.get("site_id") or ""))
        if not g:
            continue
        for k, v in g.items():
            if row.get(k) is None and v is not None:
                row[k] = v
                n += 1
    path.write_text(json.dumps(data, ensure_ascii=False, indent=2), encoding="utf-8")
    print(f"Guardé geo en {path} ({n} campos).", flush=True)


def load_sites_from_report(
    path: Path, limit: int | None,
) -> tuple[list[SiteRow], dict[str, Decision]]:
    if not path.is_file():
        raise SystemExit(f"Falta el reporte base: {path}")
    data = json.loads(path.read_text(encoding="utf-8"))
    raw = data.get("decisions") if isinstance(data, dict) else None
    if not isinstance(raw, list):
        raise SystemExit(f"Reporte inválido: {path}")
    sites: list[SiteRow] = []
    prior_by_id: dict[str, Decision] = {}
    for row in raw:
        if not isinstance(row, dict):
            continue
        ext = str(row.get("external_id") or "").strip()
        sid = str(row.get("site_id") or "").strip()
        name = str(row.get("site_name") or "").strip()
        if not ext or not sid:
            continue
        lat, lng = row.get("lat"), row.get("lng")
        sites.append(SiteRow(
            id=sid,
            name=name,
            external_id=ext,
            city=row.get("city") or city_from_site_name(name),
            department=row.get("department"),
            lat=float(lat) if lat is not None else None,
            lng=float(lng) if lng is not None else None,
        ))
        prior = normalize_prior(row)
        if prior is not None:
            prior_by_id[sid] = prior
        if limit is not None and len(sites) >= limit:
            break
    return sites, prior_by_id


def load_sites(cur, limit: int | None) -> list[SiteRow]:
    sql = """
        select
          s.id::text, s.name, s.external_id, s.city, s.department,
          st_y(s.location::geometry) as lat, st_x(s.location::geometry) as lng
        from public.sites s
        where s.external_id is not null
          and length(trim(s.external_id)) > 0
          and not exists (select 1 from public.site_photos p where p.site_id = s.id)
        order by s.external_id
    """
    if limit is not None:
        sql += " limit %s"
        cur.execute(sql, (limit,))
    else:
        cur.execute(sql)
    rows = []
    for r in cur.fetchall():
        rows.append(SiteRow(
            id=r[0], name=r[1], external_id=r[2], city=r[3], department=r[4],
            lat=float(r[5]) if r[5] is not None else None,
            lng=float(r[6]) if r[6] is not None else None,
        ))
    return rows


def apply_decision(cur, d: Decision, owner_id) -> None:
    photos = unique_photo_dicts(
        d.photos or (
            [photo_dict(d)] if d.confidence in {"alta", "media"} and d.image_url else []
        )
    )
    if not photos:
        return
    cur.execute("select 1 from public.site_photos where site_id = %s::uuid limit 1", (d.site_id,))
    if cur.fetchone():
        return
    cover_id = None
    for i, p in enumerate(photos):
        url = p.get("image_url")
        if not url:
            continue
        cur.execute(
            """
            insert into public.site_photos (
              site_id, storage_path, external_url, source, attribution,
              uploaded_by, sort_order
            ) values (%s, null, %s, 'external_link', %s, %s, %s)
            returning id
            """,
            (d.site_id, url, p.get("attribution"), owner_id, i),
        )
        photo_id = cur.fetchone()[0]
        if cover_id is None:
            cover_id = photo_id
    if cover_id is not None:
        cur.execute(
            "update public.sites set cover_photo_id = %s, updated_at = now() where id = %s",
            (cover_id, d.site_id),
        )


def origin_counts(rows: list[Decision]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for d in rows:
        counts[d.origin] = counts.get(d.origin, 0) + 1
    return dict(sorted(counts.items(), key=lambda kv: -kv[1]))


def skip_buckets(rows: list[Decision]) -> dict[str, int]:
    counts: dict[str, int] = {}
    for d in rows:
        key = (d.reason or "skip").split()[0]
        counts[key] = counts.get(key, 0) + 1
    return dict(sorted(counts.items(), key=lambda kv: (-kv[1], kv[0])))


def print_examples(title: str, rows: list[Decision], n: int = 12) -> None:
    print(f"\n{title} (muestra {min(n, len(rows))} de {len(rows)}):")
    for d in rows[:n]:
        print(f"  - {d.site_name} [{d.external_id}] -> {d.origin} ({d.reason}) "
              f"[{d.candidates_found} fuente(s); {len(d.photos)} foto(s)]")


def print_summary(high: list[Decision], medium: list[Decision], skip: list[Decision],
                   report_path: Path, label: str) -> None:
    total_ok = len(high) + len(medium)
    total = total_ok + len(skip)
    rate = (total_ok / total * 100) if total else 0.0
    print(f"\n=== Resumen {label} ===")
    print(f"ALTA (portada automática): {len(high)}")
    print(f"MEDIA (galería, espera ⋮): {len(medium)}")
    print(f"Sin candidato:             {len(skip)}")
    print(f"Tasa de acierto:           {rate:.1f}% ({total_ok}/{total})")
    print("  por fuente:", ", ".join(f"{k}={v}" for k, v in origin_counts(high + medium).items()) or "—")
    two = sum(1 for d in (high + medium) if len(d.photos) >= 2)
    print(f"  con 2 fotos:             {two}")
    buckets = skip_buckets(skip)
    if buckets:
        print("  motivos skip:", ", ".join(f"{k}={v}" for k, v in buckets.items()))
    print(f"Reporte: {report_path}")
    print_examples("ALTA", high)
    print_examples("MEDIA", medium)
    print_examples("SKIP", skip)


def decision_from_dict(row: dict[str, Any]) -> Decision:
    fields = Decision.__dataclass_fields__
    return Decision(**{k: row.get(k) for k in fields})


def load_report(path: Path) -> list[Decision]:
    data = json.loads(path.read_text(encoding="utf-8"))
    raw = data.get("decisions") if isinstance(data, dict) else None
    if not isinstance(raw, list):
        raise SystemExit(f"Reporte inválido: {path}")
    return [decision_from_dict(r) for r in raw if isinstance(r, dict)]


def write_report(path: Path, *, dry: bool, stopped_early: bool,
                  decisions: list[Decision]) -> None:
    for d in decisions:
        d.photos = unique_photo_dicts(d.photos or [])
        if d.photos:
            first = d.photos[0]
            d.image_url = first.get("image_url")
            d.filename = first.get("filename")
            d.attribution = first.get("attribution")
    high = [d for d in decisions if d.confidence == "alta"]
    medium = [d for d in decisions if d.confidence == "media"]
    skip = [d for d in decisions if d.confidence == "skip"]
    report = {
        "dry_run": dry,
        "stopped_early_below_threshold": stopped_early,
        "total": len(decisions),
        "alta": len(high),
        "media": len(medium),
        "skip": len(skip),
        "skip_reasons": skip_buckets(skip),
        "by_origin": origin_counts(high + medium),
        "decisions": [asdict(d) for d in decisions],
    }
    path.write_text(json.dumps(report, ensure_ascii=False, indent=2), encoding="utf-8")


def evaluate_batch(
    sites: list[SiteRow], client: WikiClient, outer_workers: int,
    inner_workers: int, include_geosearch: bool, progress_label: str,
    prior_by_id: dict[str, Decision] | None = None,
) -> list[Decision]:
    prior_by_id = prior_by_id or {}
    decisions: list[Decision] = []
    with concurrent.futures.ThreadPoolExecutor(max_workers=outer_workers) as ex:
        futures = {
            ex.submit(
                evaluate_site, s, client, inner_workers, include_geosearch,
                prior_by_id.get(s.id),
            ): s
            for s in sites
        }
        done = 0
        for fut in concurrent.futures.as_completed(futures):
            s = futures[fut]
            try:
                d = fut.result()
            except Exception as e:
                print(f"  aviso sitio {s.external_id}: {e}", flush=True)
                d = _skip(s, f"error:{e}")
                _stamp_geo(d, s)
            decisions.append(d)
            done += 1
            if done % 20 == 0 or done == len(sites):
                print(f"  … {progress_label} {done}/{len(sites)}", flush=True)
    return decisions


def main() -> int:
    try:
        sys.stdout.reconfigure(encoding="utf-8", errors="replace")
        sys.stderr.reconfigure(encoding="utf-8", errors="replace")
    except Exception:
        pass

    parser = argparse.ArgumentParser(description="Fotos catálogo multi-fuente en paralelo")
    parser.add_argument("--apply", action="store_true", help="Escribe en la DB. Sin esto, solo reporta.")
    parser.add_argument("--refresh", action="store_true", help="Con --apply, ignora el reporte y reconsulta.")
    parser.add_argument("--limit", type=int, default=None)
    parser.add_argument("--include-geosearch", action="store_true")
    parser.add_argument("--skip-sample-check", action="store_true",
                         help="Salta la prueba de 100 municipios y corre todo de una.")
    parser.add_argument("--outer-workers", type=int, default=DEFAULT_OUTER_WORKERS)
    parser.add_argument("--inner-workers", type=int, default=DEFAULT_INNER_WORKERS)
    parser.add_argument("--owner-email", default=OWNER_EMAIL)
    parser.add_argument(
        "--input",
        default=str(BASE_REPORT_PATH),
        help="Copia del reporte Wikidata (default: _wikidata_photos_report.base.json)",
    )
    args = parser.parse_args()

    _load_dotenv(ROOT / ".env")
    env_name = (os.environ.get("CHEVERE_DB_ENV") or "").strip().lower()
    if env_name and env_name != "test":
        print("CHEVERE_DB_ENV debe ser test (no PDN).", file=sys.stderr)
        return 2

    if args.apply:
        _ensure_psycopg()
        db_url = _db_url()
        if PDN_REF in db_url:
            print("Este script solo corre contra TEST, no PDN.", file=sys.stderr)
            return 2
        conn = _connect(db_url)
        try:
            with conn.cursor() as cur:
                cur.execute("select id from auth.users where email = %s", (args.owner_email,))
                row = cur.fetchone()
                owner_id = row[0] if row else None
            if owner_id is None:
                print(f"Falta usuario {args.owner_email} en Auth", file=sys.stderr)
                return 1
            if not args.refresh and REPORT_PATH.is_file():
                print(f"Aplicando desde reporte (sin reconsultar): {REPORT_PATH}")
                decisions = load_report(REPORT_PATH)
            else:
                print("--refresh con --apply no reconsulta aquí; corre dry-run antes.", file=sys.stderr)
                return 2
            with conn.cursor() as cur:
                for d in decisions:
                    apply_decision(cur, d, owner_id)
                conn.commit()
                cur.execute(
                    """
                    select
                      count(*) filter (where s.cover_photo_id is not null)
                        as con_portada,
                      count(*) as catalogo
                    from public.sites s
                    where s.external_id is not null
                      and length(trim(s.external_id)) > 0
                    """
                )
                row = cur.fetchone()
                cur.execute(
                    """
                    select count(*)
                    from public.site_photos p
                    join public.sites s on s.id = p.site_id
                    where s.external_id is not null
                      and length(trim(s.external_id)) > 0
                    """
                )
                n_photos = cur.fetchone()[0]
            print(
                f"\nAplicado en TEST. Catálogo con portada: {row[0]} / {row[1]}. "
                f"Fotos: {n_photos}."
            )
            return 0
        finally:
            conn.close()

    input_path = Path(args.input)
    ensure_geo_in_report(input_path)
    sites, prior_by_id = load_sites_from_report(input_path, args.limit)
    print(f"Sitios desde reporte: {len(sites)}"
          f"{'' if args.limit is None else f' (limit {args.limit})'}")
    print(f"Fotos ya en el base: {len(prior_by_id)}")
    print("Modo: DRY-RUN (no escribe)")

    already: list[Decision] = []
    if REPORT_PATH.is_file():
        already = load_report(REPORT_PATH)
        done_ids = {d.site_id for d in already}
        if done_ids:
            n_left = sum(1 for s in sites if s.id not in done_ids)
            print(f"Retomo {len(already)} ya evaluados; faltan {n_left}.")
            sites = [s for s in sites if s.id not in done_ids]

    client = WikiClient(RateLimiter())
    munis = [s for s in sites if s.is_muni]
    curated = [s for s in sites if not s.is_muni]
    stopped_early = False

    def run_batch(batch: list[SiteRow], label: str) -> list[Decision]:
        return evaluate_batch(
            batch, client, args.outer_workers, args.inner_workers,
            args.include_geosearch, label, prior_by_id,
        )

    skip_gate = args.skip_sample_check or bool(already)
    if not skip_gate and munis:
        sample_size = min(TEST_SAMPLE_SIZE, len(munis))
        sample = random.sample(munis, sample_size)
        print(f"\n>>> Prueba inicial: {sample_size} municipios (de {len(munis)}) <<<")
        sample_decisions = run_batch(sample, "prueba")
        ok = sum(1 for d in sample_decisions if d.confidence in {"alta", "media"})
        rate = ok / sample_size
        print(f"\nTasa de acierto en la muestra: {rate * 100:.1f}% ({ok}/{sample_size})")
        if rate < TEST_HIT_RATE_THRESHOLD:
            stopped_early = True
            write_report(REPORT_PATH, dry=True, stopped_early=True, decisions=sample_decisions)
            high = [d for d in sample_decisions if d.confidence == "alta"]
            medium = [d for d in sample_decisions if d.confidence == "media"]
            skip = [d for d in sample_decisions if d.confidence == "skip"]
            print_summary(high, medium, skip, REPORT_PATH, "PRUEBA (detenido, < 90%)")
            print(f"\nMe detuve: {rate*100:.1f}% está por debajo del 90%.")
            print("No evalué el resto del catálogo. Revisa el desglose de arriba")
            print("(por fuente y motivos de skip) antes de ajustar y reintentar.")
            return 0
        print("Tasa >= 90%, sigo con el resto del catálogo.\n")
        remaining_munis = [s for s in munis if s not in sample]
        muni_decisions = sample_decisions + run_batch(remaining_munis, "municipios")
    else:
        muni_decisions = run_batch(munis, "municipios")

    curated_decisions = run_batch(curated, "atractivos")
    decisions = already + muni_decisions + curated_decisions
    write_report(REPORT_PATH, dry=True, stopped_early=False, decisions=decisions)
    high = [d for d in decisions if d.confidence == "alta"]
    medium = [d for d in decisions if d.confidence == "media"]
    skip = [d for d in decisions if d.confidence == "skip"]
    print_summary(high, medium, skip, REPORT_PATH, "TOTAL")
    print("\nNada escrito. Para aplicar (usa el reporte, no reconsulta):")
    print("  python supabase/scripts/09_import_catalog_photos_parallel.py --apply")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())