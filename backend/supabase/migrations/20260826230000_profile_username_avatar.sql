-- Perfil público: @username único + foto (Google opt-in / custom).
-- Fold into baseline schema + storage when closing the cycle.

-- ---------------------------------------------------------------------------
-- Columns
-- ---------------------------------------------------------------------------
alter table public.profiles
  add column if not exists username text,
  add column if not exists google_avatar_url text,
  add column if not exists use_google_avatar boolean not null default false;

comment on column public.profiles.username is
  'Handle público único (a-z0-9._, 3–20). Se muestra como @username.';
comment on column public.profiles.google_avatar_url is
  'URL de avatar de OAuth (Google). No se muestra salvo use_google_avatar.';
comment on column public.profiles.use_google_avatar is
  'Si true y no hay avatar_url custom, se muestra google_avatar_url.';
comment on column public.profiles.avatar_url is
  'Avatar propio (URL pública Storage avatars). Tiene prioridad sobre Google.';

-- Migrar fotos de Google fuera de avatar_url (dejar de mostrarlas por defecto).
update public.profiles
set
  google_avatar_url = coalesce(google_avatar_url, avatar_url),
  avatar_url = null
where avatar_url is not null
  and (
    google_avatar_url is null
    or google_avatar_url = avatar_url
  )
  and (
    avatar_url like '%googleusercontent.com%'
    or avatar_url like '%ggpht.com%'
    or avatar_url like '%google.com%'
  );

-- Si aún hay avatar_url que parece Google y google vacío:
update public.profiles
set
  google_avatar_url = coalesce(google_avatar_url, avatar_url),
  avatar_url = null
where avatar_url is not null
  and google_avatar_url is null;

create unique index if not exists profiles_username_unique
  on public.profiles (username)
  where username is not null;

alter table public.profiles
  drop constraint if exists profiles_username_format;

alter table public.profiles
  add constraint profiles_username_format
  check (
    username is null
    or username ~ '^[a-z0-9._]{3,20}$'
  );

-- ---------------------------------------------------------------------------
-- Normalize / availability / suggestions
-- ---------------------------------------------------------------------------
create or replace function public.normalize_username(raw text)
returns text
language plpgsql
immutable
set search_path to 'public'
as $function$
declare
  s text;
begin
  if raw is null then
    return null;
  end if;
  s := lower(btrim(raw));
  s := regexp_replace(s, '^@+', '');
  -- Español / latín común → ASCII (búsqueda tolerante a tildes).
  s := translate(
    s,
    'áàäâãåāăąéèëêēėęíìïîīįóòöôõøōúùüûūųýÿñçÁÀÄÂÃÅĀĂĄÉÈËÊĒĖĘÍÌÏÎĪĮÓÒÖÔÕØŌÚÙÜÛŪŲÝŸÑÇ',
    'aaaaaaaaaeeeeeeeiiiiiiioooooooouuuuuuyyncaaaaaaaaaeeeeeeeiiiiiiioooooooouuuuuuyync'
  );
  s := regexp_replace(s, '[^a-z0-9._]', '', 'g');
  if s = '' then
    return null;
  end if;
  return s;
end;
$function$;

create or replace function public.is_reserved_username(u text)
returns boolean
language sql
immutable
set search_path to 'public'
as $function$
  select u in (
    'admin', 'root', 'support', 'soporte', 'help', 'ayuda',
    'chevere', 'chevereplan', 'oficial', 'official', 'null',
    'undefined', 'system', 'sistema', 'staff', 'mod', 'moderator'
  );
$function$;

create or replace function public.username_available(p_username text)
returns jsonb
language plpgsql
stable
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid();
  norm text;
  taken boolean;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  norm := public.normalize_username(p_username);
  if norm is null then
    return jsonb_build_object(
      'available', false,
      'normalized', null,
      'reason', 'invalid'
    );
  end if;
  if char_length(norm) < 3 or char_length(norm) > 20 then
    return jsonb_build_object(
      'available', false,
      'normalized', norm,
      'reason', 'length'
    );
  end if;
  if norm !~ '^[a-z0-9._]{3,20}$' then
    return jsonb_build_object(
      'available', false,
      'normalized', norm,
      'reason', 'invalid'
    );
  end if;
  if public.is_reserved_username(norm) then
    return jsonb_build_object(
      'available', false,
      'normalized', norm,
      'reason', 'reserved'
    );
  end if;
  select exists (
    select 1
    from public.profiles p
    where p.username = norm
      and p.id <> uid
  ) into taken;
  return jsonb_build_object(
    'available', not taken,
    'normalized', norm,
    'reason', case when taken then 'taken' else 'ok' end
  );
