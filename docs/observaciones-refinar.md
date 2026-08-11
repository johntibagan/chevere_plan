# Observaciones para refinar (post Ciclo 8 / pulido + Figma)

Notas de usabilidad y deuda suave. No bloquean el MVP funcional; se revisan al pulir UI o enriquecer fichas.

## Hecho en Ciclo 8 (funcional)

- [x] Completar/editar guardado incompleto desde Inicio.
- [x] Búsqueda: limpiar hits al cambiar filtros/modo + botón Limpiar.
- [x] Términos de Uso + Aviso de privacidad mínimos en login (checkbox).
- [x] RPC `get_site_coords` para editar con mapa prellenado.

## Ciclo 2 — Captura / guardados

- Google Places API pendiente (exige facturación). En MVP usamos **Geoapify** (autocomplete + reverse, sin tarjeta).
- Autocomplete de categorías: busca por nombre **y keywords** (nadar→piscina/río, caminar→sendero, tejo, plaza…).
- **Ubicación:** mapa OSM + Geoapify (`GEOAPIFY_API_KEY`, tope local `GEOAPIFY_DAILY_LIMIT=100`); fallback Nominatim si no hay key.
- Árbol ampliado (migración 10): deporte/tejo, plazas, bares/discotecas, termales, piscinas, etc.

## Ciclo 3 — Privacidad / duplicados

- Flujo “¿Es el mismo sitio?” funciona; revisar copy y fricción si usuarios se confunden.

## Ciclo 4 — Geofencing

- Warning de Flutter por `native_geofence` + KGP (`android.builtInKotlin=false` obligatorio mientras `app_links`/otros no migren). No bloquea; migrar cuando el ecosistema lo permita.
- Pedir ubicación “siempre” es sensible: copy y timing del permiso a mejorar.
- Revisión fina de batería / tiempos de sync de geofences pendiente.

## Ciclo 5 — Planes

- **“Marcar visitado” confunde** frente a “incluir en Maps” (checkbox). En pulido/Figma: UX más clara.
- Si una parada no tiene lat/lng, Maps no puede incluirla — avisar mejor.
- Compartir plan por link queda fuera (spec lo permite; no entregado).

## Ciclo 6 — Búsqueda

- Filtro de horario en UI es placeholder hasta fichas enriquecidas.
- Búsqueda de planes por título no incluida (solo sitios).
- Fallback local si falla RPC `search_sites` (aplicar SQL C6/C7/C8 en Supabase tras reset).

## Ciclo 7 — Trazabilidad / moderación

- Transporte usado al marcar “visitado” no se persiste aún.
- Reportar sitio/perfil/evento: tabla lista; UI MVP solo fotos.
- Admin aún no elimina la foto del storage al “actioned”.

## Transversal / diseño

- **Figma:** aplicado tema dark + shell (Inicio / Explorar / + / Planes / Rutas) según Make `HhANLxoeQuTr5YJZnTAfG7`. Refinar pixel-perfect por pantalla en iteraciones.
- Errores al usuario: solo negocio o “Error en la app…” (regla 8).
- Horarios de apertura: hook listo (`PlanHoursPolicy`); filtrado real cuando existan fichas (§8.2).
- Textos legales MVP son borrador; versión formal revisada por abogado pendiente.
