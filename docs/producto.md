# Especificación de producto

Fuente de **qué debería hacer** la app a mediano plazo (incluye ideas aún no construidas).

**Lo que ya existe hoy**, con flujos y límites reales: [`aplicacion-actual.md`](aplicacion-actual.md).

Lo técnico operativo está en [README](README.md) y [setup](setup/02-supabase.md).

**Versión:** 1.0 (concepto vivo) · Colombia · Android primero

---

## 1. Resumen ejecutivo

Aplicación que centraliza el "guardado rápido" de lugares descubiertos en redes sociales (Instagram, TikTok, Facebook, etc.), organizándolos por categoría y ubicación, para luego:

- Recordarlos por proximidad (estilo "recuerdos" de Google Fotos, pero geolocalizado).
- Armar planes/itinerarios inteligentes bajo demanda ("arma un plan para mañana en X"), considerando horarios, tarifas, presupuesto y medio de transporte.
- Compartir esos guardados públicamente, alimentando la búsqueda y los planes de otros usuarios.
- Generar ingresos mediante promoción de eventos, fichas enriquecidas de negocios y donaciones.

**Enfoque explícito de la app:** turismo, gastronomía, planes de ocio y actividades sanas. Uso fuera de esta finalidad (contenido sexual, ilegal, acoso, etc.) está prohibido por Términos de Uso y sujeto a moderación.

---

## 2. Análisis de mercado (competencia existente)

Ya existen apps que resuelven parcialmente el problema de "guardar lugares desde redes sociales":

| App | Qué hace | Limitación frente a esta idea |
|---|---|---|
| **Mapstr** | Guardar lugares, etiquetas/colores, importar desde Google Maps/CSV, seguir mapas de otros usuarios, alertas de proximidad | Solo lugares, sin planes generados por IA, sin transporte inteligente, sin monetización de eventos |
| **Plotline** | Extrae ubicación de un post compartido (IG/TikTok) y lo pinea en un mapa de viajes | Similar, enfoque solo en extracción y mapa, sin capa social ni planes |
| **Stashed, Spots, Stash, Instabites, JoySpot** | Variantes del mismo concepto: compartir post → extraer lugar → guardar en mapa personal | Mismo problema: no arman planes, no manejan transporte, no tienen monetización de eventos locales |

**Diferenciales de esta propuesta:**
1. Guardado no limitado solo a "compartir para extraer lugar": permite categorías amplias (planes, restaurantes, lugares a visitar).
2. Armado de planes con IA sobre los guardados propios y/o públicos.
3. Transporte inteligente calculado en vivo según distancia y rangos configurables.
4. Capa social con anti-duplicados y atribución de aporte ("guardado también por").
5. Monetización estructurada: eventos geolocalizados + fichas de negocio enriquecidas + donaciones.

---

## 3. Flujo de captura (guardado rápido)

1. Usuario ve contenido en IG/TikTok/FB → usa botón "Compartir" del sistema → selecciona esta app.
2. La app intenta **detectar automáticamente la ubicación** del contenido (vía texto, geoetiqueta o consulta a Google Places API).
   - Si lo logra: se guarda el sitio con ubicación confirmada.
   - Si no lo logra: el guardado queda en **estado "pendiente de definir ubicación"**, visible y editable después (para no interrumpir la agilidad de guardar).
3. Usuario asigna **categoría/subcategoría** desde el árbol fijo definido en la sección 4 (autocompletable, puede seleccionar varias).
4. Ubicación editable manualmente en cualquier momento (ciudad, departamento, dirección exacta vía buscador).
5. El sitio queda **privado por defecto**; el usuario decide si hacerlo público.
6. Si el contenido guardado no corresponde a un lugar físico (ej. una receta, un video motivacional), se guarda igual pero **queda siempre privado** (fuera del alcance de la capa pública, que es 100% sobre lugares).

### 3.1 Guardado incompleto → estado "borrador"
- Si el usuario comparte contenido a la app y **no completa nada** (sin categoría, sin ubicación, etc.), el registro queda en **estado "borrador"**.
- El sistema envía notificaciones periódicas invitando a completar la tarjeta (ej. a las 24 horas, y luego recordatorios espaciados) hasta que el usuario la complete o la descarte explícitamente.
- Un borrador no cuenta como guardado válido para estadísticas, planes ni búsquedas hasta que se complete al menos categoría y ubicación.

