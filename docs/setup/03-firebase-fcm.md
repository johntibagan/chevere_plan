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

## FCM — cañería push (sin features de negocio)

Patrón: [Sending Push Notifications (FCM)](https://supabase.com/docs/guides/functions/examples/push-notifications) adaptado a **tabla de tokens** (multi-dispositivo) en lugar de una columna en `profiles`.

### Tablas (TEST; PDN en la próxima publica)

| Tabla | Rol |
|---|---|
| `user_fcm_tokens` | Token FCM por dispositivo (`user_id` → `profiles`). Unique `token`. RLS: solo el dueño. |
| `notifications` | Cola: `user_id`, `title?`, `body`, `data` jsonb. INSERT → webhook → Edge Function. |

No hay triggers de Compartir / planes todavía: una feature futura solo hace `insert into notifications (...)`.

### Flutter

- `PushNotificationService` (Riverpod): al tener sesión → permiso SO + `getToken` + upsert; al logout → borra ese token.
- Sin pantalla nueva de “activar notificaciones” (solo diálogo del sistema).
- Performance: `fcm_bootstrap.dart` (solo Perf).

### Edge Function `push`

- Código: `backend/supabase/functions/push/index.ts`.
- `verify_jwt = false`; exige `Authorization: Bearer <service_role>` (lo pone el Database Webhook).
- Secret **`FIREBASE_SERVICE_ACCOUNT_JSON`**: JSON completo de la service account Firebase (Project settings → Service accounts → Generate new private key). **No** commitear el JSON.

```powershell
# Ejemplo (TEST), con la CLI de Supabase linkeada al proyecto test:
cd backend
supabase secrets set FIREBASE_SERVICE_ACCOUNT_JSON="{(pegar JSON en una línea)}" --project-ref ofyivxbfcumowbooehqp
```

### Database Webhook (manual en Dashboard TEST)

1. Database → Webhooks → Create.
2. Tabla `public.notifications`, evento **Insert**.
3. Tipo: Supabase Edge Functions → función **`push`**, POST.
4. Headers: **Add auth header with service key**.
5. Crear.

Prueba: con la app logueada (token en `user_fcm_tokens`), insertar una fila en `notifications` con ese `user_id` y un `body`. Debe llegar el push.

Si FCM responde `UNREGISTERED` / `NotRegistered`, el token está viejo (reinstalaste, cambiaste debug↔profile, etc.). La función `push` borra ese token y responde 200; abrí la app logueada otra vez para registrar uno fresco y reintentá el insert.

### Si recreas el proyecto Firebase

1. https://console.firebase.google.com/ → proyecto `chevere-plan` (misma cuenta que OAuth).
2. Añadir app Android, package `com.chevere.plan`.
3. Activar **Crashlytics** y **Cloud Messaging**.
4. Descargar `google-services.json`:

```powershell
Copy-Item "$env:USERPROFILE\Downloads\google-services.json" "C:\workspace\chevere_plan\frontend\android\app\google-services.json"
```

5. Generar service account JSON y setear el secret de la Edge Function (arriba).

No hace falta FlutterFire CLI.
