# ADR 0009 — Ciclo 8: pulido funcional y cierre Fase 1

## Contexto

Prompt Ciclo 8: textos legales mínimos, aplicar observaciones, MVP navegable E2E.  
**Fuera de alcance explícito en esta pasada:** rediseño Figma / UI visual (queda para cuando se pida).

## Decisiones

1. **Búsqueda:** al cambiar modo (simple/avanzada), filtros o pulsar Limpiar, se invalidan resultados previos (`_hits` vacío + `_searched` false) y cada Buscar parte de lista limpia. Evita el bug de “siguen saliendo los mismos datos”.
2. **Editar / completar guardado:** desde Inicio, tap (o icono editar si incompleto) abre `SavePlacePage` con `existingSaveId`. `updateSave` actualiza sitio + categorías + `user_saves`; coords vía `get_site_coords` (migración 09).
3. **Legales mínimos:** checkbox en login + pantallas de Términos y Aviso de privacidad (textos MVP en app). Aceptación local en `SharedPreferences` (`legal_accepted_v1`). No son documentos notariales; quedan marcados como borrador funcional.
4. **Rendimiento:** sin cambios estructurales; listados ya en `ListView` / refresh. Deuda de batería/geofencing queda en observaciones.
5. **Observaciones:** se cierran las de filtro de búsqueda y edición de borrador; el resto se deja explícito para pulido / Figma / Places API.

## Migración

`20260808000009_ciclo8_get_site_coords.sql` — RPC `get_site_coords` para prellenar mapa al editar.

## Fuera de alcance (confirmado)

Figma, Places API, compartir plan por link, filtro horario real, persistir transporte al visitar, borrar foto en storage al actioned del reporte.
