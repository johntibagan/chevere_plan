-- Estado de logs de prueba: pending | resolved.

alter table public.client_debug_logs
  add column if not exists status text not null default 'pending';

alter table public.client_debug_logs
  drop constraint if exists client_debug_logs_status_check;

alter table public.client_debug_logs
  add constraint client_debug_logs_status_check
  check (status in ('pending', 'resolved'));

alter table public.client_debug_logs
  add column if not exists resolved_at timestamptz;

create index if not exists client_debug_logs_status_created_idx
  on public.client_debug_logs (status, created_at desc);

drop policy if exists client_debug_logs_update_staff on public.client_debug_logs;
create policy client_debug_logs_update_staff on public.client_debug_logs
  for update to authenticated
  using (public.is_staff())
  with check (public.is_staff());

grant update on public.client_debug_logs to authenticated;