### Fotos de la tarjeta del sitio
- Prioridad: extracción automática desde Google Places (si existe).
- Si no hay foto disponible, el usuario puede subir la propia.
- **Límite: 15 fotos por sitio en total**, sin importar cuántos usuarios distintos hayan aportado.
- Al subir una foto, se muestra un aviso recordando cumplir los Términos de Uso (ver sección 9).
- Cada foto individual tiene botón de "reportar contenido inadecuado"; **desde el primer reporte se genera alarma a los administradores**, quienes deciden si la eliminan.

### Enlace a la publicación original
- El link a la red social de origen (IG/TikTok/FB) **solo es visible para el usuario que hizo el guardado** (privado).
- La tarjeta pública nunca redistribuye el post original, solo datos extraídos del sitio (nombre, dirección, fotos con licencia/proveniencia adecuada).

---

## 4. Organización y categorías

### 4.1 Árbol de categorías fijo (no editable por usuarios regulares)

Para evitar errores de sintaxis, duplicados y categorías inconsistentes, el árbol de categorías es **fijo y parametrizado por administradores** (ver sección 12). Un sitio puede tener **una o varias** categorías/subcategorías. Al enriquecer una tarjeta, el campo es **autocompletable** contra este árbol (no texto libre).

Propuesta de árbol (Google Places / OSM tourism·leisure·amenity + MINCIT gastronomía CO + nicho local). Administrable; cada ítem tiene **keywords** para autocomplete (ej. “nadar” → piscina/río; “caminar” → sendero).

| Categoría | Subcategorías |
|---|---|
| **Gastronomía** | Restaurante, Cafetería, Bar/vida nocturna (+18), Discoteca/club (+18), Cervecería, Comida rápida, Asadero/parrilla, Comida típica, Cevichería/mariscos, Piqueteadero, Panadería/repostería, Heladería, Food truck |
| **Alojamiento** | Hotel, Hostal, Glamping/camping, Finca/casa de descanso, Cabaña, Posada, Resort/eco-hotel |
| **Naturaleza y aire libre** | Mirador, Sendero/caminata, Cascada/río, Lago/laguna, Montaña, Parque natural, Reserva ecológica, Playa/balneario, Piscina, Termales, Jardín botánico, Picnic/zona verde |
| **Cultura e historia** | Museo, Monumento, Plaza principal/Plaza de Bolívar, Iglesia/templo, Sitio arqueológico, Centro histórico, Galería de arte, Biblioteca/casa de cultura, Arquitectura patrimonial |
| **Entretenimiento y planes** | Parque urbano, Parque temático, Parque acuático, Deporte de aventura, Spa/bienestar, Cine/teatro, Karaoke, Escape room, Actividad familiar, Bolera, Billar |
| **Deporte y recreación** | Tejo, Cancha deportiva, Gimnasio/fitness, Estadio/coliseo, Ciclismo/ruta, Deportes acuáticos, Running/trail |
| **Compras** | Mercado artesanal, Plaza de mercado, Centro comercial, Tienda local/souvenir, Feria/pulgas |
| **Eventos** | Festival, Concierto, Feria, Evento cultural, Evento deportivo, Evento religioso |
| **Servicios turísticos** | Agencia de viajes, Guía turístico, Alquiler de equipos, Punto de información turística |

- Este árbol se administra desde el panel de administración (sección 12): agregar, editar o desactivar categorías/subcategorías sin afectar tarjetas ya existentes.
- Un sitio con contenido para adultos (ej. "Bar/Vida nocturna") queda automáticamente restringido para usuarios que declararon ser menores de 18 (ver sección 15).

### 4.2 Ubicación jerárquica
- Ubicación jerárquica rápida: ciudad, departamento, etc., para facilitar búsquedas posteriores.
- Un mismo sitio público puede acumular **múltiples categorías** aportadas por distintos usuarios (ej. "Restaurante" + "Bar/Vida nocturna").

---

## 5. Capa social y anti-duplicados

- Guardado público = visible para otros usuarios y disponible para búsquedas/planes de terceros (mediante checkbox "incluir guardados públicos").
- **Cero sitios públicos duplicados.** Detección por coordenadas (~50–100 m) + similitud de nombre.
  - Si ya existe un sitio público parecido: se ofrece **vincular** al existente (“compartido también por”) con reseña visible o bitácora privada. Al **guardar**, también se puede **guardar de todas formas** (crear el propio). En Maps / pegar enlace solo se avisa para vincular o seguir editando.
  - El chequeo se reitera al guardar; si sigue habiendo match, solo se puede vincular+reseñar o cancelar.
