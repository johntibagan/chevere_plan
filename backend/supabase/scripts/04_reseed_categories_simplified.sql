-- =============================================================================
-- RESEED categorías (propuesta simplificada)
-- Fuente: frontend/categorias-propuesta-simplificada.csv
--
-- Requisitos: site_categories vacío (p. ej. tras 00_reset_public.sql).
-- Ejecutar en: Supabase SQL Editor.
--
-- Tras aplicar: cerrar sesión en la app (limpia caché de categorías).
-- =============================================================================

truncate table public.site_categories restart identity cascade;
truncate table public.categories restart identity cascade;

-- Raíces
insert into public.categories (slug, name_i18n, sort_order, icon_key, color_hex, is_active, age_restricted, keywords)
values
  ('gastronomia', '{"es": "Gastronomía"}'::jsonb, 1, 'coffee', '#FF8C42', true, false, array['comida','comer','restaurante','beber','gastro','food']::text[]),
  ('alojamiento', '{"es": "Alojamiento"}'::jsonb, 2, 'bed', '#8B7FFF', true, false, array['hotel','hospedaje','dormir','quedarse','hospedar','lodging']::text[]),
  ('naturaleza', '{"es": "Naturaleza y aire libre"}'::jsonb, 3, 'trees', '#00D68F', true, false, array['aire libre','outdoor','naturaleza','campo','verde','ecologia']::text[]),
  ('deporte', '{"es": "Deporte y recreación"}'::jsonb, 4, 'sport', '#2ECC71', true, false, array['deporte','deportivo','ejercicio','cancha','juego','actividad fisica']::text[]),
  ('cultura', '{"es": "Cultura e historia"}'::jsonb, 5, 'palette', '#E84393', true, false, array['cultura','historia','patrimonio','turismo cultural','monumentos']::text[]),
  ('entretenimiento', '{"es": "Planes y entretenimiento"}'::jsonb, 6, 'music', '#FFBB33', true, false, array['plan','planes','diversion','ocio','recreacion','entretenimiento','salir']::text[]),
  ('compras', '{"es": "Compras"}'::jsonb, 7, 'shopping', '#00C9A7', true, false, array['comprar','shopping','tienda','mercado','souvenir']::text[]),
  ('otros', '{"es": "Otros"}'::jsonb, 8, 'more', '#9E9E9E', true, false, array['otro','otros','varios','terminal','transporte']::text[]);

