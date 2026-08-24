# Lineamientos de desarrollo — Frontend Chevere Plan

> Cursor: `.cursor/rules/frontend-lineamientos.mdc`. App hoy: [`aplicacion-actual.md`](aplicacion-actual.md). No romper: [`invariantes.md`](invariantes.md). No inventar features. Todo cambio de comportamiento actualiza esos docs **en el mismo pase**.

## 1. Principio general

La prioridad número uno de este proyecto es **la agilidad percibida por el usuario**: pantallas que cargan al instante, navegación fluida entre tabs, y formularios rápidos de llenar. Ante cualquier decisión técnica en duda, la pregunta que decide es: *¿esto hace que la app se sienta más rápida e intuitiva, o menos?*

## 2. Arquitectura y código

- **Modular por feature**, con capas `data / domain / presentation` dentro de `frontend/`. Cada módulo (usuarios, guardados, planes, categorías, ubicación, moderación) debe poder testearse y modificarse de forma independiente.
- **Inyección de dependencias con Riverpod** en toda la app. Nada de lógica de negocio dentro de widgets.
- **Cero duplicación (diseño y funciones):** no copiar pantallas, cards, chips, CTA ni flujos. Un widget/módulo compartido; las pantallas solo componen. Si el mismo look o la misma acción aparece (o va a aparecer) en 2+ sitios, se extrae a `core/widgets` o al feature dueño (p. ej. `home_cards`). Variantes = parámetros, no un segundo archivo casi igual. Caso extremo: un layout de una sola pantalla que extraer empeora. **Prohibido** dos CTA que hacen lo mismo en la misma pantalla (card Crear + FAB Crear).
- **Cero duplicación de código**: widgets, servicios y utilidades reutilizables antes que copiar-pegar. Si un patrón se repite 2+ veces, se extrae.
- **Theming centralizado**: colores, tipografías y spacing como tokens de diseño (coherentes con el prototipo Figma), nunca valores sueltos hardcodeados en cada pantalla.
- **Código legible antes que ingenioso**: nombres explícitos, funciones cortas y de una sola responsabilidad, comentarios solo donde el código no se explica solo. Preferir claridad sobre abstracciones prematuras.
- **Nada de reglas de negocio hardcodeadas**: todo lo parametrizable (categorías, vehículos, tarifas, topes, divisiones político-administrativas) vive en base de datos, nunca en el código.
- **No inventar comportamiento**: si la especificación no cubre un detalle necesario para codificar, se pregunta antes de asumir.

## 3. Multi-idioma y multi-región (preparación a futuro)

- Internacionalización completa desde ya con `intl` + archivos `.arb`, aunque el MVP solo use español. Ningún string de UI debe quedar hardcodeado fuera de los `.arb`.
- Fechas y horas siempre en UTC internamente; conversión a la zona local del usuario solo en la capa de presentación. Nunca asumir una sola zona horaria fija.
- Formateo de moneda desacoplado del valor numérico (multi-moneda desde el modelo de datos, aunque el MVP solo use COP).
- División político-administrativa (departamentos/ciudades) modelada con `country_code` desde el día uno, para poder agregar otros países sin cambiar esquema ni UI.

## 4. Caché y rendimiento — máxima prioridad

Esta es la sección más crítica del documento. Ninguna funcionalidad nueva se considera "terminada" si no resuelve su carga de datos vía caché.

- **Caché en capas tipo read-through**: memoria → disco (Hive CE) → red, en ese orden, para todo dato que no cambie en cada request.
- **Stale-while-revalidate** en toda pantalla que muestre datos ya vistos: se pinta de inmediato lo que ya está en caché mientras se refresca en segundo plano, sin spinners innecesarios en navegación repetida.
- **TTL explícito por tipo de dato**, ejemplo de referencia:
  | Dato | TTL fresco | Stale usable |
  |---|---|---|
  | Categorías / transporte | 24 h | 7 días |
  | Departamentos / ciudades (DIVIPOLA) | 30 días | 90 días |
  | Mis guardados (lista) | 2–5 min | 24 h |
  | Favoritos (ids) | 5 min | 24 h |
  | Ficha de sitio | 2–5 min | 12–24 h |
  | Fotos (metadata + signed URL) | alineado a firma (~50 min) | — |
  | Planes / rutas | 5–10 min | 24 h |
  | Búsqueda | 1–2 min por query | 30–60 min |