- El **creador** del sitio público (y admin/root) puede editar la ficha; descartar quita el guardado/aporte del usuario sin borrar el sitio si otros lo usan.
- Catálogo masivo (`external_id`) no se hace privado.

---

## 6. Recuerdos por ubicación (estilo Google Fotos)

- La app usa la geolocalización del dispositivo para detectar cuándo el usuario está cerca de un sitio guardado (propio o público, si activó la opción).
- Envía notificación tipo "recuerdo": "Tienes guardado un lugar cerca de aquí".

---

## 7. Planes inteligentes

### 7.1 Generación de planes
- El usuario pide, por ejemplo: "arma un plan para mañana en Villa de Leyva".
- El sistema arma un plan basado en los guardados del usuario (y guardados públicos, si el usuario activa el checkbox correspondiente) que correspondan a esa ubicación.
- El plan se presenta como una **lista ordenable** (ruta en texto, no mapa interactivo dentro de la app): Sitio 1 → Sitio 2 → Sitio 3, con distancia y transporte sugerido entre paradas.
- El sistema valida **horarios de apertura** de cada sitio para no sugerir paradas cerradas en el horario del plan.
- Los planes se pueden **crear, editar y compartir** libremente.

### 7.2 Transporte inteligente

**Tipos de transporte (fijos, parametrizados por administradores):**

| Grupo | Medios incluidos |
|---|---|
| **Particular** | Caminar, Bicicleta, Moto propia, Carro propio |
| **Público** | Bus, Sistema de transporte masivo (ej. SITP/Transmilenio-tipo según ciudad), Colectivo/Buseta intermunicipal |
| **Otro (plataformas)** | Taxi, Uber, DiDi, InDriver |

- Cálculo de medio de transporte sugerido **en vivo**, según distancia entre ubicación actual (o una definida manualmente) y cada sitio del plan.
- Rangos configurables por el usuario, con valores por defecto sugeridos:
  - Caminar: hasta 3 km
  - Bicicleta: hasta 10 km
  - Moto / Carro: sin límite superior definido
- Si un trayecto cae dentro del rango de dos categorías (ej. 4 km entra en rango de bici y también sería viable en moto), se muestran **ambas opciones**.
- Ubicación inicial por defecto = ubicación actual del dispositivo, pero editable manualmente.
- **Fase futura**: definir tarifas de referencia para transporte público (ej. costo de pasaje de bus por ciudad), para que el presupuesto del plan también incluya el costo de desplazamiento, no solo el de los sitios.

### 7.3 Exportar a navegación
- Botón "Enviar a Maps": abre Google Maps (o similar) con los puntos del plan cargados como ruta de navegación multi-destino.
- **El envío es consciente del progreso del plan**: si el usuario ya marcó (o el sistema detecta, por ubicación en vivo) que ya visitó uno o más sitios del plan, la ruta enviada a Maps **inicia desde la ubicación actual del usuario y solo incluye las paradas pendientes**, no desde el primer sitio del plan original.
- La app **no renderiza un mapa propio**; usa Google Places API únicamente para geocodificar/precisar ubicaciones al guardar sitios, reduciendo costos.

### 7.4 Presupuesto en planes
- Búsqueda de planes por presupuesto: el usuario define un monto, y el sistema filtra/arma planes considerando el costo de cada sitio.
- El presupuesto se maneja **por tarjeta/sitio individual**, no como total repartido del plan.
- Si el sitio no tiene tarifa oficial ni rango público, quien arma el plan puede asignar un **valor estimado por persona**, visible para quien reciba/vea el plan compartido, dejando claro que es un estimado arbitrario del creador (no oficial).

### 7.5 Búsqueda de planes/sitios

- **Búsqueda general**: campo único de texto (nombre, ciudad, tipo de plan), pensado para agilidad.
- **Búsqueda avanzada**: filtros combinables:
  - Categoría/subcategoría (árbol fijo de sección 4.1)
  - Ubicación (ciudad/departamento/radio desde ubicación actual)
  - Medio de transporte disponible (particular/público/otro)
  - Presupuesto (rango de precio por sitio)
  - Incluir o no guardados públicos de otros usuarios (checkbox)
  - Horario disponible (para que solo muestre sitios abiertos en la franja deseada)

### 7.6 Trazabilidad de lugares visitados ("Mis rutas/planes")

- Historial personal de planes ejecutados: qué planes se armaron, qué sitios se marcaron como visitados, cuándo y con qué transporte.
- Sirve como registro tipo "diario de viajes" del usuario, visible solo para él (privado).
- Puede alimentar a futuro recomendaciones personalizadas (ej. "te gustan los planes de naturaleza en Boyacá").

