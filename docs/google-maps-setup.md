# Google Maps Platform — setup Chevere Plan

Cupos gratis (desde mar 2025, por SKU): Essentials ≈ 10 000/mes.
Maps SDK Android = **ilimitado ($0)**.

## 1. Cloud Console

1. Proyecto Google Cloud + facturación (obligatorio aunque uses cupo gratis).
2. APIs → activar solo:
   - **Maps SDK for Android**
   - **Places API** (New)
   - **Geocoding API**
3. Credenciales → API key.
4. Restricciones de API: solo las 3 de arriba.
5. Restricción de aplicación:
   - **MVP / REST desde Flutter:** sin restricción de app (solo API).
   - **Producción ideal:** key Android (package + SHA-1) para Maps SDK +
     key o proxy solo para Places/Geocoding.
6. Cuotas diarias en consola (ej. Place Details 300/día).
7. Presupuesto: alerta US$5, tope US$15–20.

## 2. App

1. `frontend/.env` → `GOOGLE_MAPS_API_KEY=...` y `GOOGLE_PLACES_DAILY_LIMIT=80`.
2. `frontend/android/local.properties` (gitignored):

```properties
GOOGLE_MAPS_API_KEY=la_misma_key
```

3. Run:

```bash
flutter run --dart-define-from-file=.env
```

## 3. Anti-fugas (ya en código)

- Pegar link Maps → parse gratis + **1× Place Details** (si hace falta).
- Buscador del mapa → **solo al pulsar 🔍** (sin teclas).
- Autocomplete con **session token** → al elegir, Place Details y fin de sesión.
- Tap en mapa → **1× Geocoding reverse**.
- Cupo local diario; Geoapify/OSM como fallback.

## 4. Field mask Essentials

Solo: `id`, `displayName`, `formattedAddress`, `location`, `addressComponents`.
Nunca Pro/Enterprise (teléfono, reviews, etc.).
