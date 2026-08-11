# Observaciones para refinar (cierre Fase 1 / Ciclo 8)

Notas de usabilidad y deuda suave recogidas ciclo a ciclo. No bloquean el MVP; se revisan al pulir.

## Ciclo 2 — Captura / guardados

- Edición de borrador in-app todavía pendiente (completar desde la lista).
- Google Places API / geocoding automático pendiente.
- Autocomplete textual de categorías pendiente (hoy selector por árbol).
- **Ubicación:** picker OSM + búsqueda Nominatim; autocompleta ciudad/depto/dirección/nombre. Refinar UX de categorías buscables si hace falta.

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
- UI reescrita a ListView + toggle Avanzada (TabBarView/SegmentedButton rompían layout).
- Fallback local si falla RPC `search_sites` (sigue haciendo falta aplicar SQL C6 en Supabase).
- **Refinar filtros avanzados:** al cambiar/limpiar filtros parece seguir mostrando los mismos datos o no resetear resultados previos; hay que forzar nueva consulta limpia y limpiar hits al cambiar filtros / modo.
- **Bug layout (histórico):** TabBarView daba ancho infinito en General.

## Ciclo 7 — Trazabilidad / moderación

- Transporte usado al marcar “visitado” no se persiste aún (historial solo sitio/plan/fecha).
- Reportar sitio/perfil/evento: tabla lista; UI MVP solo fotos.
- Admin aún no elimina la foto del storage al “actioned” — solo cambia estado del reporte.

## Transversal

- Errores al usuario: solo negocio o “Error en la app…” (regla 8 del prompt). Revisar pantallas nuevas en cada ciclo.
- Horarios de apertura: hook listo (`PlanHoursPolicy`); filtrado real cuando existan fichas enriquecidas (§8.2).
