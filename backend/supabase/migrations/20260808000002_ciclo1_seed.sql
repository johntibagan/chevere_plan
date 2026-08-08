-- Seed categorías (§4.1) y transporte (§7.2) — idempotente

insert into public.categories (slug, name_i18n, sort_order, icon_key, color_hex, age_restricted)
select v.slug, v.name_i18n, v.sort_order, v.icon_key, v.color_hex, false
from (
  values
    ('gastronomia', '{"es":"Gastronomía"}'::jsonb, 1, 'coffee', '#FF8C42'),
    ('alojamiento', '{"es":"Alojamiento"}'::jsonb, 2, 'bed', '#8B7FFF'),
    ('naturaleza', '{"es":"Naturaleza y aire libre"}'::jsonb, 3, 'trees', '#00D68F'),
    ('cultura', '{"es":"Cultura e historia"}'::jsonb, 4, 'palette', '#E84393'),
    ('entretenimiento', '{"es":"Entretenimiento y planes"}'::jsonb, 5, 'music', '#FFBB33'),
    ('compras', '{"es":"Compras"}'::jsonb, 6, 'shopping', '#00C9A7'),
    ('eventos', '{"es":"Eventos"}'::jsonb, 7, 'calendar', '#FF5252'),
    ('servicios', '{"es":"Servicios turísticos"}'::jsonb, 8, 'globe', '#4A90D9')
) as v(slug, name_i18n, sort_order, icon_key, color_hex)
where not exists (
  select 1 from public.categories c where c.parent_id is null and c.slug = v.slug
);

insert into public.categories (parent_id, slug, name_i18n, sort_order, age_restricted)
select p.id, v.slug, v.name_i18n, v.sort_order, v.age_restricted
from public.categories p
join (
  values
    ('gastronomia', 'restaurante', '{"es":"Restaurante"}'::jsonb, 1, false),
    ('gastronomia', 'cafeteria', '{"es":"Cafetería"}'::jsonb, 2, false),
    ('gastronomia', 'bar-vida-nocturna', '{"es":"Bar/Vida nocturna"}'::jsonb, 3, true),
    ('gastronomia', 'comida-rapida', '{"es":"Comida rápida"}'::jsonb, 4, false),
    ('gastronomia', 'panaderia-reposteria', '{"es":"Panadería/Repostería"}'::jsonb, 5, false),
    ('gastronomia', 'heladeria', '{"es":"Heladería"}'::jsonb, 6, false),
    ('gastronomia', 'food-truck', '{"es":"Food truck"}'::jsonb, 7, false),
    ('alojamiento', 'hotel', '{"es":"Hotel"}'::jsonb, 1, false),
    ('alojamiento', 'hostal', '{"es":"Hostal"}'::jsonb, 2, false),
    ('alojamiento', 'glamping-camping', '{"es":"Glamping/Camping"}'::jsonb, 3, false),
    ('alojamiento', 'finca-casa-descanso', '{"es":"Finca/Casa de descanso"}'::jsonb, 4, false),
    ('alojamiento', 'posada', '{"es":"Posada"}'::jsonb, 5, false),
    ('naturaleza', 'mirador', '{"es":"Mirador"}'::jsonb, 1, false),
    ('naturaleza', 'sendero-caminata', '{"es":"Sendero/Caminata"}'::jsonb, 2, false),
    ('naturaleza', 'cascada-rio', '{"es":"Cascada/Río"}'::jsonb, 3, false),
    ('naturaleza', 'montana', '{"es":"Montaña"}'::jsonb, 4, false),
    ('naturaleza', 'parque-natural', '{"es":"Parque natural"}'::jsonb, 5, false),
    ('naturaleza', 'playa-balneario', '{"es":"Playa/Balneario"}'::jsonb, 6, false),
    ('naturaleza', 'reserva-ecologica', '{"es":"Reserva ecológica"}'::jsonb, 7, false),
    ('cultura', 'museo', '{"es":"Museo"}'::jsonb, 1, false),
    ('cultura', 'monumento', '{"es":"Monumento"}'::jsonb, 2, false),
    ('cultura', 'iglesia-templo', '{"es":"Iglesia/Templo"}'::jsonb, 3, false),
    ('cultura', 'sitio-arqueologico', '{"es":"Sitio arqueológico"}'::jsonb, 4, false),
    ('cultura', 'centro-historico', '{"es":"Centro histórico"}'::jsonb, 5, false),
    ('cultura', 'galeria-arte', '{"es":"Galería de arte"}'::jsonb, 6, false),
    ('entretenimiento', 'parque-tematico', '{"es":"Parque temático/Recreacional"}'::jsonb, 1, false),
    ('entretenimiento', 'deporte-aventura', '{"es":"Deporte de aventura"}'::jsonb, 2, false),
    ('entretenimiento', 'spa-bienestar', '{"es":"Spa/Bienestar"}'::jsonb, 3, false),
    ('entretenimiento', 'cine-teatro', '{"es":"Cine/Teatro"}'::jsonb, 4, false),
    ('entretenimiento', 'actividad-familiar', '{"es":"Actividad familiar"}'::jsonb, 5, false),
    ('compras', 'mercado-artesanal', '{"es":"Mercado artesanal"}'::jsonb, 1, false),
    ('compras', 'centro-comercial', '{"es":"Centro comercial"}'::jsonb, 2, false),
    ('compras', 'tienda-local', '{"es":"Tienda local/Souvenir"}'::jsonb, 3, false),
    ('eventos', 'festival', '{"es":"Festival"}'::jsonb, 1, false),
    ('eventos', 'concierto', '{"es":"Concierto"}'::jsonb, 2, false),
    ('eventos', 'feria', '{"es":"Feria"}'::jsonb, 3, false),
    ('eventos', 'evento-cultural', '{"es":"Evento cultural"}'::jsonb, 4, false),
    ('eventos', 'evento-deportivo', '{"es":"Evento deportivo"}'::jsonb, 5, false),
    ('eventos', 'evento-religioso', '{"es":"Evento religioso"}'::jsonb, 6, false),
    ('servicios', 'agencia-viajes', '{"es":"Agencia de viajes"}'::jsonb, 1, false),
    ('servicios', 'guia-turistico', '{"es":"Guía turístico"}'::jsonb, 2, false),
    ('servicios', 'alquiler-equipos', '{"es":"Alquiler de equipos"}'::jsonb, 3, false)
) as v(parent_slug, slug, name_i18n, sort_order, age_restricted)
  on p.slug = v.parent_slug and p.parent_id is null
