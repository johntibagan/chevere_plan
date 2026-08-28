# Especificación de producto

**App de hoy (fuente para implementar):** [`aplicacion-actual.md`](aplicacion-actual.md).  
**Contratos que no romper:** [`invariantes.md`](invariantes.md).  
**UI / Figma:** [`ui-navegacion.md`](ui-navegacion.md).

Este archivo mezcla **visión de negocio** y el **estado del MVP ya construido**.  
Para decidir features nuevas (p. ej. **compartir sitios y planes**), usar la §**1bis** y [`aplicacion-actual.md`](aplicacion-actual.md).

Setup: [setup/02-supabase.md](setup/02-supabase.md).

**Mercado:** Colombia · **Cliente diario:** Android (Flutter; iOS no es producto aún)  
**Versión documento:** alineada al código (ago 2026)

---

## 1. Resumen ejecutivo (visión)

Aplicación que centraliza el "guardado rápido" de lugares descubiertos en redes sociales (Instagram, TikTok, Facebook, etc.) y en la vida real, organizándolos por categoría y ubicación, para luego:

- Recordarlos por proximidad (estilo "recuerdos" de Google Fotos, pero geolocalizado).
- Armar planes/itinerarios bajo demanda, con transporte y presupuesto (parte aún en construcción).
- Hacer visibles sitios **públicos** a otros usuarios (búsqueda / planes), con anti-duplicados.
- A futuro: **compartir** sitios/planes dentro de la app (Fase 2); luego monetización (eventos, fichas de negocio, donaciones — Fase 3) y expansión (Fase 4). Ver §15.

**Enfoque explícito:** turismo, gastronomía, planes de ocio y actividades sanas. Uso fuera de esa finalidad está prohibido por Términos y sujeto a moderación.

---

## 1bis. Estado del producto hoy (MVP implementado) — base para decisiones

Lo que un usuario **ya puede hacer** en producción/beta. No inventar capacidades al diseñar “compartir”.

### Propuesta de valor viva

| Capacidad | Estado |
|---|---|
| Guardar lugar (físico) o tarjeta (no física) | **Sí** — misma pantalla crear/editar |
| Share **entrante** del SO (IG/TikTok/FB/Maps → app) | **Sí** — abre Guardar con parseo |
| Pegar enlace Google Maps en el formulario | **Sí** — pin + Place ID; Público habilitado si hay coords |
| Público / privado por sitio | **Sí** — default privado; color verde/morado + icono |
| Anti-duplicados al guardar | **Sí** — aviso suave + bloqueo al Guardar; vincular / reseña / favorito / guardar igual |
| Catálogo masivo Colombia | **Sí** — sitios con `external_id`; no se privatizan |
| Favoritos (corazón) | **Sí** — persistidos; filtro Explorar + atajo Inicio |
| Reseñas públicas y bitácoras privadas | **Sí** — varias por usuario; promedio solo públicas |
| Explorar / búsqueda de sitios | **Sí** — paginación servidor 15; filtros reales |
| Planes (crear, paradas, reordenar, visitado) | **Sí** — IA y transporte sugerido = “en construcción” |
| Llevar plan a Google Maps | **Sí** — intent externo multi-destino |
| “Compartir” plan | **Parcial** — copia **texto** (título + nombres) al portapapeles; **no hay link** |
| Compartir sitio (privado o público) hacia fuera | **No** — no hay botón ni deep link de ficha |
| Recuerdos por geocerca | **Sí** — notificación tipo tarjeta |
| Rutas (historial de visitados) | **Sí** |
| Perfil @usuario + avatar | **Sí** — @ obligatorio; cambio cada 90 días |
| Admin (categorías, vehículos, distancias, reportes) | **Sí** — staff |
| Portal beta (APK + reportes + cómo probar) | **Sí** — web; no es share de contenido de la app |
| Eventos / fichas de negocio de pago / IA de planes | **No** (Fase 3 / placeholders) |
| Compartir por @ + notificaciones in-app | **No** — diseño Fase 2 en [`pendientes.md`](pendientes.md) |

### Modelo de visibilidad actual (crítico para “compartir”)

