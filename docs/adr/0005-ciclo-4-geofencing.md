# ADR 0005 — Ciclo 4: recuerdos por ubicación (geofencing)

## Contexto

Especificación §6; prompt Ciclo 4. Notificación tipo recuerdo al acercarse a un sitio guardado (propio o público si el usuario lo activa), sin polling constante de GPS.

## Decisiones

1. **API:** Google Play Services GeofencingClient vía paquete `native_geofence` (Android primero).
2. **Notificación:** canal local `proximity_reminders` con `flutter_local_notifications` (mismo stack que borradores). FCM no se usa para este recuerdo.
3. **Radio:** default **200 m**, parametrizable por usuario en `profiles.proximity_radius_m` (check 100–2000).
4. **Sitios públicos:** `profiles.remind_public_sites` (default `false`); switch en menú de Inicio / preferencias.
5. **Trigger:** solo evento `enter`.
6. **Elegibles:** sitios con `location` y guardado `complete`; no borradores ni `pending_location`.
7. **Límite Android:** máx. 100 geofences — propios primero; si hay cupo y el switch está on, se añaden públicos.
8. **Coords para sync:** RPC `list_proximity_sites(p_include_public)` con `ST_Y`/`ST_X`.
9. **Permisos:** when-in-use primero, luego background; mensaje de negocio si faltan.

## Consecuencias

- Tras reboot, el plugin re-registra geofences; la app debe re-sync al abrir Home.
- Validación en emulador: Extended Controls → Location dentro del radio.
