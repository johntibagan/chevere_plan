-- Fusionar Piscilago duplicado (creación usuario) → catálogo DIVIPOLA.
-- Origen (user): 355a29d8-52e5-49c1-912b-2122b92af3ce
-- Destino (catálogo): c1d7aac2-5a4b-48d6-8bf5-6b754bfd6eeb

do $$
declare
  src uuid := '355a29d8-52e5-49c1-912b-2122b92af3ce';
  dst uuid := 'c1d7aac2-5a4b-48d6-8bf5-6b754bfd6eeb';
  v_src_name text;
begin
  if not exists (select 1 from public.sites where id = src) then
    raise notice 'merge skip: src missing';
    return;
  end if;
  if not exists (select 1 from public.sites where id = dst and external_id is not null) then
    raise notice 'merge skip: dst catalog missing';
    return;
  end if;

  select name into v_src_name from public.sites where id = src;

  -- Guardados: mover; si ya hay fila dst, borrar la de src
  delete from public.user_saves us
  where us.site_id = src
    and exists (
      select 1 from public.user_saves x
      where x.user_id = us.user_id and x.site_id = dst
    );
  update public.user_saves set site_id = dst where site_id = src;

  -- Reseñas
  update public.site_reviews set site_id = dst where site_id = src;

  -- Contributors
  insert into public.site_contributors (site_id, user_id, created_at)
  select dst, sc.user_id, sc.created_at
  from public.site_contributors sc
  where sc.site_id = src
  on conflict do nothing;
  delete from public.site_contributors where site_id = src;

  -- Fotos de galería
  if to_regclass('public.site_photos') is not null then
    update public.site_photos set site_id = dst where site_id = src;
  end if;

  -- Enlaces sociales
  if to_regclass('public.site_social_links') is not null then
    update public.site_social_links set site_id = dst where site_id = src;
  end if;

  -- Paradas de plan
  if to_regclass('public.plan_stops') is not null then
    update public.plan_stops ps
    set site_id = dst
    where ps.site_id = src
      and not exists (
        select 1 from public.plan_stops x
        where x.plan_id = ps.plan_id and x.site_id = dst
      );
    delete from public.plan_stops where site_id = src;
  end if;

  -- Nombre más descriptivo del Maps en el catálogo
  if v_src_name is not null and length(trim(v_src_name)) > 0 then
    update public.sites
    set name = v_src_name, updated_at = now()
    where id = dst;
  end if;

  delete from public.sites where id = src;
end;
$$;
