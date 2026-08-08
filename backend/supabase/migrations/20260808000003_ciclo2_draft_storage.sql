-- Ciclo 2: recordatorios de borrador + policies Storage site-photos

alter table public.user_saves
  add column if not exists draft_remind_at timestamptz,
  add column if not exists last_draft_reminder_at timestamptz;

-- Storage: bucket esperado `site-photos` (creado en setup). Policies para usuarios autenticados.
insert into storage.buckets (id, name, public)
values ('site-photos', 'site-photos', false)
on conflict (id) do nothing;

drop policy if exists site_photos_storage_select on storage.objects;
drop policy if exists site_photos_storage_insert on storage.objects;
drop policy if exists site_photos_storage_update on storage.objects;
drop policy if exists site_photos_storage_delete on storage.objects;

-- Path convention: {user_id}/{site_id}/{filename}
create policy site_photos_storage_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'site-photos'
    and (
      (storage.foldername(name))[1] = auth.uid()::text
      or public.is_staff()
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
