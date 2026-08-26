-- Proximidad: ciudad, departamento y portada para notificaciones enriquecidas.

drop function if exists public.list_proximity_sites(boolean);

create or replace function public.list_proximity_sites(
  p_include_public boolean default false
)
returns table(
  site_id uuid,
  name text,
  lat double precision,
  lng double precision,
  is_own boolean,
  city text,
  department text,
  cover_storage_path text
)
language sql
stable
security definer
set search_path to 'public'
as $function$
  with own_sites as (
    select
      s.id as site_id,
      s.name,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      true as is_own,
      s.city,
      s.department,
      public.site_cover_storage_path(s.id) as cover_storage_path
    from public.user_saves us
    join public.sites s on s.id = us.site_id
    where us.user_id = auth.uid()
      and us.status = 'complete'
      and s.location is not null
  ),
  public_sites as (
    select
      s.id as site_id,
      s.name,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      false as is_own,
      s.city,
      s.department,
      public.site_cover_storage_path(s.id) as cover_storage_path
    from public.sites s
    where p_include_public = true
      and s.is_public = true
      and s.location is not null
      and s.id not in (select own_sites.site_id from own_sites)
  )
  select * from own_sites
  union all
  select * from public_sites;
$function$;

grant execute on function public.list_proximity_sites(boolean)
  to anon, authenticated, service_role;

notify pgrst, 'reload schema';
