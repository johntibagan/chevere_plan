#!/usr/bin/env python3
"""Mezcla frontend/env/test.env + pdn.env → env/.pdn.build.env para flutter build PDN."""

from __future__ import annotations

import sys
from pathlib import Path


def load_env(path: Path) -> dict[str, str]:
    out: dict[str, str] = {}
    if not path.is_file():
        return out
    for line in path.read_text(encoding="utf-8").splitlines():
        line = line.strip()
        if not line or line.startswith("#") or "=" not in line:
            continue
        key, val = line.split("=", 1)
        out[key.strip()] = val.strip().strip('"').strip("'")
    return out


def write_env(path: Path, data: dict[str, str]) -> None:
    lines: list[str] = []
    for key, val in data.items():
        if " " in val or "#" in val:
            lines.append(f'{key}="{val}"')
        else:
            lines.append(f"{key}={val}")
    path.write_text("\n".join(lines) + "\n", encoding="utf-8")


def main() -> int:
    frontend = Path(__file__).resolve().parents[2] / "frontend"
    env_dir = frontend / "env"
    test_path = env_dir / "test.env"
    pdn_path = env_dir / "pdn.env"
    out_path = env_dir / ".pdn.build.env"

    if not test_path.is_file():
        print("Falta env/test.env", file=sys.stderr)
        return 1
    if not pdn_path.is_file():
        print("Falta env/pdn.env", file=sys.stderr)
        return 1

    merged = load_env(test_path)
    pdn = load_env(pdn_path)

    if url := (pdn.get("SUPABASE_URL_PDN") or "").strip():
        merged["SUPABASE_URL"] = url
    if key := (pdn.get("SUPABASE_ANON_KEY_PDN") or "").strip():
        merged["SUPABASE_ANON_KEY"] = key

    for k, v in pdn.items():
        if k.endswith("_PDN"):
            continue
        merged[k] = v

    if not merged.get("SUPABASE_URL") or not merged.get("SUPABASE_ANON_KEY"):
        print("pdn.env debe tener SUPABASE_URL_PDN y SUPABASE_ANON_KEY_PDN", file=sys.stderr)
        return 1

    merged["APP_ENV"] = "beta"
    write_env(out_path, merged)
    print(out_path)
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
