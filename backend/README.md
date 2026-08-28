# Backend Supabase

## Reset

**Solo TEST.** Requiere `CHEVERE_DB_ENV=test` y `SUPABASE_DB_URL` en `backend/.env`.
`SUPABASE_URL` debe ser el mismo proyecto que la DB (evita `.env` mal pegado).
Con `-Full` pide escribir `test` en consola.

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

Pide escribir `test` en consola para confirmar el entorno antes de ejecutar.

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

## Esquema: TEST vs PDN (beta)

| Dónde | Cuándo aplicar cambios SQL |
|--------|----------------------------|
| **TEST** (`SUPABASE_DB_URL`) | Al desarrollar: plegar al baseline y aplicar a la DB de TEST en el mismo trabajo. |
| **PDN** (`SUPABASE_DB_URL_PDN`, usuarios reales) | **Solo cuando el dueño lo indique** (p. ej. al publicar versión / decir «aplica en PDN»). **No** MCP, `migrate_test_to_pdn.py` ni SQL directo contra PDN por defecto. |

Flujo habitual en TEST: editar `supabase/migrations/` → aplicar a TEST → plegar al baseline.

Cuando toque PDN (el dueño lo dirá):

```powershell
python scripts/migrate_test_to_pdn.py
```

Requiere `SUPABASE_DB_URL_PDN` en `backend/.env`.

La copia masiva TEST→PDN (datos, one-shot 2026) ya está hecha; no repetir.
