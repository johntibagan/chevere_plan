-- Logs de cliente solo para etapa de pruebas (beta).
-- El app inserta al fallar; staff / service_role lee. No mostrar en UI de producto.

create table if not exists public.client_debug_logs (
  id uuid primary key default gen_random_uuid(),
  user_id uuid references public.profiles (id) on delete set null,
  context text not null,
  message text not null,
  error_type text,
  detail text,
  status text not null default 'pending'
    check (status in ('pending', 'resolved')),
  resolved_at timestamptz,
  created_at timestamptz not null default now(),
  constraint client_debug_logs_context_len check (char_length(context) between 1 and 120),
  constraint client_debug_logs_message_len check (char_length(message) between 1 and 2000),
  constraint client_debug_logs_detail_len check (
    detail is null or char_length(detail) <= 4000
  )
);

create index if not exists client_debug_logs_created_at_idx
  on public.client_debug_logs (created_at desc);

create index if not exists client_debug_logs_context_idx
  on public.client_debug_logs (context, created_at desc);

create index if not exists client_debug_logs_status_created_idx
  on public.client_debug_logs (status, created_at desc);

alter table public.client_debug_logs enable row level security;

drop policy if exists client_debug_logs_insert_own on public.client_debug_logs;
create policy client_debug_logs_insert_own on public.client_debug_logs
  for insert to authenticated
  with check (
    (user_id is null or user_id = auth.uid())
    and status = 'pending'
    and resolved_at is null
  );

drop policy if exists client_debug_logs_select_staff on public.client_debug_logs;
create policy client_debug_logs_select_staff on public.client_debug_logs
  for select to authenticated
  using (public.is_staff() or user_id = auth.uid());

drop policy if exists client_debug_logs_update_staff on public.client_debug_logs;
create policy client_debug_logs_update_staff on public.client_debug_logs
  for update to authenticated
  using (public.is_staff())
  with check (public.is_staff());

grant select, insert, update on public.client_debug_logs to authenticated;
grant all on public.client_debug_logs to service_role;
