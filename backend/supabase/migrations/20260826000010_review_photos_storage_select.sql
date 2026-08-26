-- Fotos de reseñas públicas: createSignedUrl fallaba para otros usuarios.
-- La SELECT de storage solo miraba site_photos; site_review_photos queda
-- en el mismo bucket (path {uid}/reviews/{reviewId}/…).

drop policy if exists site_photos_storage_select on storage.objects;

create policy site_photos_storage_select on storage.objects
  for select to authenticated
  using (
    bucket_id = 'site-photos'
    and (
      (storage.foldername(objects.name))[1] = auth.uid()::text
      or public.is_staff()
      or exists (
        select 1
        from public.site_photos sp
        join public.sites s on s.id = sp.site_id
        where sp.storage_path = objects.name
          and (
            s.is_public
            or s.created_by = auth.uid()
            or public.is_staff()
          )
      )
      or exists (
        select 1
        from public.site_review_photos rp
        join public.site_reviews r on r.id = rp.review_id
        join public.sites s on s.id = r.site_id
        where rp.storage_path = objects.name
          and (
            r.user_id = auth.uid()
            or (
              r.is_public
              and (
                s.is_public
                or s.created_by = auth.uid()
                or public.is_staff()
              )
            )
          )
      )
    )
  );
