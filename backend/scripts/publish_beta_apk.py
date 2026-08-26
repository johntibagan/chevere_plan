#!/usr/bin/env python3
"""Publica APK de prueba cerrada a Supabase Storage (bucket beta-apks).

Uso (desde la raíz del repo, tras `flutter build apk --release`):
  python backend/scripts/publish_beta_apk.py --version 0.0.1 --build 1 \\
    --apk frontend/build/app/outputs/flutter-apk/app-release.apk

Requiere backend/.env con SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY.
Imprime la URL pública de descarga (latest + versionada).
"""

from __future__ import annotations

import argparse
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path


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


def upload(url: str, key: str, object_path: str, data: bytes, content_type: str) -> None:
    endpoint = f"{url.rstrip('/')}/storage/v1/object/{object_path}"
    req = urllib.request.Request(
        endpoint,
        data=data,
        method="POST",
        headers={
            "Authorization": f"Bearer {key}",
            "apikey": key,
            "Content-Type": content_type,
            "x-upsert": "true",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=600) as resp:
            body = resp.read().decode("utf-8", errors="replace")
            if resp.status not in (200, 201):
                raise SystemExit(f"Upload failed {resp.status}: {body}")
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"Upload HTTP {e.code}: {detail}") from e


def main() -> int:
    parser = argparse.ArgumentParser()
    parser.add_argument("--version", required=True, help="Ej. 0.0.1")
    parser.add_argument("--build", required=True, type=int, help="versionCode, ej. 1")
    parser.add_argument("--apk", required=True, type=Path)
    parser.add_argument(
        "--env",
        type=Path,
        default=Path(__file__).resolve().parents[1] / ".env",
    )
    args = parser.parse_args()

    if not args.apk.is_file():
        print(f"APK no encontrado: {args.apk}", file=sys.stderr)
        return 1

    env = load_env(args.env)
    base = env.get("SUPABASE_URL") or os.environ.get("SUPABASE_URL")
    key = env.get("SUPABASE_SERVICE_ROLE_KEY") or os.environ.get(
        "SUPABASE_SERVICE_ROLE_KEY"
    )
    if not base or not key:
        print("Falta SUPABASE_URL o SUPABASE_SERVICE_ROLE_KEY", file=sys.stderr)
        return 1

    data = args.apk.read_bytes()
    versioned = f"beta-apks/releases/chevere-plan-{args.version}+{args.build}.apk"
    latest = "beta-apks/latest/chevere-plan.apk"

    print(f"Subiendo {len(data)} bytes…")
    upload(base, key, versioned, data, "application/vnd.android.package-archive")
    upload(base, key, latest, data, "application/vnd.android.package-archive")

    public_base = f"{base.rstrip('/')}/storage/v1/object/public"
    public_latest = f"{public_base}/beta-apks/latest/chevere-plan.apk"
    public_versioned = (
        f"{public_base}/beta-apks/releases/"
        f"chevere-plan-{args.version}+{args.build}.apk"
    )

    # Portal de pruebas (GitHub Pages) lee esta fila.
    patch_release(
        base,
        key,
        version=args.version,
        build=args.build,
        apk_url=public_latest,
    )

    result = {
        "version": args.version,
        "build": args.build,
        "bytes": len(data),
        "download_latest": public_latest,
        "download_versioned": public_versioned,
        "portal": "https://johntibagan.github.io/chevere_plan/",
    }
    print(json.dumps(result, indent=2))
    return 0


def patch_release(
    url: str,
    key: str,
    *,
    version: str,
    build: int,
    apk_url: str,
) -> None:
    endpoint = f"{url.rstrip('/')}/rest/v1/beta_release?id=eq.1"
    payload = json.dumps(
        {
            "version": version,
            "build": build,
            "apk_url": apk_url,
            "updated_at": datetime.now(timezone.utc)
            .isoformat()
            .replace("+00:00", "Z"),
        }
    ).encode("utf-8")
    req = urllib.request.Request(
        endpoint,
        data=payload,
        method="PATCH",
        headers={
            "Authorization": f"Bearer {key}",
            "apikey": key,
            "Content-Type": "application/json",
            "Prefer": "return=minimal",
        },
    )
    try:
        with urllib.request.urlopen(req, timeout=60) as resp:
            if resp.status not in (200, 204):
                body = resp.read().decode("utf-8", errors="replace")
                raise SystemExit(f"beta_release PATCH {resp.status}: {body}")
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"beta_release HTTP {e.code}: {detail}") from e


if __name__ == "__main__":
    raise SystemExit(main())
