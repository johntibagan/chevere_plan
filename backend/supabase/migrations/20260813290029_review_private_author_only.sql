-- Bitácora privada: SOLO el autor. Admin/root no la ven.
-- Staff conserva privilegios sobre lo público (sitios, reseñas públicas, etc.).

drop policy if exists site_reviews_select on public.site_reviews;
create policy site_reviews_select on public.site_reviews
  for select to authenticated
  using (
    user_id = auth.uid()
    or (
      is_public = true
      and exists (
        select 1 from public.sites s
        where s.id = site_id
          and (s.is_public or s.created_by = auth.uid() or public.is_staff())
      )
    )
  );

drop policy if exists site_reviews_update on public.site_reviews;
create policy site_reviews_update on public.site_reviews
  for update to authenticated
  using (
    user_id = auth.uid()
    or (public.is_staff() and is_public = true)
  )
  with check (
    user_id = auth.uid()
    or (public.is_staff() and is_public = true)
  );

drop policy if exists site_reviews_delete on public.site_reviews;
create policy site_reviews_delete on public.site_reviews
  for delete to authenticated
  using (
    user_id = auth.uid()
    or (public.is_staff() and is_public = true)
  );

drop policy if exists site_review_photos_select on public.site_review_photos;
create policy site_review_photos_select on public.site_review_photos
  for select to authenticated
  using (
    exists (
      select 1 from public.site_reviews r
      where r.id = review_id
        and (
          r.user_id = auth.uid()
          or (
            r.is_public = true
            and exists (
              select 1 from public.sites s
              where s.id = r.site_id
                and (s.is_public or s.created_by = auth.uid() or public.is_staff())
            )
          )
        )
    )
  );

drop policy if exists site_review_photos_write on public.site_review_photos;
create policy site_review_photos_write on public.site_review_photos
  for all to authenticated
  using (
    exists (
      select 1 from public.site_reviews r
      where r.id = review_id
        and (
          r.user_id = auth.uid()
          or (public.is_staff() and r.is_public = true)
        )
    )
  )
  with check (
    exists (
      select 1 from public.site_reviews r
      where r.id = review_id
        and (
          r.user_id = auth.uid()
          or (public.is_staff() and r.is_public = true)
        )
    )
  );

comment on column public.site_reviews.is_public is
  'true: visible en ficha/promedio (moderables por staff). false: bitácora solo del autor; ni admin/root la ven.';

comment on policy site_reviews_select on public.site_reviews is
  'Autor ve las suyas (incl. bitácora). Resto y staff solo reseñas públicas en sitios visibles.';
