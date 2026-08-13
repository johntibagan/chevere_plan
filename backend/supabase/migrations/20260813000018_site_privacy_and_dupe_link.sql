-- Privacidad + anti-duplicados: blockers al pasar a privado; exclude en búsqueda de dupes.

drop function if exists public.find_possible_duplicate_sites(
  text, double precision, double precision, text, double precision
);

-- 1) Duplicados: permitir excluir el sitio que se está editando
create or replace function public.find_possible_duplicate_sites(
  p_name text,
  p_lat double precision default null,
  p_lng double precision default null,
  p_city text default null,
  p_radius_m double precision default 100,
  p_exclude_site_id uuid default null
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
      and (p_exclude_site_id is null or s.id <> p_exclude_site_id)
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
    ) + 1
  from candidates c
  order by c.score desc nulls last, c.dist_m asc nulls last
  limit 10;
$$;

grant execute on function public.find_possible_duplicate_sites(
  text, double precision, double precision, text, double precision, uuid
) to authenticated;

-- 2) ¿Se puede pasar a privado? (refs de otros usuarios o catálogo)
create or replace function public.site_privacy_blockers(p_site_id uuid)
returns json
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_other_saves bigint := 0;
  v_other_contrib bigint := 0;
  v_other_plans bigint := 0;
  v_catalog boolean := false;
  v_allowed boolean := false;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select
    public.is_staff()
    or s.created_by = uid
    or exists (
      select 1 from public.user_saves us
      where us.site_id = s.id and us.user_id = uid
    )
  into v_allowed
  from public.sites s
  where s.id = p_site_id;

  if not coalesce(v_allowed, false) then
    raise exception 'forbidden';
  end if;

  select (s.external_id is not null and length(trim(s.external_id)) > 0)
  into v_catalog
  from public.sites s
  where s.id = p_site_id;

  select count(*) into v_other_saves
  from public.user_saves us
  where us.site_id = p_site_id and us.user_id <> uid;

  select count(*) into v_other_contrib
  from public.site_contributors sc
  where sc.site_id = p_site_id and sc.user_id <> uid;

  select count(*) into v_other_plans
  from public.plan_stops ps
  join public.plans p on p.id = ps.plan_id
  where ps.site_id = p_site_id and p.user_id <> uid;

  return json_build_object(
    'is_catalog', coalesce(v_catalog, false),
    'other_saves', v_other_saves,
    'other_contributors', v_other_contrib,
    'other_plan_stops', v_other_plans,
    'blocked',
      coalesce(v_catalog, false)
      or v_other_saves > 0
      or v_other_contrib > 0
      or v_other_plans > 0
  );
end;
$$;

grant execute on function public.site_privacy_blockers(uuid) to authenticated;

-- 3) Vincular mi guardado a un sitio público existente (anti-dupe al editar/crear)
create or replace function public.link_save_to_existing_site(
  p_save_id uuid,
  p_existing_site_id uuid
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_old_site uuid;
  v_existing_public boolean;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select us.site_id into v_old_site
  from public.user_saves us
  where us.id = p_save_id and us.user_id = uid;

  if v_old_site is null then
    raise exception 'save not found';
  end if;

  select s.is_public into v_existing_public
  from public.sites s
  where s.id = p_existing_site_id;

  if v_existing_public is distinct from true then
    raise exception 'existing site must be public';
  end if;

  if v_old_site = p_existing_site_id then
    return p_existing_site_id;
  end if;

  insert into public.site_contributors (site_id, user_id)
  values (p_existing_site_id, uid)
  on conflict do nothing;

  -- Mis planes: mover paradas al sitio público (si ya existe la parada, quitar la vieja)
  update public.plan_stops ps
  set site_id = p_existing_site_id
  from public.plans p
  where ps.plan_id = p.id
    and p.user_id = uid
    and ps.site_id = v_old_site
    and not exists (
      select 1 from public.plan_stops x
      where x.plan_id = ps.plan_id and x.site_id = p_existing_site_id
    );

  delete from public.plan_stops ps
  using public.plans p
  where ps.plan_id = p.id
    and p.user_id = uid
    and ps.site_id = v_old_site;

  update public.user_saves
  set
    site_id = p_existing_site_id,
    is_possible_duplicate = true,
    possible_duplicate_of_site_id = p_existing_site_id,
    updated_at = now()
  where id = p_save_id and user_id = uid;

  -- Si el sitio viejo era mío y nadie más lo usa, borrarlo
  if exists (
    select 1 from public.sites s
    where s.id = v_old_site and s.created_by = uid
  )
  and not exists (select 1 from public.user_saves where site_id = v_old_site)
  and not exists (select 1 from public.site_contributors where site_id = v_old_site)
  and not exists (select 1 from public.plan_stops where site_id = v_old_site)
  then
    delete from public.sites where id = v_old_site and created_by = uid;
  end if;

  return p_existing_site_id;
end;
$$;

grant execute on function public.link_save_to_existing_site(uuid, uuid) to authenticated;

-- Borrar sitio propio huérfano (tras link); RLS no tenía DELETE en sites
drop policy if exists sites_delete_own_unused on public.sites;
create policy sites_delete_own_unused on public.sites
  for delete to authenticated
  using (
    created_by = auth.uid()
    or public.is_staff()
  );
