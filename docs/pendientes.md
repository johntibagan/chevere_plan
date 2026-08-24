# Pendientes

No bloquean el uso diario. Al implementar, tacha aquí y ajusta el código.

## Favoritos

- El corazón **ya persiste** favorito sí/no (`site_favorites`).
- Pendiente de producto: lista o filtro de favoritos, usarlo en planes/ranking, notificaciones, etc.

## Captura / Maps

- Import Maps: redirect → parse `!3d!4d` → **1× Place Details** (si falta pin y hay key). Caché por URL. Sin probes HTML multi-estrategia. Setup: [`docs/google-maps-setup.md`](google-maps-setup.md). Buscador del mapa solo con botón 🔍.

## Planes

- Compartir plan por link formal (ahora solo copia texto al portapapeles).
- “Marcar visitado” / exportar a Maps: se puede reintroducir desde el menú ⋮ más adelante.
- Transporte usado al marcar visitado no se persiste.

## Búsqueda

- Filtro de horario en UI es placeholder hasta fichas con horarios reales.
- No hay búsqueda de planes por título (solo sitios).

## Moderación

- Reportar sitio/perfil/evento: tabla lista; UI MVP cubre fotos.
- Admin aún no borra el archivo de Storage al marcar un reporte como actioned.

## Proximidad

- Pedir ubicación “siempre”: copy y momento del permiso a mejorar.
- Batería / intervalos de sync de geofences: revisión fina pendiente.
- Warning Flutter `native_geofence` + KGP (`android.builtInKotlin=false`) mientras el ecosistema no migre.

## Legal / diseño

- Textos legales del login son borrador; revisión formal pendiente.
- Pixel-perfect Figma por pantalla: tema dark + shell ya aplicados; detalle por vista pendiente.


## Mis notas
- Trazabilidad: Todo debe tener fecha/usuario de creacion y fecha/usuario edicion, y demas campos necesarios para trazabilidades
- ~~Reseñas / estrellas / promedio en sitios~~ (site_reviews)
- En el sitio incluir.