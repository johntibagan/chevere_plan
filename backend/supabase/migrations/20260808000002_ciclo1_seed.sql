-- Seed categorías (§4.1 ampliado: Google Places / OSM leisure-tourism + nicho CO)
-- + keywords para autocomplete. Idempotente.

insert into public.categories (slug, name_i18n, sort_order, icon_key, color_hex, age_restricted, keywords)
select v.slug, v.name_i18n, v.sort_order, v.icon_key, v.color_hex, false, v.keywords
from (
  values
    ('gastronomia', '{"es":"Gastronomía"}'::jsonb, 1, 'coffee', '#FF8C42',
      array['comida','comer','restaurante','beber','gastro','food']::text[]),
    ('alojamiento', '{"es":"Alojamiento"}'::jsonb, 2, 'bed', '#8B7FFF',
      array['hotel','hospedaje','dormir','quedarse','hospedar','lodging']::text[]),
    ('naturaleza', '{"es":"Naturaleza y aire libre"}'::jsonb, 3, 'trees', '#00D68F',
      array['aire libre','outdoor','naturaleza','campo','verde','ecologia']::text[]),
    ('cultura', '{"es":"Cultura e historia"}'::jsonb, 4, 'palette', '#E84393',
      array['cultura','historia','patrimonio','turismo cultural','monumentos']::text[]),
    ('entretenimiento', '{"es":"Entretenimiento y planes"}'::jsonb, 5, 'music', '#FFBB33',
      array['plan','planes','diversion','ocio','recreacion','entretenimiento','salir']::text[]),
    ('deporte', '{"es":"Deporte y recreación"}'::jsonb, 6, 'sport', '#2ECC71',
      array['deporte','deportivo','ejercicio','cancha','juego','actividad fisica']::text[]),
    ('compras', '{"es":"Compras"}'::jsonb, 7, 'shopping', '#00C9A7',
      array['comprar','shopping','tienda','mercado','souvenir']::text[]),
    ('eventos', '{"es":"Eventos"}'::jsonb, 8, 'calendar', '#FF5252',
      array['evento','fiesta','festival','agenda','concierto']::text[]),
    ('servicios', '{"es":"Servicios turísticos"}'::jsonb, 9, 'globe', '#4A90D9',
      array['servicio','agencia','guia','alquiler','tour']::text[])
) as v(slug, name_i18n, sort_order, icon_key, color_hex, keywords)
where not exists (
  select 1 from public.categories c where c.parent_id is null and c.slug = v.slug
);

