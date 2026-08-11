-- Enlaces de redes / web asociados a un sitio (previews OG cacheados en fila).

create table if not exists public.site_social_links (
  id uuid primary key default gen_random_uuid(),
  site_id uuid not null references public.sites (id) on delete cascade,
  url text not null,
  network text,
  title text,
  description text,
  image_url text,
  sort_order int not null default 0,
  added_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now(),
  unique (site_id, url)
);

create index if not exists site_social_links_site_id_idx
  on public.site_social_links (site_id);

alter table public.site_social_links enable row level security;

drop policy if exists site_social_links_select on public.site_social_links;
create policy site_social_links_select on public.site_social_links
  for select to authenticated
  using (
    exists (
      select 1 from public.sites s
      where s.id = site_id
        and (s.is_public or s.created_by = auth.uid() or public.is_staff())
    )
  );

drop policy if exists site_social_links_write on public.site_social_links;
create policy site_social_links_write on public.site_social_links
  for all to authenticated
  using (
    public.is_staff()
    or exists (
      select 1 from public.sites s
      where s.id = site_id and s.created_by = auth.uid()
    )
  )
  with check (
    public.is_staff()
    or exists (
      select 1 from public.sites s
      where s.id = site_id and s.created_by = auth.uid()
    )
  );
