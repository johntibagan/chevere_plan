-- Anti-duplicados: department + is_public real del sitio (para UI).
DROP FUNCTION IF EXISTS public.find_possible_duplicate_sites(
  text, double precision, double precision, text, double precision, uuid, text
);

CREATE OR REPLACE FUNCTION public.find_possible_duplicate_sites(p_name text, p_lat double precision DEFAULT NULL::double precision, p_lng double precision DEFAULT NULL::double precision, p_city text DEFAULT NULL::text, p_radius_m double precision DEFAULT 250, p_exclude_site_id uuid DEFAULT NULL::uuid, p_google_place_id text DEFAULT NULL::text)
 RETURNS TABLE(
   site_id uuid,
   site_name text,
   city text,
   department text,
   address_line text,
   distance_m double precision,
   name_score real,
   contributor_count bigint,
   is_public boolean
 )
 LANGUAGE sql
 STABLE
 SET search_path TO 'public'
AS $function$
  select
    s.id,
    s.name,
    s.city,
    s.department,
    s.address_line,
    case
      when p_lat is not null and p_lng is not null and s.location is not null then
        st_distance(
          s.location,
          st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography
        )
      else null
    end as dist_m,
    case
      when nullif(trim(p_name), '') is null then 0::real
      else greatest(
        similarity(lower(s.name), lower(trim(p_name))),
        word_similarity(lower(trim(p_name)), lower(s.name))
      )
    end as score,
    (
      select count(*) from public.site_contributors sc where sc.site_id = s.id
    ) + 1,
    s.is_public
  from public.sites s
  where s.is_physical_place = true
    and (p_exclude_site_id is null or s.id <> p_exclude_site_id)
    and (
      (s.is_public = true and s.status = 'complete')
      or (
        s.created_by = auth.uid()
        and s.status = 'complete'
        and s.location is not null
      )
    )
    and (
      (
        nullif(trim(coalesce(p_google_place_id, '')), '') is not null
        and s.google_place_id is not null
        and s.google_place_id = trim(p_google_place_id)
      )
      or (
        p_lat is not null and p_lng is not null and s.location is not null
        and st_dwithin(
          s.location,
          st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
          greatest(coalesce(p_radius_m, 250), 80)
        )
      )
      or (
        p_lat is not null and p_lng is not null and s.location is not null
        and nullif(trim(p_name), '') is not null
        and st_dwithin(
          s.location,
          st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
          2500
        )
        and greatest(
          similarity(lower(s.name), lower(trim(p_name))),
          word_similarity(lower(trim(p_name)), lower(s.name))
        ) >= 0.28
      )
      or (
        nullif(trim(coalesce(p_city, '')), '') is not null
        and s.city ilike trim(p_city)
        and nullif(trim(p_name), '') is not null
        and greatest(
          similarity(lower(s.name), lower(trim(p_name))),
          word_similarity(lower(trim(p_name)), lower(s.name))
        ) >= 0.32
      )
    )
  order by
    score desc nulls last,
    dist_m asc nulls last
  limit 10;
$function$;

GRANT EXECUTE ON FUNCTION public.find_possible_duplicate_sites(
  text, double precision, double precision, text, double precision, uuid, text
) TO anon, authenticated, service_role;
