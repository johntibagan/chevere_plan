# Dataset sitios públicos (Colombia)

## Qué va a qué tabla

| Origen JSON | Tabla Supabase | Filas típicas | Notas |
|---|---|---|---|
| `departments` | **no se importa** | — | Ya están en `public.departments` (DIVIPOLA) |
| `municipalities` | `public.sites` | ~1122 | Un **sitio público** por municipio (`external_id=co-muni-{código}`). Tiene `department`/`department_id` como dato del sitio, **no** se crea un sitio por departamento. |
| `sites` | `public.sites` | 40 hoy | Atractivos curados (Zipaquirá, etc.), otro `external_id` |

Catálogo DIVIPOLA (selectores depto/ciudad en la app):

| Tabla | Qué es |
|---|---|
| `public.departments` | 32/33 deptos |
| `public.cities` | 1122 municipios |

No hay duplicado “depto como sitio”. Homónimos tipo *Buenavista* en varios deptos son municipios distintos (`external_id` distinto).

Owner de carga masiva y **único root**: `johnftm.proyectos@gmail.com`.

## Importar / reset

Import manual:

```powershell
cd C:\workspace\chevere_plan\backend
python supabase\scripts\06_import_public_sites.py ..\docs\data\colombia_departamentos_municipios_sitios.json
```

Fotos de catálogo (carga one-shot): scripts `07`/`08`/`09`, JSON de progreso y el visor viven solo en `supabase/scripts/_photos_review_local/` (**ignorada por git**, no va al repo). Ejemplo:

```powershell
cd C:\workspace\chevere_plan\backend
python supabase\scripts\_photos_review_local\09_import_catalog_photos_parallel.py --skip-sample-check
python supabase\scripts\_photos_review_local\photos_review.py
python supabase\scripts\_photos_review_local\09_import_catalog_photos_parallel.py --apply
```

Openverse opcional en `.env` local: `OPENVERSE_CLIENT_ID` / `OPENVERSE_CLIENT_SECRET`. `--apply` inserta solo fotos con **me gusta**; portada = primera liked.

Reset DB (default / `-Full`): [`backend/README.md`](../../backend/README.md).

