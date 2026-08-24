-- Cómo abrir Google Maps desde la ficha:
-- false (default) = búsqueda / ficha del lugar (nombre + google_place_id).
-- true = pin por lat/lng (punto exacto). Ambos datos se conservan.

alter table public.sites
  add column if not exists use_exact_pin boolean not null default false;

comment on column public.sites.use_exact_pin is
  'true: Maps con coords; false: Maps con nombre/place_id. No borra location.';
