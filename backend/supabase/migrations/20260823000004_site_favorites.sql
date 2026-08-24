-- Favoritos de sitio (corazón). Independiente de user_saves.
-- Frontend: lista site_id del usuario; insert/delete al tocar el corazón.
-- No altera coords ni visibilidad del sitio.

create table if not exists public.site_favorites (
  user_id uuid not null references public.profiles(id) on delete cascade,
  site_id uuid not null references public.sites(id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (user_id, site_id)
);

create index if not exists site_favorites_site_id_idx
  on public.site_favorites (site_id);

alter table public.site_favorites enable row level security;

drop policy if exists site_favorites_own on public.site_favorites;
create policy site_favorites_own on public.site_favorites
  for all
  to authenticated
  using (user_id = auth.uid())
  with check (user_id = auth.uid());

grant select, insert, delete on table public.site_favorites to authenticated;
revoke all on table public.site_favorites from anon;