end;
$function$;

revoke all on function public.username_available(text) from public;
grant execute on function public.username_available(text) to authenticated;

create or replace function public.suggest_usernames(p_base text, p_limit int default 5)
returns text[]
language plpgsql
stable
security definer
set search_path to 'public'
as $function$
declare
  uid uuid := auth.uid();
  base text;
  out text[] := '{}';
  cand text;
  i int := 0;
  n int;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;
  n := greatest(1, least(coalesce(p_limit, 5), 8));
  base := public.normalize_username(p_base);
  if base is null or char_length(base) < 2 then
    base := 'user';
  end if;
  if char_length(base) > 16 then
    base := left(base, 16);
  end if;

  for i in 0..40 loop
    if i = 0 then
      cand := base;
    elsif i <= 9 then
      cand := base || i::text;
    else
      cand := base || '_' || (100 + i)::text;
    end if;
    if char_length(cand) > 20 then
      cand := left(base, greatest(3, 20 - 3)) || (i % 100)::text;
    end if;
    if char_length(cand) < 3 then
      continue;
    end if;
    if public.is_reserved_username(cand) then
      continue;
    end if;
    if exists (
      select 1 from public.profiles p
      where p.username = cand and p.id <> uid
    ) then
      continue;
    end if;
    if not (cand = any (out)) then
      out := array_append(out, cand);
    end if;
    exit when coalesce(array_length(out, 1), 0) >= n;
  end loop;
  return out;
end;
$function$;

revoke all on function public.suggest_usernames(text, int) from public;
grant execute on function public.suggest_usernames(text, int) to authenticated;

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
    update public.profiles
    set username = norm
    where id = uid;
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

-- ---------------------------------------------------------------------------
-- Signup: Google photo → google_avatar_url; no mostrar por defecto
-- ---------------------------------------------------------------------------
create or replace function public.handle_new_user()
returns trigger
language plpgsql
security definer
set search_path to 'public'
as $function$
begin
  insert into public.profiles (id, display_name, google_avatar_url, avatar_url, use_google_avatar)
  values (
    new.id,
    coalesce(
      new.raw_user_meta_data->>'full_name',
      new.raw_user_meta_data->>'name',
      new.email
    ),
    coalesce(
      new.raw_user_meta_data->>'avatar_url',
      new.raw_user_meta_data->>'picture'
    ),
    null,
    false
  )
  on conflict (id) do nothing;
  return new;
end;
$function$;

-- Reporter name → @username
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
  site_name text,
  snippet text
)
language sql
stable
security definer
set search_path to 'public'
as $function$
  select
    r.id as report_id,
    r.target_type,
    r.target_id,
    r.reason,
    r.status,
    r.created_at,
    r.reporter_id,
    case
      when pr.username is not null and length(pr.username) > 0
        then '@' || pr.username
      else 'Usuario'
    end as reporter_name,
    coalesce(ph.storage_path, null) as photo_path,
    coalesce(s_photo.name, s_review.name) as site_name,
    case
      when r.target_type = 'review' then left(trim(coalesce(rev.body, '')), 160)
      else null
    end as snippet
  from public.content_reports r
  join public.profiles pr on pr.id = r.reporter_id
  left join public.site_photos ph
    on r.target_type = 'photo' and ph.id = r.target_id
  left join public.sites s_photo on s_photo.id = ph.site_id
  left join public.site_reviews rev
    on r.target_type = 'review' and rev.id = r.target_id
  left join public.sites s_review on s_review.id = rev.site_id
  where public.is_staff()
    and r.status = 'open'
  order by r.created_at desc
  limit 200;
$function$;

-- ---------------------------------------------------------------------------
-- Storage: avatars (público, path {user_id}/…)
-- ---------------------------------------------------------------------------
insert into storage.buckets (id, name, public, file_size_limit)
values ('avatars', 'avatars', true, 5242880)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit;

drop policy if exists avatars_storage_select on storage.objects;
drop policy if exists avatars_storage_insert on storage.objects;
drop policy if exists avatars_storage_update on storage.objects;
drop policy if exists avatars_storage_delete on storage.objects;

create policy avatars_storage_select on storage.objects
  for select to public
  using (bucket_id = 'avatars');

create policy avatars_storage_insert on storage.objects
  for insert to authenticated
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  );

create policy avatars_storage_update on storage.objects
  for update to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  )
  with check (
    bucket_id = 'avatars'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  );

create policy avatars_storage_delete on storage.objects
  for delete to authenticated
  using (
    bucket_id = 'avatars'
    and (storage.foldername(objects.name))[1] = auth.uid()::text
  );