| Objeto | Quién lo ve hoy | Cómo “sale” de la app hoy |
|---|---|---|
| Sitio **privado** | Solo el dueño (staff no ve bitácoras privadas ajenas) | No hay export/share de ficha. Solo el dueño puede editar. |
| Sitio **público** | Cualquier usuario **logueado** (RLS authenticated) | Visible en Explorar / anti-dupe / planes si “incluir públicos”. **No** hay share OS ni URL pública anónima de ficha. |
| Sitio **catálogo** (`external_id`) | Como público; **no se puede pasar a privado** | Idem públicos. |
| Guardado / notas / link original del save | Solo el dueño del `user_saves` | No se expone en ficha pública. |
| Reseña **pública** | Quien ve el sitio público | En ficha; reportable. |
| Bitácora **privada** | Solo el autor | Nunca staff ni otros. |
| Plan | Solo el **dueño** del plan | “Compartir” = portapapeles local (texto). Paradas pueden apuntar a sitios públicos o privados del dueño. |
| Favorito | Relación privada user↔sitio | No es “compartir”; es marca personal. |

**Bloqueo público → privado:** si **otros** (no el dueño del sitio) lo tienen en saves, aportes, paradas de plan o reseñas públicas, o es catálogo → la app **impide** privatizar (`site_privacy_blockers`). Los vínculos del dueño no bloquean.

**Compartir (diseño en curso, no implementado):** fuente única → [`pendientes.md`](pendientes.md) (*Compartir sitios y planes*). No repetir decisiones aquí.

### Superficies de producto (shell)

- **Tabs:** Inicio · Explorar · **+ Guardar** · Planes · Rutas  
- **Menú (foto de perfil):** Tu perfil, Tarjetas (no físicas), Recuerdos cercanos, Mismo sitio al guardar (m), Unidad de distancia, Admin/Reportes (staff), Tema, Cerrar sesión  
- **Inicio:** borradores, Eventos (próximamente), Guardados recientes (físicos), Populares cerca, atajos (Cerca de mí / Mis guardados / Mis favoritos / Por categoría)

Detalle operativo: [`aplicacion-actual.md`](aplicacion-actual.md).

---

## 2. Análisis de mercado (competencia existente)

Ya existen apps que resuelven parcialmente el problema de "guardar lugares desde redes sociales":

| App | Qué hace | Limitación frente a esta idea |
|---|---|---|
| **Mapstr** | Guardar lugares, etiquetas/colores, importar desde Google Maps/CSV, seguir mapas de otros usuarios, alertas de proximidad | Solo lugares, sin planes generados por IA, sin transporte inteligente, sin monetización de eventos |
| **Plotline** | Extrae ubicación de un post compartido (IG/TikTok) y lo pinea en un mapa de viajes | Similar, enfoque solo en extracción y mapa, sin capa social ni planes |
| **Stashed, Spots, Stash, Instabites, JoySpot** | Variantes del mismo concepto: compartir post → extraer lugar → guardar en mapa personal | Mismo problema: no arman planes, no manejan transporte, no tienen monetización de eventos locales |

**Diferenciales de esta propuesta:**
1. Guardado no limitado solo a "compartir para extraer lugar": categorías amplias; también **tarjetas** no físicas (privadas de uso).
2. Armado de planes (hoy manual + candidatos; IA = visión).
3. Transporte inteligente (parametrizado en admin; cálculo en app = pendiente).
4. Capa social con anti-duplicados y atribución / reseñas.
5. Monetización estructurada (visión Fase 3): eventos + fichas enriquecidas + donaciones.  
6. Compartir interno por @ (visión Fase 2): ver [`pendientes.md`](pendientes.md).

---

## 3. Flujo de captura (guardado rápido) — visión + hoy

1. Usuario ve contenido en IG/TikTok/FB → “Compartir” del sistema → esta app (**hoy: sí**).
2. La app intenta detectar ubicación (Maps link / Places; caption social más limitado).
3. Categorías desde árbol admin (**hoy: sí**; default Otros al crear).
4. Ubicación DIVIPOLA por ids + pin opcional (**hoy: sí**).
5. **Privado por defecto**; el usuario puede publicar (**hoy: sí**, con pin en físico).
6. Contenido no físico → **tarjeta**: sin mapa; no entra Explorar/planes/rutas/cercanía (**hoy: sí**; lista en ☰ → Tarjetas).

### 3.1 Guardado incompleto → borrador
- **Hoy:** estados borrador / pendiente ubicación / completo; aviso en Inicio; notificaciones locales 24 h / 3 d / 7 d; tocar abre editar.

### Fotos
- **Hoy:** hasta **15** por sitio; primera = portada (no se pisa al subir más); ⋮ en visor para cambiar portada / eliminar / reportar. Sin extracción automática Places como galería completa en MVP.

