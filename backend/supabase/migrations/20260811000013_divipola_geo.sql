-- Catálogo político-administrativo (DIVIPOLA / DANE).
-- La app no llama datos.gov.co: sincroniza un script y consulta estas tablas.
-- country_code desde el inicio para otros países sin cambiar esquema.

create table if not exists public.countries (
  code char(2) primary key,
  name text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists countries_set_updated_at on public.countries;
create trigger countries_set_updated_at
before update on public.countries
for each row execute function public.set_updated_at();

create table if not exists public.departments (
  id uuid primary key default gen_random_uuid(),
  country_code char(2) not null references public.countries (code) on delete restrict,
  code text not null,
  name text not null,
  name_norm text not null,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (country_code, code)
);

create index if not exists departments_country_name_idx
  on public.departments (country_code, name);

drop trigger if exists departments_set_updated_at on public.departments;
create trigger departments_set_updated_at
before update on public.departments
for each row execute function public.set_updated_at();

create table if not exists public.cities (
  id uuid primary key default gen_random_uuid(),
  department_id uuid not null references public.departments (id) on delete cascade,
  code text not null,
  name text not null,
  name_norm text not null,
  kind text,
  is_active boolean not null default true,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (department_id, code)
);

create index if not exists cities_department_name_idx
  on public.cities (department_id, name);

drop trigger if exists cities_set_updated_at on public.cities;
create trigger cities_set_updated_at
before update on public.cities
for each row execute function public.set_updated_at();

insert into public.countries (code, name)
values ('CO', 'Colombia')
on conflict (code) do update set name = excluded.name, is_active = true;

alter table public.sites
  add column if not exists department_id uuid references public.departments (id) on delete set null,
  add column if not exists city_id uuid references public.cities (id) on delete set null;

create index if not exists sites_department_id_idx on public.sites (department_id);
create index if not exists sites_city_id_idx on public.sites (city_id);

alter table public.countries enable row level security;
alter table public.departments enable row level security;
alter table public.cities enable row level security;

drop policy if exists countries_select_active_or_staff on public.countries;
create policy countries_select_active_or_staff on public.countries
  for select to authenticated
  using (is_active = true or public.is_staff());

drop policy if exists departments_select_active_or_staff on public.departments;
create policy departments_select_active_or_staff on public.departments
  for select to authenticated
  using (is_active = true or public.is_staff());

drop policy if exists cities_select_active_or_staff on public.cities;
create policy cities_select_active_or_staff on public.cities
  for select to authenticated
  using (is_active = true or public.is_staff());

drop policy if exists countries_staff_write on public.countries;
create policy countries_staff_write on public.countries
  for all to authenticated
  using (public.is_staff())
  with check (public.is_staff());

drop policy if exists departments_staff_write on public.departments;
create policy departments_staff_write on public.departments
  for all to authenticated
  using (public.is_staff())
  with check (public.is_staff());

drop policy if exists cities_staff_write on public.cities;
create policy cities_staff_write on public.cities
  for all to authenticated
  using (public.is_staff())
  with check (public.is_staff());
