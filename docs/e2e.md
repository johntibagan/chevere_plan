# Patrol E2E (Android físico)

Suite en `frontend/patrol_test/`. Backend: proyecto Supabase **e2e** aparte, no el de uso diario.

## P0 (hecho)

| Test | Archivo | Qué valida |
|------|---------|------------|
| Plumbing | `acceptance/p0_patrol_plumbing_test.dart` | Patrol habla con el device |
| Smoke | `acceptance/p0_smoke_test.dart` | Arranque → Login, Home o error de config |
| Sesión / Home | `acceptance/p0_session_home_test.dart` | Tokens e2e o sesión persistida → Home |
| Regla 8 | `acceptance/p0_regla8_test.dart` | Fallo técnico → solo `Error en la app. Intenta de nuevo.` |

P0 **no** automatiza el login de Google (Google bloquea robots). Opciones: sesión ya abierta en el teléfono, o `E2E_SUPABASE_REFRESH_TOKEN` en `.env.e2e`.

## Correr

```powershell
cd frontend
copy .env.e2e.example .env.e2e
dart pub global activate patrol_cli
adb devices
patrol test -d DEVICE_ID --dart-define-from-file=.env.e2e
```

Si Gradle dice `Total: 0`: red/Maven, o `network_security_config` sin localhost, o API 35+ (probar emulador API 34).

## Siguientes tandas (no hechas)

P1 guardar desde FAB · P1b share sheet · P2 categorías/borrador · P3 privacidad · P4 proximidad · P5 planes · P6 búsqueda.
