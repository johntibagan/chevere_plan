# Pendientes

No bloquean el uso diario. Al implementar, tacha aquí y ajusta el código.

## Captura / Maps

- Autocomplete al pegar URL de Google Maps: a veces no llena ciudad, departamento ni dirección. Quedó explícitamente en espera. El usuario puede completar el selector DIVIPOLA a mano.

## Planes

- “Marcar visitado” vs “incluir en Maps” (checkbox) confunde; falta copy más claro.
- Si una parada no tiene coords, Maps no la incluye — avisar mejor.
- Compartir plan por link: en la spec, no entregado.
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
