# Chevere Plan (Flutter)

## Config segura (R5)

Los valores de cliente se inyectan en compile-time con `.env` (no van como asset en el APK).

1. Copia `.env.example` → `.env` (gitignored) y rellena valores.
2. Ejecuta:

```bash
flutter run --dart-define-from-file=.env
```

Windows (PowerShell):

```powershell
.\tool\run_dev.ps1
```

### Qué sí / qué no

| Valor | Cliente | Notas |
|-------|---------|--------|
| `SUPABASE_URL` + `SUPABASE_ANON_KEY` | Sí | Públicas por diseño; la seguridad real es **RLS** en Supabase |
| `GOOGLE_WEB_CLIENT_ID` | Sí | OAuth Web client id |
| `GEOAPIFY_API_KEY` | Sí | Key de cliente + cuota local |
| `SUPABASE_SERVICE_ROLE_KEY` | **Nunca** | Solo backend/CI; `Env.assertNoServerSecrets()` falla en debug si se inyecta |

Release recomendado:

```bash
flutter build apk --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=.env
```

## Getting Started

```bash
flutter pub get
# copiar .env.example → .env
flutter run --dart-define-from-file=.env
```
