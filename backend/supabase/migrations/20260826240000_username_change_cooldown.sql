-- Cooldown de @usuario (cada 3 meses) + timestamp de último cambio.

alter table public.profiles
  add column if not exists username_changed_at timestamptz;

comment on column public.profiles.username_changed_at is
  'Última vez que se asignó o cambió username. Nuevo cambio solo tras 3 meses.';

-- Quienes ya tienen username: marcar ahora (no pueden cambiar ya).
update public.profiles
set username_changed_at = coalesce(username_changed_at, now())
where username is not null
  and username_changed_at is null;

create or replace function public.update_my_profile(
  p_username text default null,
  p_use_google_avatar boolean default null,
  p_clear_custom_avatar boolean default false
)
returns public.profiles
language plpgsql
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid();
  avail jsonb;
  norm text;
  cur_username text;
  cur_changed timestamptz;
  row public.profiles;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  if p_username is not null then
    avail := public.username_available(p_username);
    if not coalesce((avail->>'available')::boolean, false) then
      raise exception 'username not available: %', avail->>'reason';
    end if;
    norm := avail->>'normalized';

    select p.username, p.username_changed_at
      into cur_username, cur_changed
    from public.profiles p
    where p.id = uid;

    -- Primer @usuario: siempre. Cambio de uno existente: cada 3 meses.
    if cur_username is not null
       and cur_username is distinct from norm then
      if cur_changed is not null
         and cur_changed > (timezone('utc', now()) - interval '3 months') then
        raise exception 'username change cooldown';
      end if;
    end if;

    if cur_username is distinct from norm then
      update public.profiles
      set
        username = norm,
        username_changed_at = timezone('utc', now())
      where id = uid;
    end if;
  end if;

  if p_use_google_avatar is not null then
    update public.profiles
    set use_google_avatar = p_use_google_avatar
    where id = uid;
  end if;

  if p_clear_custom_avatar then
    update public.profiles
    set avatar_url = null
    where id = uid;
  end if;

  select * into row from public.profiles where id = uid;
  return row;
end;
$function$;

revoke all on function public.update_my_profile(text, boolean, boolean) from public;
grant execute on function public.update_my_profile(text, boolean, boolean) to authenticated;
