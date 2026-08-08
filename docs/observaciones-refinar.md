# Observaciones para refinar (cierre Fase 1 / Ciclo 8)

Notas de usabilidad y deuda suave recogidas ciclo a ciclo. No bloquean el MVP; se revisan al pulir.

## Ciclo 2 — Captura / guardados

- Edición de borrador in-app todavía pendiente (completar desde la lista).
- Google Places API / geocoding automático pendiente.
- Autocomplete textual de categorías pendiente (hoy selector por árbol).

## Ciclo 3 — Privacidad / duplicados

- Flujo “¿Es el mismo sitio?” funciona; revisar copy y fricción si usuarios se confunden.

## Ciclo 4 — Geofencing

- Warning de Flutter por `native_geofence` + KGP (`android.builtInKotlin=false` obligatorio mientras `app_links`/otros no migren). No bloquea; migrar cuando el ecosistema lo permita.
- Pedir ubicación “siempre” es sensible: copy y timing del permiso a mejorar.

## Ciclo 5 — Planes

- **“Marcar visitado” confunde** frente a “incluir en Maps” (checkbox). El visitado es progreso (§7.3); el check es la ruta a exportar. En pulido: UX más clara (p. ej. un solo concepto, o copy/tooltip más explícito, o “ya pasé por aquí” vs “llevar a Maps”).
- Si una parada no tiene lat/lng, Maps no puede incluirla — avisar mejor al armar el plan o al completar ubicación del sitio.
- Compartir plan por link queda fuera (spec lo permite; no está en entregable C5).

## Ciclo 6 — Búsqueda

- Filtro de horario en UI es placeholder hasta fichas enriquecidas (comportamiento esperado).
- Búsqueda de planes por título no incluida (solo sitios); valorar en pulido.
- Tabs General/Avanzada: la avanzada es densa en móvil; valorar sheet de filtros.
- **Bug layout (corregido):** TabBarView daba ancho infinito y ocultaba el campo General (`BoxConstraints forces an infinite width` en `FilledButton`).
- **RPC:** re-ejecutar `20260808000007_ciclo6_search.sql` si falla con “Error en la app” (firma con `p_transport_group text`).

## Ciclo 7 — Trazabilidad / moderación

_(se irá llenando)_

## Transversal

- Errores al usuario: solo negocio o “Error en la app…” (regla 8 del prompt). Revisar pantallas nuevas en cada ciclo.
- Horarios de apertura: hook listo (`PlanHoursPolicy`); filtrado real cuando existan fichas enriquecidas (§8.2).
