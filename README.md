# Chevere Plan

App Flutter (Android) + Supabase para guardar lugares y armar planes de ocio en Colombia.

```
frontend/   App Flutter — package com.chevere.plan
backend/    Supabase: migraciones + reset
docs/       Producto, setup, ADRs, E2E
```

## Arranque diario

```powershell
cd frontend
.\tool\run_dev.ps1
```

Requisitos: `frontend/.env` (ver `.env.example`) y un dispositivo/emulador Android.

## Reset de la base (desde cero)

```powershell
powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1
```

Detalles: [backend/README.md](backend/README.md).

## Documentación

| Doc | Qué es |
|-----|--------|
| [docs/README.md](docs/README.md) | Índice |
| [docs/producto.md](docs/producto.md) | Especificación de producto |
| [docs/lineamientos-desarrollo-frontend.md](docs/lineamientos-desarrollo-frontend.md) | Cómo construir el frontend |
| [docs/setup/01-flutter-android.md](docs/setup/01-flutter-android.md) | Flutter + Android |
| [docs/setup/02-supabase.md](docs/setup/02-supabase.md) | Supabase, Google Auth, reset |
| [docs/setup/03-firebase-fcm.md](docs/setup/03-firebase-fcm.md) | FCM |
| [docs/pendientes.md](docs/pendientes.md) | Deuda y pendientes |
| [docs/e2e.md](docs/e2e.md) | Patrol E2E |
| [docs/adr/](docs/adr/) | Decisiones por ciclo (histórico) |
