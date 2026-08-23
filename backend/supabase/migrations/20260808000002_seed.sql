-- Seed categorías simplificadas + tipos de transporte.
-- + keywords para autocomplete. Idempotente.

insert into public.categories (slug, name_i18n, sort_order, icon_key, color_hex, age_restricted, keywords)
select v.slug, v.name_i18n, v.sort_order, v.icon_key, v.color_hex, false, v.keywords
from (
  values
    ('gastronomia', '{"es": "Gastronomía"}'::jsonb, 1, 'coffee', '#FF8C42', array['comida','comer','restaurante','beber','gastro','food']::text[]),
    ('alojamiento', '{"es": "Alojamiento"}'::jsonb, 2, 'bed', '#8B7FFF', array['hotel','hospedaje','dormir','quedarse','hospedar','lodging']::text[]),
    ('naturaleza', '{"es": "Naturaleza y aire libre"}'::jsonb, 3, 'trees', '#00D68F', array['aire libre','outdoor','naturaleza','campo','verde','ecologia']::text[]),
    ('deporte', '{"es": "Deporte y recreación"}'::jsonb, 4, 'sport', '#2ECC71', array['deporte','deportivo','ejercicio','cancha','juego','actividad fisica']::text[]),
    ('cultura', '{"es": "Cultura e historia"}'::jsonb, 5, 'palette', '#E84393', array['cultura','historia','patrimonio','turismo cultural','monumentos']::text[]),
    ('entretenimiento', '{"es": "Planes y entretenimiento"}'::jsonb, 6, 'music', '#FFBB33', array['plan','planes','diversion','ocio','recreacion','entretenimiento','salir']::text[]),
    ('compras', '{"es": "Compras"}'::jsonb, 7, 'shopping', '#00C9A7', array['comprar','shopping','tienda','mercado','souvenir']::text[]),
    ('otros', '{"es": "Otros"}'::jsonb, 8, 'more', '#9E9E9E', array['otro','otros','varios','terminal','transporte']::text[])
) as v(slug, name_i18n, sort_order, icon_key, color_hex, keywords)
where not exists (
  select 1 from public.categories c where c.parent_id is null and c.slug = v.slug
);

