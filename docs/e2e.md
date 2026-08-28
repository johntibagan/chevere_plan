# Patrol E2E (Android)

Suite en `frontend/patrol_test/`. Backend: proyecto Supabase **e2e** aparte, no el de uso diario.

Patrón **Robot** en `patrol_test/robots/`. Keys estables: `lib/core/testing/widget_keys.dart`.

## Tags

| Tag | Uso |
|-----|-----|
| `@smoke` | Arranque / plumbing |
| `@critical` | Corazón: guardar, shell, planes, rutas |
| `@saves` | Sitios / Explorar |
| `@plans` | Planes / Rutas |

```powershell
# PR (emulador): solo critical
patrol test --tags critical --dart-define-from-file=env/e2e.env

# Nightly / pre-release: suite completa
patrol test --dart-define-from-file=env/e2e.env
```

## P0

| Test | Archivo |
|------|---------|
| Plumbing | `acceptance/p0_patrol_plumbing_test.dart` |
| Smoke | `acceptance/p0_smoke_test.dart` |
| Sesión / Home | `acceptance/p0_session_home_test.dart` |
| Regla 8 | `acceptance/p0_regla8_test.dart` |

Login Google **no** se automatiza. Usá `E2E_SUPABASE_REFRESH_TOKEN` (cuenta de prueba, no root).

## Ruta crítica (P1)

| Archivo | Cubierto en device (con sesión) |
|---------|----------------------------------|
| `p1_saves_test.dart` | FAB+nombre, Guardar disabled, Público sin pin, pin mapa, punto exacto apagado por default, share simulado, Maps paste si `E2E_MAPS_URL` |
| `p1_privacy_test.dart` | Default privado; lista de coincidencias (suave/hard) si el RPC matchea |
| `p1_plans_test.dart` | Crear plan → builder; toggle incluir públicos |
| `p1_routes_test.dart` | Tab Rutas sin crash ni admin |
| `p1_search_test.dart` | Query Explorar |
| `p1_reviews_test.dart` | Skip documentado (galería nativa) |

Lógica pura (no E2E): `test/save_policies_test.dart`, `review_policies_test.dart`, `route_stats_test.dart`, `plan_reorder_test.dart`.

## Correr

```powershell
cd frontend
copy env\e2e.env.example env\e2e.env
dart pub global activate patrol_cli
adb devices
patrol test -d DEVICE_ID --dart-define-from-file=env/e2e.env --tags critical
```

`test_bundle.dart` lo regenera `patrol test`; no commitear.

## CI

Job PR: emulador API 34 + `--tags critical`. Job nightly: suite completa. Orchestrator limpia datos de app entre tests (`clearPackageData`).

Sin `--retry` salvo flake de animación documentado. Hoy: ningún retry.

## Cómo leer el resultado

Mirá el resumen `✅ Successful` y el HTML en `frontend/build/app/reports/androidTests/connected/debug/index.html`. Si ahí está 100% y 0 failed, **las aserciones Dart pasaron**.

Patrol 4.x + Android Test Orchestrator a veces termina con `Gradle test execution failed with code 1` igual (crash al cerrar el último test, no un `expect` fallido). Es un bug conocido del runner ([patrol#2879](https://github.com/leancodepl/patrol/issues/2879)). El aviso de actualizar `patrol_cli` y el warning de Kotlin Gradle Plugin (`native_geofence`, `patrol`) no invalidan la corrida.

`--tags critical` cubre más archivos que esos 4 (guardar, rutas, búsqueda, segundo caso de privacidad). Si el Gradle muere a mitad, el HTML solo lista los que alcanzaron a correr. Para el resto, un archivo a la vez:

```powershell
patrol test -d DEVICE_ID --dart-define-from-file=env/e2e.env --target patrol_test/acceptance/p1_saves_test.dart
```
