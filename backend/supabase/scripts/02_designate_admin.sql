-- Designar admin (solo después de tener un root).
-- Sustituye el email del usuario a promover.

update public.profiles
set role = 'admin'
where id = (
  select id from auth.users where email = 'otro@gmail.com'
);
