-- Privacidad reseñas: el creador del sitio NO ve bitácoras privadas ajenas.
-- Solo staff (admin/root), el autor, o reseñas is_public=true (si el sitio es
-- visible). Reafirma la policy por si hubo confusión con privilegios de dueño.
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
          and (s.is_public or s.created_by = auth.uid() or public.is_staff())
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
                and (s.is_public or s.created_by = auth.uid() or public.is_staff())
            )
          )
        )
    )
  );

comment on policy site_reviews_select on public.site_reviews is
  'Staff ve todo; autor ve las suyas; terceros solo reseñas públicas en sitios visibles. Crear un sitio no otorga ver bitácoras ajenas.';
