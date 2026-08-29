# Pendientes

No bloquean el uso diario. Al implementar, tacha aquí y ajusta el código / docs.

---

## Compartir sitios y planes — decisiones de producto

**Fuente única** de este tema (no duplicar el detalle en otros docs; solo referenciar aquí).  
**Estado en app hoy:** [`aplicacion-actual.md`](aplicacion-actual.md). Lo de abajo es **diseño acordado**, aún no construido.

**Fase:** **Fase 2 — Compartir** (Monetización = Fase 3, Expansión = Fase 4).  
**Ahora (Fase 1):** mejoras del MVP. Share no se implementa aún; **diseño de producto cerrado** (abajo).

### Resumen en lenguaje de la app

**Sitio físico (ficha → icono compartir):** elegís @ → aviso si es privado → notificación in-app al recargar → al tocar, **SiteDetailPage**. Para quien **no** está invitado, un privado sigue invisible (no sale en Explorar). Para el **grupo cerrado** que elegiste el dueño, la ficha se comporta **como un público** (mismas acciones: favorito, Reseñas, fotos, Maps…). **Única diferencia:** reseñas y bitácoras que hoy son privadas del autor se **ven entre todos** los del grupo (no solo las públicas).

**Plan (detalle → icono compartir):** mismo selector de @. El plan arranca **Abierto**. Con **Abierto:** dueño edita todo; invitados agregan/eliminan **solo sus** paradas; todos reordenan; todos marcan visitado. Con **Cerrado:** solo marcar visitado + **Llevar a Maps**; nadie edita ni toca paradas; **solo el dueño** puede **Reabrir** y ahí gestionar @ otra vez. Gestión de invitados = **mismo diálogo** al volver a compartir; Guardar aplica altas/bajas. Quitar un @ = revocación **suave** (abajo).

**Invitee y “Tuyo”:** no recibe guardado propio; puede **favorito** y usar la ficha. **Mis guardados** / **Tuyo** / filtro Explorar **siguen igual** en el MVP para quien crea o guarda sitios.

**Etiqueta de origen:** si te compartieron un sitio **privado**, en cards y ficha (fila de origen, junto a Tuyo/Catálogo/…) aparece **Compartido** — **solo** para el invitado y **solo** en privados compartidos contigo. Públicos/catálogo compartidos **no** llevan esa etiqueta (siguen Público/Catálogo/Tuyo como hoy). El dueño no ve **Compartido** en lo suyo.

**Notificaciones:** icono junto al avatar → pantalla nueva (**solo Fase 2**).

### Decisiones cerradas

| # | Tema | Decisión | Fecha |
|---|---|---|---|
| C1 | Alcance Fase 2 | Sitios **físicos** + planes. | 2026-08-27 |
| C2 | Canal | Solo **dentro de la app** (sin link externo / share sheet). | 2026-08-27 |
| C3 | Destinatarios | **@** exacto; varios; sin reenvío por invitados. | 2026-08-27 |
| C4 | Selector @ | Estándar: @ exacto, sin sugerencias, agregados + búsqueda, **Guardar/Cancelar**. Sitio y plan. | 2026-08-27 |
| C5 | UI compartir | Icono → directo al selector (sin menú extra). | 2026-08-27 |
| C6 | Avisos | Privado: aviso. Público: texto de notificación a esos @. | 2026-08-27 |
| C7 | Notificación | In-app; tocar → ficha o plan. Sin push al inicio. | 2026-08-27 |
| C9 | Bandeja | Icono al lado del avatar → pantalla nueva. **Solo Fase 2**. | 2026-08-27 |
| C10 | Plan clipboard | Se **reemplaza** por compartir con @. | 2026-08-27 |
| C11 | Paradas privadas del dueño | Invitados **las ven** en el plan compartido. | 2026-08-27 |
| C12 | Plan en vivo | Mismo plan; cambios al **refrescar**. | 2026-08-27 |
| C13 | Grupo cerrado (sitio) | Invitados: ficha **como público** (Explorar no). Reseñas/bitácoras **privadas** de cualquier miembro del grupo **visibles entre ellos**. | 2026-08-27 |
| C14 | Invitee / Tuyo | Sin guardado **Tuyo** por el invite; **favorito** sí. **Mis guardados** del MVP **se mantiene** para quien crea/guarda. | 2026-08-27 |
| C15 | Sitios compartibles | Cualquier **físico** (privado, público, catálogo). No tarjetas. | 2026-08-27 |
| C16 | Gestión @ | Mismo diálogo compartir; Guardar aplica; revocación **suave** (abajo). | 2026-08-27 |
| C17 | Plan **Abierto** | Dueño: editar plan, paradas, cerrar, compartir. Invitados: **agregar** paradas; **eliminar solo las suyas**; **reordenar** (todos). Marcar visitado: todos. | 2026-08-27 |
| C18 | Plan **Cerrado** | Solo **marcar visitado** + **Llevar a Maps**. Nadie edita plan/paradas. **Solo dueño** **Reabrir**. | 2026-08-27 |
| C19 | @ con plan cerrado | **No** gestionar invitados hasta **Reabrir** (luego sí el diálogo compartir). | 2026-08-27 |
| C20 | Estado inicial plan | Al **crear** → **Abierto**. Etiquetas UI: **Abierto** / **Cerrado**. | 2026-08-27 |
| C21 | Revocación suave | Al quitar @ y guardar: pierde acceso; favorito deja de aplicar; en **Planes/Rutas/Explorar favoritos** el sitio o plan aparece **“Ya no disponible”** (gris, sin abrir ficha); no borra el historial del pasado. | 2026-08-27 |
| C22 | Etiqueta **Compartido** | En la fila de origen (`SiteOriginTags`): **solo** el **invitado** ve **Compartido** en sitios **privados** que otro le compartió. No en públicos/catálogo compartidos; no en el dueño; no sustituye la franja morada de privado. | 2026-08-27 |

