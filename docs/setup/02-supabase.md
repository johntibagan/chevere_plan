# Supabase

Package Android: `com.chevere.plan`. No subas keys a git: `frontend/.env` y `backend/.env` están ignorados.

## Cliente (app)

En `frontend/.env`:

| Variable | Dónde |
|----------|--------|
| `SUPABASE_URL` | Dashboard → Project Settings → API |
| `SUPABASE_ANON_KEY` | Misma pantalla (anon / publishable) |
| `GOOGLE_WEB_CLIENT_ID` | Google Cloud → Credentials → OAuth **Web** |

Auth: provider Google activado en Supabase. El SHA-1 de debug de esta máquina:

```
26:39:0F:7D:ED:18:CA:58:A2:74:C6:ED:90:47:9B:30:3E:72:FB:4E
```

Google Cloud → cliente OAuth **Android**, package `com.chevere.plan`.

```powershell
keytool -list -v -keystore "$env:USERPROFILE\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

## Reset de la base

- Default: borra datos de **usuarios**; conserva DIVIPOLA y sitios de catálogo (`external_id`).
- `-Full`: nuke → 3 migraciones (schema, categorías/transporte, storage) → DIVIPOLA → JSON masivo → root `johnftm.proyectos@gmail.com` (conserva logins de Google en Auth).

1. Copia `backend/.env.example` → `backend/.env`
2. Pega **SUPABASE_DB_URL**: Dashboard → Database → Connect → **Session pooler** (Windows no enruta IPv6 de la URI directa).
3. Corre:

```powershell
powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1
```

Luego cierra sesión en la app (caché Hive).

El seed de categorías y transporte va en `20260808000002_seed.sql`. DIVIPOLA se carga desde `backend/supabase/scripts/05_sync_divipola.sql`.

Para regenerar DIVIPOLA desde datos.gov.co:

```powershell
python backend/supabase/scripts/05_sync_divipola.py --sql -o backend/supabase/scripts/05_sync_divipola.sql
```

## CLI de Supabase (opcional)

No hace falta para el reset. Si la quieres: `npm install -g supabase`.
