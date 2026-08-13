-- Al vincular a sitio público existente: el guardado queda público (no crea sitio nuevo).
create or replace function public.link_save_to_existing_site(
  p_save_id uuid,
  p_existing_site_id uuid
)
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  uid uuid := auth.uid();
  v_old_site uuid;
  v_existing_public boolean;
begin
  if uid is null then
    raise exception 'not authenticated';
  end if;

  select us.site_id into v_old_site
  from public.user_saves us
  where us.id = p_save_id and us.user_id = uid;

  if v_old_site is null then
    raise exception 'save not found';
  end if;

  select s.is_public into v_existing_public
  from public.sites s
  where s.id = p_existing_site_id;

  if v_existing_public is distinct from true then
    raise exception 'existing site must be public';
  end if;

  if v_old_site = p_existing_site_id then
    update public.user_saves
    set
      is_public = true,
      status = 'complete',
      is_possible_duplicate = true,
      possible_duplicate_of_site_id = p_existing_site_id,
      updated_at = now()
    where id = p_save_id and user_id = uid;
    return p_existing_site_id;
  end if;

  insert into public.site_contributors (site_id, user_id)
  values (p_existing_site_id, uid)
  on conflict do nothing;

  update public.plan_stops ps
  set site_id = p_existing_site_id
  from public.plans p
  where ps.plan_id = p.id
    and p.user_id = uid
    and ps.site_id = v_old_site
    and not exists (
      select 1 from public.plan_stops x
      where x.plan_id = ps.plan_id and x.site_id = p_existing_site_id
    );

  delete from public.plan_stops ps
  using public.plans p
  where ps.plan_id = p.id
    and p.user_id = uid
    and ps.site_id = v_old_site;

  update public.user_saves
  set
    site_id = p_existing_site_id,
    is_public = true,
    status = 'complete',
    is_possible_duplicate = true,
    possible_duplicate_of_site_id = p_existing_site_id,
    updated_at = now()
  where id = p_save_id and user_id = uid;

  if exists (
    select 1 from public.sites s
    where s.id = v_old_site and s.created_by = uid
  )
  and not exists (select 1 from public.user_saves where site_id = v_old_site)
  and not exists (select 1 from public.site_contributors where site_id = v_old_site)
  and not exists (select 1 from public.plan_stops where site_id = v_old_site)
  then
    delete from public.sites where id = v_old_site and created_by = uid;
  end if;

  return p_existing_site_id;
end;
$$;

grant execute on function public.link_save_to_existing_site(uuid, uuid) to authenticated;
