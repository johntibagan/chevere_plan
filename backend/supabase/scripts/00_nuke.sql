-- =============================================================================
-- NUKE: borra schema public + fotos del bucket. Lo usa reset_all.py
-- Conserva Auth (el login de Google) para poder dejar root.
-- =============================================================================

drop trigger if exists on_auth_user_created on auth.users;

do $$
begin
  if exists (
    select 1 from storage.buckets where id = 'site-photos'
  ) then
    perform set_config('storage.allow_delete_query', 'true', true);
    perform set_config('storage.can_delete', 'true', true);
    delete from storage.objects where bucket_id = 'site-photos';
  end if;
end
$$;

drop schema if exists public cascade;
create schema public;

grant usage on schema public to postgres, anon, authenticated, service_role;
grant all on schema public to postgres, service_role;
grant all on schema public to anon, authenticated;

alter default privileges for role postgres in schema public
  grant all on tables to postgres, anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  grant all on functions to postgres, anon, authenticated, service_role;
alter default privileges for role postgres in schema public
  grant all on sequences to postgres, anon, authenticated, service_role;
