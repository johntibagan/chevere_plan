-- Descripción de reportes beta: 500 → 1000 caracteres.

alter table public.beta_feedback
  drop constraint if exists beta_feedback_body_len;

alter table public.beta_feedback
  add constraint beta_feedback_body_len check (
    char_length(trim(body)) between 3 and 1000
  );
