-- =============================================================================
-- RESET DE DATOS (solo filas) — no toca estructura
-- =============================================================================
-- Si quieres schema + datos desde cero, usa:  python backend/reset_all.py --yes
--
-- Vacía el contenido de la app (sitios, planes, etc.) SIN dropear tablas.
-- Conserva tablas, funciones, triggers, enums, RLS, bucket y policies.
-- NO hace falta volver a ejecutar las migraciones.
--
-- Borra: sitios y relacionados, planes, reportes, fotos en Storage.
-- Conserva: categories, transport_types (seed), countries/departments/cities
--           (DIVIPOLA), profiles (roles / prefs), auth.users, bucket site-photos.
--
-- Después (si hace falta root de nuevo): scripts/01_bootstrap_root.sql
-- =============================================================================

-- Fotos en Storage (el bucket y las policies se quedan).
select set_config('storage.allow_delete_query', 'true', true);
select set_config('storage.can_delete', 'true', true);
delete from storage.objects where bucket_id = 'site-photos';

-- Contenido de la app (orden libre: truncate multi-tabla respeta FKs entre ellas)
truncate table
  public.site_social_links,
  public.content_reports,
  public.plan_stops,
  public.plans,
  public.site_contributors,
  public.user_saves,
  public.site_photos,
  public.site_categories,
  public.sites
restart identity cascade;
