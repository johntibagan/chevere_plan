-- Perfiles visibles: creadores de sitios públicos (avatar + nombre vía tooltip en app).
-- Complementa profiles_select_public_contributors (ciclo 3).

drop policy if exists profiles_select_public_site_creators on public.profiles;
create policy profiles_select_public_site_creators on public.profiles
  for select to authenticated
  using (
    exists (
      select 1
      from public.sites s
      where s.created_by = profiles.id
        and s.is_public = true
    )
  );
