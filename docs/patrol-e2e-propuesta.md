# Patrol E2E — propuesta de aceptación

> Estado: **P0 implementado**. Detalle de ejecución: [`docs/patrol-e2e.md`](patrol-e2e.md).

## Objetivo

Suite E2E de aceptación con **Patrol** (LeanCode) sobre celular Android por USB, por ciclos cortos, cubriendo flujos reales del MVP (incl. UI nativa: share sheet, permisos, etc.) y la **regla 8** (mensaje genérico ante fallo técnico).

## Decisiones cerradas (P0)

| Pregunta | Respuesta |
|----------|-----------|
| Backend | **A** — proyecto Supabase e2e separado |
| Device | Solo **Android físico** por USB |
| Google | Cuenta dedicada e2e; **sin** automatizar password/picker (sesión persistida o `E2E_SUPABASE_*_TOKEN`) |
| Carpeta | `frontend/patrol_test/` |
| Arranque | P0 hecho |

## Stack y carpetas

| Pieza | Ubicación |
|--------|-----------|
| Framework | `patrol` + `patrol_cli` |
| Specs P0 | `patrol_test/acceptance/p0_*_test.dart` |
| Helpers | `patrol_test/helpers/` |
| Docs | `docs/patrol-e2e.md` |
| Secrets | `.env.e2e` / `.patrol.env` (gitignored); plantilla `.env.e2e.example` |

## Ciclos de pruebas (prioridad)

| Tanda | Flujos | Estado |
|-------|--------|--------|
| **P0** | Smoke + sesión/Home + regla 8 | **Hecho** |
| **P1** | Guardar (FAB) → aparece en Inicio | Pendiente |
| **P1b** | Share sheet → app | Pendiente |
| **P2** | Categorías / borrador | Pendiente |
| **P3** | Privacidad | Pendiente |
| **P4** | Proximidad + permiso ubicación | Pendiente |
| **P5** | Planes | Pendiente |
| **P6** | Búsqueda | Pendiente |
| **P7** | Rutas / reportes staff | Pendiente |

## Criterio de flaky

Falla ≥2/5 corridas sin cambio de código → reescribir una vez; si sigue, aislar nativo o degradar a checklist manual. **Prohibido** reintentar a ciegas para “hacerla pasar”.
