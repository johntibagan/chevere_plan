-- Ciclo 5: planes inteligentes, stops, overrides de transporte en perfil

do $$ begin
  create type public.plan_status as enum ('draft', 'active', 'done');
exception when duplicate_object then null;
end $$;

alter table public.profiles
  add column if not exists transport_max_km jsonb not null default '{}'::jsonb;

create table if not exists public.plans (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null references public.profiles (id) on delete cascade,
  title text not null,
  location_query text not null,
  start_lat double precision,
  start_lng double precision,
  include_public boolean not null default false,
  max_budget_amount numeric(12, 2),
  currency_code char(3) not null default 'COP',
  status public.plan_status not null default 'active',
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists plans_user_id_idx on public.plans (user_id);

drop trigger if exists plans_set_updated_at on public.plans;
create trigger plans_set_updated_at
before update on public.plans
for each row execute function public.set_updated_at();

create table if not exists public.plan_stops (
  id uuid primary key default gen_random_uuid(),
  plan_id uuid not null references public.plans (id) on delete cascade,
  site_id uuid not null references public.sites (id) on delete cascade,
  sort_order int not null default 0,
  visited_at timestamptz,
  estimated_price_amount numeric(12, 2),
  lat double precision,
  lng double precision,
  created_at timestamptz not null default now(),
  unique (plan_id, site_id)
);

create index if not exists plan_stops_plan_id_idx on public.plan_stops (plan_id, sort_order);

alter table public.plans enable row level security;
alter table public.plan_stops enable row level security;

drop policy if exists plans_owner_all on public.plans;
create policy plans_owner_all on public.plans
  for all
  using (user_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or public.is_staff());

drop policy if exists plan_stops_owner_all on public.plan_stops;
create policy plan_stops_owner_all on public.plan_stops
  for all
  using (
    exists (
      select 1 from public.plans p
      where p.id = plan_id and (p.user_id = auth.uid() or public.is_staff())
    )
  )
  with check (
    exists (
      select 1 from public.plans p
      where p.id = plan_id and (p.user_id = auth.uid() or public.is_staff())
    )
  );

-- Candidatos para armar plan (propios complete + públicos opcionales)
create or replace function public.list_plan_candidates(
  p_location_query text,
  p_include_public boolean default false,
  p_max_budget numeric default null
)
returns table (
  site_id uuid,
  name text,
  city text,
  department text,
  lat double precision,
  lng double precision,
  estimated_price_amount numeric,
  currency_code char
)
language sql
stable
security definer
set search_path = public
as $$
  with q as (
    select trim(both from coalesce(p_location_query, '')) as loc
  ),
  own as (
    select
      s.id as site_id,
      s.name,
      s.city,
      s.department,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      s.estimated_price_amount,
      s.currency_code
    from public.user_saves us
    join public.sites s on s.id = us.site_id
    cross join q
    where us.user_id = auth.uid()
      and us.status = 'complete'
      and s.location is not null
      and q.loc <> ''
      and (
        s.city ilike '%' || q.loc || '%'
        or s.department ilike '%' || q.loc || '%'
      )
      and (
        p_max_budget is null
        or s.estimated_price_amount is null
        or s.estimated_price_amount <= p_max_budget
      )
  ),
  pub as (
    select
      s.id as site_id,
      s.name,
      s.city,
      s.department,
      st_y(s.location::geometry) as lat,
      st_x(s.location::geometry) as lng,
      s.estimated_price_amount,
      s.currency_code
    from public.sites s
    cross join q
    where p_include_public = true
      and s.is_public = true
      and s.location is not null
      and q.loc <> ''
      and (
        s.city ilike '%' || q.loc || '%'
        or s.department ilike '%' || q.loc || '%'
      )
      and (
        p_max_budget is null
        or s.estimated_price_amount is null
        or s.estimated_price_amount <= p_max_budget
      )
      and s.id not in (select own.site_id from own)
  )
  select * from own
  union all
  select * from pub;
$$;

grant execute on function public.list_plan_candidates(text, boolean, numeric) to authenticated;