---

## 8. Ficha del sitio (tarjeta pública)

### 8.1 Datos base (gratuitos, alimentados por la comunidad)
- Nombre, dirección, fotos de galería (máx. 15 por sitio), categorías.
- **Reseñas:** cada usuario puede dejar **varias** reseñas por sitio (bitácora de visitas): comentario, puntuación 1–5 estrellas, hasta **3 fotos** por reseña. En un sitio **público**, cada reseña puede ser **pública** (visible en ficha y cuenta para el promedio) o **privada** (solo el autor; ni admin/root la ven). Staff sí modera sitios y reseñas **públicas**. Trazabilidad: usuario, fecha de creación y última edición. El promedio usa solo reseñas públicas. En ficha: filtros por estrellas / mías y orden por fecha o puntuación.
- **Rango de precio público**: promedio calculado a partir de reportes de precio que dejan los propios usuarios (o "gratis" si aplica). Requiere un mínimo de reportes distintos antes de mostrarse, para evitar manipulación.

### 8.2 Ficha enriquecida por el dueño del negocio (de pago)

**Campos que el dueño puede alimentar:**

| Campo | Límite | Notas |
|---|---|---|
| Nombre de contacto | 60 caracteres | Opcional |
| Teléfono/WhatsApp | 1-2 números | Formato validado |
| Email | 1 | Opcional |
| Sitio web / redes oficiales | hasta 3 links | Opcional |
| Horario de atención | Estructurado (día + hora apertura/cierre) | No es texto libre; se usa para validar planes |
| Tarifas / precios | Lista de ítems (nombre + precio), máx. ~10 ítems | Alimenta el "rango oficial" |
| Descripción del negocio | 300-500 caracteres | Límite para evitar spam publicitario |
| Categoría / servicios | Selección de lista predefinida | Facilita moderación y búsqueda |

**Precio oficial vs. público:**
- La tarjeta muestra **dos secciones de precio**: el rango público (crowdsourced) y el "oficial" (si el dueño solicitó y pagó la ficha enriquecida).

### 8.3 Flujo de verificación y cobro de ficha enriquecida

1. Dueño llena formulario de solicitud con datos de verificación.
2. Un administrador valida la información y se contacta con el solicitante (llamada, email o WhatsApp) para confirmar identidad y acordar condiciones.
3. Verificación según tipo de negocio:
   - **Negocios formales** (hoteles, restaurantes, etc.): Certificado de Cámara de Comercio (matrícula mercantil, verificable en RUES) o RUT como alternativa.
   - **Sitios informales / lugares sin dueño claro** (miradores, planes naturales): no aplica ficha "oficial"; quedan siempre en modo público/crowdsourced.
   - **Personas naturales que prestan servicio en un sitio** (guías, vendedores fijos): cédula + foto en el sitio + evidencia de presencia recurrente (reportes de usuarios), sujeto a criterio del admin.
   - **Respaldo general**: foto del local con nombre visible + selfie/video corto del solicitante en el sitio.
4. Administrador marca la solicitud como "lista para pago" → el dueño paga y adjunta comprobante.
5. Administrador valida el comprobante → aprueba → se activa/edita la ficha.

**Modelo de cobro (Modelo B seleccionado):**
- Cobro de activación único: **$30.000 COP**.
- Incluye **3 ediciones gratuitas**, utilizables dentro de los **6 meses** siguientes a la activación.
- Agotadas las 3 ediciones gratuitas (o vencido el plazo de 6 meses), cada edición adicional tiene un costo de **$10.000 COP**.
- Estos valores son parametrizables desde el panel de administración (sección 12), no están escritos en código de forma fija.

### 8.4 Reportes sobre la ficha

- **"Precio desactualizado"**: usuarios reportan; al llegar a un tope definido, la sección de tarifas se **oculta automáticamente** hasta que el dueño actualice.
- **"Sitio deprecado / ya no existe"**: usuarios reportan; al llegar a un tope, el sitio se marca como **fuera de búsquedas/planes** (se conserva como historial, reactivable a futuro).
- Ambos casos requieren **revisión humana de un administrador** antes de la acción final (no es 100% automático):
  - Se guarda registro de qué usuarios reportaron (visible solo para administradores).
  - Se intenta contactar al dueño del sitio.
  - Si no hay contacto posible, el administrador decide, con criterio, entre depreciar el sitio o incrementar el tope de reportes necesario.
- **Apelación**: el dueño puede apelar una depreciación; un administrador revisa, intenta contacto, y decide entre reactivar (subiendo el tope) o mantener la depreciación.

