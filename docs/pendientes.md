# Pendientes

No bloquean el uso diario. Al implementar, tacha aquí y ajusta el código.

## Captura / Maps

- Autocomplete Maps: cadena multi-estrategia (redirect → `!3d!4d` → HTML → feature-id → geocode acotado por nombre en CO → viewport `@`). Sin Google Places API (billing). Si falla, mapa interactivo.

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
- Rutas
- Planes