- **Imágenes**: `cached_network_image` en todo lugar donde se muestren fotos, con límite explícito de caché en disco/memoria (para no generar crashes en equipos de gama media/baja) y `memCacheWidth/Height` acotado según el tamaño real mostrado en pantalla.
- **Selectores/autocompletados que dependen de catálogos "fríos"** (categorías, ubicación) deben resolverse 100% desde memoria/disco tras la primera sincronización, sin golpe de red por interacción del usuario, incluso sin conexión.
- **Paginación y lazy loading** en toda lista potencialmente larga (Inicio, Explorar, Mis rutas). Nunca traer todo de una vez.
- **Prefetching liviano** de la pantalla siguiente probable en momentos de inactividad del usuario, sin consumir datos móviles de forma agresiva.
- **Navegación entre tabs con `IndexedStack`** (o equivalente) para que no se reconstruya cada vista al cambiar de tab.
- **`ref.watch` acotado al mínimo dato necesario** (con `.select`), nunca al objeto completo, para evitar rebuilds en cascada.
- Antes de agregar caché alrededor de una consulta pesada, evaluar primero si la consulta en sí puede aligerarse (traer solo las columnas que la vista necesita, no el objeto completo con joins).
- **Invalidación explícita** al guardar/editar/descartar, más refresco en segundo plano cuando el TTL fresco venció.

## 5. Manejo de errores (regla no negociable)

- Nunca mostrar en la UI mensajes técnicos: nada de PostgREST, SQL, stack traces, nombres de tablas/FK, códigos `PGRST*`, paths, tokens, keys, SDKs, Gradle, etc.
- Solo mensajes de negocio claros (ej. "Máximo 15 fotos por sitio").
- Ante cualquier fallo técnico o de infraestructura (incluida caché corrupta o falla de red), mostrar únicamente algo genérico: **"Error en la app. Intenta de nuevo."**
- El detalle técnico se registra en logs de depuración (`developer.log`/consola), nunca en pantalla.

## 6. UX — pantallas intuitivas y formularios rápidos

- El **formulario de crear/editar sitios** es la pantalla más sensible. No romper: [`invariantes.md`](invariantes.md). Pocos campos, prellenado, confirmar. Acciones **dentro** del campo (`suffixIcon`: pegar, buscar), no botones sueltos.
- **Botones de ayuda contextual dentro de los campos**, no como elementos separados que ocupan espacio aparte:
  - Campo para pegar un enlace (Instagram/TikTok/Google Maps/etc.): icono de "pegar" (clipboard) dentro del propio campo (`suffixIcon`) que, al tocarlo, pega el contenido del portapapeles **y dispara automáticamente** la acción asociada (ej. pegar un link de Google Maps ejecuta de inmediato la búsqueda/geocodificación, sin un botón "Buscar" adicional después).
  - Campos de búsqueda: el ícono de lupa vive dentro del propio campo de texto (`suffixIcon`/`prefixIcon`) y funciona como botón real (`onTap`), no solo decorativo — evita un botón "Buscar" separado que ocupa espacio y un tap adicional.
  - Aplicar este mismo patrón (ícono-acción embebido en el campo) a cualquier otro campo con una acción obvia asociada, en vez de multiplicar botones sueltos en la pantalla.
- Preferir iconografía estándar y reconocible (Material Icons) sobre íconos custom poco claros, para que la acción se entienda sin necesidad de texto explicativo.
- Feedback inmediato ante cada acción rápida (pegar, buscar, autocompletar): estado de carga breve y confirmación visual, nunca una acción que parezca no haber pasado nada.
- Minimizar pasos manuales: todo dato que se pueda inferir automáticamente (ubicación desde caption/Places, categoría desde texto, departamento/ciudad desde autocompletado difuso) se pre-llena y se deja solo para confirmar, no para escribir desde cero.

## 7. Cómo trabajar (aplica a todos los ciclos)

1. Releer [`aplicacion-actual.md`](aplicacion-actual.md), [`invariantes.md`](invariantes.md) y este documento antes de empezar.
2. Proponer brevemente el enfoque técnico antes de escribir código, especialmente si hay una decisión de arquitectura no trivial.
3. Implementar en pasos pequeños y verificables, no todo el ciclo de una sola vez.
4. Señalar explícitamente cualquier supuesto tomado por falta de detalle.
5. Al cerrar: qué cambió, qué probar en el celular, y **docs al día** (`aplicacion-actual.md` / `invariantes.md` si cambió comportamiento o un contrato).
6. No dar por cerrado un cambio de producto sin esa actualización de docs.
