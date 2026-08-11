-- Ciclo 8+: keywords de búsqueda + ampliación del árbol de categorías
-- Fuentes: Google Places (ámbitos turismo/ocio), OSM tourism/leisure/amenity,
-- MINCIT gastronomía CO, nicho local (tejo, plazas, termales…).

alter table public.categories
  add column if not exists keywords text[] not null default '{}'::text[];

create index if not exists categories_keywords_gin
  on public.categories using gin (keywords);

-- Padre nuevo: Deporte y recreación
insert into public.categories (slug, name_i18n, sort_order, icon_key, color_hex, age_restricted, keywords)
select 'deporte', '{"es":"Deporte y recreación"}'::jsonb, 6, 'sport', '#2ECC71', false,
       array['deporte','deportivo','ejercicio','cancha','juego','actividad fisica']::text[]
where not exists (
  select 1 from public.categories c where c.parent_id is null and c.slug = 'deporte'
);

-- Reordenar raíces existentes (compras/eventos/servicios detrás de deporte)
update public.categories set sort_order = 7, keywords = array['comprar','shopping','tienda','mercado','souvenir']
where parent_id is null and slug = 'compras';
update public.categories set sort_order = 8, keywords = array['evento','fiesta','festival','agenda','concierto']
where parent_id is null and slug = 'eventos';
update public.categories set sort_order = 9, keywords = array['servicio','agencia','guia','alquiler','tour']
where parent_id is null and slug = 'servicios';

update public.categories set keywords = array['comida','comer','restaurante','beber','gastro','food']
where parent_id is null and slug = 'gastronomia';
update public.categories set keywords = array['hotel','hospedaje','dormir','quedarse','hospedar','lodging']
where parent_id is null and slug = 'alojamiento';
update public.categories set keywords = array['aire libre','outdoor','naturaleza','campo','verde','ecologia']
where parent_id is null and slug = 'naturaleza';
update public.categories set keywords = array['cultura','historia','patrimonio','turismo cultural','monumentos']
where parent_id is null and slug = 'cultura';
update public.categories set keywords = array['plan','planes','diversion','ocio','recreacion','entretenimiento','salir']
where parent_id is null and slug = 'entretenimiento';