-- Subcategorías
insert into public.categories (parent_id, slug, name_i18n, sort_order, is_active, age_restricted, keywords)
select p.id, v.slug, v.name_i18n, v.sort_order, v.is_active, v.age_restricted, v.keywords
from public.categories p
join (
  values
    ('gastronomia', 'restaurante', '{"es": "Restaurante"}'::jsonb, 1, true, false, array['comida','almuerzo','cena','menu','comer','restaurant']::text[]),
    ('gastronomia', 'cafeteria', '{"es": "Cafetería"}'::jsonb, 2, true, false, array['cafe','café','coffee','brunch','desayuno','tinto']::text[]),
    ('gastronomia', 'comida-tipica', '{"es": "Comida típica / regional"}'::jsonb, 3, true, false, array['tipica','bandeja','ajiaco','sancocho','arepas','regional','criolla']::text[]),
    ('gastronomia', 'comida-rapida-callejera', '{"es": "Comida rápida / callejera"}'::jsonb, 4, true, false, array['rapida','hamburguesa','pizza','perro','hot dog','fast food','delivery','food truck','calle','street food','carrito','puesto']::text[]),
    ('gastronomia', 'asadero-piqueteadero', '{"es": "Asadero / piqueteadero"}'::jsonb, 5, true, false, array['asado','carne','bbq','parrilla','churrasco','braza','piquete','fritanga','chicharron','chorizo','picada']::text[]),
    ('gastronomia', 'bar-cerveceria', '{"es": "Bar / cervecería"}'::jsonb, 6, true, true, array['bar','bares','tragos','cocteles','cócteles','rumba','nightlife','pub','drinks','cerveza','craft','birra','brewery','beer']::text[]),
    ('gastronomia', 'postres-panaderia', '{"es": "Postres / panadería / heladería"}'::jsonb, 7, true, false, array['pan','pastel','torta','postre','bakery','dulce','amasijo','helado','nieve','gelato','paleta','ice cream']::text[]),
    ('alojamiento', 'hotel', '{"es": "Hotel"}'::jsonb, 1, true, false, array['hotel','hospedaje','suite','resort','eco hotel']::text[]),
    ('alojamiento', 'hostal', '{"es": "Hostal / hostel"}'::jsonb, 2, true, false, array['hostal','hostel','backpacker','mochilero']::text[]),
    ('alojamiento', 'finca-glamping', '{"es": "Finca / glamping / camping"}'::jsonb, 3, true, false, array['finca','quinta','casa campo','descanso','villa','camping','campamento','carpa','glamping','tienda de campaña','cabana','cabaña','cabin','chalet']::text[]),
    ('alojamiento', 'posada-boutique', '{"es": "Posada / boutique"}'::jsonb, 4, true, false, array['posada','boutique','bed and breakfast','b&b']::text[]),
    ('naturaleza', 'parque-natural-reserva', '{"es": "Parque natural / reserva"}'::jsonb, 1, true, false, array['parque','reserva','bosque','national park','naturaleza','ecologia','ecológica','biodiversidad','conservacion']::text[]),
    ('naturaleza', 'sendero-caminata', '{"es": "Sendero / caminata"}'::jsonb, 2, true, false, array['caminar','caminata','hiking','trek','trekking','senderismo','paseo','trail','pie']::text[]),
    ('naturaleza', 'cascada-rio-represa-laguna', '{"es": "Cascada / río / represa / laguna"}'::jsonb, 3, true, false, array['cascada','rio','río','quebrada','agua','chorro','waterfall','lago','laguna','embalse','represa','nadar','kayak']::text[]),
    ('naturaleza', 'playa', '{"es": "Playa / balneario"}'::jsonb, 4, true, false, array['playa','mar','arena','balneario','costa','nadar','oleaje','surf']::text[]),
    ('naturaleza', 'montana-mirador', '{"es": "Montaña / mirador"}'::jsonb, 5, true, false, array['montana','montaña','cerro','pico','altura','escalar','vista','panorama','atardecer','viewpoint','mirador','mirar']::text[]),
    ('naturaleza', 'termales', '{"es": "Termales / aguas termales"}'::jsonb, 6, true, false, array['termales','termal','aguas termales','jacuzzi natural','hot spring','agua caliente']::text[]),
    ('naturaleza', 'parque-urbano', '{"es": "Parque urbano"}'::jsonb, 7, true, false, array['parque','parque urbano','parque recreativo','zona verde','picnic','pradera']::text[]),
    ('deporte', 'cancha-deportiva', '{"es": "Cancha deportiva"}'::jsonb, 1, true, false, array['cancha','futbol','fútbol','basquet','basket','tenis','voley','soccer']::text[]),
    ('deporte', 'tejo', '{"es": "Tejo"}'::jsonb, 2, true, false, array['tejo','cancha de tejo','turmeque','pólvora','polvora','juego tipico']::text[]),
    ('deporte', 'piscina', '{"es": "Piscina"}'::jsonb, 3, true, false, array['piscina','alberca','natacion','natación','nadar','agua','pool','chapuzon']::text[]),
    ('deporte', 'patinaje', '{"es": "Patinaje"}'::jsonb, 4, true, false, array['patinaje','patinar','patines','skate','pista de patinaje']::text[]),
    ('deporte', 'gimnasio-fitness', '{"es": "Gimnasio / fitness"}'::jsonb, 5, true, false, array['gym','gimnasio','fitness','ejercicio','pesas','crossfit']::text[]),
    ('deporte', 'deporte-aventura', '{"es": "Deporte de aventura"}'::jsonb, 6, true, false, array['aventura','rappel','rafting','canopy','parapente','escalada','bungee','adrenaline','bici','bicicleta','ciclovia','ciclismo','mtb','paddle','surf','buceo','snorkel','correr','running']::text[]),
    ('cultura', 'museo', '{"es": "Museo"}'::jsonb, 1, true, false, array['museo','exposicion','exposición','coleccion','gallery museum']::text[]),
    ('cultura', 'centro-historico-patrimonio', '{"es": "Centro histórico / patrimonio"}'::jsonb, 2, true, false, array['centro','casco historico','histórico','colonia','patrimonio','arquitectura','edificio historico','casona']::text[]),
    ('cultura', 'pueblo-ciudad', '{"es": "Pueblo / ciudad / destino"}'::jsonb, 3, true, false, array['pueblo','ciudad','municipio','destino','vereda','corregimiento']::text[]),
    ('cultura', 'iglesia-templo', '{"es": "Iglesia / templo"}'::jsonb, 4, true, false, array['iglesia','templo','catedral','capilla','santuario','mezquita']::text[]),
    ('cultura', 'plaza-principal', '{"es": "Plaza principal / Plaza de Bolívar"}'::jsonb, 5, true, false, array['plaza','plaza de bolivar','bolívar','parque principal','plaza mayor','centro plaza','square']::text[]),
    ('cultura', 'galeria-arte', '{"es": "Galería de arte"}'::jsonb, 6, true, false, array['galeria','arte','exposicion','pintura','fotografia']::text[]),
    ('entretenimiento', 'cine-teatro-conciertos', '{"es": "Cine / teatro / conciertos"}'::jsonb, 1, true, false, array['cine','teatro','pelicula','obra','show','cinema','concierto','musica','banda','live']::text[]),
    ('entretenimiento', 'parque-tematico-acuatico', '{"es": "Parque temático / acuático"}'::jsonb, 2, true, false, array['tematico','atracciones','juegos mecanicos','theme park','acuatico','toboganes','water park']::text[]),
    ('entretenimiento', 'vida-nocturna-juegos', '{"es": "Discoteca / karaoke / juegos"}'::jsonb, 3, true, true, array['discoteca','disco','club','bailar','dj','karaoke','cantar','bolos','bowling','bolera','billar','pool','escape room']::text[]),
    ('entretenimiento', 'spa-bienestar', '{"es": "Spa / bienestar"}'::jsonb, 4, true, false, array['spa','masaje','relajar','wellness','sauna','cuidado']::text[]),
    ('entretenimiento', 'actividad-familiar', '{"es": "Actividad familiar / niños"}'::jsonb, 5, true, false, array['familiar','ninos','niños','kids','familia','infantil']::text[]),
    ('entretenimiento', 'festival-feria', '{"es": "Festival / feria / evento"}'::jsonb, 6, true, false, array['festival','festejo','carnaval','feria','exposicion','stand','evento cultural','evento deportivo','torneo','procesion','procesión','religioso']::text[]),
    ('compras', 'centro-comercial', '{"es": "Centro comercial"}'::jsonb, 1, true, false, array['mall','cc','centro comercial','shopping center']::text[]),
    ('compras', 'mercado-artesanal-plaza', '{"es": "Mercado artesanal / plaza de mercado"}'::jsonb, 2, true, false, array['artesanal','artesania','artesanías','hecho a mano','plaza de mercado','galeria','frutas','verduras','mercado']::text[]),
    ('compras', 'tienda-souvenir', '{"es": "Tienda de souvenir / artesanías"}'::jsonb, 3, true, false, array['souvenir','regalo','artesania','feria','pulgas','vintage','anticuario']::text[]),
    ('compras', 'tienda-general', '{"es": "Tienda"}'::jsonb, 4, true, false, array['tienda','almacen','almacén','ropa','calzado','shop','store']::text[]),
    ('otros', 'terminal-transporte', '{"es": "Terminal / transporte"}'::jsonb, 1, true, false, array['terminal','bus','aeropuerto','transporte','estacion','estación']::text[]),
    ('otros', 'otro', '{"es": "Otro"}'::jsonb, 2, true, false, array['otro','otros','varios']::text[])
) as v(parent_slug, slug, name_i18n, sort_order, is_active, age_restricted, keywords)
  on p.slug = v.parent_slug and p.parent_id is null;

-- Verificación rápida
select coalesce(p.name_i18n->>'es', p.slug) as category,
       count(c.id) as subcategories
from public.categories p
left join public.categories c on c.parent_id = p.id
where p.parent_id is null
group by p.id, p.name_i18n, p.slug, p.sort_order
order by p.sort_order;
