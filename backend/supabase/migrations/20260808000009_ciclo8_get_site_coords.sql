-- Ciclo 8: leer lat/lng de un sitio para edición (sin exponer WKT al cliente).
create or replace function public.get_site_coords(p_site_id uuid)
returns table (lat double precision, lng double precision)
language sql
stable
security definer
set search_path = public
as $$
  select
    st_y(location::geometry) as lat,
    st_x(location::geometry) as lng
  from public.sites
  where id = p_site_id
    and location is not null
    and (
      created_by = auth.uid()
      or is_public = true
      or public.is_staff()
      or exists (
        select 1 from public.user_saves us
        where us.site_id = p_site_id and us.user_id = auth.uid()
      )
    );
$$;

grant execute on function public.get_site_coords(uuid) to authenticated;
