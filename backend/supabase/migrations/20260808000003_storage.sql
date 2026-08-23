-- Storage: bucket privado site-photos. Path {user_id}/{site_id}/{filename}.
-- Lectura: dueño del path, staff, o foto de un sitio público/propio.

insert into storage.buckets (id, name, public)
values ('site-photos', 'site-photos', false)
on conflict (id) do nothing;

drop policy if exists site_photos_storage_select on storage.objects;
drop policy if exists site_photos_storage_insert on storage.objects;
drop policy if exists site_photos_storage_update on storage.objects;
drop policy if exists site_photos_storage_delete on storage.objects;

create policy site_photos_storage_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'site-photos'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_staff()
      or exists (
        select 1
        from public.site_photos sp
        join public.sites s on s.id = sp.site_id
        where sp.storage_path = name
          and (
            s.is_public
            or s.created_by = auth.uid()
            or public.is_staff()
          )
      )
    )
  );

create policy site_photos_storage_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'site-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy site_photos_storage_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'site-photos'
    and (storage.foldername(name))[1] = auth.uid()::text
  );

create policy site_photos_storage_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'site-photos'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_staff()
    )
  );