### Enlace a la publicación original
- **Hoy:** vive en el guardado del usuario (sección Enlaces); no se redistribuye como “repost” en la ficha pública comunitaria.

---

## 4. Organización y categorías

Árbol **fijo en DB**, administrable (padres/hijos, keywords, activar/desactivar). Un sitio: varias categorías.  
Ubicación: país / departamento / ciudad (DIVIPOLA), no listas quemadas en la app.

*(Tabla larga de subcategorías de la visión original sigue siendo la guía editorial; el contenido vivo es el seed/admin en Supabase.)*

---

## 5. Capa social y anti-duplicados (hoy)

- Público = visible a usuarios logueados en búsqueda/planes (si incluyen públicos).
- **Anti-dupe:** Place ID, radio pin (preferencia **m**, default 100), fuzzy nombre, misma ciudad + nombre. Flujos: aviso suave Maps/pin; al Guardar, grilla + “Guardar de todas formas” / vincular con reseña pública|privada o favorito.
- Catálogo masivo no se privatiza.
- **Compartir outbound de sitio: no implementado** (ver §1bis).

---

## 6. Recuerdos por ubicación (hoy)

- Preferencias: radio 100–2000 m + incluir públicos.
- Geofences nativas; notificación tarjeta (portada, nombre, depto–ciudad).
- Populares cerca en Inicio: públicos de **otros**, caché por celda ~2 km / 24 h.

---

## 7. Planes (visión vs hoy)

### 7.1 Generación
- **Hoy:** crear/editar plan (título, zona, incluir públicos, presupuesto tope) → candidatos → elegir paradas → reordenar → detalle → marcar visitado → Rutas.  
- **No hoy:** IA “arma un plan para mañana”; validación de horarios reales; búsqueda de planes por título.

### 7.2 Transporte
- Tipos y `default_max_km` en admin.  
- **No hoy:** sugerencia automática de medio por tramo en la UI (pantalla “en construcción”).

### 7.3 Exportar / compartir
- **Hoy:** **Llevar a Maps** (GPS + nombres / pin exacto).  
- **Hoy:** Compartir = **copiar texto** al portapapeles.  
- **No hoy:** link profundo, invite, plan colaborativo.

### 7.4–7.6 Presupuesto / búsqueda / rutas
- Tope de presupuesto en plan y filtro Explorar (UI presupuesto oculta en Explorar).  
- Explorar: sitios (no planes).  
- Rutas: historial de visitados (**sí**).

---

## 8. Ficha del sitio

### 8.1 Hoy (comunidad)
Nombre, dirección, fotos (≤15), categorías, precio estimado, notas, Maps, reseñas/bitácoras, favorito, trazabilidad básica (“más”).  
Staff edita público; no ve bitácoras privadas ajenas.

### 8.2–8.4 Ficha enriquecida / cobro / reportes de precio
**Visión Fase 3** — no implementado como producto de pago. Reportes MVP: fotos y reseñas públicas (y tipos previstos en DB).

---

## 9. Moderación (MVP simplificado)

- Reportar foto / reseña pública → bandeja admin.  
- Aviso al subir fotos (Términos).  
- Legales en login (borrador; revisión formal pendiente).

---

## 10. Eventos y monetización por promoción geolocalizada

*(Visión — **no está en el MVP vivo**. Monetización = **Fase 3**. Ver §15.)*

### 10.1 Niveles de alcance (de menor a mayor precio)
1. Municipal  
2. Multi-municipal  
3. Departamental  
4. Multi-departamental  
5. Nacional  

### 10.2 Referencia de precios de mercado
*(Sin cambios — calibración futura.)*

### 10.3 Asistencia a eventos
*(Visión Fase 3.)*

---

## 11. Roles de usuario

- **Root:** dueño plataforma / catálogo reset; designa admins.  
- **Admin:** panel + moderación contenido público.  
- **Usuario:** guarda, busca, planes, reporta, favoritos.  

---

## 12. Panel de administración (hoy)

| Módulo | Hoy |
|---|---|
| Categorías | Sí (árbol, keywords, activo) |
| Vehículos / transporte | Sí (grupo, km default, icono) |
| Unidades de distancia | Sí |
| Reportes abiertos | Sí (fotos, reseñas; tipos ampliables) |
| Solicitudes ficha enriquecida / precios plataforma / eventos | No (Fase 3) |

---

## 13–14. Legales y pagos

