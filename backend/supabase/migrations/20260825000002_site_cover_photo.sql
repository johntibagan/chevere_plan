-- Portada del sitio: foto de encabezado (miniaturas y ficha).
-- Si cover_photo_id es null, se usa la primera foto (sort_order, created_at).

alter table public.sites
  add column if not exists cover_photo_id uuid;

alter table public.sites
  drop constraint if exists sites_cover_photo_id_fkey;

alter table public.sites
  add constraint sites_cover_photo_id_fkey
  foreign key (cover_photo_id) references public.site_photos(id)
  on delete set null;

create index if not exists sites_cover_photo_id_idx
  on public.sites (cover_photo_id);

comment on column public.sites.cover_photo_id is
  'Foto de portada (encabezado y miniaturas). Null = primera del sitio.';

create or replace function public.enforce_site_cover_photo()
returns trigger
language plpgsql
as $$
begin
  if new.cover_photo_id is null then
    return new;
  end if;
  if not exists (
    select 1
    from public.site_photos p
    where p.id = new.cover_photo_id
      and p.site_id = new.id
  ) then
    raise exception 'cover photo must belong to the site';
  end if;
  return new;
end;
$$;

drop trigger if exists sites_cover_photo_trg on public.sites;
create trigger sites_cover_photo_trg
  before insert or update of cover_photo_id on public.sites
  for each row
  EXECUTE FUNCTION public.enforce_site_cover_photo();

create or replace function public.site_cover_storage_path(p_site_id uuid)
returns text
language sql
stable
security invoker
set search_path to 'public'
as $$
  select coalesce(
    (
      select ph.storage_path
      from public.site_photos ph
      join public.sites s on s.cover_photo_id = ph.id
      where s.id = p_site_id
    ),
    (
      select ph.storage_path
      from public.site_photos ph
      where ph.site_id = p_site_id
      order by ph.sort_order, ph.created_at
      limit 1
    )
  );
$$;

grant execute on function public.site_cover_storage_path(uuid)
  to anon, authenticated, service_role;

drop function if exists public.search_sites(
  text, uuid, text, double precision, double precision, double precision,
  text, numeric, numeric, boolean
);

create or replace function public.search_sites(
  p_query text default null::text,
  p_category_id uuid default null::uuid,
  p_location_query text default null::text,
  p_lat double precision default null::double precision,
  p_lng double precision default null::double precision,
  p_radius_km double precision default null::double precision,
  p_transport_group text default null::text,
  p_budget_min numeric default null::numeric,
  p_budget_max numeric default null::numeric,
  p_include_public boolean default false
)
returns table(
  site_id uuid,
  name text,
  city text,
  department text,
  address_line text,
  lat double precision,
  lng double precision,
  estimated_price_amount numeric,
  currency_code text,
  is_own boolean,
  is_public boolean,
  is_catalog boolean,
  is_linked boolean,
  updated_at timestamp with time zone,
  distance_km double precision,
  category_names text[],
  cover_storage_path text
)
language plpgsql
stable
security definer
set search_path to 'public'
as $function$
declare
  v_is_minor boolean := false;
  v_max_km numeric;
  v_group public.transport_group;
begin
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid()
      and p.birth_date is not null
      and p.birth_date > (current_date - interval '18 years')
  ) into v_is_minor;

  if p_transport_group is not null and trim(p_transport_group) <> '' then
    begin
      v_group := trim(p_transport_group)::public.transport_group;
    exception when others then
      v_group := null;
    end;

    if v_group is not null then
      select
        case when bool_or(t.default_max_km is null) then null
             else max(t.default_max_km)
        end
      into v_max_km
      from public.transport_types t
      where t.is_active
        and t.transport_group = v_group;
    end if;
  end if;

  return query
  with base as (
    select
      s.id as sid,
      s.name as sname,
      s.city as scity,
      s.department as sdepartment,
      s.address_line as saddress,
      st_y(s.location::geometry) as slat,
      st_x(s.location::geometry) as slng,
      s.estimated_price_amount as sprice,
      s.currency_code::text as scurrency,
      s.is_public as spublic,
      (s.external_id is not null and length(trim(s.external_id)) > 0) as scatalog,
      exists (
        select 1 from public.user_saves us
        where us.site_id = s.id
          and us.user_id = auth.uid()
          and us.status = 'complete'
      ) as sown,
      exists (
        select 1 from public.user_saves us
        where us.site_id = s.id
          and us.user_id = auth.uid()
          and us.is_possible_duplicate = true
      ) as slinked,
      s.updated_at as supdated,
      case
        when p_lat is not null and p_lng is not null and s.location is not null then
          st_distance(
            s.location,
            st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
          ) / 1000.0
        else null::double precision
      end as sdistance_km,
      (
        select array_agg(c.name_i18n->>'es' order by c.sort_order, c.name_i18n->>'es')
        from public.site_categories sc
        join public.categories c on c.id = sc.category_id
        where sc.site_id = s.id
      ) as scats,
      public.site_cover_storage_path(s.id) as scover
    from public.sites s
    where s.location is not null
      and s.status = 'complete'
      and (
        exists (
          select 1 from public.user_saves us
          where us.site_id = s.id
            and us.user_id = auth.uid()
            and us.status = 'complete'
        )
        or (p_include_public and s.is_public)
      )
      and (
        p_query is null or trim(p_query) = ''
        or s.name ilike '%' || trim(p_query) || '%'
        or coalesce(s.city, '') ilike '%' || trim(p_query) || '%'
        or coalesce(s.department, '') ilike '%' || trim(p_query) || '%'
      )
      and (
        p_location_query is null or trim(p_location_query) = ''
        or coalesce(s.city, '') ilike '%' || trim(p_location_query) || '%'
        or coalesce(s.department, '') ilike '%' || trim(p_location_query) || '%'
      )
      and (
        p_budget_min is null
        or s.estimated_price_amount is null
        or s.estimated_price_amount >= p_budget_min
      )
      and (
        p_budget_max is null
        or s.estimated_price_amount is null
        or s.estimated_price_amount <= p_budget_max
      )
      and (
        p_category_id is null
        or exists (
          select 1
          from public.site_categories sc
          join public.categories c on c.id = sc.category_id
          where sc.site_id = s.id
            and (
              c.id = p_category_id
              or c.parent_id = p_category_id
            )
        )
      )
      and (
        not v_is_minor
        or not exists (
          select 1
          from public.site_categories sc
          join public.categories c on c.id = sc.category_id
          where sc.site_id = s.id and c.age_restricted = true
        )
      )
      and (
        p_lat is null or p_lng is null or p_radius_km is null
        or st_dwithin(
          s.location,
          st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
          p_radius_km * 1000.0
        )
      )
      and (
        v_group is null
        or p_lat is null
        or p_lng is null
        or v_max_km is null
        or st_dwithin(
          s.location,
          st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
          v_max_km * 1000.0
        )
      )
  )
  select
    b.sid,
    b.sname,
    b.scity,
    b.sdepartment,
    b.saddress,
    b.slat,
    b.slng,
    b.sprice,
    b.scurrency,
    b.sown,
    b.spublic,
    b.scatalog,
    b.slinked,
    b.supdated,
    b.sdistance_km,
    b.scats,
    b.scover
  from base b
  order by
    case when b.sdistance_km is null then 1 else 0 end,
    b.sdistance_km nulls last,
    b.sname
  limit 100;
end;
$function$;

grant execute on function public.search_sites(
  text, uuid, text, double precision, double precision, double precision,
  text, numeric, numeric, boolean
) to anon, authenticated, service_role;

notify pgrst, 'reload schema';
