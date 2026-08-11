-- Ciclo 7: historial de visitas (vista) + reportes de contenido (fotos)

create table if not exists public.content_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_id uuid not null references public.profiles (id) on delete cascade,
  target_type text not null check (target_type in ('photo', 'site', 'profile', 'event')),
  target_id uuid not null,
  reason text,
  status text not null default 'open'
    check (status in ('open', 'reviewed', 'dismissed', 'actioned')),
  created_at timestamptz not null default now(),
  unique (reporter_id, target_type, target_id)
);

create index if not exists content_reports_status_idx
  on public.content_reports (status, created_at desc);

create index if not exists content_reports_target_idx
  on public.content_reports (target_type, target_id);

alter table public.content_reports enable row level security;

drop policy if exists content_reports_insert_own on public.content_reports;
create policy content_reports_insert_own on public.content_reports
  for insert
  with check (reporter_id = auth.uid());

drop policy if exists content_reports_select_own_or_staff on public.content_reports;
create policy content_reports_select_own_or_staff on public.content_reports
  for select
  using (reporter_id = auth.uid() or public.is_staff());

drop policy if exists content_reports_staff_update on public.content_reports;
create policy content_reports_staff_update on public.content_reports
  for update
  using (public.is_staff())
  with check (public.is_staff());

-- Historial "Mis rutas": paradas visitadas del usuario
create or replace function public.list_my_route_history()
returns table (
  stop_id uuid,
  plan_id uuid,
  plan_title text,
  site_id uuid,
  site_name text,
  city text,
  visited_at timestamptz
)
language sql
stable
security definer
set search_path = public
as $$
  select
    ps.id as stop_id,
    p.id as plan_id,
    p.title as plan_title,
    s.id as site_id,
    s.name as site_name,
    s.city,
    ps.visited_at
  from public.plan_stops ps
  join public.plans p on p.id = ps.plan_id
  join public.sites s on s.id = ps.site_id
  where p.user_id = auth.uid()
    and ps.visited_at is not null
  order by ps.visited_at desc
  limit 200;
$$;

grant execute on function public.list_my_route_history() to authenticated;

-- Lista reportes abiertos para staff (alarma desde el 1er reporte)
create or replace function public.list_open_content_reports()
returns table (
  report_id uuid,
  target_type text,
  target_id uuid,
  reason text,
  status text,
  created_at timestamptz,
  reporter_id uuid,
  reporter_name text,
  photo_path text,
  site_name text
)
language sql
stable
security definer
set search_path = public
as $$
  select
    r.id as report_id,
    r.target_type,
    r.target_id,
    r.reason,
    r.status,
    r.created_at,
    r.reporter_id,
    coalesce(pr.display_name, 'Usuario') as reporter_name,
    ph.storage_path as photo_path,
    s.name as site_name
  from public.content_reports r
  join public.profiles pr on pr.id = r.reporter_id
  left join public.site_photos ph
    on r.target_type = 'photo' and ph.id = r.target_id
  left join public.sites s on s.id = ph.site_id
  where public.is_staff()
    and r.status = 'open'
  order by r.created_at desc
  limit 200;
$$;

grant execute on function public.list_open_content_reports() to authenticated;
