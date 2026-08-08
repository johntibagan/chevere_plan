# Backend Supabase — Ciclo 1

## Aplicar migraciones (SQL Editor)

1. Abre el proyecto en [Supabase Dashboard](https://supabase.com/dashboard) → **SQL Editor**.
2. Ejecuta en orden el contenido actualizado de:
   - `supabase/migrations/20260808000001_ciclo1_schema.sql`
   - `supabase/migrations/20260808000002_ciclo1_seed.sql`
3. Verifica: Table Editor debe mostrar `profiles`, `categories`, `transport_types`, `sites`, etc.

> **Nota:** si un intento anterior falló a mitad, vuelve a pegar el schema completo (es idempotente con `if not exists` / `create or replace`). No hace falta borrar el proyecto.

## Ciclo 2 — Storage + columnas borrador

Ejecuta también:

- `supabase/migrations/20260808000003_ciclo2_draft_storage.sql`

(crea/asegura bucket `site-photos` + policies + columnas `draft_remind_at`).

## Ciclo 3 — Anti-duplicados

Ejecuta:

- `supabase/migrations/20260808000004_ciclo3_duplicates.sql`

## Ciclo 4 — Proximidad / geofencing

Ejecuta:

- `supabase/migrations/20260808000005_ciclo4_proximity.sql`

(añade `profiles.proximity_radius_m`, `profiles.remind_public_sites` y RPC `list_proximity_sites`).

## Bootstrap root (obligatorio una vez)

Tras iniciar sesión en la app con tu Google, ejecuta **todo este bloque** en SQL Editor:

```sql
-- 1) Permitir bootstrap desde el SQL Editor (auth.uid() es null ahí)
create or replace function public.prevent_role_escalation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if new.role is distinct from old.role then
    if auth.uid() is null then
      return new;
    end if;
    if not public.is_staff() then
      raise exception 'Solo admin/root pueden cambiar roles';
    end if;
  end if;
  return new;
end;
$$;

-- 2) Backfill si tu usuario ya existía antes del trigger
insert into public.profiles (id, display_name, role)
select id, coalesce(raw_user_meta_data->>'full_name', email), 'user'
from auth.users
on conflict (id) do nothing;

-- 3) Conviértete en root
update public.profiles
set role = 'root'
where id = (select id from auth.users where email = 'johnftmovil@gmail.com');
```

## Designar admin (solo root/staff vía SQL por ahora)

```sql
update public.profiles
set role = 'admin'
where id = (select id from auth.users where email = 'otro@gmail.com');
```
