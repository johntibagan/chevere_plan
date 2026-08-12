-- Place ID de Google para abrir Maps con ficha (fotos/reseñas), no solo pin.

alter table public.sites
  add column if not exists google_place_id text;

create index if not exists sites_google_place_id_idx
  on public.sites (google_place_id)
  where google_place_id is not null;

comment on column public.sites.google_place_id is
  'Places API place_id (ChIJ…). Usado en deep links a Google Maps.';
