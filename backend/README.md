# Backend Supabase

## Reset (un comando)

Borra sitios, planes y fotos; reaplica migraciones + DIVIPOLA; deja `johnftmovil@gmail.com` como root. Conserva el login de Google.

```powershell
powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1
```

Requisito: `backend/.env` con `SUPABASE_DB_URL` (en Windows: URI **Session pooler** del dashboard).

Después cierra sesión en la app.

## Qué corre

1. `supabase/scripts/00_nuke.sql` — schema `public` + fotos
2. `supabase/migrations/*.sql` (000001 … 000013)
3. `supabase/scripts/05_sync_divipola.sql`

## Regenerar DIVIPOLA

```powershell
python backend/supabase/scripts/05_sync_divipola.py --sql -o backend/supabase/scripts/05_sync_divipola.sql
```

Luego vuelve a correr el reset (o aplica solo el SQL generado).