---

## 9. Moderación de contenido (enfoque MVP simplificado)

- La app está explícitamente delimitada a fines de **turismo, gastronomía y planes de ocio**. Cualquier uso fuera de esta finalidad (contenido sexual, ilegal, acoso, lenguaje obsceno) es causal de suspensión/expulsión.
- **Mecanismos para el MVP** (deliberadamente simples, sin IA de moderación automática por ahora):
  - Botón de "reportar" disponible en: fotos individuales, sitios, eventos, perfiles de usuario.
  - **Aviso al subir cualquier foto**: recordatorio de que debe cumplir los Términos de Uso antes de publicar.
  - Reportes de fotos generan **alarma a los administradores desde el primer reporte** (no requiere tope), quienes deciden eliminar o mantener.
- **Documentos legales necesarios** (ver también sección 11):
  - Términos y Condiciones de Uso, con cláusula explícita de finalidad de la plataforma.
  - Política de Uso Aceptable / Conducta, listando prohibiciones y consecuencias (advertencia → suspensión temporal → expulsión).
  - Cláusula de responsabilidad de contenido generado por usuarios (la app modera de forma reactiva, no previa).
  - **Restricción de edad mínima: 13 años** para crear cuenta (autodeclarado vía fecha de nacimiento en el registro).
    - Usuarios registrados como menores de 18 años **no verán en búsquedas, planes ni recomendaciones** las categorías/subcategorías marcadas como restringidas (ej. "Bar/Vida nocturna"). El filtro se aplica automáticamente en backend según el árbol de categorías (sección 4.1).
    - Es un control por buena fe (sin verificación biométrica en el MVP), consistente con el estándar de la mayoría de plataformas.
- **Nota de expectativa realista**: estas medidas reducen el riesgo y demuestran debida diligencia, pero ninguna plataforma con contenido generado por usuarios elimina el riesgo al 100%. La moderación automática (filtros de texto, SafeSearch de imágenes, sistema de "strikes") queda anotada como mejora de **fase futura**, no bloqueante para el MVP.

---

## 10. Eventos y monetización por promoción geolocalizada

### 10.1 Niveles de alcance (de menor a mayor precio)
1. Municipal
2. Multi-municipal (rango elegido por el usuario)
3. Departamental
4. Multi-departamental (rango elegido por el usuario)
5. Nacional

- El precio varía según el **tamaño/población** del municipio o departamento (no tarifa plana).
- Los niveles "multi" (multi-municipal, multi-departamental) aplican un **% de descuento progresivo** por cada unidad adicional agregada.
- Publicación **automática al pagar** (sin revisión previa), con moderación reactiva posterior (ver sección 9 y roles de administrador en sección 12).

### 10.2 Referencia de precios de mercado (para calibrar tarifas)
Publicidad en Meta Ads (Facebook/Instagram) en Colombia: CPC promedio entre $250 y $1.500 COP, con inversión mensual real recomendada entre $600.000 y $1.500.000 COP para resultados consistentes. Esta app no compite en ese modelo de subasta algorítmica, sino en un nicho hiperlocal de costo operativo mucho menor, lo que permite tarifas significativamente más bajas y aun así rentables.

**Ejemplo de estructura de referencia (ajustable):**

| Alcance | Precio de referencia | Nota |
|---|---|---|
| Municipal | $15.000–$40.000 COP | Según tamaño de población |
| Departamental | $50.000–$150.000 COP | Según tamaño de población |
| Multi (municipal/departamental) | Precio base × cantidad, con descuento progresivo | Ej. 10%/15%/20% según unidades agregadas |
| Nacional | $300.000–$600.000 COP | Tope máximo |
| Duración | Multiplicador simple según días activo | Con descuento por volumen de días |

### 10.3 Asistencia a eventos
- Usuarios verificados (Google Sign-In) pueden marcar "voy" o "tal vez" — dato **privado**, solo visible para el propio usuario.
- Quien publica el evento ve únicamente el **conteo agregado** ("45 confirmados, 120 tal vez"), nunca identidades, fotos ni perfiles.
- El publicador decide si ese conteo agregado se muestra públicamente o se mantiene oculto.
- Los eventos se incluyen automáticamente como recomendados y entran en la búsqueda de planes.

---

## 11. Roles de usuario y moderación administrativa

