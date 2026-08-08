# ADR 0002 — Esquema Ciclo 1 (categorías, roles, transporte, sitios)

## Contexto

Ciclo 1 (§4.1, §7.2, §11, §12, §16.3): modelo en PostgreSQL/PostGIS + panel admin mínimo.

## Decisiones

1. **`profiles`** ligado a `auth.users` (trigger `on_auth_user_created`). Rol: `user` | `admin` | `root`.
2. **Bootstrap de root:** tras el primer login, ejecutar SQL manual `update profiles set role = 'root' where id = '<uuid>'` (documentado). El root designa admins desde el panel (Ciclo 1: al menos ver rol; designar admin puede ser SQL o toggle simple).
3. **Categorías:** árbol con `parent_id` (adjacency list). Nombres en `name_i18n jsonb` (`{"es":"..."}`). `age_restricted` en nodos (ej. Bar/Vida nocturna). Soft-deactivate con `is_active` (no borrar para no romper sitios).
4. **Transporte:** tabla `transport_types` con `transport_group` (`particular` | `publico` | `otro`), `default_max_km` nullable (sin tope = null).
5. **Sitios / fotos / guardados:** tablas base listas; flujos de negocio en Ciclos 2–3. `sites.location` = `geography(Point,4326)`. Precios con `amount` + `currency_code` (default COP).
6. **RLS:** usuarios leen categorías/transporte activos; solo `admin`/`root` escriben parametrización. Perfil: cada uno lee/edita el propio; root/admin leen todos.
7. **Admin UI:** dentro de la app Flutter (como Figma Make `admin`), no web aparte. Ciclo 1 entrega tabs Categorías + Vehículos; Overview/Usuarios/Reportes del mock quedan fuera o como stub.

## Supuestos explícitos

- Marca en UI: **Chevere Plan** (no “Chebre” del prototipo).
- No se implementan aún topes de reportes, fichas enriquecidas ni pagos.
