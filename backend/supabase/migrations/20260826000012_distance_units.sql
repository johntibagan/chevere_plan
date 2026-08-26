-- Unidades de distancia (admin) + preferencia de usuario.
-- Canon interno: metros (proximidad/geofence) y km (RPC búsqueda).
-- La UI convierte según profiles.preferred_distance_unit.

create table if not exists public.distance_units (
  id uuid default gen_random_uuid() not null,
  slug text not null,
  name_i18n jsonb default '{}'::jsonb not null,
  symbol text not null,
  meters_per_unit numeric(16, 6) not null,
  is_active boolean default true not null,
  is_default boolean default false not null,
  sort_order integer default 0 not null,
  created_at timestamp with time zone default now() not null,
  updated_at timestamp with time zone default now() not null,
  constraint distance_units_pkey primary key (id),
  constraint distance_units_slug_key unique (slug),
  constraint distance_units_meters_per_unit_check check (meters_per_unit > 0),
  constraint distance_units_symbol_check check (char_length(trim(symbol)) > 0)
);

create unique index if not exists distance_units_one_default_idx
  on public.distance_units ((is_default))
  where is_default;

drop trigger if exists distance_units_set_updated_at on public.distance_units;
create trigger distance_units_set_updated_at
  before update on public.distance_units
  for each row execute function public.set_updated_at();

create or replace function public.distance_units_clear_other_defaults()
returns trigger
language plpgsql
as $$
begin
  if new.is_default then
    update public.distance_units
    set is_default = false
    where id is distinct from new.id
      and is_default;
  end if;
  return new;
end;
$$;

drop trigger if exists distance_units_one_default_trg on public.distance_units;
create trigger distance_units_one_default_trg
  before insert or update of is_default on public.distance_units
  for each row
  when (new.is_default)
  execute function public.distance_units_clear_other_defaults();

insert into public.distance_units (slug, name_i18n, symbol, meters_per_unit, is_active, is_default, sort_order)
values
  ('m', '{"es":"Metros"}'::jsonb, 'm', 1, true, false, 10),
  ('km', '{"es":"Kilómetros"}'::jsonb, 'km', 1000, true, true, 20),
  ('mi', '{"es":"Millas"}'::jsonb, 'mi', 1609.344, true, false, 30)
on conflict (slug) do update
set
  name_i18n = excluded.name_i18n,
  symbol = excluded.symbol,
  meters_per_unit = excluded.meters_per_unit,
  is_active = excluded.is_active,
  sort_order = excluded.sort_order;

-- Preferencia por usuario (default km).
alter table public.profiles
  add column if not exists preferred_distance_unit text;

update public.profiles
set preferred_distance_unit = 'km'
where preferred_distance_unit is null;

alter table public.profiles
  alter column preferred_distance_unit set default 'km';

alter table public.profiles
  alter column preferred_distance_unit set not null;

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'profiles_preferred_distance_unit_fkey'
  ) then
    alter table public.profiles
      add constraint profiles_preferred_distance_unit_fkey
      foreign key (preferred_distance_unit)
      references public.distance_units (slug)
      on update cascade
      on delete restrict;
  end if;
end $$;

alter table public.distance_units enable row level security;

drop policy if exists distance_units_select_active_or_staff on public.distance_units;
create policy distance_units_select_active_or_staff on public.distance_units
  for select
  to authenticated
  using ((is_active = true) or is_staff());

drop policy if exists distance_units_staff_write on public.distance_units;
create policy distance_units_staff_write on public.distance_units
  for all
  to authenticated
  using (is_staff())
  with check (is_staff());

grant select on public.distance_units to authenticated;
grant all on public.distance_units to service_role;