- **Root**: el creador/dueño de la plataforma, control total. **El root es quien designa manualmente a los administradores** (no hay auto-postulación ni solicitud de rol).
- **Administradores**: usuarios designados por el root, con permisos para validar solicitudes de fichas enriquecidas, revisar reportes (fotos, sitios, eventos), gestionar depreciaciones y apelaciones, y usar el panel de administración (sección 12).
- **Usuarios regulares**: guardan, comparten, arman planes, reportan, marcan asistencia a eventos.

*(Nota: en el MVP todos los administradores tienen el mismo nivel de acceso al panel. Sub-roles de administrador con permisos diferenciados —ej. uno solo modera fotos, otro solo aprueba pagos— quedan como posible mejora de fase futura.)*

---

## 12. Panel de administración

Sección exclusiva para **root y administradores**, con las siguientes capacidades de parametrización (para no dejar nada fijo en código y poder ajustar sin nuevos despliegues):

| Módulo | Qué permite configurar |
|---|---|
| **Categorías** | Crear, editar, activar/desactivar categorías y subcategorías del árbol fijo (sección 4.1); marcar cuáles están restringidas para menores de edad |
| **Vehículos/Transporte** | Editar los tipos de transporte disponibles (Particular/Público/Otro) y sus rangos de distancia por defecto |
| **Topes de reportes** | Definir cuántos reportes activan la ocultación automática de precio, la depreciación de un sitio, o el bloqueo de una foto |
| **Solicitudes** | Ver y gestionar el flujo completo de solicitudes de fichas enriquecidas (formulario → verificación → pago → aprobación) |
| **Reportes** | Bandeja de reportes de fotos, sitios, eventos y usuarios, con historial de quién reportó (visible solo para admins) |
| **Apelaciones** | Gestionar apelaciones de dueños de negocios sobre depreciaciones u ocultamientos |
| **Precios y tarifas de la plataforma** | Editar valores de: activación de ficha ($30.000), ediciones incluidas (3) y su vigencia (6 meses), costo por edición adicional ($10.000), tarifas de eventos por nivel de alcance y sus descuentos por combos |
| **Usuarios y roles** | Root designa/revoca administradores; suspende o expulsa usuarios (strikes manuales, dado que el MVP no automatiza esto) |
| **Eventos** | Revisión posterior de eventos publicados automáticamente, con opción de despublicar si incumplen los Términos de Uso |

---

## 13. Aspectos legales (Colombia)

- **Ley 1581 de 2012 (Habeas Data)**: aplica al tratamiento de datos personales realizado en territorio colombiano, exigiendo autorización expresa del titular para recolectar/usar sus datos, y mecanismos para que el usuario conozca, actualice o elimine su información. Como la app recopila ubicación en tiempo real, datos de Google Sign-In y fotos, esto **aplica desde el día uno** del MVP.
  - Se requiere: política de tratamiento de datos personales + checkbox de aceptación expresa en el registro.
- **Facturación y régimen tributario**: al recibir pagos (eventos, fichas de negocio, donaciones), es necesario resolver con un contador el esquema de facturación electrónica DIAN y la figura bajo la cual se opera (persona natural con RUT vs. sociedad SAS), especialmente relevante si se factura a entidades públicas (alcaldías).
- **Términos y Condiciones + Política de Uso Aceptable**: documentos propios (no exigidos por ley, pero necesarios contractualmente) que delimitan la finalidad de la app y las consecuencias de su mal uso.
- **Responsabilidad sobre contenido de eventos de terceros**: recomendable incluir un descargo de responsabilidad indicando que la plataforma no verifica previamente la veracidad de los eventos publicados (dado el modelo de auto-publicación al pagar).
- **Facturación electrónica (DIAN)**: dado que los pagos (donaciones, eventos, fichas de negocio) se lanzan en una fase posterior al MVP, se recomienda:
  1. **Fase de demo/validación** (donde estás ahora): operar sin procesar pagos reales, o con pagos de prueba (sandbox de la pasarela), sin necesidad de facturación electrónica todavía, ya que no hay ingresos reales que declarar.
  2. **Antes de activar cobros reales** (donaciones, eventos y fichas de negocio): definir con un contador la figura bajo la cual facturarás (persona natural con RUT en régimen simplificado, o constituir una SAS), y registrarte como facturador electrónico ante la DIAN si superas los umbrales que exigen factura electrónica (esto depende del tipo de ingreso y volumen, y conviene confirmarlo puntualmente con el contador en el momento de activar cobros, ya que los topes y requisitos pueden variar).
  3. La mayoría de pasarelas de pago en Colombia (Wompi, PSE) no generan la factura electrónica DIAN por ti automáticamente — eso corre por cuenta del negocio (tú), normalmente mediante un proveedor tecnológico autorizado por la DIAN o un software contable integrado.