insert into public.categories (parent_id, slug, name_i18n, sort_order, age_restricted, keywords)
select p.id, v.slug, v.name_i18n, v.sort_order, v.age_restricted, v.keywords
from public.categories p
join (
  values
    -- Gastronomía (MINCIT + OSM amenity)
    ('gastronomia', 'restaurante', '{"es":"Restaurante"}'::jsonb, 1, false,
      array['comida','almuerzo','cena','menu','comer','restaurant']::text[]),
    ('gastronomia', 'cafeteria', '{"es":"Cafetería"}'::jsonb, 2, false,
      array['cafe','café','coffee','brunch','desayuno','tinto']::text[]),
    ('gastronomia', 'bar-vida-nocturna', '{"es":"Bar / vida nocturna"}'::jsonb, 3, true,
      array['bar','bares','tragos','cocteles','cócteles','rumba','nightlife','pub','drinks']::text[]),
    ('gastronomia', 'discoteca-club', '{"es":"Discoteca / club"}'::jsonb, 4, true,
      array['discoteca','disco','club','rumba','bailar','dj','antro']::text[]),
    ('gastronomia', 'cerveceria', '{"es":"Cervecería"}'::jsonb, 5, false,
      array['cerveza','craft','birra','brewery','beer','cerveceria']::text[]),
    ('gastronomia', 'comida-rapida', '{"es":"Comida rápida"}'::jsonb, 6, false,
      array['rapida','hamburguesa','pizza','perro','hot dog','fast food','delivery']::text[]),
    ('gastronomia', 'asadero-parrilla', '{"es":"Asadero / parrilla"}'::jsonb, 7, false,
      array['asado','carne','bbq','parrilla','churrasco','braza']::text[]),
    ('gastronomia', 'comida-tipica', '{"es":"Comida típica / regional"}'::jsonb, 8, false,
      array['tipica','bandeja','ajiaco','sancocho','arepas','regional','criolla']::text[]),
    ('gastronomia', 'cevicheria-mariscos', '{"es":"Cevichería / mariscos"}'::jsonb, 9, false,
      array['ceviche','mariscos','pescado','camaron','camarón','seafood']::text[]),
    ('gastronomia', 'piqueteadero', '{"es":"Piqueteadero / fritanga"}'::jsonb, 10, false,
      array['piquete','fritanga','chicharron','chorizo','picada']::text[]),
    ('gastronomia', 'panaderia-reposteria', '{"es":"Panadería / repostería"}'::jsonb, 11, false,
      array['pan','pastel','torta','postre','bakery','dulce','amasijo']::text[]),
    ('gastronomia', 'heladeria', '{"es":"Heladería"}'::jsonb, 12, false,
      array['helado','nieve','gelato','paleta','ice cream']::text[]),
    ('gastronomia', 'food-truck', '{"es":"Food truck / comida callejera"}'::jsonb, 13, false,
      array['foodtruck','calle','street food','carrito','puesto']::text[]),

    -- Alojamiento
    ('alojamiento', 'hotel', '{"es":"Hotel"}'::jsonb, 1, false,
      array['hotel','hospedaje','suite']::text[]),
    ('alojamiento', 'hostal', '{"es":"Hostal / hostel"}'::jsonb, 2, false,
      array['hostal','hostel','backpacker','mochilero']::text[]),
    ('alojamiento', 'glamping-camping', '{"es":"Glamping / camping"}'::jsonb, 3, false,
      array['camping','campamento','carpa','glamping','tienda']::text[]),
    ('alojamiento', 'finca-casa-descanso', '{"es":"Finca / casa de descanso"}'::jsonb, 4, false,
      array['finca','quinta','casa campo','descanso','villa']::text[]),
    ('alojamiento', 'cabana', '{"es":"Cabaña"}'::jsonb, 5, false,
      array['cabana','cabaña','cabin','chalet']::text[]),
    ('alojamiento', 'posada', '{"es":"Posada / boutique"}'::jsonb, 6, false,
      array['posada','boutique','bed and breakfast','b&b']::text[]),
    ('alojamiento', 'resort', '{"es":"Resort / eco-hotel"}'::jsonb, 7, false,
      array['resort','eco hotel','todo incluido','spa hotel']::text[]),

    -- Naturaleza y aire libre
    ('naturaleza', 'mirador', '{"es":"Mirador"}'::jsonb, 1, false,
      array['vista','panorama','atardecer','viewpoint','mirar']::text[]),
    ('naturaleza', 'sendero-caminata', '{"es":"Sendero / caminata"}'::jsonb, 2, false,
      array['caminar','caminata','hiking','trek','trekking','senderismo','paseo','trail','pie']::text[]),
    ('naturaleza', 'cascada-rio', '{"es":"Cascada / río"}'::jsonb, 3, false,
      array['cascada','rio','río','quebrada','agua','chorro','waterfall','nadar','baño','banarse','bañarse']::text[]),
    ('naturaleza', 'lago-laguna', '{"es":"Lago / laguna"}'::jsonb, 4, false,
      array['lago','laguna','embalse','agua','nadar','kayak']::text[]),
    ('naturaleza', 'montana', '{"es":"Montaña / cerro"}'::jsonb, 5, false,
      array['montana','montaña','cerro','pico','altura','escalar','trekking']::text[]),
    ('naturaleza', 'parque-natural', '{"es":"Parque natural"}'::jsonb, 6, false,
      array['parque','reserva','bosque','national park','naturaleza']::text[]),
    ('naturaleza', 'reserva-ecologica', '{"es":"Reserva ecológica"}'::jsonb, 7, false,
      array['reserva','ecologia','ecológica','biodiversidad','conservacion']::text[]),
    ('naturaleza', 'playa-balneario', '{"es":"Playa / balneario"}'::jsonb, 8, false,
      array['playa','mar','arena','balneario','costa','nadar','oleaje','surf']::text[]),
    ('naturaleza', 'piscina', '{"es":"Piscina"}'::jsonb, 9, false,
      array['piscina','alberca','natacion','natación','nadar','agua','pool','chapuzon']::text[]),
    ('naturaleza', 'termales', '{"es":"Termales / aguas termales"}'::jsonb, 10, false,
      array['termales','termal','aguas termales','jacuzzi natural','hot spring','agua caliente']::text[]),
    ('naturaleza', 'jardin-botanico', '{"es":"Jardín botánico / vivero"}'::jsonb, 11, false,
      array['jardin','jardín','botanico','flores','plantas','vivero']::text[]),
    ('naturaleza', 'picnic-zona-verde', '{"es":"Picnic / zona verde"}'::jsonb, 12, false,
      array['picnic','asado al aire','zona verde','pradera','merienda']::text[]),

    -- Cultura e historia
    ('cultura', 'museo', '{"es":"Museo"}'::jsonb, 1, false,
      array['museo','exposicion','exposición','coleccion','gallery museum']::text[]),
    ('cultura', 'monumento', '{"es":"Monumento"}'::jsonb, 2, false,
      array['monumento','estatua','memorial','escultura']::text[]),
    ('cultura', 'plaza-principal', '{"es":"Plaza principal / Plaza de Bolívar"}'::jsonb, 3, false,
      array['plaza','plaza de bolivar','bolívar','parque principal','plaza mayor','centro plaza','square']::text[]),
    ('cultura', 'iglesia-templo', '{"es":"Iglesia / templo"}'::jsonb, 4, false,
      array['iglesia','templo','catedral','capilla','santuario','mezquita']::text[]),
    ('cultura', 'sitio-arqueologico', '{"es":"Sitio arqueológico"}'::jsonb, 5, false,
      array['arqueologia','ruinas','petroglifo','precolombino']::text[]),
    ('cultura', 'centro-historico', '{"es":"Centro histórico"}'::jsonb, 6, false,
      array['centro','casco historico','histórico','colonia','patrimonio']::text[]),
    ('cultura', 'galeria-arte', '{"es":"Galería de arte"}'::jsonb, 7, false,
      array['galeria','arte','exposicion','pintura','fotografia']::text[]),
    ('cultura', 'biblioteca-casa-cultura', '{"es":"Biblioteca / casa de cultura"}'::jsonb, 8, false,
      array['biblioteca','casa de cultura','lectura','libros']::text[]),
    ('cultura', 'arquitectura-patrimonial', '{"es":"Arquitectura patrimonial"}'::jsonb, 9, false,
      array['arquitectura','edificio historico','casona','patrimonio']::text[]),

    -- Entretenimiento y planes
    ('entretenimiento', 'parque-urbano', '{"es":"Parque urbano / recreativo"}'::jsonb, 1, false,
      array['parque','parque simon bolivar','recreativo','verde urbano','juegos']::text[]),
    ('entretenimiento', 'parque-tematico', '{"es":"Parque temático"}'::jsonb, 2, false,
      array['tematico','atracciones','juegos mecanicos','theme park']::text[]),
    ('entretenimiento', 'parque-acuatico', '{"es":"Parque acuático"}'::jsonb, 3, false,
      array['acuatico','toboganes','water park','nadar','agua','slides']::text[]),
    ('entretenimiento', 'deporte-aventura', '{"es":"Deporte de aventura"}'::jsonb, 4, false,
      array['aventura','rappel','rafting','canopy','parapente','escalada','bungee','adrenaline']::text[]),
    ('entretenimiento', 'spa-bienestar', '{"es":"Spa / bienestar"}'::jsonb, 5, false,
      array['spa','masaje','relajar','wellness','sauna','cuidado']::text[]),
    ('entretenimiento', 'cine-teatro', '{"es":"Cine / teatro"}'::jsonb, 6, false,
      array['cine','teatro','pelicula','obra','show','cinema']::text[]),
    ('entretenimiento', 'karaoke', '{"es":"Karaoke"}'::jsonb, 7, false,
      array['karaoke','cantar','musica']::text[]),
    ('entretenimiento', 'escape-room', '{"es":"Escape room"}'::jsonb, 8, false,
      array['escape','escape room','puzzle','enigma']::text[]),
    ('entretenimiento', 'actividad-familiar', '{"es":"Actividad familiar / niños"}'::jsonb, 9, false,
      array['familiar','ninos','niños','kids','familia','infantil']::text[]),
    ('entretenimiento', 'bolera-bolos', '{"es":"Bolera / bolos"}'::jsonb, 10, false,
      array['bolos','bowling','bolera']::text[]),
    ('entretenimiento', 'billar', '{"es":"Billar / pool"}'::jsonb, 11, false,
      array['billar','pool','snooker','mesa de billar']::text[]),

    -- Deporte y recreación (nuevo padre; tejo, canchas…)
    ('deporte', 'tejo', '{"es":"Tejo"}'::jsonb, 1, false,
      array['tejo','cancha de tejo','turmeque','pólvora','polvora','juego tipico']::text[]),
    ('deporte', 'cancha-deportiva', '{"es":"Cancha deportiva"}'::jsonb, 2, false,
      array['cancha','futbol','fútbol','basquet','basket','tenis','voley','soccer']::text[]),
    ('deporte', 'gimnasio-fitness', '{"es":"Gimnasio / fitness"}'::jsonb, 3, false,
      array['gym','gimnasio','fitness','ejercicio','pesas','crossfit']::text[]),
    ('deporte', 'estadio-coliseo', '{"es":"Estadio / coliseo"}'::jsonb, 4, false,
      array['estadio','coliseo','arena','partido','hinchada']::text[]),
    ('deporte', 'ciclismo-ruta', '{"es":"Ciclismo / ruta en bici"}'::jsonb, 5, false,
      array['bici','bicicleta','ciclovia','ciclismo','mtb','ruta']::text[]),
    ('deporte', 'deportes-acuaticos', '{"es":"Deportes acuáticos"}'::jsonb, 6, false,
      array['kayak','paddle','surf','buceo','snorkel','agua','nadar','vela']::text[]),
    ('deporte', 'senderismo-running', '{"es":"Running / trail"}'::jsonb, 7, false,
      array['correr','running','trail','jog','maratón','maraton','caminar']::text[]),

    -- Compras
    ('compras', 'mercado-artesanal', '{"es":"Mercado artesanal"}'::jsonb, 1, false,
      array['artesanal','artesania','artesanías','hecho a mano']::text[]),
    ('compras', 'mercado-plaza', '{"es":"Plaza de mercado"}'::jsonb, 2, false,
      array['plaza de mercado','galeria','frutas','verduras','mercado']::text[]),
    ('compras', 'centro-comercial', '{"es":"Centro comercial"}'::jsonb, 3, false,
      array['mall','cc','centro comercial','shopping center']::text[]),
    ('compras', 'tienda-local', '{"es":"Tienda local / souvenir"}'::jsonb, 4, false,
      array['souvenir','regalo','tienda','local']::text[]),
    ('compras', 'feria-pulgas', '{"es":"Feria / pulgas"}'::jsonb, 5, false,
      array['feria','pulgas','vintage','segunda','anticuario']::text[]),

    -- Eventos
    ('eventos', 'festival', '{"es":"Festival"}'::jsonb, 1, false,
      array['festival','festejo','carnaval']::text[]),
    ('eventos', 'concierto', '{"es":"Concierto"}'::jsonb, 2, false,
      array['concierto','musica','banda','live']::text[]),
    ('eventos', 'feria', '{"es":"Feria"}'::jsonb, 3, false,
      array['feria','exposicion','stand']::text[]),
    ('eventos', 'evento-cultural', '{"es":"Evento cultural"}'::jsonb, 4, false,
      array['cultural','obra','lectura','charla']::text[]),
    ('eventos', 'evento-deportivo', '{"es":"Evento deportivo"}'::jsonb, 5, false,
      array['partido','carrera','torneo','competencia']::text[]),
    ('eventos', 'evento-religioso', '{"es":"Evento religioso"}'::jsonb, 6, false,
      array['procesion','procesión','misa','peregrinacion','religioso']::text[]),

    -- Servicios
    ('servicios', 'agencia-viajes', '{"es":"Agencia de viajes"}'::jsonb, 1, false,
      array['agencia','tour','paquetes','viaje']::text[]),
    ('servicios', 'guia-turistico', '{"es":"Guía turístico"}'::jsonb, 2, false,
      array['guia','guía','tour guide','tour']::text[]),
    ('servicios', 'alquiler-equipos', '{"es":"Alquiler de equipos"}'::jsonb, 3, false,
      array['alquiler','renta','equipos','bicicletas','kayak']::text[]),
    ('servicios', 'punto-informacion', '{"es":"Punto de información turística"}'::jsonb, 4, false,
      array['informacion','información','i','tourist info','oficina turismo']::text[])
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
