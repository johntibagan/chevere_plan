-- Vincular guardado a sitio público existente sin save previo (anti-dupe).
-- Evita fallos de upsert/embed PostgREST en el cliente al crear+vincular.

create or replace function public.attach_save_to_existing_site(
  p_existing_site_id uuid,
  p_source_url text default null,
  p_source_network text default null,
  p_notes text default null
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_public boolean;
  v_save_id uuid;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select s.is_public into v_public
  from public.sites s
  where s.id = p_existing_site_id;

  if v_public is distinct from true then
    raise exception 'existing site must be public';
  end if;

  insert into public.site_contributors (site_id, user_id)
  values (p_existing_site_id, uid)
  on conflict do nothing;

  insert into public.user_saves (
    user_id,
    site_id,
    status,
    is_public,
    source_url,
    source_network,
    notes,
    draft_remind_at,
    is_possible_duplicate,
    possible_duplicate_of_site_id
  )
  values (
    uid,
    p_existing_site_id,
    'complete',
    true,
    nullif(trim(p_source_url), ''),
    nullif(trim(p_source_network), ''),
    nullif(trim(p_notes), ''),
    null,
    true,
    p_existing_site_id
  )
  on conflict (user_id, site_id) do update
  set
    status = 'complete',
    is_public = true,
    source_url = coalesce(excluded.source_url, public.user_saves.source_url),
    source_network = coalesce(excluded.source_network, public.user_saves.source_network),
    notes = coalesce(excluded.notes, public.user_saves.notes),
    draft_remind_at = null,
    is_possible_duplicate = true,
    possible_duplicate_of_site_id = p_existing_site_id,
    updated_at = now()
  returning id into v_save_id;

  return v_save_id;
end;
$$;

grant execute on function public.attach_save_to_existing_site(uuid, text, text, text)
  to authenticated;

comment on function public.attach_save_to_existing_site(uuid, text, text, text) is
  'Crea/actualiza mi user_save + contributor hacia un sitio público (cero dupe).';
