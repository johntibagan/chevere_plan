-- Ciclo 1: extensión PostGIS, perfiles/roles, categorías, transporte, sitios base
-- Fuente: especificacion §4.1, §7.2, §11, §12, §16.3 / ADR 0002

create extension if not exists postgis;
create extension if not exists pgcrypto;

-- ─── Enums ─────────────────────────────────────────────────────────
do $$ begin
  create type public.app_role as enum ('user', 'admin', 'root');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.transport_group as enum ('particular', 'publico', 'otro');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.site_status as enum ('draft', 'pending_location', 'complete');
exception when duplicate_object then null;
end $$;

do $$ begin
  create type public.photo_source as enum ('google_places', 'user');
exception when duplicate_object then null;
end $$;

-- ─── Helpers ───────────────────────────────────────────────────────
create or replace function public.set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

-- ─── Profiles ──────────────────────────────────────────────────────
create table if not exists public.profiles (
  id uuid primary key references auth.users (id) on delete cascade,
  display_name text,
  avatar_url text,
  role public.app_role not null default 'user',
  birth_date date,
  preferred_locale text not null default 'es',
  preferred_currency char(3) not null default 'COP',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

-- Debe ir DESPUÉS de crear profiles (SQL valida la relación al crear la función)
create or replace function public.is_staff()
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1 from public.profiles p
    where p.id = auth.uid() and p.role in ('admin', 'root')
  );
$$;

drop trigger if exists profiles_set_updated_at on public.profiles;
create trigger profiles_set_updated_at
before update on public.profiles
for each row execute function public.set_updated_at();

create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  insert into public.profiles (id, display_name, avatar_url)
  values (
    new.id,
    coalesce(new.raw_user_meta_data->>'full_name', new.raw_user_meta_data->>'name', new.email),
    new.raw_user_meta_data->>'avatar_url'
  )
  on conflict (id) do nothing;
  return new;
end;
$$;

drop trigger if exists on_auth_user_created on auth.users;
create trigger on_auth_user_created
after insert on auth.users
for each row execute function public.handle_new_user();

-- ─── Categories (árbol) ────────────────────────────────────────────
create table if not exists public.categories (
  id uuid primary key default gen_random_uuid(),
  parent_id uuid references public.categories (id) on delete restrict,
  slug text not null,
  name_i18n jsonb not null default '{}'::jsonb,
  is_active boolean not null default true,
  age_restricted boolean not null default false,
  sort_order int not null default 0,
  icon_key text,
  color_hex text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (parent_id, slug)
);

create unique index if not exists categories_root_slug_uidx
  on public.categories (slug) where parent_id is null;

drop trigger if exists categories_set_updated_at on public.categories;
create trigger categories_set_updated_at
before update on public.categories
for each row execute function public.set_updated_at();