-- Nuevas subcategorías + keywords (idempotente)
insert into public.categories (parent_id, slug, name_i18n, sort_order, age_restricted, keywords)
select p.id, v.slug, v.name_i18n, v.sort_order, v.age_restricted, v.keywords
from public.categories p
join (
  values
    ('gastronomia', 'discoteca-club', '{"es":"Discoteca / club"}'::jsonb, 4, true,
      array['discoteca','disco','club','rumba','bailar','dj','antro']::text[]),
    ('gastronomia', 'cerveceria', '{"es":"Cervecería"}'::jsonb, 5, false,
      array['cerveza','craft','birra','brewery','beer','cerveceria']::text[]),
    ('gastronomia', 'asadero-parrilla', '{"es":"Asadero / parrilla"}'::jsonb, 7, false,
      array['asado','carne','bbq','parrilla','churrasco','braza']::text[]),
    ('gastronomia', 'comida-tipica', '{"es":"Comida típica / regional"}'::jsonb, 8, false,
      array['tipica','bandeja','ajiaco','sancocho','arepas','regional','criolla']::text[]),
    ('gastronomia', 'cevicheria-mariscos', '{"es":"Cevichería / mariscos"}'::jsonb, 9, false,
      array['ceviche','mariscos','pescado','camaron','camarón','seafood']::text[]),
    ('gastronomia', 'piqueteadero', '{"es":"Piqueteadero / fritanga"}'::jsonb, 10, false,
      array['piquete','fritanga','chicharron','chorizo','picada']::text[]),

    ('alojamiento', 'cabana', '{"es":"Cabaña"}'::jsonb, 5, false,
      array['cabana','cabaña','cabin','chalet']::text[]),
    ('alojamiento', 'resort', '{"es":"Resort / eco-hotel"}'::jsonb, 7, false,
      array['resort','eco hotel','todo incluido','spa hotel']::text[]),

    ('naturaleza', 'lago-laguna', '{"es":"Lago / laguna"}'::jsonb, 4, false,
      array['lago','laguna','embalse','agua','nadar','kayak']::text[]),
    ('naturaleza', 'piscina', '{"es":"Piscina"}'::jsonb, 9, false,
      array['piscina','alberca','natacion','natación','nadar','agua','pool','chapuzon']::text[]),
    ('naturaleza', 'termales', '{"es":"Termales / aguas termales"}'::jsonb, 10, false,
      array['termales','termal','aguas termales','jacuzzi natural','hot spring','agua caliente']::text[]),
    ('naturaleza', 'jardin-botanico', '{"es":"Jardín botánico / vivero"}'::jsonb, 11, false,
      array['jardin','jardín','botanico','flores','plantas','vivero']::text[]),
    ('naturaleza', 'picnic-zona-verde', '{"es":"Picnic / zona verde"}'::jsonb, 12, false,
      array['picnic','asado al aire','zona verde','pradera','merienda']::text[]),

    ('cultura', 'plaza-principal', '{"es":"Plaza principal / Plaza de Bolívar"}'::jsonb, 3, false,
      array['plaza','plaza de bolivar','bolívar','parque principal','plaza mayor','centro plaza','square']::text[]),
    ('cultura', 'biblioteca-casa-cultura', '{"es":"Biblioteca / casa de cultura"}'::jsonb, 8, false,
      array['biblioteca','casa de cultura','lectura','libros']::text[]),
    ('cultura', 'arquitectura-patrimonial', '{"es":"Arquitectura patrimonial"}'::jsonb, 9, false,
      array['arquitectura','edificio historico','casona','patrimonio']::text[]),

    ('entretenimiento', 'parque-urbano', '{"es":"Parque urbano / recreativo"}'::jsonb, 1, false,
      array['parque','parque simon bolivar','recreativo','verde urbano','juegos']::text[]),
    ('entretenimiento', 'parque-acuatico', '{"es":"Parque acuático"}'::jsonb, 3, false,
      array['acuatico','toboganes','water park','nadar','agua','slides']::text[]),
    ('entretenimiento', 'karaoke', '{"es":"Karaoke"}'::jsonb, 7, false,
      array['karaoke','cantar','musica']::text[]),
    ('entretenimiento', 'escape-room', '{"es":"Escape room"}'::jsonb, 8, false,
      array['escape','escape room','puzzle','enigma']::text[]),
    ('entretenimiento', 'bolera-bolos', '{"es":"Bolera / bolos"}'::jsonb, 10, false,
      array['bolos','bowling','bolera']::text[]),
    ('entretenimiento', 'billar', '{"es":"Billar / pool"}'::jsonb, 11, false,
      array['billar','pool','snooker','mesa de billar']::text[]),

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

    ('compras', 'mercado-plaza', '{"es":"Plaza de mercado"}'::jsonb, 2, false,
      array['plaza de mercado','galeria','frutas','verduras','mercado']::text[]),
    ('compras', 'feria-pulgas', '{"es":"Feria / pulgas"}'::jsonb, 5, false,
      array['feria','pulgas','vintage','segunda','anticuario']::text[]),

    ('servicios', 'punto-informacion', '{"es":"Punto de información turística"}'::jsonb, 4, false,
      array['informacion','información','tourist info','oficina turismo']::text[])
) as v(parent_slug, slug, name_i18n, sort_order, age_restricted, keywords)
  on p.slug = v.parent_slug and p.parent_id is null
where not exists (
  select 1 from public.categories c
  where c.parent_id = p.id and c.slug = v.slug
);

-- Keywords + nombres refinados en categorías ya existentes
update public.categories c set
  name_i18n = coalesce(v.name_i18n, c.name_i18n),
  keywords = v.keywords,
  age_restricted = coalesce(v.age_restricted, c.age_restricted)
