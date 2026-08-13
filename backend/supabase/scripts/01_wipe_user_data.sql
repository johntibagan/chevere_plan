-- Wipe rápido: borra TODO lo creado por usuarios (planes, saves, fotos,
-- sitios sin external_id — incluidos los del root).
-- Conserva:
--   - DIVIPOLA: countries / departments / cities
--   - categorías + transporte
--   - sitios de carga masiva (sites.external_id IS NOT NULL)
--   - Auth + profiles (reset_all reasigna roots)

do $$
begin
  if exists (
    select 1 from storage.buckets where id = 'site-photos'
  ) then
    perform set_config('storage.allow_delete_query', 'true', true);
    perform set_config('storage.can_delete', 'true', true);
    delete from storage.objects where bucket_id = 'site-photos';
  end if;
end
$$;

do $$
begin
  if to_regclass('public.plan_stops') is not null then
    truncate table public.plan_stops restart identity cascade;
  end if;
  if to_regclass('public.plans') is not null then
    truncate table public.plans restart identity cascade;
  end if;
  if to_regclass('public.content_reports') is not null then
    truncate table public.content_reports restart identity cascade;
  end if;
  if to_regclass('public.user_saves') is not null then
    truncate table public.user_saves restart identity cascade;
  end if;
  if to_regclass('public.site_review_photos') is not null then
    truncate table public.site_review_photos restart identity cascade;
  end if;
  if to_regclass('public.site_reviews') is not null then
    truncate table public.site_reviews restart identity cascade;
  end if;

  -- Solo sitios de usuario (sin external_id). Catálogo masivo se conserva.
  if to_regclass('public.sites') is not null then
    if to_regclass('public.site_social_links') is not null then
      delete from public.site_social_links
      where site_id in (select id from public.sites where external_id is null);
    end if;
    if to_regclass('public.site_contributors') is not null then
      delete from public.site_contributors
      where site_id in (select id from public.sites where external_id is null);
    end if;
    if to_regclass('public.site_photos') is not null then
      delete from public.site_photos
      where site_id in (select id from public.sites where external_id is null);
    end if;
    if to_regclass('public.site_categories') is not null then
      delete from public.site_categories
      where site_id in (select id from public.sites where external_id is null);
    end if;
    delete from public.sites where external_id is null;
  end if;
end
$$;
