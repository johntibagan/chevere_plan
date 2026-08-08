-- Ciclo 4: preferencias de proximidad + RPC de sitios para geofencing

alter table public.profiles
  add column if not exists proximity_radius_m integer not null default 200,
  add column if not exists remind_public_sites boolean not null default false;

alter table public.profiles
  drop constraint if exists profiles_proximity_radius_m_check;

alter table public.profiles
  add constraint profiles_proximity_radius_m_check
  check (proximity_radius_m >= 100 and proximity_radius_m <= 2000);

create or replace function public.list_proximity_sites(p_include_public boolean default false)
returns table (
  site_id uuid,
  name text,
  lat double precision,
  lng double precision,
  is_own boolean
)
language sql
stable
security definer
set search_path = public
as $$
  with own_sites as (
    select
      s.id as site_id,
      s.name,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      true as is_own
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
      false as is_own
    from public.sites s
    where p_include_public = true
      and s.is_public = true
      and s.location is not null
      and s.id not in (select own_sites.site_id from own_sites)
  )
  select * from own_sites
  union all
  select * from public_sites;
$$;

grant execute on function public.list_proximity_sites(boolean) to authenticated;