insert into public.categories (parent_id, slug, name_i18n, sort_order, age_restricted, keywords)
select p.id, v.slug, v.name_i18n, v.sort_order, v.age_restricted, v.keywords
from public.categories p
join (
  values
    ('gastronomia', 'restaurante', '{"es": "Restaurante"}'::jsonb, 1, false, array['comida','almuerzo','cena','menu','comer','restaurant']::text[]),
    ('gastronomia', 'cafeteria', '{"es": "Cafetería"}'::jsonb, 2, false, array['cafe','café','coffee','brunch','desayuno','tinto']::text[]),
    ('gastronomia', 'comida-tipica', '{"es": "Comida típica / regional"}'::jsonb, 3, false, array['tipica','bandeja','ajiaco','sancocho','arepas','regional','criolla']::text[]),
    ('gastronomia', 'comida-rapida-callejera', '{"es": "Comida rápida / callejera"}'::jsonb, 4, false, array['rapida','hamburguesa','pizza','perro','hot dog','fast food','delivery','food truck','calle','street food','carrito','puesto']::text[]),
    ('gastronomia', 'asadero-piqueteadero', '{"es": "Asadero / piqueteadero"}'::jsonb, 5, false, array['asado','carne','bbq','parrilla','churrasco','braza','piquete','fritanga','chicharron','chorizo','picada']::text[]),
    ('gastronomia', 'bar-cerveceria', '{"es": "Bar / cervecería"}'::jsonb, 6, true, array['bar','bares','tragos','cocteles','cócteles','rumba','nightlife','pub','drinks','cerveza','craft','birra','brewery','beer']::text[]),
    ('gastronomia', 'postres-panaderia', '{"es": "Postres / panadería / heladería"}'::jsonb, 7, false, array['pan','pastel','torta','postre','bakery','dulce','amasijo','helado','nieve','gelato','paleta','ice cream']::text[]),
    ('alojamiento', 'hotel', '{"es": "Hotel"}'::jsonb, 1, false, array['hotel','hospedaje','suite','resort','eco hotel']::text[]),
    ('alojamiento', 'hostal', '{"es": "Hostal / hostel"}'::jsonb, 2, false, array['hostal','hostel','backpacker','mochilero']::text[]),
    ('alojamiento', 'finca-glamping', '{"es": "Finca / glamping / camping"}'::jsonb, 3, false, array['finca','quinta','casa campo','descanso','villa','camping','campamento','carpa','glamping','tienda de campaña','cabana','cabaña','cabin','chalet']::text[]),
    ('alojamiento', 'posada-boutique', '{"es": "Posada / boutique"}'::jsonb, 4, false, array['posada','boutique','bed and breakfast','b&b']::text[]),
    ('naturaleza', 'parque-natural-reserva', '{"es": "Parque natural / reserva"}'::jsonb, 1, false, array['parque','reserva','bosque','national park','naturaleza','ecologia','ecológica','biodiversidad','conservacion']::text[]),
    ('naturaleza', 'sendero-caminata', '{"es": "Sendero / caminata"}'::jsonb, 2, false, array['caminar','caminata','hiking','trek','trekking','senderismo','paseo','trail','pie']::text[]),
    ('naturaleza', 'cascada-rio-represa-laguna', '{"es": "Cascada / río / represa / laguna"}'::jsonb, 3, false, array['cascada','rio','río','quebrada','agua','chorro','waterfall','lago','laguna','embalse','represa','nadar','kayak']::text[]),
    ('naturaleza', 'playa', '{"es": "Playa / balneario"}'::jsonb, 4, false, array['playa','mar','arena','balneario','costa','nadar','oleaje','surf']::text[]),
    ('naturaleza', 'montana-mirador', '{"es": "Montaña / mirador"}'::jsonb, 5, false, array['montana','montaña','cerro','pico','altura','escalar','vista','panorama','atardecer','viewpoint','mirador','mirar']::text[]),
    ('naturaleza', 'termales', '{"es": "Termales / aguas termales"}'::jsonb, 6, false, array['termales','termal','aguas termales','jacuzzi natural','hot spring','agua caliente']::text[]),
    ('naturaleza', 'parque-urbano', '{"es": "Parque urbano"}'::jsonb, 7, false, array['parque','parque urbano','parque recreativo','zona verde','picnic','pradera']::text[]),
    ('deporte', 'cancha-deportiva', '{"es": "Cancha deportiva"}'::jsonb, 1, false, array['cancha','futbol','fútbol','basquet','basket','tenis','voley','soccer']::text[]),
    ('deporte', 'tejo', '{"es": "Tejo"}'::jsonb, 2, false, array['tejo','cancha de tejo','turmeque','pólvora','polvora','juego tipico']::text[]),
    ('deporte', 'piscina', '{"es": "Piscina"}'::jsonb, 3, false, array['piscina','alberca','natacion','natación','nadar','agua','pool','chapuzon']::text[]),
    ('deporte', 'patinaje', '{"es": "Patinaje"}'::jsonb, 4, false, array['patinaje','patinar','patines','skate','pista de patinaje']::text[]),
    ('deporte', 'gimnasio-fitness', '{"es": "Gimnasio / fitness"}'::jsonb, 5, false, array['gym','gimnasio','fitness','ejercicio','pesas','crossfit']::text[]),
    ('deporte', 'deporte-aventura', '{"es": "Deporte de aventura"}'::jsonb, 6, false, array['aventura','rappel','rafting','canopy','parapente','escalada','bungee','adrenaline','bici','bicicleta','ciclovia','ciclismo','mtb','paddle','surf','buceo','snorkel','correr','running']::text[]),
    ('cultura', 'museo', '{"es": "Museo"}'::jsonb, 1, false, array['museo','exposicion','exposición','coleccion','gallery museum']::text[]),
    ('cultura', 'centro-historico-patrimonio', '{"es": "Centro histórico / patrimonio"}'::jsonb, 2, false, array['centro','casco historico','histórico','colonia','patrimonio','arquitectura','edificio historico','casona']::text[]),
    ('cultura', 'pueblo-ciudad', '{"es": "Pueblo / ciudad / destino"}'::jsonb, 3, false, array['pueblo','ciudad','municipio','destino','vereda','corregimiento']::text[]),
    ('cultura', 'iglesia-templo', '{"es": "Iglesia / templo"}'::jsonb, 4, false, array['iglesia','templo','catedral','capilla','santuario','mezquita']::text[]),
    ('cultura', 'plaza-principal', '{"es": "Plaza principal / Plaza de Bolívar"}'::jsonb, 5, false, array['plaza','plaza de bolivar','bolívar','parque principal','plaza mayor','centro plaza','square']::text[]),
    ('cultura', 'galeria-arte', '{"es": "Galería de arte"}'::jsonb, 6, false, array['galeria','arte','exposicion','pintura','fotografia']::text[]),
    ('entretenimiento', 'cine-teatro-conciertos', '{"es": "Cine / teatro / conciertos"}'::jsonb, 1, false, array['cine','teatro','pelicula','obra','show','cinema','concierto','musica','banda','live']::text[]),
    ('entretenimiento', 'parque-tematico-acuatico', '{"es": "Parque temático / acuático"}'::jsonb, 2, false, array['tematico','atracciones','juegos mecanicos','theme park','acuatico','toboganes','water park']::text[]),
    ('entretenimiento', 'vida-nocturna-juegos', '{"es": "Discoteca / karaoke / juegos"}'::jsonb, 3, true, array['discoteca','disco','club','bailar','dj','karaoke','cantar','bolos','bowling','bolera','billar','pool','escape room']::text[]),
    ('entretenimiento', 'spa-bienestar', '{"es": "Spa / bienestar"}'::jsonb, 4, false, array['spa','masaje','relajar','wellness','sauna','cuidado']::text[]),
    ('entretenimiento', 'actividad-familiar', '{"es": "Actividad familiar / niños"}'::jsonb, 5, false, array['familiar','ninos','niños','kids','familia','infantil']::text[]),
    ('entretenimiento', 'festival-feria', '{"es": "Festival / feria / evento"}'::jsonb, 6, false, array['festival','festejo','carnaval','feria','exposicion','stand','evento cultural','evento deportivo','torneo','procesion','procesión','religioso']::text[]),
    ('compras', 'centro-comercial', '{"es": "Centro comercial"}'::jsonb, 1, false, array['mall','cc','centro comercial','shopping center']::text[]),
    ('compras', 'mercado-artesanal-plaza', '{"es": "Mercado artesanal / plaza de mercado"}'::jsonb, 2, false, array['artesanal','artesania','artesanías','hecho a mano','plaza de mercado','galeria','frutas','verduras','mercado']::text[]),
    ('compras', 'tienda-souvenir', '{"es": "Tienda de souvenir / artesanías"}'::jsonb, 3, false, array['souvenir','regalo','artesania','feria','pulgas','vintage','anticuario']::text[]),
    ('compras', 'tienda-general', '{"es": "Tienda"}'::jsonb, 4, false, array['tienda','almacen','almacén','ropa','calzado','shop','store']::text[]),
    ('otros', 'terminal-transporte', '{"es": "Terminal / transporte"}'::jsonb, 1, false, array['terminal','bus','aeropuerto','transporte','estacion','estación']::text[]),
    ('otros', 'otro', '{"es": "Otro"}'::jsonb, 2, false, array['otro','otros','varios']::text[])
) as v(parent_slug, slug, name_i18n, sort_order, age_restricted, keywords)
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
