-- Ciclo 3: anti-duplicados, contributors, set location RPC

create extension if not exists pg_trgm;

alter table public.user_saves
  add column if not exists is_possible_duplicate boolean not null default false,
  add column if not exists possible_duplicate_of_site_id uuid references public.sites (id) on delete set null;

create table if not exists public.site_contributors (
  site_id uuid not null references public.sites (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (site_id, user_id)
);

alter table public.site_contributors enable row level security;

drop policy if exists site_contributors_select on public.site_contributors;
create policy site_contributors_select on public.site_contributors
  for select to authenticated
  using (
    exists (
      select 1 from public.sites s
      where s.id = site_id and (s.is_public or s.created_by = auth.uid() or public.is_staff())
    )
  );

drop policy if exists site_contributors_insert on public.site_contributors;
create policy site_contributors_insert on public.site_contributors
  for insert to authenticated
  with check (user_id = auth.uid() or public.is_staff());

drop policy if exists site_contributors_delete on public.site_contributors;
create policy site_contributors_delete on public.site_contributors
  for delete to authenticated
  using (user_id = auth.uid() or public.is_staff());

-- Poblar geography desde lat/lng (cliente no envía WKT)
create or replace function public.set_site_location(
  p_site_id uuid,
  p_lng double precision,
  p_lat double precision
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    raise exception 'No autenticado';
  end if;
  update public.sites
  set location = st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
      updated_at = now()
  where id = p_site_id
    and (created_by = auth.uid() or public.is_staff());
end;
$$;

grant execute on function public.set_site_location(uuid, double precision, double precision) to authenticated;

-- Buscar posibles duplicados públicos
create or replace function public.find_possible_duplicate_sites(
  p_name text,
  p_lat double precision default null,
  p_lng double precision default null,
  p_city text default null,
  p_radius_m double precision default 100
)
returns table (
  site_id uuid,
  site_name text,
  city text,
  distance_m double precision,
  name_score real,
  contributor_count bigint
)
language sql
stable
security invoker
set search_path = public
as $$
  with candidates as (
    select
      s.id,
      s.name,
      s.city,
      case
        when p_lat is not null and p_lng is not null and s.location is not null then
          st_distance(
            s.location,
            st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
          )
        else null
      end as dist_m,
      similarity(lower(s.name), lower(p_name)) as score
    from public.sites s
    where s.is_public = true
      and s.is_physical_place = true
      and s.status = 'complete'
      and (
        (
          p_lat is not null and p_lng is not null and s.location is not null
          and st_dwithin(
            s.location,
            st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
            p_radius_m
          )
          and similarity(lower(s.name), lower(p_name)) >= 0.35
        )
        or (
          (p_lat is null or p_lng is null or s.location is null)
          and p_city is not null and length(trim(p_city)) > 0
          and s.city ilike trim(p_city)
          and similarity(lower(s.name), lower(p_name)) >= 0.45
        )
      )
  )
  select
    c.id,
    c.name,
    c.city,
    c.dist_m,
    c.score,
    (
      select count(*) from public.site_contributors sc where sc.site_id = c.id
    ) + 1 -- + creador implícito en conteo mínimo
  from candidates c
  order by c.score desc nulls last, c.dist_m asc nulls last
  limit 10;
$$;

grant execute on function public.find_possible_duplicate_sites(text, double precision, double precision, text, double precision) to authenticated;

-- Ver display_name de contribuidores de sitios públicos
drop policy if exists profiles_select_public_contributors on public.profiles;
create policy profiles_select_public_contributors on public.profiles
  for select to authenticated
  using (
    exists (
      select 1
      from public.site_contributors sc
      join public.sites s on s.id = sc.site_id
      where sc.user_id = profiles.id
        and s.is_public = true
    )
  );
