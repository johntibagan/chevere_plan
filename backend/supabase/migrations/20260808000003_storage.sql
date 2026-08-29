-- Storage: bucket privado site-photos + bucket público beta-apks.
-- Sitio: {user_id}/{site_id}/{filename}. Reseña sitio: {user_id}/reviews/{review_id}/…
-- Reseña plan: {user_id}/plan-reviews/{review_id}/…
-- Lectura: dueño del path, staff, foto de sitio público/propio, o foto de
-- reseña pública (en sitio visible).

insert into storage.buckets (id, name, public)
values ('site-photos', 'site-photos', false)
on conflict (id) do nothing;

-- APKs de prueba cerrada: público (solo quien tenga el link), 200 MiB.
-- Subida solo con service_role: sin policies de insert para anon/authenticated.
insert into storage.buckets (id, name, public, file_size_limit)
values ('beta-apks', 'beta-apks', true, 209715200)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit;

drop policy if exists site_photos_storage_select on storage.objects;
drop policy if exists site_photos_storage_insert on storage.objects;
drop policy if exists site_photos_storage_update on storage.objects;
drop policy if exists site_photos_storage_delete on storage.objects;

create policy site_photos_storage_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'site-photos'
    and (
      (storage.foldername(objects.name))[1] = auth.uid()::text
      or public.is_staff()
      or exists (
        select 1
        from public.site_photos sp
        join public.sites s on s.id = sp.site_id
        where sp.storage_path = objects.name
          and (
            s.is_public
            or s.created_by = auth.uid()
            or public.is_staff()
          )
      )
      or exists (
        select 1
        from public.site_review_photos rp
        join public.site_reviews r on r.id = rp.review_id
        join public.sites s on s.id = r.site_id
        where rp.storage_path = objects.name
          and (
            r.user_id = auth.uid()
            or (
              r.is_public
              and (
                s.is_public
                or s.created_by = auth.uid()
                or public.is_staff()
              )
            )
          )
      )
      or exists (
        select 1
        from public.plan_review_photos rp
        join public.plan_reviews r on r.id = rp.review_id
        join public.plans p on p.id = r.plan_id
        where rp.storage_path = objects.name
          and (
            p.user_id = auth.uid()
            or public.is_staff()
          )
      )
    )
  );

create policy site_photos_storage_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'site-photos'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  );

create policy site_photos_storage_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'site-photos'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  );

create policy site_photos_storage_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'site-photos'
    and (
      (storage.foldername(objects.name))[1] = auth.uid()::text
      or public.is_staff()
    )
  );

-- Avatares de perfil: públicos, path {user_id}/avatar.ext (máx. 5 MiB).
insert into storage.buckets (id, name, public, file_size_limit)
values ('avatars', 'avatars', true, 5242880)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit;

drop policy if exists avatars_storage_select on storage.objects;
drop policy if exists avatars_storage_insert on storage.objects;
drop policy if exists avatars_storage_update on storage.objects;
drop policy if exists avatars_storage_delete on storage.objects;

create policy avatars_storage_select on storage.objects
  for select to public
  using (bucket_id = 'avatars');

create policy avatars_storage_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  );

create policy avatars_storage_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  );

create policy avatars_storage_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  );
