-- Permitir editar el texto de un reporte mientras no esté marcado como hecho.

drop policy if exists beta_feedback_update_pending on public.beta_feedback;
create policy beta_feedback_update_pending on public.beta_feedback
  for update to anon, authenticated
  using (done = false)
  with check (
    done = false
    and fixed_in_version is null
  );
