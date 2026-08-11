-- Fotos: quien puede ver la fila en site_photos también puede leer el objeto en Storage.
-- (Antes solo el dueño del path / staff; getPublicUrl fallaba con bucket privado.)

drop policy if exists site_photos_storage_select on storage.objects;

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
