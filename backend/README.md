# Backend Supabase

## Reset

**Root único:** `johnftm.proyectos@gmail.com`  
(Catálogo masivo también queda con ese `created_by`.)

### 1) Solo datos de usuario (rápido)

Borra sitios creados a mano, planes, saves, reportes y fotos.  
**Conserva** DIVIPOLA (`departments`/`cities`) y sitios de carga masiva (`external_id`).

```powershell
powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1
```

### 2) Cero absoluto + reseeding (lento)

Nuke del schema `public` → migraciones → regenera/aplica DIVIPOLA →  
carga masiva desde `docs/data/colombia_departamentos_municipios_sitios.json` → root único.

```powershell
powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1 -Full
```

Requisito: `backend/.env` con `SUPABASE_DB_URL` (Session pooler).  
Después cierra sesión en la app.

## Regenerar DIVIPOLA a mano

```powershell
python backend/supabase/scripts/05_sync_divipola.py --sql -o backend/supabase/scripts/05_sync_divipola.sql
```

El `-Full` ya intenta regenerarlo solo antes de aplicar.
