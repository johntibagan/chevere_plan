# Patrol E2E — propuesta de aceptación (pendiente de implementar)

> Estado: **propuesta validable**, aún sin código Patrol en el repo.  
> Cuando se retome: acordar respuestas al final y arrancar **P0**.

## Objetivo

Suite E2E de aceptación con **Patrol** (LeanCode) sobre celular Android por USB, por ciclos cortos, cubriendo flujos reales del MVP (incl. UI nativa: share sheet, permisos, etc.) y la **regla 8** (mensaje genérico ante fallo técnico).

## Stack y carpetas

| Pieza | Decisión propuesta |
|--------|-------------------|
| Framework | `patrol` + `patrol_cli` (no `flutter test` para estos E2E) |
| Carpeta | `frontend/patrol_test/` (default Patrol 4.x) |
| Helpers | `patrol_test/helpers/` (`app_harness.dart`, `keys.dart`, `fakes/`) |
| Specs | `patrol_test/acceptance/c0_login_test.dart`, `c2_share_save_test.dart`, … |
| Docs de ejecución | `docs/patrol-e2e.md` (crear al implementar P0) |
| Secrets | `.patrol.env` + `.env.e2e` → gitignored |

`pubspec.yaml` (cuando se implemente):

```yaml
patrol:
  app_name: Chevere Plan
  android:
    package_name: com.chevere.plan
```

Android: `PatrolJUnitRunner` + instrumentation en `build.gradle.kts`.

## Backend / datos

**Preferido: proyecto Supabase e2e aparte** (no prod).

| Opción | Uso |
|--------|-----|
| **A (preferida)** | Proyecto `chevere-plan-e2e` + migraciones 1→10 + usuario Google de prueba |
| **B** | Mismo proyecto + cleanup agresivo (más frágil) |
| **C** | Overrides Riverpod (rápido; no valida nativo) |

Híbrido:

1. Happy path / nativo → Supabase e2e real.
2. Regla 8 → URL inválida o repo que lanza error técnico; UI solo muestra `Error en la app. Intenta de nuevo.`

## Ciclos de pruebas (prioridad)

| Tanda | Flujos | Nativo |
|-------|--------|--------|
| **P0** | Smoke + login Google + error genérico | UI Google / sistema |
| **P1** | Guardar (FAB) → aparece en Inicio | — |
| **P1b** | Share sheet → app | Sí |
| **P2** | Categorías / borrador | — |
| **P3** | Privacidad | — |
| **P4** | Proximidad + permiso ubicación | Sí |
| **P5** | Planes | — |
| **P6** | Búsqueda | — |
| **P7** | Rutas / reportes staff | — |

## Cómo correr (borrador; detallar en P0)

```bash
adb devices
cd frontend
patrol doctor
patrol test -t patrol_test/acceptance/c0_login_test.dart --dart-define-from-file=.env.e2e
```

## Criterio de flaky

Falla ≥2/5 corridas sin cambio de código → reescribir una vez; si sigue, aislar nativo o degradar a checklist manual. **Prohibido** reintentar a ciegas para “hacerla pasar”.

## Preguntas abiertas (antes de P0)

1. ¿Supabase e2e separado (A) u otra opción?
2. ¿Solo Android físico primero?
3. ¿Cuenta Google de prueba dedicada?
4. ¿Confirmar carpeta `patrol_test/`?
5. ¿Arrancar con “adelante con P0”?