from (
  values
    ('restaurante', '{"es":"Restaurante"}'::jsonb, false,
      array['comida','almuerzo','cena','menu','comer','restaurant']::text[]),
    ('cafeteria', '{"es":"Cafetería"}'::jsonb, false,
      array['cafe','café','coffee','brunch','desayuno','tinto']::text[]),
    ('bar-vida-nocturna', '{"es":"Bar / vida nocturna"}'::jsonb, true,
      array['bar','bares','tragos','cocteles','cócteles','rumba','nightlife','pub','drinks']::text[]),
    ('comida-rapida', '{"es":"Comida rápida"}'::jsonb, false,
      array['rapida','hamburguesa','pizza','perro','hot dog','fast food','delivery']::text[]),
    ('panaderia-reposteria', '{"es":"Panadería / repostería"}'::jsonb, false,
      array['pan','pastel','torta','postre','bakery','dulce','amasijo']::text[]),
    ('heladeria', '{"es":"Heladería"}'::jsonb, false,
      array['helado','nieve','gelato','paleta','ice cream']::text[]),
    ('food-truck', '{"es":"Food truck / comida callejera"}'::jsonb, false,
      array['foodtruck','calle','street food','carrito','puesto']::text[]),
    ('hotel', null::jsonb, false, array['hotel','hospedaje','suite']::text[]),
    ('hostal', '{"es":"Hostal / hostel"}'::jsonb, false,
      array['hostal','hostel','backpacker','mochilero']::text[]),
    ('glamping-camping', null::jsonb, false,
      array['camping','campamento','carpa','glamping','tienda']::text[]),
    ('finca-casa-descanso', null::jsonb, false,
      array['finca','quinta','casa campo','descanso','villa']::text[]),
    ('posada', '{"es":"Posada / boutique"}'::jsonb, false,
      array['posada','boutique','bed and breakfast','b&b']::text[]),
    ('mirador', null::jsonb, false,
      array['vista','panorama','atardecer','viewpoint','mirar']::text[]),
    ('sendero-caminata', null::jsonb, false,
      array['caminar','caminata','hiking','trek','trekking','senderismo','paseo','trail','pie']::text[]),
    ('cascada-rio', null::jsonb, false,
      array['cascada','rio','río','quebrada','agua','chorro','waterfall','nadar','baño','banarse','bañarse']::text[]),
    ('montana', '{"es":"Montaña / cerro"}'::jsonb, false,
      array['montana','montaña','cerro','pico','altura','escalar','trekking']::text[]),
    ('parque-natural', null::jsonb, false,
      array['parque','reserva','bosque','national park','naturaleza']::text[]),
    ('playa-balneario', null::jsonb, false,
      array['playa','mar','arena','balneario','costa','nadar','oleaje','surf']::text[]),
    ('reserva-ecologica', null::jsonb, false,
      array['reserva','ecologia','ecológica','biodiversidad','conservacion']::text[]),
    ('museo', null::jsonb, false,
      array['museo','exposicion','exposición','coleccion','gallery museum']::text[]),
    ('monumento', null::jsonb, false,
      array['monumento','estatua','memorial','escultura']::text[]),
    ('iglesia-templo', null::jsonb, false,
      array['iglesia','templo','catedral','capilla','santuario','mezquita']::text[]),
    ('sitio-arqueologico', null::jsonb, false,
      array['arqueologia','ruinas','petroglifo','precolombino']::text[]),
    ('centro-historico', null::jsonb, false,
      array['centro','casco historico','histórico','colonia','patrimonio']::text[]),
    ('galeria-arte', null::jsonb, false,
      array['galeria','arte','exposicion','pintura','fotografia']::text[]),
    ('parque-tematico', '{"es":"Parque temático"}'::jsonb, false,
      array['tematico','atracciones','juegos mecanicos','theme park']::text[]),
    ('deporte-aventura', null::jsonb, false,
      array['aventura','rappel','rafting','canopy','parapente','escalada','bungee','adrenaline']::text[]),
    ('spa-bienestar', null::jsonb, false,
      array['spa','masaje','relajar','wellness','sauna','cuidado']::text[]),
    ('cine-teatro', null::jsonb, false,
      array['cine','teatro','pelicula','obra','show','cinema']::text[]),
    ('actividad-familiar', '{"es":"Actividad familiar / niños"}'::jsonb, false,
      array['familiar','ninos','niños','kids','familia','infantil']::text[]),
    ('mercado-artesanal', null::jsonb, false,
      array['artesanal','artesania','artesanías','hecho a mano']::text[]),
    ('centro-comercial', null::jsonb, false,
      array['mall','cc','centro comercial','shopping center']::text[]),
    ('tienda-local', null::jsonb, false,
      array['souvenir','regalo','tienda','local']::text[]),
    ('festival', null::jsonb, false, array['festival','festejo','carnaval']::text[]),
    ('concierto', null::jsonb, false, array['concierto','musica','banda','live']::text[]),
    ('feria', null::jsonb, false, array['feria','exposicion','stand']::text[]),
    ('evento-cultural', null::jsonb, false, array['cultural','obra','lectura','charla']::text[]),
    ('evento-deportivo', null::jsonb, false, array['partido','carrera','torneo','competencia']::text[]),
    ('evento-religioso', null::jsonb, false,
      array['procesion','procesión','misa','peregrinacion','religioso']::text[]),
    ('agencia-viajes', null::jsonb, false, array['agencia','tour','paquetes','viaje']::text[]),
    ('guia-turistico', null::jsonb, false, array['guia','guía','tour guide','tour']::text[]),
    ('alquiler-equipos', null::jsonb, false,
      array['alquiler','renta','equipos','bicicletas','kayak']::text[])
) as v(slug, name_i18n, age_restricted, keywords)
where c.slug = v.slug;
