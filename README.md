# Chevere Plan

App Flutter (Android) + Supabase: guardar lugares y armar planes de ocio en Colombia.

```
frontend/   App Flutter — package com.chevere.plan
backend/    Supabase: migraciones + reset
docs/       Qué hace la app hoy + lo que no se toca
```

## Arranque diario

```powershell
cd frontend
.\tool\run_dev.ps1
```

Requisitos: `frontend/.env` (ver `.env.example`) y un dispositivo/emulador Android.

## Reset de la base

```powershell
powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1
```

Detalles: [backend/README.md](backend/README.md).

## Docs

- [docs/aplicacion-actual.md](docs/aplicacion-actual.md) — comportamiento **actual**
- [docs/invariantes.md](docs/invariantes.md) — lo que **no** se rompe
- [docs/README.md](docs/README.md) — índice (setup, archivo)
