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

Resets (ver `backend/README.md`):

- `reset_all.ps1` → solo datos de usuario  
- `reset_all.ps1 -Full` → cero + DIVIPOLA + esta carga masiva  