---

## 14. Pagos

- **Pasarelas externas** (Wompi, PSE, MercadoPago) en vez de Google Play Billing, ya que este último está pensado para bienes/contenido digital y cobra comisión de 15-30%; usar pasarelas externas para "servicios del mundo real" como publicidad de eventos es más adecuado y evita fricción con las políticas de Google Play.
- **Bre-B** (sistema de pagos inmediatos interoperable del Banco de la República) como opción prioritaria para donaciones rápidas, sujeto a que la pasarela elegida ya lo soporte en su API al momento de implementar.

---

## 15. Resumen de fases sugeridas

### Fase 1 — MVP
- Guardado vía share sheet (Android).
- Categorización + ubicación (auto-detección o estado "pendiente").
- Fotos (Google Places + subida manual, límite 15).
- Privacidad por defecto, opción de hacer público.
- Capa social básica con anti-duplicados (confirmación manual del usuario).
- Recuerdos por proximidad geolocalizada.
- Planes: creación, edición, transporte inteligente en vivo, exportar a Maps, validación de horarios.
- Búsqueda/armado de planes por presupuesto (por sitio, opcional).
- Moderación simple: reportar + aviso al subir fotos.
- Roles root/admin + panel de administración (categorías, vehículos, topes, solicitudes, reportes).
- Trazabilidad de rutas/planes visitados ("Mis rutas").
- Búsqueda general + búsqueda avanzada por filtros.
- Términos de Uso, Política de Conducta, política de datos personales.
- Pagos en modo demo/sandbox (sin facturación electrónica real todavía).

### Fase 2 — Monetización
- Activación de pagos reales (salida del modo demo): definición de figura tributaria y facturación electrónica DIAN con el contador.
- Eventos geolocalizados con niveles de alcance, descuentos por combos, auto-publicación, asistencia verificada.
- Fichas enriquecidas de negocio (verificación, cobro, reportes de precio desactualizado/deprecado).
- Pasarelas de pago + donaciones + Bre-B.
- Tarifas de referencia para transporte público (costo de pasaje por ciudad).

### Fase 3 — Expansión
- iOS.
- Moderación automática (filtros de texto, SafeSearch de imágenes, sistema de "strikes").
- ~~Sistema de reseñas/calificaciones para sitios.~~ (adelantado; ver §8.1)
- Presupuestos/paquetes promocionales para negocios.
- Expansión geográfica fuera de Colombia (sujeto a validación de éxito y marco legal de cada país).

---

## 16. Recomendación tecnológica y escalabilidad

### 16.1 Por qué esta base y no otra (respuestas a dudas de diseño)

**¿Por qué relacional y no NoSQL?**
La app depende de relaciones complejas (un sitio con múltiples categorías, fotos, usuarios que lo guardaron; un plan con sitios ordenados; eventos con asistentes), de **transacciones atómicas** para pagos/ediciones/topes de reportes, y de **consultas geoespaciales avanzadas** (radio + categoría + presupuesto + horario combinados). PostgreSQL con PostGIS es el estándar de la industria para exactamente este perfil de necesidades; una base NoSQL tipo documento obligaría a duplicar datos o hacer múltiples consultas para reconstruir esas relaciones, y sus capacidades geoespaciales son más limitadas para combinaciones complejas.

**¿Por qué Flutter y no Kotlin desde el inicio, si se quiere priorizar iOS?**
Kotlin es un lenguaje que corre sobre la JVM (Android). Para tener iOS con Kotlin haría falta Kotlin Multiplatform (comparte solo lógica, no interfaz — hay que construir la UI de iOS aparte en Swift) o reescribir la app completa en Swift. **Flutter comparte interfaz y lógica en un solo código para Android e iOS desde el día uno**, por lo que es la opción que efectivamente evita reescribir todo cuando llegue la Fase 3 (expansión a iOS).

### 16.2 Stack recomendado para el MVP (100% gratuito, pensado para un círculo cerrado de prueba)

