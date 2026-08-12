# ADR 0001 — Bootstrapping Ciclo 0 (auth + FCM)

## Contexto

Ciclo 0: app que compila con login Google vía Supabase y FCM inicializado, sin lógica de negocio (especificación §15 Fase 1).

## Decisiones

1. **Config local** con `flutter_dotenv` + `frontend/.env` (gitignored). Variables: `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `GOOGLE_WEB_CLIENT_ID`.
2. **Auth**: `google_sign_in` obtiene ID token → `supabase.auth.signInWithIdToken(provider: google)`. El `GOOGLE_WEB_CLIENT_ID` es el OAuth **Web** de Google Cloud (requerido en Android para `idToken`).
3. **FCM**: solo `Firebase.initializeApp`, permiso de notificaciones y lectura del token. Sin topics ni geofencing.
4. **Navegación**: gate simple por sesión Supabase (splash → login | home). Sin go_router todavía.
5. **Estructura** `lib/{core,features,shared}` preparada para ciclos siguientes.

## Consecuencias

- Sin `GOOGLE_WEB_CLIENT_ID` en `.env`, el botón de Google muestra error explícito.
- Esquema de perfiles/roles (root/admin) queda para Ciclo 1.
