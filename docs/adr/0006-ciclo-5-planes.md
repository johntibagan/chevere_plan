# ADR 0006 — Ciclo 5: planes inteligentes

## Contexto

Especificación §7.1–7.4; prompt Ciclo 5. Armar plan por ubicación, ordenar, transporte, exportar a Maps.

## Decisiones

1. **Match ubicación:** texto de ciudad **o** departamento (`ILIKE` sobre `sites.city` / `sites.department`).
2. **Punto de inicio:** lat/lng opcionales (GPS actual o manual); se usan para vecino más cercano y origen de Maps.
3. **Horarios:** no filtrar en C5. Hook/stub `PlanHoursPolicy.isOpenInWindow` siempre `true` hasta fichas enriquecidas (§8.2). Sitios sin horario se incluyen.
4. **Presupuesto:** tope opcional por sitio (`estimated_price_amount`); null pasa el filtro. Override por stop en `plan_stops`.
5. **Algoritmo:** vecino más cercano (Haversine) desde el inicio; máx. 10 paradas.
6. **Transporte:** `transport_types.default_max_km` + `profiles.transport_max_km` jsonb por slug; si distancia entra en varios rangos, se muestran todos.
7. **Persistencia:** `plans` + `plan_stops` (orden, `visited_at`, estimado).
8. **Maps:** deep link `maps/dir` solo con paradas no visitadas; origen = GPS/inicio.

## Fuera de alcance

Compartir plan por link, §7.5 búsqueda, §7.6 historial, tarifas de transporte público.
