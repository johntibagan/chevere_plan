-- Portal beta: consecutivo corto (#n) para commits + marcar “en revisión”
-- (solo dueño con PIN). En revisión el público no edita ni borra.

alter table public.beta_feedback
  add column if not exists in_review boolean not null default false;

alter table public.beta_feedback
  add column if not exists ticket_no smallint;

with numbered as (
  select
    id,
    coalesce(
      (select max(t.ticket_no) from public.beta_feedback t),
      0
    ) + row_number() over (order by created_at asc, id asc) as n
  from public.beta_feedback
  where ticket_no is null
)
update public.beta_feedback f
set ticket_no = numbered.n
from numbered
where f.id = numbered.id;

do $$
declare
  seq text;
  mx int;
begin
  if exists (
    select 1
    from information_schema.columns
    where table_schema = 'public'
      and table_name = 'beta_feedback'
      and column_name = 'ticket_no'
      and is_identity = 'NO'
  ) then
    alter table public.beta_feedback
      alter column ticket_no set not null;
    alter table public.beta_feedback
      alter column ticket_no add generated always as identity;
  end if;

  seq := pg_get_serial_sequence('public.beta_feedback', 'ticket_no');
  if seq is not null then
    select max(ticket_no) into mx from public.beta_feedback;
    if mx is null then
      perform setval(seq, 1, false);
    else
      perform setval(seq, mx, true);
    end if;
    execute format(
      'grant usage, select on sequence %s to anon, authenticated, service_role',
      seq
    );
  end if;
end $$;

create unique index if not exists beta_feedback_ticket_no_uidx
  on public.beta_feedback (ticket_no);

create or replace function public.beta_feedback_touch_updated_at()
returns trigger
language plpgsql
as $$
begin
  if new.ticket_no is distinct from old.ticket_no then
    raise exception 'ticket_no inmutable';
  end if;
  new.updated_at := now();
  return new;
end;
$$;

drop policy if exists beta_feedback_insert on public.beta_feedback;
create policy beta_feedback_insert on public.beta_feedback
  for insert to anon, authenticated
  with check (
    done = false
    and in_review = false
    and fixed_in_version is null
  );

drop policy if exists beta_feedback_update_pending on public.beta_feedback;
create policy beta_feedback_update_pending on public.beta_feedback
  for update to anon, authenticated
  using (done = false and in_review = false)
  with check (
    done = false
    and in_review = false
    and fixed_in_version is null
  );

drop policy if exists beta_feedback_delete_pending on public.beta_feedback;
create policy beta_feedback_delete_pending on public.beta_feedback
  for delete to anon, authenticated
  using (done = false and in_review = false);

create or replace function public.beta_set_feedback_review(
  p_id uuid,
  p_in_review boolean,
  p_pin text
)
returns public.beta_feedback
language plpgsql
security definer
set search_path = public
as $$
declare
  expected text;
  row public.beta_feedback;
begin
  select pin into expected from private.beta_admin where id = 1;
  if expected is null or p_pin is distinct from expected then
    raise exception 'PIN incorrecto';
  end if;

  update public.beta_feedback
  set in_review = p_in_review
  where id = p_id
    and done = false
  returning * into row;

  if row.id is null then
    raise exception 'No encontrado';
  end if;
  return row;
end;
$$;

revoke all on function public.beta_set_feedback_review(uuid, boolean, text)
  from public;
grant execute on function public.beta_set_feedback_review(uuid, boolean, text)
  to anon, authenticated;

comment on column public.beta_feedback.ticket_no is
  'Consecutivo corto para commits (#1, #2). Identity, inmutable.';
comment on column public.beta_feedback.in_review is
  'Dueño (PIN): en revisión; el público no edita ni borra.';
