# Documentación

**Un tema = un archivo dueño.** El resto solo enlaza (regla Cursor `docs-sin-duplicar.mdc`).

## Producto (fuente de verdad)

| Tema | Archivo |
|---|---|
| Cómo está la app **hoy** (flujos + UI) | [aplicacion-actual.md](aplicacion-actual.md) |
| Qué **no** se rompe | [invariantes.md](invariantes.md) |
| Visión y fases futuras | [producto.md](producto.md) |
| Deuda + diseño Compartir (Fase 2) | [pendientes.md](pendientes.md) |

Al cambiar comportamiento: código **y** `aplicacion-actual` / `invariantes` en el mismo pase (`docs-al-cambiar.mdc`).

## Cómo construir / operar

| Tema | Archivo |
|---|---|
| Correr app en local | [../frontend/GETTINGSTAR.md](../frontend/GETTINGSTAR.md) |
| Setup Flutter / Android (una vez) | [setup/01-flutter-android.md](setup/01-flutter-android.md) |
| Setup Supabase / Auth Google | [setup/02-supabase.md](setup/02-supabase.md) |
| Setup Firebase FCM | [setup/03-firebase-fcm.md](setup/03-firebase-fcm.md) |
| Reset DB / migraciones | [../backend/README.md](../backend/README.md) |
| Publicar APK beta (PDN) | [../beta-portal/README.md](../beta-portal/README.md) |
| Lineamientos frontend | [lineamientos-desarrollo-frontend.md](lineamientos-desarrollo-frontend.md) |
| Google Maps (keys / Places) | [google-maps-setup.md](google-maps-setup.md) |
| Imágenes de red / Commons | [imagenes-red.md](imagenes-red.md) |
| E2E Patrol | [e2e.md](e2e.md) |
| Import catálogo Colombia (JSON) | [data/README.md](data/README.md) |
| Hallazgos técnicos cortos | [investigaciones-tecnicas.md](investigaciones-tecnicas.md) |
| Figma Make (snapshot) | [../design/figma-make/](../design/figma-make/README.md) |

Credenciales: comentarios en `frontend/env/*.example` y `backend/.env.example` — no duplicar aquí.