Visión y checklist Colombia / pasarelas: siguen válidos como **marco**.  
**Hoy:** sin cobros reales de producto; beta usa Storage/portal, no facturación DIAN de features.

---

## 15. Resumen de fases

### Fase 1 — MVP (**actualizado al producto vivo**)

**Hecho**
- Guardado vía share sheet (Android) + FAB + pegar Maps.  
- Categorización + ubicación DIVIPOLA + pin / Place ID.  
- Fotos (subida manual, límite 15, portada estable).  
- Privacidad por defecto + público con reglas de pin / tarjeta.  
- Anti-duplicados con confirmación de usuario.  
- Recuerdos por proximidad (geofences + preferencias).  
- Planes: crear/editar, paradas, reordenar, visitado → Rutas; export a Maps; compartir texto.  
- Explorar: búsqueda de sitios, filtros, favoritos, mis guardados, GPS+radio, paginación servidor.  
- Reseñas públicas + bitácoras privadas + favoritos.  
- Perfil @usuario + avatar.  
- Moderación reactiva (reportes foto/reseña) + roles root/admin + panel (categorías, vehículos, distancias, reportes).  
- Términos/privacidad en login (texto borrador).  
- Beta portal (APK + reportes + cómo probar).

**En el MVP de visión, aún no / parcial** *(siguen en Fase 1 o quedan para después; share = Fase 2)*  
- Validación de horarios de apertura en planes/búsqueda.  
- Cálculo de transporte sugerido por tramo.  
- IA que arma planes.  
- iOS como producto publicado.

### Fase 2 — Compartir (siguiente gran bloque de producto)

**Diseño de producto cerrado** (2026-08-27): [`pendientes.md`](pendientes.md) — *Compartir sitios y planes* (única fuente).  
Resumen: @ dentro de la app, grupo cerrado en sitios privados, plan Abierto/Cerrado, revocación suave. **No implementado aún.**

### Fase 3 — Monetización

*(Antes Fase 2 — mismo contenido.)*

- Activación de pagos reales (salida del modo demo): definición de figura tributaria y facturación electrónica DIAN con el contador.
- Eventos geolocalizados con niveles de alcance, descuentos por combos, auto-publicación, asistencia verificada.
- Fichas enriquecidas de negocio (verificación, cobro, reportes de precio desactualizado/deprecado).
- Pasarelas de pago + donaciones + Bre-B.
- Tarifas de referencia para transporte público (costo de pasaje por ciudad).

### Fase 4 — Expansión

*(Antes Fase 3 — mismo contenido.)*

- iOS.
- Moderación automática (filtros de texto, SafeSearch de imágenes, sistema de "strikes").
- ~~Sistema de reseñas/calificaciones para sitios.~~ (adelantado; ver §8.1 / app hoy)
- Presupuestos/paquetes promocionales para negocios.
- Expansión geográfica fuera de Colombia (sujeto a validación de éxito y marco legal de cada país).
- Push / tiempo real para notificaciones de compartir (evolución de Fase 2).
---

## 16. Recomendación tecnológica y escalabilidad

### 16.1 Por qué esta base

**PostgreSQL + PostGIS (Supabase):** relaciones, RLS, geo, anti-dupe.  
**Flutter:** un código Android/iOS; el uso diario del MVP es Android.

### 16.2 Stack del MVP (vivo)

| Componente | Hoy |
|---|---|
| Backend / Auth / Storage / DB | Supabase (Postgres + PostGIS + RLS + Storage) |
| App | Flutter (Material 3, Riverpod, i18n `es`) |
| Push / geofence | FCM + geofencing nativo (recuerdos) |
| Maps | Places / geocoding + deep link a Google Maps app |
| Planes | Lógica propia (candidatos + orden manual); sin LLM |
| Beta | GitHub Pages + Storage APK |

### 16.3–16.4 Escalabilidad / capa gratuita

Sin cambios de intención: PostGIS desde el día uno; catálogos en DB; Flutter; migrar plan Supabase al crecer. Proyectos free pueden pausarse por inactividad.

---

## Lectura recomendada al diseñar “compartir”

1. [`pendientes.md`](pendientes.md) — *Compartir sitios y planes* (**única fuente** de decisiones).  
2. §**1bis** (esta página) — qué hay **hoy** en la app.  
3. [`aplicacion-actual.md`](aplicacion-actual.md) — flujos implementados.  
4. [`invariantes.md`](invariantes.md) — privacidad / público→privado.
