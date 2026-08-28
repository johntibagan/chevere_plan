# Supabase

Package Android: `com.chevere.plan`. Credenciales: `frontend/env/*.example` y `backend/.env.example` (copias gitignored).

## Auth Google (debug)

SHA-1 de esta máquina:

```
26:39:0F:7D:ED:18:CA:58:A2:74:C6:ED:90:47:9B:30:3E:72:FB:4E
```

Google Cloud → OAuth **Android**, package `com.chevere.plan`.

## Reset de la base

- Default: borra datos de **usuarios**; conserva DIVIPOLA y catálogo (`external_id`).
- `-Full`: nuke → migraciones baseline → DIVIPOLA → JSON masivo → root `johnftm.proyectos@gmail.com`.

```powershell
copy backend\.env.example backend\.env
powershell -File backend\reset_all.ps1
```

`-Full`: añade `-Full` al comando. Detalle: [backend/README.md](../../backend/README.md).

Tras reset: cierra sesión en la app (caché Hive).
