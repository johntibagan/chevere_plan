# ADR 0010 — R5: seguridad del cliente (secretos, logs, red)

## Contexto

Ciclo R5 del refactor frontend. El foco de “seguridad” no es solo empaquetado:
incluye **no dejar puertas traseras**, no filtrar datos sensibles en logs y alinear
prácticas de cliente móvil con RLS en backend.

## Decisiones

1. **Config por `--dart-define-from-file`** (`env/env.json`). Se elimina `.env` como
   asset de Flutter (antes iba dentro del APK).
2. **Solo claves de cliente:** `SUPABASE_ANON_KEY` / publishable, Google Web Client ID,
   Geoapify. **Prohibido** `SUPABASE_SERVICE_ROLE*` en el binario
   (`Env.assertNoServerSecrets()` en debug).
3. **Logs:** `AppLog` redacta JWT / Bearer / `apiKey=` en query; en release no se
   vuelca el `toString` de excepciones (solo tipo). FCM nunca loguea el token completo.
4. **UI de errores:** `userFacingError` sigue la regla 8 (mensaje genérico al usuario).
5. **Red Android:** `usesCleartextTraffic=false` + `network_security_config` sin HTTP.
6. **Staff/admin en UI:** el badge/panel es UX; la autorización real sigue siendo RLS
   en Supabase (sin bypass en cliente).

## Cómo correr

Ver `frontend/README.md` y `frontend/env/env.json.example`.

## Fuera de alcance

Rotación de keys en proveedores, WAF, pentest formal, iOS ATS custom (default ATS
ya exige HTTPS), migrar Geoapify a proxy backend (recomendable a medio plazo para
ocultar la key de mapas).
