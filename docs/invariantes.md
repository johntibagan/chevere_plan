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

Abrir Maps **desde la ficha** puede usar nombre / `google_place_id`. Eso no autoriza borrar coords al importar.

### Pin vs interruptor

| Origen | Coords |
|---|---|
| Enlace / share Maps | Se conservan (o se geocodifican) |
| Mapa interactivo | Se conservan; no preguntar |
| Interruptor “Punto exacto” | Solo si el usuario lo toca. Apagar = quitar pin y **bloquear Público** (lugar físico). No apagarlo en silencio |

Público en lugar físico exige **lat y lng**. Ciudad o dirección solas no alcanzan.

### Más invariantes de esta pantalla

- Depto → ciudad (DIVIPOLA, ids, no listas en Dart).
- Crear: categoría default Otros. Editar: no pisar categorías cargadas.
- Pegar = icono **dentro** del campo, no botón “Buscar” aparte.
- Anti-dupe: suave al Maps/pin; en Guardar, “de todas formas”. Vincular + reseña o bitácora.

Alto riesgo: `save_place_page.dart`, `google_maps_link_importer.dart`, `save_policies.dart`, `saves_repository.dart`, `location_picker_page.dart`.

---

## UI y errores

- Público = verde; privado = morado. Si ya hay borde/franja de color, **no** repetir “Público/Privado”.
- Listas clicables: chevron; fecha si aporta.
- Errores en UI: mensaje de negocio o **"Error en la app. Intenta de nuevo."** Nunca SQL, PostgREST, stacks, keys.
- Modales: nada de barrier sin contenido. Fotos del sitio en la ficha, no en sheet.

## Datos

- Categorías, transporte, depto/ciudad: **base + caché**, nunca hardcode en Dart.
- Reset: default conserva DIVIPOLA + catálogo (`external_id`); `-Full` = 3 migraciones + DIVIPOLA + JSON.

## Código

Ver [`lineamientos-desarrollo-frontend.md`](lineamientos-desarrollo-frontend.md): caché SWR, i18n `.arb`, negocio fuera de widgets.
