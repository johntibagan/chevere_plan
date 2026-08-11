-- Bootstrap root (ejecutar DESPUÉS del primer login Google en la app).
-- 1) Sustituye el email por el tuyo.
-- 2) Corre este archivo entero en SQL Editor.

-- Backfill de perfil si el usuario existía antes del trigger
insert into public.profiles (id, display_name, role)
select
  id,
  coalesce(raw_user_meta_data->>'full_name', email),
  'user'
from auth.users
on conflict (id) do nothing;

-- Designar root (cambia el email)
update public.profiles
set role = 'root'
where id = (
  select id from auth.users where email = 'johnftmovil@gmail.com'
);
