#!/usr/bin/env python3
"""Publica APK de prueba cerrada a Supabase Storage (bucket beta-apks).

Preferido (APK más liviano: release + R8 + arm64):
  frontend\\tool\\publish_beta.ps1

Manual:
  flutter build apk --release --dart-define-from-file=.env --target-platform android-arm64
  python backend/scripts/publish_beta_apk.py --version 1.0.0 --build 3 \\
    --apk frontend/build/app/outputs/flutter-apk/app-release.apk

Plan Free ≤ 50 MB: arm64 obligatorio. Universal suele pasar el tope.

Requiere backend/.env con SUPABASE_URL y SUPABASE_SERVICE_ROLE_KEY.
Imprime la URL pública de descarga (latest + versionada).
"""

from __future__ import annotations

import argparse
import base64
import json
import os
import sys
import urllib.error
import urllib.request
from datetime import datetime, timezone
from pathlib import Path

# TUS chunk size exigido por Storage de Supabase.
_TUS_CHUNK = 6 * 1024 * 1024


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


def storage_api_base(supabase_url: str) -> str:
    """Base para Storage. Prefiere *.storage.supabase.co; si no resuelve DNS, el API normal."""
    base = supabase_url.rstrip("/")
    preferred = base
    if "://" in base and ".supabase.co" in base and ".storage.supabase.co" not in base:
        scheme, rest = base.split("://", 1)
        host = rest.split("/", 1)[0]
        if host.endswith(".supabase.co") and not host.endswith(".storage.supabase.co"):
            project = host[: -len(".supabase.co")]
            preferred = f"{scheme}://{project}.storage.supabase.co"
    try:
        import socket

        host = preferred.split("://", 1)[1].split("/", 1)[0]
        socket.getaddrinfo(host, 443)
        return preferred
    except OSError:
        return base


def _b64(s: str) -> str:
    return base64.b64encode(s.encode("utf-8")).decode("ascii")


def upload(
    url: str,
    key: str,
    bucket: str,
    object_name: str,
    data: bytes,
    content_type: str,
) -> None:
    """Subida TUS (resumable). La POST simple falla >~50 MB (413 EntityTooLarge)."""
    endpoint = f"{storage_api_base(url)}/storage/v1/upload/resumable"
    meta = ",".join(
        [
            f"bucketName {_b64(bucket)}",
            f"objectName {_b64(object_name)}",
            f"contentType {_b64(content_type)}",
            f"cacheControl {_b64('3600')}",
        ]
    )
    create = urllib.request.Request(
        endpoint,
        data=b"",
        method="POST",
        headers={
            "Authorization": f"Bearer {key}",
            "apikey": key,
            "Tus-Resumable": "1.0.0",
            "Upload-Length": str(len(data)),
            "Upload-Metadata": meta,
            "x-upsert": "true",
            "Content-Type": "application/offset+octet-stream",
        },
    )
    try:
        with urllib.request.urlopen(create, timeout=120) as resp:
            location = resp.headers.get("Location") or resp.headers.get("location")
            if not location:
                raise SystemExit("TUS create: sin Location")
    except urllib.error.HTTPError as e:
        detail = e.read().decode("utf-8", errors="replace")
        raise SystemExit(f"TUS create HTTP {e.code}: {detail}") from e

    offset = 0
    total = len(data)
    while offset < total:
        chunk = data[offset : offset + _TUS_CHUNK]
        patch = urllib.request.Request(
            location,
            data=chunk,
            method="PATCH",
            headers={
                "Authorization": f"Bearer {key}",
                "apikey": key,
                "Tus-Resumable": "1.0.0",
                "Upload-Offset": str(offset),
                "Content-Type": "application/offset+octet-stream",
                "Content-Length": str(len(chunk)),
            },
        )
        try:
            with urllib.request.urlopen(patch, timeout=600) as resp:
                new_off = resp.headers.get("Upload-Offset")
                offset = int(new_off) if new_off else offset + len(chunk)
                pct = (offset / total) * 100
                print(f"  {object_name}: {offset}/{total} ({pct:.0f}%)")
        except urllib.error.HTTPError as e:
            detail = e.read().decode("utf-8", errors="replace")
            raise SystemExit(f"TUS patch HTTP {e.code}: {detail}") from e


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
    versioned_name = f"releases/chevere-plan-{args.version}+{args.build}.apk"
    latest_name = "latest/chevere-plan.apk"
    content_type = "application/vnd.android.package-archive"

    print(f"Subiendo {len(data)} bytes (TUS)…")
    upload(base, key, "beta-apks", versioned_name, data, content_type)
    upload(base, key, "beta-apks", latest_name, data, content_type)

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
