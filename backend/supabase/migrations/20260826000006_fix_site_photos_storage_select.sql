-- Fix: en RLS de storage.objects, bare `name` dentro del EXISTS se resolvía
-- como sites.name (columna del join), no como storage.objects.name.
-- Resultado: solo el dueño del path (o staff) podía createSignedUrl; en un
-- sitio público otras cuentas veían la fila de site_photos pero la imagen
-- no cargaba.

drop policy if exists site_photos_storage_select on storage.objects;

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
    )
  );
