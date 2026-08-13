-- Varias reseñas por usuario en el mismo sitio (bitácora / visitas).

alter table public.site_reviews
  drop constraint if exists site_reviews_site_id_user_id_key;

-- Índice para listar / filtrar por sitio + rating / fecha
create index if not exists site_reviews_site_rating_idx
  on public.site_reviews (site_id, rating, created_at desc);

create index if not exists site_reviews_site_created_idx
  on public.site_reviews (site_id, created_at desc);
