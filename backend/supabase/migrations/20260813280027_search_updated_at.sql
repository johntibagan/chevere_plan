-- Explorar: fecha del sitio + is_linked (tags sin texto Público/Privado redundante).

drop function if exists public.search_sites(
  text, uuid, text, double precision, double precision, double precision,
  text, numeric, numeric, boolean
);

create or replace function public.search_sites(
  p_query text default null,
  p_category_id uuid default null,
  p_location_query text default null,
  p_lat double precision default null,
  p_lng double precision default null,
  p_radius_km double precision default null,
  p_transport_group text default null,
  p_budget_min numeric default null,
  p_budget_max numeric default null,
  p_include_public boolean default false
)
returns table (
  site_id uuid,
  name text,
  city text,
  department text,
  lat double precision,
  lng double precision,
  estimated_price_amount numeric,
  currency_code text,
  is_own boolean,
  is_public boolean,
  is_catalog boolean,
  is_linked boolean,
  updated_at timestamptz,
  distance_km double precision
)
language plpgsql
stable
security definer
set search_path = public
as $$
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
      end as sdistance_km
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
    b.slat,
    b.slng,
    b.sprice,
    b.scurrency,
    b.sown,
    b.spublic,
    b.scatalog,
    b.slinked,
    b.supdated,
    b.sdistance_km
  from base b
  order by
    case when b.sdistance_km is null then 1 else 0 end,
    b.sdistance_km nulls last,
    b.sname
  limit 100;
end;
$$;

grant execute on function public.search_sites(
  text, uuid, text, double precision, double precision, double precision,
  text, numeric, numeric, boolean
) to authenticated;
