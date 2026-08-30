# Lo que no se toca

Contratos de producto. Si un cambio los rompe, el cambio está mal.  
Cursor: `.cursor/rules/` (sobre todo `docs-al-cambiar.mdc` y `guardar-sitio.mdc`).

No inventar features. Fuente de **cómo está la app hoy:** [`aplicacion-actual.md`](aplicacion-actual.md).

---

## Guardar sitio (corazón)

Pantalla: `frontend/lib/features/saves/presentation/save_place_page.dart`.

### Checklist (probar o decir qué no se pudo)

1. **+** → a mano → Guardar (privado y público).
2. **Pegar enlace de Google Maps** → se rellena nombre/ciudad/pin → **Público se activa sin abrir el mapa**.
3. Compartir desde Maps hacia la app (mismo importador).
4. Mapa interactivo → confirmar pin → coords se quedan.
5. Editar un sitio con pin: no borrar coords salvo interruptor o “limpiar punto”.
6. Anti-duplicado suave (Maps/pin) y duro (Guardar).
7. No físico → no público.
8. Crear y editar = **la misma pantalla**.

Si falla el punto 2, revertir.

### Enlace Maps = lugar ya elegido

El usuario buscó en Maps y trajo el link. **No** preguntar “¿guardar el punto exacto?”. **No** poner lat/lng en null. Conservar pin o geocodificar el nombre una vez. Público habilitado si hay coords.

Ese diálogo **no se reintroduce**: al decir “solo el lugar” se perdía el pin y Público pedía ubicación aunque el form ya estaba lleno.

Abrir Maps **desde la ficha**:
- **Lugar** (interruptor apagado, default): búsqueda / ficha (nombre + `google_place_id`).
- **Punto exacto** (interruptor encendido): búsqueda `lat,lng` (sin nombre ni Place ID).

Al pegar Maps o confirmar el mapa se **guardan las dos**. El interruptor no borra coords.

### Pin vs interruptor

| Origen | Coords (pin) | Lugar (nombre / Place ID) |
|---|---|---|
| Enlace / share Maps | Se conservan (o se geocodifican) | Se conservan |
| Mapa interactivo (ficha: búsqueda o chip Nearby) | Se conservan | Place ID de la ficha. **Apaga** punto exacto |
| Mapa interactivo (solo pin) | Se conservan | Reverse / sin ficha. **Enciende** punto exacto |
| Interruptor “Punto exacto” | No borra el pin. Solo elige cómo abrir Maps. Default **apagado**. Encenderlo sin pin abre el mapa. |

En el mapa: Confirmar desactivado hasta buscar, tocar, arrastrar o GPS (el centro de Colombia al abrir no habilita guardar).

Público en lugar físico exige **lat y lng guardados**. El interruptor apagado **no** bloquea Público.

Público es **sección siempre visible**. Sin pin, el interruptor se muestra **desactivado** (no se oculta). No reaparece el diálogo de “¿punto exacto?” al pegar Maps.

**Llevar a Maps** (plan): origen = GPS; destino = nombre / Place ID del sitio. Prohibido armar la ruta solo con lat/lng del catálogo (el municipio es un centroide; Maps lo pega a otro POI).

**Plan — solo dueño edita (hoy):** crear/editar meta, paradas, reordenar, borrar y marcar visitado solo si `plans.user_id` = usuario logueado. RLS `plans_owner_all` en backend. Fase 2 (compartir): reglas abierto/cerrado en [`pendientes.md`](pendientes.md).

### Layout del formulario

- Si es **lugar físico**: Ubicación → Nombre (obligatorio; Maps lo rellena) → **Visibilidad** (lugar físico + Público en **una** fila, cada uno con icono i).
- Si **no** es físico: **sin** sección de mapa/ubicación; banner de tarjeta; Nombre + visibilidad (Público desactivado).
- Extra detrás de **+**: Detalles, Enlaces, Categorías, Fotos.
- Al **editar**: misma pantalla; **Ubicación** sin pegar enlace Maps (solo mapa + punto exacto) **solo si es físico**. Conservar `is_physical_place` cargado.
- Crear: lugar físico **encendido** y privado por defecto (ambos interruptores visibles). Editar: mismas secciones fijas + extras abiertos.
- Nombre vacío: no guardar (nada de “Sin nombre”).
- Ayuda en tooltip (tap), no textos largos bajo los campos.

### Más invariantes de esta pantalla

