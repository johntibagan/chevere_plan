# ADR 0004 — Ciclo 3: privacidad, anti-duplicados, atribución

## Contexto

Especificación §5; prompt Ciclo 3. Privado por defecto ya en Ciclo 2.

## Decisiones

1. **Radio de duplicado:** 100 m (`ST_DWithin` sobre `geography`).
2. **Nombre:** extensión `pg_trgm`; umbral `similarity(lower(name), lower(input)) >= 0.35`, o igualdad normalizada. Sin coords: mismo criterio + `city` ILIKE.
3. **Confirmación manual:** diálogo “¿Es el mismo sitio?” → *Sí, es el mismo* | *Es uno nuevo*. Nunca fusionar solo.
4. **Si elige el mismo (y público):** el `user_save` apunta al `site_id` original; fila en `site_contributors` (“compartido también por”); `user_saves.is_possible_duplicate = true` con opción de descartar su guardado.
5. **Si elige uno nuevo:** se crea sitio propio como hasta ahora.
6. **Coords en guardado:** RPC `set_site_location(site_id, lng, lat)` para poblar PostGIS (el cliente no manda WKT crudo).

## Ciclo 2 — cierre

Entregable OK (share → borrador → lista). Aplazado: editar borrador in-app, Places API, autocomplete textual de categorías.
