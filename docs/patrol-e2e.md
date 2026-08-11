# Patrol E2E — P0 (Android físico)

Suite de aceptación con [Patrol](https://patrol.leancode.co/) sobre **Android por USB**.  
Backend: proyecto Supabase **e2e** separado (opción A). Carpeta: `frontend/patrol_test/`.

## P0 cubierto

| Test | Archivo | Qué valida |
|------|---------|------------|
| Plumbing | `acceptance/p0_patrol_plumbing_test.dart` | Patrol habla con el device (sin Firebase) |
| Smoke | `acceptance/p0_smoke_test.dart` | Arranque → Login, Home o error de config |
| Sesión / Home | `acceptance/p0_session_home_test.dart` | Con tokens e2e o sesión persistida → Home; si no → Login |
| Regla 8 | `acceptance/p0_regla8_test.dart` | Fallo técnico en Home → solo `Error en la app. Intenta de nuevo.` |

## Google y bloqueo por automatización

Google **suele bloquear o marcar** flujos OAuth cuando un robot escribe usuario/contraseña o fuerza el Account Picker de forma agresiva. P0 **no** automatiza credenciales ni el login nativo de Google como camino principal.

Cómo evitamos el bloqueo:

1. **Cuenta Google dedicada solo e2e** (humana): úsala para un login **manual** en el teléfono (o para emitir tokens), no para stuffing de password desde Patrol.
2. **Sesión pre-calentada (preferido en dispositivo):** tras ese login manual, Supabase persiste la sesión en el app; los tests de Home/regla 8 reutilizan esa sesión.
3. **Tokens vía `--dart-define` (preferido en CI / reproducible):** en `.env.e2e` pon `E2E_SUPABASE_REFRESH_TOKEN` (+ access). El harness llama `auth.setSession` **sin abrir UI de Google**.
4. **Proyecto OAuth / Supabase e2e** distinto de prod; no uses la cuenta personal de producción.
5. Automatizar el Account Picker nativo queda **fuera de P0** (alto flake / riesgo de challenge). Se puede valorar en P1 solo como “elegir cuenta ya logueada en el device”, nunca tipar password.

## Setup una vez

```powershell
# Flutter + device
flutter doctor
adb devices

# CLI Patrol (añade Pub\Cache\bin al PATH si hace falta)
dart pub global activate patrol_cli
patrol doctor

cd frontend
flutter pub get
copy .env.e2e.example .env.e2e
# Rellena SUPABASE_* del proyecto e2e (+ tokens opcionales)
```

Android ya incluye `PatrolJUnitRunner`, orchestrator y `MainActivityTest`.

## Cómo correr (solo device USB)

Evita el selector de “Edge” (navegador) pasando el id del Motorola:

```powershell
cd frontend
adb devices
# motorola edge 60 fusion → ZY22MW45BV (cambia si adb muestra otro)
patrol test -d ZY22MW45BV --dart-define-from-file=.env.e2e
# o un archivo:
patrol test -d ZY22MW45BV -t patrol_test/acceptance/p0_smoke_test.dart --dart-define-from-file=.env.e2e
```

Misma regla de secrets que R5: defines en compile-time, nunca `.env` como asset.

### Si ves `Total: 0` / Gradle code 1

1. **DNS / Maven:** si el log dice `Host desconocido (maven-central.storage-download.googleapis.com)`,
   es red/repos (no el test). Usa `google()` + `mavenCentral()` sin ese mirror
   (ya en `android/build.gradle.kts` / `settings.gradle.kts`).
2. **Cleartext / Patrol:** la app deniega HTTP salvo loopback. Si alguien quita
   `localhost` de `network_security_config.xml`, Patrol no descubre tests.
3. **Android 15/16 (API 35+):** hay reports de Patrol con 0 tests en API altas.
   Tu Motorola puede estar en API 36. Si tras el fix de red/localhost sigue en 0,
   prueba un emulador **API 34** o actualiza `patrol` / `patrol_cli`.
4. Corre con `--verbose` y en paralelo `adb logcat | findstr Patrol`.

## Criterio flaky

Falla ≥2/5 corridas sin cambio de código → reescribir una vez; si sigue, aislar nativo o checklist manual. **Prohibido** reintentar a ciegas para “hacerla pasar”.

## Cómo verificar que los tests fallan de verdad

1. **Smoke:** quita defines / rompe package → no debería asentarse Login/Home sano.
2. **Sesión:** borra datos de la app (`adb shell pm clear com.chevere.plan`) sin tokens e2e → debe exigir Login, no Home.
3. **Regla 8:** con sesión, el fake lanza texto tipo `PostgrestException…`; la UI **no** debe mostrar ese string. Si cambias el test a `expect(find.textContaining('Postgrest'), findsOneWidget)` debería fallar (la app sigue oculta el detalle).

## Próximo (no P0)

P1 guardar desde FAB, P1b share sheet, etc. — ver `docs/patrol-e2e-propuesta.md`.
