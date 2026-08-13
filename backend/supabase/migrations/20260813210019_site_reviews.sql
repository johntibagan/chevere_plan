-- Reseñas por sitio: varias por usuario (bitácora), estrellas, hasta 3 fotos.
-- is_public: reseña pública (promedio) vs bitácora privada.

create table if not exists public.site_reviews (
  id uuid primary key default gen_random_uuid(),
  site_id uuid not null references public.sites (id) on delete cascade,
  user_id uuid not null references public.profiles (id) on delete cascade,
  body text not null default '',
  rating smallint not null check (rating between 1 and 5),
  is_public boolean not null default false,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index if not exists site_reviews_site_id_idx
  on public.site_reviews (site_id, updated_at desc);

create index if not exists site_reviews_site_rating_idx
  on public.site_reviews (site_id, rating, created_at desc);

create index if not exists site_reviews_site_created_idx
  on public.site_reviews (site_id, created_at desc);

drop trigger if exists site_reviews_set_updated_at on public.site_reviews;
create trigger site_reviews_set_updated_at
before update on public.site_reviews
for each row execute function public.set_updated_at();

create table if not exists public.site_review_photos (
  id uuid primary key default gen_random_uuid(),
  review_id uuid not null references public.site_reviews (id) on delete cascade,
  storage_path text not null,
  sort_order int not null default 0,
  uploaded_by uuid references public.profiles (id) on delete set null,
  created_at timestamptz not null default now()
);

create index if not exists site_review_photos_review_id_idx
  on public.site_review_photos (review_id, sort_order);

-- Máx. 3 fotos por reseña
create or replace function public.enforce_site_review_photo_limit()
returns trigger
language plpgsql
as $$
declare
  n int;
begin
  select count(*) into n from public.site_review_photos where review_id = new.review_id;
  if n >= 3 then
    raise exception 'max 3 photos per review';
  end if;
  return new;
end;
$$;

drop trigger if exists site_review_photos_limit on public.site_review_photos;
create trigger site_review_photos_limit
before insert on public.site_review_photos
for each row execute function public.enforce_site_review_photo_limit();

alter table public.site_reviews enable row level security;
alter table public.site_review_photos enable row level security;

drop policy if exists site_reviews_select on public.site_reviews;
create policy site_reviews_select on public.site_reviews
  for select to authenticated
  using (
    public.is_staff()
    or user_id = auth.uid()
    or (
      is_public = true
      and exists (
        select 1 from public.sites s
        where s.id = site_id
          and (s.is_public or s.created_by = auth.uid())
      )
    )
  );

drop policy if exists site_reviews_insert on public.site_reviews;
create policy site_reviews_insert on public.site_reviews
  for insert to authenticated
  with check (
    user_id = auth.uid()
    and exists (
      select 1 from public.sites s
      where s.id = site_id
        and (s.is_public or s.created_by = auth.uid() or public.is_staff())
    )
  );

drop policy if exists site_reviews_update on public.site_reviews;
create policy site_reviews_update on public.site_reviews
  for update to authenticated
  using (user_id = auth.uid() or public.is_staff())
  with check (user_id = auth.uid() or public.is_staff());

drop policy if exists site_reviews_delete on public.site_reviews;
create policy site_reviews_delete on public.site_reviews
  for delete to authenticated
  using (user_id = auth.uid() or public.is_staff());

drop policy if exists site_review_photos_select on public.site_review_photos;
create policy site_review_photos_select on public.site_review_photos
  for select to authenticated
  using (
    exists (
      select 1 from public.site_reviews r
      where r.id = review_id
        and (
          public.is_staff()
          or r.user_id = auth.uid()
          or (
            r.is_public = true
            and exists (
              select 1 from public.sites s
              where s.id = r.site_id
                and (s.is_public or s.created_by = auth.uid())
            )
          )
        )
    )
  );

drop policy if exists site_review_photos_write on public.site_review_photos;
create policy site_review_photos_write on public.site_review_photos
  for all to authenticated
  using (
    public.is_staff()
    or exists (
      select 1 from public.site_reviews r
      where r.id = review_id and r.user_id = auth.uid()
    )
  )
  with check (
    public.is_staff()
    or exists (
      select 1 from public.site_reviews r
      where r.id = review_id and r.user_id = auth.uid()
    )
  );

-- Storage: reutilizar bucket site-photos; path {uid}/reviews/{reviewId}/...
-- (mismas policies de insert/update/delete por carpeta del usuario)

create or replace function public.site_rating_summary(p_site_id uuid)
returns json
language sql
stable
security invoker
set search_path = public
as $$
  select json_build_object(
    'avg_rating', coalesce(round(avg(rating)::numeric, 1), 0),
    'review_count', count(*)
  )
  from public.site_reviews
  where site_id = p_site_id
    and is_public = true;
$$;

grant execute on function public.site_rating_summary(uuid) to authenticated;

-- Ver perfiles de autores de reseñas públicas en sitios públicos
drop policy if exists profiles_select_public_reviewers on public.profiles;
create policy profiles_select_public_reviewers on public.profiles
  for select to authenticated
  using (
    exists (
      select 1
      from public.site_reviews r
      join public.sites s on s.id = r.site_id
      where r.user_id = profiles.id
        and r.is_public = true
        and s.is_public = true
    )
  );
