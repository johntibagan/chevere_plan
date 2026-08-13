-- Privacidad de reseñas: públicas (promedio / ficha) o privadas (bitácora).

alter table public.site_reviews
  add column if not exists is_public boolean not null default false;

comment on column public.site_reviews.is_public is
  'Si true y el sitio es público, visible a otros y cuenta en el promedio. Si false, solo el autor (bitácora).';

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

-- Promedio solo con reseñas públicas
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
