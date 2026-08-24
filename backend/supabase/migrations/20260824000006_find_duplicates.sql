-- Anti-dupe: el chequeo anterior casi no encontraba coincidencias.
-- 1) Solo públicos (no veías tus propios privados).
-- 2) Con lat/lng NO usaba ciudad+nombre (el catálogo "Plaza / parque…"
--    no matchea "Plaza de Bolívar" cerca del centroide).
-- 3) No comparaba google_place_id.

drop function if exists public.find_possible_duplicate_sites(
  text, double precision, double precision, text, double precision, uuid
);

create or replace function public.find_possible_duplicate_sites(
  p_name text,
  p_lat double precision default null,
  p_lng double precision default null,
  p_city text default null,
  p_radius_m double precision default 250,
  p_exclude_site_id uuid default null,
  p_google_place_id text default null
)
returns table(
  site_id uuid,
  site_name text,
  city text,
  distance_m double precision,
  name_score real,
  contributor_count bigint
)
language sql
stable
set search_path to 'public'
as $function$
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
    case
      when nullif(trim(p_name), '') is null then 0::real
      else greatest(
        similarity(lower(s.name), lower(trim(p_name))),
        word_similarity(lower(trim(p_name)), lower(s.name))
      )
    end as score,
    (
      select count(*) from public.site_contributors sc where sc.site_id = s.id
    ) + 1
  from public.sites s
  where s.is_physical_place = true
    and (p_exclude_site_id is null or s.id <> p_exclude_site_id)
    and (
      (s.is_public = true and s.status = 'complete')
      or s.created_by = auth.uid()
    )
    and (
      -- Mismo Place ID de Google.
      (
        nullif(trim(coalesce(p_google_place_id, '')), '') is not null
        and s.google_place_id is not null
        and s.google_place_id = trim(p_google_place_id)
      )
      -- Mismo pin (~250 m): el nombre puede ser distinto.
      or (
        p_lat is not null and p_lng is not null and s.location is not null
        and st_dwithin(
          s.location,
          st_setsrid(st_makepoint(p_lng, p_lat), 4326)::geography,
          greatest(coalesce(p_radius_m, 250), 80)
        )
      )
      -- Hasta 2.5 km si el nombre se parece (catálogo vs ficha de Maps).
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
      -- Misma ciudad + nombre parecido (aunque ya tengas coords).
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

grant execute on function public.find_possible_duplicate_sites(
  text, double precision, double precision, text, double precision, uuid, text
) to anon, authenticated, service_role;

notify pgrst, 'reload schema';
