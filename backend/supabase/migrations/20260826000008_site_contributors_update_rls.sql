-- site_contributors: upsert falla sin política UPDATE (USING).
-- El creador ya es contributor; al reeditar un sitio público PostgREST
-- hace UPDATE del conflicto y RLS lo bloqueaba → “Error en la app.”

drop policy if exists site_contributors_update on public.site_contributors;
create policy site_contributors_update on public.site_contributors
  for update to authenticated
  using ((user_id = auth.uid()) or is_staff())
  with check ((user_id = auth.uid()) or is_staff());