### Revocación suave (C21)

1. Ya no abre la ficha/plan privado compartido.  
2. **Mis favoritos** / corazón: deja de listarse para ese sitio.  
3. **Planes** donde era parada: en el itinerario → **“Ya no disponible”** (no se rompe el plan del dueño ni de otros).  
4. **Rutas** (historial): fila en gris / sin navegar a ficha (“ya no disponible”).  
5. **Plan compartido** del que lo sacaron: deja de ver el plan entero.

### Dudas abiertas

*Ninguna por ahora (2026-08-27).*

### Fuera de alcance (1.ª entrega Fase 2)

- Links / deep links / share sheet hacia afuera.
- Push o tiempo real.
- Compartir sin cuenta.
- Reenvío por el invitado.
- Tarjetas no físicas.
- Icono de notificaciones en el MVP (Fase 1).

### Nota Fase 1

Seguir el MVP sin UI de share. Al tocar planes/permisos/shell, no pintar caminos que impidan estados abierto/cerrado, invites ni revocación después.

---

## Favoritos

- Corazón + filtro **Mis favoritos** en Explorar + atajo Inicio: **hecho**.
- Pendiente: pantalla dedicada “Mis favoritos”; usarlo en ranking de planes.
- *Mis guardados* / Tuyo: siguen en el MVP (ver K arriba); no confundir con favorito.

## Captura / Maps

- Import Maps: redirect → parse `!3d!4d` → **1× Place Details** (si falta pin y hay key). Caché por URL. Sin probes HTML multi-estrategia. Setup: [`docs/google-maps-setup.md`](google-maps-setup.md). Buscador del mapa solo con botón 🔍.

## Planes (otros)

- Transporte usado al marcar visitado no se persiste.
- Estados abierto/cerrado del plan: **diseño Fase 2** (arriba); hoy no existen.

## Fase 5 — IA y transporte inteligente (visión)

Sin UI en la app hoy. Cuando se implemente:

- **Armame un plan con IA:** en crear plan, generar itinerario desde título/zona/presupuesto + sitios guardados/públicos.
- **Transporte entre paradas:** en detalle del plan, sugerir medio por tramo (usa catálogo admin `transport_types`); opcional persistir al marcar visitado.

Tipos de transporte en admin siguen existiendo para parametrización futura.

## Búsqueda

- Filtro de horario en UI es placeholder hasta fichas con horarios reales.
- No hay búsqueda de planes por título (solo sitios).

## Moderación

- Reportar sitio/perfil/evento: tabla lista; UI MVP cubre fotos y reseñas.

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
