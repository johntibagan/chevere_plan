# ADR 0007 — Ciclo 6: búsqueda de sitios

## Contexto

Especificación §7.5; prompt Ciclo 6. Búsqueda general y avanzada sobre sitios (propios y públicos opcionales).

## Decisiones

1. **Ámbito:** búsqueda de **sitios** (nombre, ciudad, departamento, categoría).
2. **General:** un campo texto → `ILIKE` en `sites.name`, `city`, `department`.
3. **Avanzada (combinable):**
   - `category_id` (sitio con esa categoría o hija)
   - ubicación texto (ciudad/depto) **o** radio km desde lat/lng
   - `transport_group`: solo con lat/lng; distancia ≤ max km del grupo (si algún medio del grupo no tiene tope, no se corta por distancia)
   - presupuesto min/max sobre `estimated_price_amount` (null pasa)
   - `include_public`
   - horario: **no filtra** (mismo hook C5); UI con aviso
4. **RPC** `search_sites(...)` security definer.
5. **Menores:** si `profiles.birth_date` implica < 18, excluir sitios con categoría `age_restricted`.

## Fuera de alcance

Ficha pública enriquecida, ranking, Places API.
