# ADR 0008 — Ciclo 7: Mis rutas + reportes de fotos

## Contexto

Especificación §7.6 y §9; prompt Ciclo 7.

## Decisiones

1. **Mis rutas:** RPC `list_my_route_history` sobre `plan_stops.visited_at` + plan/sitio. No tabla nueva de historial (los visitados del plan son la fuente).
2. **Transporte en historial:** no se guarda aún al marcar visitado; queda en observaciones para pulir.
3. **Reportes:** tabla `content_reports` (photo/site/profile/event). MVP UI: reportar **fotos**. Alarma admin = listado `open` desde el primer reporte (`list_open_content_reports`).
4. **Un reporte por usuario/target** (unique). Motivo texto corto opcional.
5. **ToS al subir foto:** ya en Ciclo 2 (`SavePlacePage`); se mantiene / refuerza copy §9.
6. **Admin:** pantalla/listado de reportes abiertos (marcar revisado/descartado).

## Fuera de alcance

Reportar sitios/perfiles/eventos en UI, strikes automáticos, eliminación de storage de fotos.
