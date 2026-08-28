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

Nuke del schema `public` → **migraciones baseline** (`…01_schema` → `…02_seed` → `…03_storage`) → regenera/aplica DIVIPOLA →  
carga masiva desde `docs/data/colombia_departamentos_municipios_sitios.json` → root único.

**Parches SQL:** solo para aplicar YA a la DB viva; en el mismo trabajo se **pliegan** al baseline (esquema desde la DB = fuente de verdad, sin datos) y se **borran**. No acumular migraciones sueltas.

```powershell
powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1 -Full
```

Requisito: `backend/.env` con `SUPABASE_DB_URL` (Session pooler IPv4).  
El `-Full` usa **una sola** conexión para nuke → migs → DIVIPOLA → import
(no reabre TCP entre pasos; evita fallos DNS del pooler).  
Después cierra sesión en la app.

Si el `-Full` llegó hasta DIVIPOLA y falló solo el import, no hace falta
nuke de nuevo: corre el import a mano y luego el reset default (root):

```powershell
cd C:\workspace\chevere_plan\backend
python supabase\scripts\06_import_public_sites.py ..\docs\data\colombia_departamentos_municipios_sitios.json
powershell -File .\reset_all.ps1
```


## Regenerar DIVIPOLA a mano

```powershell
python backend/supabase/scripts/05_sync_divipola.py --sql -o backend/supabase/scripts/05_sync_divipola.sql
```

El `-Full` ya intenta regenerarlo solo antes de aplicar.

## Migrar TEST → PDN (beta)

Migración de **datos** (one-shot, ago 2026): ya aplicada en `chevere_plan_pdn`. No volver a copiar datos.

Para **cambios de esquema** en PDN tras tocar las migraciones baseline:

```powershell
python scripts/migrate_test_to_pdn.py
```

Requiere `SUPABASE_DB_URL_PDN` en `backend/.env`. Aplica los `.sql` de `supabase/migrations/` en orden.