-- ─── Transport types ───────────────────────────────────────────────
create table if not exists public.transport_types (
  id uuid primary key default gen_random_uuid(),
  transport_group public.transport_group not null,
  slug text not null unique,
  name_i18n jsonb not null default '{}'::jsonb,
  default_max_km numeric(8, 2),
  is_active boolean not null default true,
  sort_order int not null default 0,
  icon_key text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

drop trigger if exists transport_types_set_updated_at on public.transport_types;
create trigger transport_types_set_updated_at
before update on public.transport_types
for each row execute function public.set_updated_at();

-- ─── Sites / photos / saves (base; flujos en Ciclo 2+) ─────────────
create table if not exists public.sites (
  id uuid primary key default gen_random_uuid(),
  name text not null,
  status public.site_status not null default 'draft',
  is_public boolean not null default false,
  is_physical_place boolean not null default true,
  location geography(point, 4326),
  address_line text,
  city text,
  department text,
  country_code char(2) not null default 'CO',
  estimated_price_amount numeric(12, 2),
  currency_code char(3) not null default 'COP',
  created_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists sites_location_gix on public.sites using gist (location);
create index if not exists sites_city_idx on public.sites (city);

drop trigger if exists sites_set_updated_at on public.sites;
create trigger sites_set_updated_at
before update on public.sites
for each row execute function public.set_updated_at();

create table if not exists public.site_categories (
  site_id uuid not null references public.sites (id) on delete cascade,
  category_id uuid not null references public.categories (id) on delete restrict,
  added_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  primary key (site_id, category_id)
);

create table if not exists public.site_photos (
  id uuid primary key default gen_random_uuid(),
  site_id uuid not null references public.sites (id) on delete cascade,
  storage_path text not null,
  source public.photo_source not null default 'user',
  uploaded_by uuid references public.profiles (id) on delete set null,
  sort_order int not null default 0,
  created_at timestamptz not null default now()
);

create table if not exists public.user_saves (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  site_id uuid not null references public.sites (id) on delete cascade,
  status public.site_status not null default 'draft',
  is_public boolean not null default false,
  source_url text,
  source_network text,
  notes text,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  unique (user_id, site_id)
);

drop trigger if exists user_saves_set_updated_at on public.user_saves;
create trigger user_saves_set_updated_at
before update on public.user_saves
for each row execute function public.set_updated_at();

-- ─── RLS ───────────────────────────────────────────────────────────
alter table public.profiles enable row level security;
alter table public.categories enable row level security;
alter table public.transport_types enable row level security;
alter table public.sites enable row level security;
alter table public.site_categories enable row level security;
alter table public.site_photos enable row level security;
alter table public.user_saves enable row level security;

-- Profiles
create policy profiles_select_own_or_staff on public.profiles
  for select to authenticated
  using (id = auth.uid() or public.is_staff());

create policy profiles_update_own on public.profiles
  for update to authenticated
  using (id = auth.uid())
  with check (id = auth.uid());

create policy profiles_staff_update on public.profiles
  for update to authenticated
  using (public.is_staff())
  with check (public.is_staff());

create or replace function public.prevent_role_escalation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role is distinct from old.role then
    -- Dashboard SQL Editor / service role: auth.uid() es null → permitir bootstrap
    if auth.uid() is null then
      return new;
    end if;
    if not public.is_staff() then
      raise exception 'Solo admin/root pueden cambiar roles';
    end if;
  end if;
  return new;
end;
$$;

drop trigger if exists profiles_prevent_role_escalation on public.profiles;
create trigger profiles_prevent_role_escalation
before update on public.profiles
for each row execute function public.prevent_role_escalation();

-- Categories: lectura pública autenticada de activas; staff ve/edita todo
create policy categories_select_active_or_staff on public.categories
  for select to authenticated
  using (is_active = true or public.is_staff());

create policy categories_staff_write on public.categories
  for all to authenticated
  using (public.is_staff())
  with check (public.is_staff());

-- Transport
create policy transport_select_active_or_staff on public.transport_types
  for select to authenticated
  using (is_active = true or public.is_staff());

create policy transport_staff_write on public.transport_types
  for all to authenticated
  using (public.is_staff())
  with check (public.is_staff());

-- Sites (mínimo Ciclo 1; se refinará en 2–3)
create policy sites_select_public_or_owner_or_staff on public.sites
  for select to authenticated
  using (is_public = true or created_by = auth.uid() or public.is_staff());

create policy sites_insert_own on public.sites
  for insert to authenticated
  with check (created_by = auth.uid());

create policy sites_update_own_or_staff on public.sites
  for update to authenticated
  using (created_by = auth.uid() or public.is_staff())
  with check (created_by = auth.uid() or public.is_staff());

-- site_categories / photos / saves
create policy site_categories_select on public.site_categories
  for select to authenticated
  using (
    exists (
      select 1 from public.sites s
      where s.id = site_id and (s.is_public or s.created_by = auth.uid() or public.is_staff())
    )
  );

create policy site_categories_write_own_or_staff on public.site_categories
  for all to authenticated
  using (
    public.is_staff() or exists (
      select 1 from public.sites s where s.id = site_id and s.created_by = auth.uid()
    )
  )
  with check (
    public.is_staff() or exists (
      select 1 from public.sites s where s.id = site_id and s.created_by = auth.uid()
    )
  );

create policy site_photos_select on public.site_photos
  for select to authenticated
  using (
    exists (
      select 1 from public.sites s
      where s.id = site_id and (s.is_public or s.created_by = auth.uid() or public.is_staff())
    )
  );

create policy site_photos_write on public.site_photos
  for all to authenticated
  using (
    public.is_staff() or exists (
      select 1 from public.sites s where s.id = site_id and s.created_by = auth.uid()
    )
  )
  with check (
    public.is_staff() or exists (
      select 1 from public.sites s where s.id = site_id and s.created_by = auth.uid()
    )
  );

create policy user_saves_own on public.user_saves
  for all to authenticated
  using (user_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or public.is_staff());

