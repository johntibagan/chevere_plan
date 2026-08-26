-- Bucket público para APKs de prueba cerrada (solo quien tenga el link de Notion).
-- Subida solo con service_role (sin policies de insert para anon/authenticated).

insert into storage.buckets (id, name, public, file_size_limit)
values (
  'beta-apks',
  'beta-apks',
  true,
  209715200 -- 200 MiB
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit;
