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
| Mejoras y reportes | Activos arriba (pendiente / revisión); resueltos en bloque colapsado (al recargar la página) |
| Navegación | Menú lateral (escritorio) + chips (móvil) con `#version`, `#reportes`, `#como-probar` |
| Cómo probar (por versión) | Desplegable por versión → `#n` + pasos. Solo la **versión actual** del APK abierta al cargar |
| Publicar flujos | En el chat del agente: decir **publica** → te pide los `#` → escribe los flujos en la DB |
| Subir APK nuevo | Ver [Publicar APK](#publicar-apk) abajo. |

Publicar un APK **no** requiere redeploy de Pages: el portal ya lee la URL desde Supabase. Los flujos de “Cómo probar” viven en `beta_qa_flows`.

## Publicar APK

Requisitos: `env/test.env`, `env/pdn.env`, `backend/.env` (service_role TEST para Storage).

1. Sube `+N` en `frontend/pubspec.yaml` si corresponde.
2. Desde `frontend/`:

```powershell
python ..\backend\scripts\merge_pdn_env.py
flutter build apk --release --dart-define-from-file=env/.pdn.build.env --target-platform android-arm64
python ..\backend\scripts\publish_beta_apk.py --version 1.0.0 --build N --apk build\app\outputs\flutter-apk\app-release.apk
```

Sustituye `1.0.0` y `N` por la versión del pubspec. Release **arm64** (Free ≤ 50 MB).

## Activar Pages (una vez)

1. Repo → **Settings** → **Pages**
2. Source: **GitHub Actions**
3. Añade los 2 secrets de arriba
4. Push a `main` que toque `beta-portal/` (o **Actions** → *beta-portal-pages* → Run workflow). El job usa `runs-on: self-hosted` (tu runner en WSL debe estar encendido).