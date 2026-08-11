# Backend Supabase — reset y aplicación ordenada

## 0. Vaciar datos de la app (opcional)

Si quieres **borrar el contenido** (sitios, planes, reportes, fotos en Storage) **sin** tocar el schema ni volver a correr migraciones:

1. SQL Editor → pega y ejecuta [`scripts/00_reset_public.sql`](supabase/scripts/00_reset_public.sql)

Ese reset **no** borra usuarios de Auth (`auth.users`), ni `profiles`, ni el seed de `categories` / `transport_types`. Tampoco borra tablas, funciones ni policies.

Si el schema aún no está aplicado, salta al paso 1 y aplica las migraciones **en este orden**.

## 1. Migraciones (SQL Editor, una tras otra)

| # | Archivo | Qué hace |
|---|---------|----------|
| 1 | [`migrations/20260808000001_ciclo1_schema.sql`](supabase/migrations/20260808000001_ciclo1_schema.sql) | PostGIS, perfiles/roles, categorías, transporte, sitios, RLS |
| 2 | [`migrations/20260808000002_ciclo1_seed.sql`](supabase/migrations/20260808000002_ciclo1_seed.sql) | Seed categorías §4.1 + transporte §7.2 |
| 3 | [`migrations/20260808000003_ciclo2_draft_storage.sql`](supabase/migrations/20260808000003_ciclo2_draft_storage.sql) | Borrador + bucket `site-photos` |
| 4 | [`migrations/20260808000004_ciclo3_duplicates.sql`](supabase/migrations/20260808000004_ciclo3_duplicates.sql) | Anti-duplicados, contributors, `set_site_location` |
| 5 | [`migrations/20260808000005_ciclo4_proximity.sql`](supabase/migrations/20260808000005_ciclo4_proximity.sql) | Preferencias proximidad + `list_proximity_sites` |
| 6 | [`migrations/20260808000006_ciclo5_plans.sql`](supabase/migrations/20260808000006_ciclo5_plans.sql) | Planes / paradas + `list_plan_candidates` |
| 7 | [`migrations/20260808000007_ciclo6_search.sql`](supabase/migrations/20260808000007_ciclo6_search.sql) | `search_sites` |
| 8 | [`migrations/20260808000008_ciclo7_routes_reports.sql`](supabase/migrations/20260808000008_ciclo7_routes_reports.sql) | Mis rutas + `content_reports` |
| 9 | [`migrations/20260808000009_ciclo8_get_site_coords.sql`](supabase/migrations/20260808000009_ciclo8_get_site_coords.sql) | `get_site_coords` (editar guardado) |
| 10 | [`migrations/20260808000010_ciclo8_categories_keywords.sql`](supabase/migrations/20260808000010_ciclo8_categories_keywords.sql) | Keywords + categorías ampliadas |
| 11 | [`migrations/20260808000011_site_photos_storage_select.sql`](supabase/migrations/20260808000011_site_photos_storage_select.sql) | SELECT en storage `site-photos` (URLs firmadas) |
| 12 | [`migrations/20260808000012_site_social_links.sql`](supabase/migrations/20260808000012_site_social_links.sql) | Enlaces sociales / web por sitio + RLS |

> Los scripts son idempotentes en lo posible (`if not exists` / `create or replace`). Si uno falla a mitad, corrige y vuelve a pegar ese archivo.

## 2. Primer login en la app

Inicia sesión con Google en la app (así nace el usuario en `auth.users` + perfil).

## 3. Scripts post-login

| # | Archivo | Qué hace |
|---|---------|----------|
| 11 | [`scripts/01_bootstrap_root.sql`](supabase/scripts/01_bootstrap_root.sql) | Te convierte en `root` — **cambia el email** dentro del archivo |
| 12 | [`scripts/02_designate_admin.sql`](supabase/scripts/02_designate_admin.sql) | (Opcional) Promueve otro usuario a `admin` |

## Notas

- El trigger `prevent_role_escalation` ya permite cambios de rol desde el SQL Editor (`auth.uid()` null); no hace falta redefinir esa función en un `.md`.
- No dejes SQL “suelto” solo en Markdown: la fuente de verdad son `migrations/` y `scripts/`.
