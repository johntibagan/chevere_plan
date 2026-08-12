# App Flutter

Antes de cambiar código: [docs/lineamientos-desarrollo-frontend.md](../docs/lineamientos-desarrollo-frontend.md).

```powershell
copy .env.example .env
.\tool\run_dev.ps1
```

Los valores se inyectan en compile-time (`--dart-define-from-file`). Nunca `SUPABASE_SERVICE_ROLE_KEY` en el cliente.

| Variable | Notas |
|----------|--------|
| `SUPABASE_URL` + `SUPABASE_ANON_KEY` | Públicas; la seguridad es RLS |
| `GOOGLE_WEB_CLIENT_ID` | OAuth Web |
| `GEOAPIFY_API_KEY` | Autocomplete / reverse (opcional) |

Tests:

```powershell
flutter test
```

E2E Patrol: [docs/e2e.md](../docs/e2e.md).
