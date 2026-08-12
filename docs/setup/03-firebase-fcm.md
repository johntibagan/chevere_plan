# Firebase FCM

Solo push. Auth y datos siguen en Supabase. Package: `com.chevere.plan`.

El archivo `frontend/android/app/google-services.json` es local (gitignored).

## Si recreas el proyecto

1. https://console.firebase.google.com/ → proyecto `chevere-plan` (misma cuenta que OAuth).
2. Añadir app Android, package `com.chevere.plan`.
3. Descargar `google-services.json` y copiarlo:

```powershell
Copy-Item "$env:USERPROFILE\Downloads\google-services.json" "C:\workspace\chevere_plan\frontend\android\app\google-services.json"
```

No hace falta FlutterFire CLI: el código FCM ya está en la app (`fcm_bootstrap.dart`).
