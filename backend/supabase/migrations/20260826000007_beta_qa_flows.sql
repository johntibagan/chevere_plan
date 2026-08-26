-- Flujos de prueba por versión en el portal beta (sección “Cómo probar”).
-- El agente los escribe al decir el dueño “publica” + IDs de ticket.

create table if not exists public.beta_qa_flows (
  id uuid primary key default gen_random_uuid(),
  version text not null,
  ticket_no smallint not null,
  title text not null,
  steps text not null,
  created_at timestamptz not null default now(),
  constraint beta_qa_flows_version_len check (
    char_length(trim(version)) between 1 and 32
  ),
  constraint beta_qa_flows_title_len check (
    char_length(trim(title)) between 3 and 200
  ),
  constraint beta_qa_flows_steps_len check (
    char_length(trim(steps)) between 10 and 4000
  ),
  constraint beta_qa_flows_version_ticket unique (version, ticket_no),
  constraint beta_qa_flows_ticket_fk
    foreign key (ticket_no) references public.beta_feedback (ticket_no)
);

create index if not exists beta_qa_flows_version_idx
  on public.beta_qa_flows (version, ticket_no);

alter table public.beta_qa_flows enable row level security;

drop policy if exists beta_qa_flows_select on public.beta_qa_flows;
create policy beta_qa_flows_select on public.beta_qa_flows
  for select to anon, authenticated
  using (true);

-- Solo el dueño (PIN) publica / actualiza / borra flujos.
create or replace function public.beta_upsert_qa_flow(
  p_version text,
  p_ticket_no smallint,
  p_title text,
  p_steps text,
  p_pin text
)
returns public.beta_qa_flows
language plpgsql
security definer
set search_path = public
as $$
declare
  expected text;
  row public.beta_qa_flows;
  v text := trim(coalesce(p_version, ''));
  t text := trim(coalesce(p_title, ''));
  s text := trim(coalesce(p_steps, ''));
begin
  select pin into expected from private.beta_admin where id = 1;
  if expected is null or p_pin is distinct from expected then
    raise exception 'PIN incorrecto';
  end if;

  if char_length(v) < 1 then
    raise exception 'Versión requerida';
  end if;
  if not exists (
    select 1 from public.beta_feedback f where f.ticket_no = p_ticket_no
  ) then
    raise exception 'Ticket no encontrado';
  end if;

  insert into public.beta_qa_flows (version, ticket_no, title, steps)
  values (v, p_ticket_no, t, s)
  on conflict (version, ticket_no) do update
    set title = excluded.title,
        steps = excluded.steps
  returning * into row;

  return row;
end;
$$;

revoke all on function public.beta_upsert_qa_flow(text, smallint, text, text, text)
  from public;
grant execute on function public.beta_upsert_qa_flow(text, smallint, text, text, text)
  to anon, authenticated, service_role;

create or replace function public.beta_delete_qa_flow(
  p_version text,
  p_ticket_no smallint,
  p_pin text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  expected text;
begin
  select pin into expected from private.beta_admin where id = 1;
  if expected is null or p_pin is distinct from expected then
    raise exception 'PIN incorrecto';
  end if;

  delete from public.beta_qa_flows
  where version = trim(p_version)
    and ticket_no = p_ticket_no;
end;
$$;

revoke all on function public.beta_delete_qa_flow(text, smallint, text) from public;
grant execute on function public.beta_delete_qa_flow(text, smallint, text)
  to anon, authenticated, service_role;

comment on table public.beta_qa_flows is
  'Flujos de prueba por versión/ticket para testers del portal beta.';