- Depto → ciudad (DIVIPOLA, ids, no listas en Dart).
- Crear: categoría default Otros. Editar: no pisar categorías cargadas.
- Pegar = icono **dentro** del campo, no botón “Buscar” aparte.
- Anti-dupe: suave al Maps/pin; en Guardar, “de todas formas”. Lista de coincidencias (públicos + los tuyos): **Place ID** o **radio del perfil (default 100 m) + nombre parecido** — ☰ → Mismo sitio al guardar, siempre metros. No basta el mismo nombre lejos. Fila abre la ficha. Vincular + reseña o bitácora. Tras reset full, las coincidencias del catálogo son sitios vivos; abrir/guardar no debe fallar por un select de portada.

Alto riesgo: `save_place_page.dart`, `google_maps_link_importer.dart`, `save_policies.dart`, `saves_repository.dart`, `location_picker_page.dart`.

---

## UI y errores

- Público = verde; privado = morado. Si ya hay borde/franja de color, **no** repetir “Público/Privado”.
- Corazón = **favorito** del usuario (`site_favorites`), no “es tuyo”. Relleno si está marcado. No crear un `user_saves` ni tocar coords al favoritar.
- Listas clicables: chevron; fecha si aporta (`dd/mmm/aaaa`, sin hora).
- Errores en UI: **en el bloque que falló**, **"Error en la app."** y botón/enlace **"Intenta de nuevo"** (reintenta esa carga). Nunca “failed”, SQL, PostgREST, stacks, keys. **No** toasts de error técnico. Detalle en `developer.log`.
- Modales: nada de barrier sin contenido. Fotos del sitio en la ficha, no en sheet.
- Portada: el **mismo sitio** se ve igual en lista, tarjeta, ficha, planes y rutas (`SiteLookCover`: padre + foto de encabezado). Encabezado = portada elegida (`sites.cover_photo_id`). Si no hay portada, la **primera foto** queda como portada y **no** cambia al añadir más; solo “Usar como portada” en el visor la cambia. Miniaturas = esa misma foto. En visor: autor, fecha (sin hora), ⋮. La tira pequeña no lleva ⋮. Verde/morado de visibilidad se mantiene.

## Datos

- Categorías, transporte, **unidades de distancia**, depto/ciudad: **base + caché**, nunca hardcode en Dart (salvo fallback `km` si el catálogo no cargó).
- Distancia en UI: siempre la unidad preferida del usuario (`profiles.preferred_distance_unit`); default **km**. Admin gestiona `distance_units`.
- Identidad pública: **@usuario** es solo display. Reseñas, fotos, sitios, favoritos y contribuciones referencian **`profiles.id`** (nunca el username). Cambio de @usuario (máx. cada 3 meses) no rompe relaciones.
- Populares cerca (Inicio): pintar caché; no GPS fino ni `search_sites` si seguís a menos de ~2 km del ancla y la lista tiene menos de 24 h. Solo públicos de **otros** (los tuyos van en Guardados recientes).
- Reset: **solo TEST** (`CHEVERE_DB_ENV=test`, `SUPABASE_DB_URL`). Default conserva DIVIPOLA + catálogo (`external_id`); `-Full` pide escribir `test` en consola y recarga catálogo — migraciones baseline de **3** + DIVIPOLA + JSON.
- **Esquema app:** `20260808000001_schema.sql` es el espejo consolidado del esquema TEST (tablas, RPC, RLS, grants). Al cambiar backend: parche timestamp → aplicar TEST → plegar al baseline; el parche se conserva hasta **publica**.
- **Paridad esquema TEST = PDN:** mismo esquema app (tablas, RPC, triggers, RLS, storage). **Cero drift.** Al **publica**: `python backend/scripts/migrate_test_to_pdn.py` (parches + baseline en PDN, luego borra parches). Si falla, no publicar APK.
- **APK beta (PDN):** `beta_release` y bucket `beta-apks` viven en **PDN** (no TEST). La app PDN compara su build con `beta_release.build` al abrir; si hay versión mayor, bloquea hasta descargar. Publicar APK actualiza esa fila **después** de subir el archivo.
- **PDN (beta, usuarios reales):** no SQL/MCP salvo **publica** o permiso explícito del dueño. Desarrollo = solo TEST.

## Código

Ver [`lineamientos-desarrollo-frontend.md`](lineamientos-desarrollo-frontend.md): caché SWR, i18n `.arb`, negocio fuera de widgets.
