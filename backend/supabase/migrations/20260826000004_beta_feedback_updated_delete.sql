-- Fecha de última actualización + borrar reportes pendientes.

alter table public.beta_feedback
  add column if not exists updated_at timestamptz;

update public.beta_feedback
set updated_at = coalesce(updated_at, created_at, now())
where updated_at is null;

alter table public.beta_feedback
  alter column updated_at set default now();

alter table public.beta_feedback
  alter column updated_at set not null;

create or replace function public.beta_feedback_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists beta_feedback_set_updated_at on public.beta_feedback;
create trigger beta_feedback_set_updated_at
  before update on public.beta_feedback
  for each row
  execute function public.beta_feedback_touch_updated_at();

drop policy if exists beta_feedback_delete_pending on public.beta_feedback;
create policy beta_feedback_delete_pending on public.beta_feedback
  for delete to anon, authenticated
  using (done = false);
