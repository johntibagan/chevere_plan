-- Prioridad en reportes/mejoras del portal beta (alta | media | baja).
-- Solo el dueño (RPC + PIN) puede cambiarla; el insert público queda en 'media'.

alter table public.beta_feedback
  add column if not exists priority text not null default 'media';

do $$
begin
  if not exists (
    select 1
    from pg_constraint
    where conname = 'beta_feedback_priority_chk'
      and conrelid = 'public.beta_feedback'::regclass
  ) then
    alter table public.beta_feedback
      add constraint beta_feedback_priority_chk
      check (priority in ('alta', 'media', 'baja'));
  end if;
end
$$;

comment on column public.beta_feedback.priority is
  'Prioridad (alta|media|baja). Solo el dueño la cambia vía beta_set_feedback_priority.';

create index if not exists beta_feedback_priority_idx
  on public.beta_feedback (priority);

-- Insert público siempre media; update no puede cambiar priority salvo RPC (flag).
create or replace function public.beta_feedback_guard_priority()
returns trigger
language plpgsql
as $$
begin
  if tg_op = 'INSERT' then
    if coalesce(current_setting('chevere.beta_priority_ok', true), '') is distinct from '1' then
      new.priority := 'media';
    end if;
    return new;
  end if;

  if new.priority is distinct from old.priority
     and coalesce(current_setting('chevere.beta_priority_ok', true), '') is distinct from '1' then
    new.priority := old.priority;
  end if;
  return new;
end;
$$;

drop trigger if exists beta_feedback_guard_priority on public.beta_feedback;
create trigger beta_feedback_guard_priority
  before insert or update on public.beta_feedback
  for each row execute function public.beta_feedback_guard_priority();

create or replace function public.beta_set_feedback_priority(
  p_id uuid,
  p_priority text,
  p_pin text
)
returns public.beta_feedback
language plpgsql
security definer
set search_path to 'public', 'extensions'
as $$
declare
  expected text;
  row public.beta_feedback;
  prio text := lower(trim(coalesce(p_priority, '')));
begin
  select pin into expected from private.beta_admin where id = 1;
  if expected is null or p_pin is distinct from expected then
    raise exception 'PIN incorrecto';
  end if;
  if prio not in ('alta', 'media', 'baja') then
    raise exception 'Prioridad inválida';
  end if;

  perform set_config('chevere.beta_priority_ok', '1', true);

  update public.beta_feedback
  set priority = prio
  where id = p_id
  returning * into row;

  if row.id is null then
    raise exception 'No encontrado';
  end if;
  return row;
end;
$$;

revoke all on function public.beta_set_feedback_priority(uuid, text, text) from public;
grant execute on function public.beta_set_feedback_priority(uuid, text, text)
  to anon, authenticated, service_role;

-- Insert público: prioridad fija media (además del trigger).
drop policy if exists beta_feedback_insert on public.beta_feedback;
create policy beta_feedback_insert on public.beta_feedback
  for insert
  to anon, authenticated
  with check (
    (done = false)
    and (in_review = false)
    and (fixed_in_version is null)
    and (priority = 'media')
  );
