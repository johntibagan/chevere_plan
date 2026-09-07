# Firebase (Crashlytics + FCM)

Mismo proyecto Firebase que Performance. Auth y datos de negocio siguen en **Supabase**.

Package Android: `com.chevere.plan`.  
`frontend/android/app/google-services.json` es local (gitignored).

## Crashlytics (canal de errores remotos)

- Plugin Dart: `firebase_crashlytics` · Gradle: `com.google.firebase.crashlytics`.
- Arranque: tras `Firebase.initializeApp` en `createRootApp` → `CrashlyticsService.installGlobalHandlers()`:
  - `FlutterError.onError` + `PlatformDispatcher.instance.onError` (fatales).
  - Colección **activa en release/profile** (`!kDebugMode`); en debug no se fuerza.
- Usuario: `setUserIdentifier` = UUID de Supabase Auth al tener sesión; se limpia en `clearSessionCaches` al logout.
- Errores de flujo (p. ej. Guardar sitio): `CrashlyticsService.recordNonFatal` con custom key `context` (+ `site_id` / `save_id` si hay).
- **No** hay tabla `client_debug_logs` (retirada). Diagnóstico beta: consola Firebase → Crashlytics → stack + keys → pasar a Cursor a mano.

APK beta (`publish_beta` / release): Crashlytics queda activo con el build release (`setCrashlyticsCollectionEnabled(!kDebugMode)`).

Smoke opcional (solo laboratorio):

```powershell
flutter build apk --profile --dart-define-from-file=env/test.env --dart-define=CRASHLYTICS_SMOKE=true --target-platform android-arm64
```

Dispara un non-fatal `context=crashlytics_smoke_test` + `sendUnsentReports`. En la consola puede tardar unos minutos.

## FCM

Inicialización mínima en `fcm_bootstrap.dart` (permiso + token). Registro en DB / envío desde Edge Function = cañería futura (Paso 2 push); no gatillos de negocio aún.

## Si recreas el proyecto Firebase

1. https://console.firebase.google.com/ → proyecto `chevere-plan` (misma cuenta que OAuth).
2. Añadir app Android, package `com.chevere.plan`.
3. Activar **Crashlytics** (y Messaging si aplica) en la consola.
4. Descargar `google-services.json`:

```powershell
Copy-Item "$env:USERPROFILE\Downloads\google-services.json" "C:\workspace\chevere_plan\frontend\android\app\google-services.json"
```

No hace falta FlutterFire CLI.
