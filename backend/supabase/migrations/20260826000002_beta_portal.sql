-- Portal de pruebas cerradas: APK + reportes anónimos.

create schema if not exists private;

create table if not exists private.beta_admin (
  id int primary key default 1 check (id = 1),
  pin text not null
);

insert into private.beta_admin (id, pin)
values (1, 'chevere')
on conflict (id) do nothing;

revoke all on schema private from public, anon, authenticated;
grant usage on schema private to postgres, service_role;

create table if not exists public.beta_release (
  id int primary key default 1 check (id = 1),
  version text not null default '—',
  build int,
  apk_url text,
  updated_at timestamptz not null default now()
);

insert into public.beta_release (id, version)
values (1, '—')
on conflict (id) do nothing;

alter table public.beta_release enable row level security;

drop policy if exists beta_release_select on public.beta_release;
create policy beta_release_select on public.beta_release
  for select to anon, authenticated
  using (true);

create table if not exists public.beta_feedback (
  id uuid primary key default gen_random_uuid(),
  body text not null,
  done boolean not null default false,
  fixed_in_version text,
  created_at timestamptz not null default now(),
  constraint beta_feedback_body_len check (
    char_length(trim(body)) between 3 and 500
  )
);

create index if not exists beta_feedback_created_at_idx
  on public.beta_feedback (created_at desc);

alter table public.beta_feedback enable row level security;

drop policy if exists beta_feedback_select on public.beta_feedback;
create policy beta_feedback_select on public.beta_feedback
  for select to anon, authenticated
  using (true);

drop policy if exists beta_feedback_insert on public.beta_feedback;
create policy beta_feedback_insert on public.beta_feedback
  for insert to anon, authenticated
  with check (
    done = false
    and fixed_in_version is null
  );

-- Solo el dueño (con PIN) marca hecho / versión.
create or replace function public.beta_mark_feedback(
  p_id uuid,
  p_done boolean,
  p_fixed_in_version text,
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
  set
    done = p_done,
    fixed_in_version = case
      when p_done then nullif(trim(coalesce(p_fixed_in_version, '')), '')
      else null
    end
  where id = p_id
  returning * into row;

  if row.id is null then
    raise exception 'No encontrado';
  end if;
  return row;
end;
$$;

revoke all on function public.beta_mark_feedback(uuid, boolean, text, text) from public;
grant execute on function public.beta_mark_feedback(uuid, boolean, text, text)
  to anon, authenticated;

comment on table public.beta_release is
  'Última APK de prueba cerrada; la actualiza el publish script / agente.';
comment on table public.beta_feedback is
  'Reportes anónimos del portal beta; marcar hecho solo con PIN.';
