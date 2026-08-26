# Portal de pruebas cerradas (GitHub Pages)

Carpeta **única** que despliega Pages. Si no hay cambios aquí, el workflow **no** corre.

## URL (tras el primer deploy)

`https://johntibagan.github.io/chevere_plan/`

## Secrets (GitHub → Settings → Secrets and variables → Actions)

| Secret | Qué es | Dónde sacarlo |
|--------|--------|----------------|
| `BETA_SUPABASE_URL` | URL del proyecto | Supabase → Project Settings → API → Project URL |
| `BETA_SUPABASE_ANON_KEY` | Clave **anon** / publishable | Misma pantalla → `anon` `public` |

**No** subas `SUPABASE_SERVICE_ROLE_KEY` a GitHub ni a esta carpeta. Esa clave solo vive en `backend/.env` (local) para publicar el APK.

## Qué hace cada cosa

| Acción | Dónde |
|--------|--------|
| Descargar APK / ver versión | Este portal (lee `beta_release` en Supabase) |
| Agregar reporte (anónimo) | Este portal → tabla `beta_feedback` |
| Editar / borrar | Solo si **no** está en revisión ni listo |
| Marcar “en revisión” | Portal + PIN de dueño (bloquea editar/borrar) |
| Marcar “listo” | Portal + PIN de dueño (en DB, no en Git) |
| Número de ticket | Columna `#n` automática (tocar copia `#n` para el commit) |
| Cómo probar (por versión) | Sección al final: desplegable por versión → `#n` + pasos. Datos en `beta_qa_flows` |
| Publicar flujos | En el chat del agente: decir **publica** → te pide los `#` → escribe los flujos en la DB |
| Subir APK nuevo | `frontend\tool\publish_beta.ps1` → release **arm64 sin R8** (estable; Free ≤ 50 MB). |

Publicar un APK **no** requiere redeploy de Pages: el portal ya lee la URL desde Supabase. Los flujos de “Cómo probar” tampoco: viven en `beta_qa_flows`.

## Activar Pages (una vez)

1. Repo → **Settings** → **Pages**
2. Source: **GitHub Actions**
3. Añade los 2 secrets de arriba
4. Push a `main` que toque `beta-portal/` (o **Actions** → *beta-portal-pages* → Run workflow)

#