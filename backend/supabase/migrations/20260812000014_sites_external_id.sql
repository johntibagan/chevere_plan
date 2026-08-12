-- Catalogo de sitios publicos importados (idempotente por external_id).
-- UNIQUE permite varios NULL (sitios de usuario).

alter table public.sites
  add column if not exists external_id text;

do $$
begin
  if not exists (
    select 1 from pg_constraint
    where conname = 'sites_external_id_key'
      and conrelid = 'public.sites'::regclass
  ) then
    alter table public.sites
      add constraint sites_external_id_key unique (external_id);
  end if;
end
$$;

comment on column public.sites.external_id is
  'Clave estable de import masivo (ej. co-cundinamarca-…). Null = creado por usuario.';
