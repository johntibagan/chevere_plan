-- =============================================================================
-- RESET TOTAL del schema public (+ policies Storage de site-photos)
-- =============================================================================
-- Borra tablas, vistas, funciones, triggers, tipos y enums de public.
-- NO borra auth.users (sesiones Google). SÍ borra profiles y datos de la app.
--
-- Orden después:
--   1) migrations 20260808000001 … 000008 (ver backend/README.md)
--   2) login en la app
--   3) scripts/01_bootstrap_root.sql
-- =============================================================================

-- Policies del bucket de fotos de la app
drop policy if exists site_photos_storage_select on storage.objects;
drop policy if exists site_photos_storage_insert on storage.objects;
drop policy if exists site_photos_storage_update on storage.objects;
drop policy if exists site_photos_storage_delete on storage.objects;

-- (Opcional) borrar también archivos del bucket:
-- delete from storage.objects where bucket_id = 'site-photos';
-- delete from storage.buckets where id = 'site-photos';

drop schema if exists public cascade;
create schema public;
comment on schema public is 'standard public schema';

-- Grants mínimos para que Supabase/PostgREST vuelvan a ver public
grant usage on schema public to postgres, anon, authenticated, service_role;
grant all on schema public to postgres, service_role;

alter default privileges for role postgres in schema public
  grant all on tables to postgres, anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  grant all on sequences to postgres, anon, authenticated, service_role;

alter default privileges for role postgres in schema public
  grant all on functions to postgres, anon, authenticated, service_role;

-- Extensiones las vuelve a asegurar la migración 01 (postgis, pgcrypto).
-- Si al correr la 01 falla error de PostGIS: Dashboard → Database → Extensions → PostGIS ON.