where not exists (
  select 1 from public.categories c
  where c.parent_id = p.id and c.slug = v.slug
);

insert into public.transport_types (transport_group, slug, name_i18n, default_max_km, sort_order, icon_key)
select v.transport_group::public.transport_group, v.slug, v.name_i18n, v.default_max_km, v.sort_order, v.icon_key
from (
  values
    ('particular', 'caminar', '{"es":"Caminar"}'::jsonb, 3::numeric, 1, 'walk'),
    ('particular', 'bicicleta', '{"es":"Bicicleta"}'::jsonb, 10::numeric, 2, 'bike'),
    ('particular', 'moto-propia', '{"es":"Moto propia"}'::jsonb, null::numeric, 3, 'moto'),
    ('particular', 'carro-propio', '{"es":"Carro propio"}'::jsonb, null::numeric, 4, 'car'),
    ('publico', 'bus', '{"es":"Bus"}'::jsonb, null::numeric, 10, 'bus'),
    ('publico', 'transporte-masivo', '{"es":"Sistema de transporte masivo"}'::jsonb, null::numeric, 11, 'metro'),
    ('publico', 'colectivo-buseta', '{"es":"Colectivo/Buseta intermunicipal"}'::jsonb, null::numeric, 12, 'minibus'),
    ('otro', 'taxi', '{"es":"Taxi"}'::jsonb, null::numeric, 20, 'taxi'),
    ('otro', 'uber', '{"es":"Uber"}'::jsonb, null::numeric, 21, 'uber'),
    ('otro', 'didi', '{"es":"DiDi"}'::jsonb, null::numeric, 22, 'didi'),
    ('otro', 'indriver', '{"es":"InDriver"}'::jsonb, null::numeric, 23, 'indriver')
) as v(transport_group, slug, name_i18n, default_max_km, sort_order, icon_key)
where not exists (
  select 1 from public.transport_types t where t.slug = v.slug
);