| Componente | Recomendación | Por qué |
|---|---|---|
| **Backend + Base de datos + Auth + Storage** | **Supabase** (plataforma open-source sobre PostgreSQL) | Capa gratuita indefinida (sin tarjeta de crédito) que incluye PostgreSQL con **PostGIS habilitado**, autenticación con Google Sign-In, almacenamiento de archivos (fotos) y funciones serverless (Edge Functions) para la lógica de negocio — todo en un solo proveedor, sin necesidad de levantar un servidor aparte para el MVP |
| **App móvil** | **Flutter** | Una sola base de código para Android e iOS, interfaz moderna con Material 3, buen rendimiento con bajo consumo de recursos |
| **Notificaciones push** | **Firebase Cloud Messaging (FCM)** | Gratis sin límite de uso; se integra sin conflicto junto a Supabase (Supabase para datos, FCM solo para notificaciones) |
| **Recordatorios/recomendaciones por ubicación** | **Geofencing API de Google Play Services** | El sistema operativo vigila los radios alrededor de los sitios guardados en segundo plano con consumo mínimo de batería, y solo despierta la app cuando el usuario entra/sale de una zona — evita el desgaste de batería de una consulta de GPS constante |
| **Geocoding de sitios al compartir** | **Google Places API** (capa gratuita mensual) | Suficiente para el volumen de un grupo cerrado de prueba |
| **Exportar rutas** | **Google Maps** (solo como destino vía intent/deep link, sin renderizar mapa propio) | Gratis, ya que solo se abre la app externa con los puntos cargados |
| **Algoritmo de armado de planes** | Lógica propia simple (vecino más cercano + filtro de presupuesto/horario), sin IA | Rápido, gratis, predecible, no depende de ninguna API externa |
| **Uso puntual de IA (opcional)** | **Gemini API, capa gratuita de Google AI Studio** (modelo Flash-Lite), solo para interpretar el texto/caption de un post compartido y sugerir categoría/ubicación cuando no se detectan automáticamente | Uso quirúrgico para una sola tarea puntual, con cupo diario gratuito amplio para un grupo cerrado — no se usa para "todo", solo para esta interpretación de texto |

### 16.3 Camino de escalabilidad (sin retrocesos, incluida expansión internacional)

| Decisión temprana | Por qué evita reescribir después |
|---|---|
| **PostgreSQL + PostGIS desde el día uno** (vía Supabase) | Migrar de motor de base de datos con datos geoespaciales ya cargados es una de las migraciones más costosas que existen; al crecer, se pasa del plan gratuito de Supabase al plan de pago (~$25 USD/mes) sin cambiar de tecnología ni reescribir consultas |
| **Multi-moneda y multi-idioma en el modelo de datos desde el inicio** (aunque el MVP solo use COP/español) | Agregar soporte a otra moneda/idioma después de que el esquema asumió "todo es COP y texto en español" obliga a migraciones de datos delicadas; declarar estos campos como configurables desde ya cuesta casi nada |
| **Categorías, vehículos, tarifas y topes parametrizados en base de datos (panel de administración), nunca hardcodeados en el código** | Permite ajustar reglas de negocio (nuevas categorías, nuevos países con otros medios de transporte típicos) sin nuevos despliegues |
| **Lógica de negocio en Edge Functions organizadas por dominio** (usuarios, guardados, planes, eventos, pagos, moderación como módulos independientes) | Si un módulo crece mucho más que otro, se puede migrar a un backend/microservicio dedicado sin rehacer el resto |
| **Flutter para la app móvil** | Una sola base de código para Android e iOS evita reescribir toda la capa de interfaz al llegar la Fase 3 |
| **Pasarela de pagos con soporte multi-país** (validar esto al elegir proveedor, ej. si Wompi u otra opción operan o planean operar fuera de Colombia) | Si la pasarela elegida no opera en otros países, expandir internacionalmente exigiría reintegrar una pasarela distinta desde cero; conviene confirmarlo con el proveedor antes de comprometerse |
| **Geofencing en vez de polling constante de GPS** | Además de ahorrar batería desde ya, es la misma arquitectura que soportará mayor volumen de usuarios sin degradar el rendimiento del dispositivo |

### 16.4 Cuándo migrar de la capa gratuita

- El proyecto puede permanecer en el plan gratuito de Supabase indefinidamente mientras no se exceda el uso (aprox. 500 MB de base de datos, 1 GB de almacenamiento de archivos, 50.000 usuarios activos mensuales) — más que suficiente para el círculo cerrado de prueba.
- Una particularidad a tener en cuenta: los proyectos gratuitos de Supabase se **pausan automáticamente tras 7 días sin actividad** (se reactivan manualmente desde el panel, o se puede programar un "ping" automático gratuito para evitarlo).
- Cuando el proyecto crezca más allá del grupo cerrado (más usuarios, más fotos, más tráfico), se migra al plan de pago de Supabase (~$25 USD/mes) sin cambiar de tecnología ni reescribir el backend.
