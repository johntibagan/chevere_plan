# ADR 0003 — Ciclo 2: captura / guardado / borrador

## Contexto

Especificación §3, §3.1; prompt Ciclo 2; UI Figma `guardar`.

## Decisiones

1. **Share sheet Android:** intent filters `SEND`/`SEND_MULTIPLE` (`text/*`, `image/*`) + paquete `receive_sharing_intent`. Al recibir, abrir flujo Guardar prellenado con URL/texto.
2. **Estados** (ya en DB): `draft` | `pending_location` | `complete`.
   - Completo = al menos **1 categoría** + **ubicación** (ciudad o coordenadas).
   - Sin categoría ni ubicación usable → `draft`.
   - Con datos parciales pero sin ubicación → `pending_location`.
3. **Geocoding Google Places:** opcional vía `GOOGLE_PLACES_API_KEY` en `.env`. Sin key: heurística mínima (parseo de texto) y/o estado pendiente + campos manuales. No bloquear el guardado.
4. **Privacidad:** `is_public = false` por defecto; toggle en el formulario (§3.5). Si `is_physical_place = false`, forzar privado (§3.6). Anti-duplicados / capa social → Ciclo 3.
5. **Fotos:** Storage bucket `site-photos`, máx. 15 por sitio, aviso Términos al subir. Extracción automática Places → fase con API key (stub documentado).
6. **Recordatorio borrador (§3.1):** al crear/quedar en `draft`, programar notificación local (+24 h) con `flutter_local_notifications`. Recordatorios espaciados posteriores: al abrir la app, avisar si hay borradores > 24 h. Cron FCM server-side queda para endurecer después.

## Supuestos

- El usuario ya creó el bucket `site-photos` (setup 02). Se añaden policies RLS de Storage en migración.
- Coordenadas manuales opcionales (lat/lng texto); sin mapa embebido.
