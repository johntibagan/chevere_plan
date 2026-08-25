# Chevere Plan — lo que hace la app hoy

Documento de producto **según el código**. Solo lo que un usuario o admin puede hacer **ya**. Se actualiza en el **mismo cambio** que el código.

Qué no romper: [`invariantes.md`](invariantes.md).  
Estilo, pantallas y navegación (para Figma): [`ui-navegacion.md`](ui-navegacion.md).

---

## En una frase

Chevere Plan es una app Android para **guardar lugares** que ves en la vida o en redes, **evitar duplicados públicos**, **escribir reseñas o bitácoras**, **buscar** sitios (tuyos y públicos), **armar un plan de paradas** y **recordarte** cuando estás cerca de uno guardado.

Público y privado se distinguen por **color** (verde / morado), no hace falta repetir las palabras en cada tarjeta.

---

## Quién entra y con qué rol

1. Abrís la app → pantalla de **iniciar sesión con Google**.
2. El servidor crea un perfil (nombre, foto, rol `usuario`).
3. Un correo concreto queda como **root** al resetear la base (dueño del catálogo masivo). Hay también rol **admin**.
4. Admin y root entran al **panel** desde el avatar en Inicio. Reportes viven en ese panel. Sobre **contenido público** actúan casi como dueños. Las **bitácoras privadas no las ven**: solo quien las escribió.

```mermaid
sequenceDiagram
  actor U as Usuario
  participant App
  participant Auth as Google / Supabase
  U->>App: Abrir app
  App->>Auth: Sesión Google
  Auth-->>App: Usuario + perfil
  App-->>U: Inicio (lista de guardados)
```

---

## Mapa de la app (barra inferior)

| Sitio | Qué ves |
|---|---|
| **Inicio** | Saludo + título, campana, banner de recuerdo, borradores, **Vista** (lista / 2 / 3 / 4, aplica a recientes y populares), esas dos secciones y **acciones rápidas** (se pliegan). **Ver más** abre Explorar. Portada: foto o ilustración de categoría padre; borde verde/morado. |
| **Explorar** | Búsqueda de sitios (cabecera Figma, chips de categoría, lista o cuadrícula 2/3/4). Misma lógica: texto obligatorio en modo simple, filtros avanzados, incluir públicos |
| **+ (centro)** | Guardar o completar un lugar (crear y editar son la **misma pantalla**) |
| **Planes** | Tus itinerarios (tarjeta de crear + lista; **un solo** CTA, sin FAB duplicado) |
| **Rutas** | Historial de paradas visitadas (stats del listado + timeline Make). Admin no vive acá |

Los tabs que ya abriste se quedan en memoria para que cambiar de pestaña se sienta instantáneo. Las listas pintan caché primero y refrescan detrás. Si una sección no carga, ves **Error en la app. Intenta de nuevo.** y al tocarlo se reintenta; no hay toasts de error ni la palabra “failed”.

**Atrás en el shell:** si estás en Explorar, Planes o Rutas, el botón atrás vuelve a **Inicio**. En Inicio, el primer atrás muestra “Pulsa atrás otra vez para salir”; el segundo (en ~2 s) cierra la app. En fichas, guardar, mapas, etc. atrás sigue cerrando esa pantalla.

**Favoritos:** el corazón (cards de Inicio/Explorar y ficha del sitio) marca o quita el sitio en tu lista de favoritos. Relleno = está marcado. Hoy no hay pestaña ni filtro de favoritos; eso va en [`pendientes.md`](pendientes.md). No es lo mismo que “Tuyo” (tu guardado).

---

## 1. Guardar un lugar

Es el corazón de la app.

### Cómo llega el lugar al formulario

- Botón **+**
- Reabrir un guardado incompleto desde Inicio
- **Compartir** un enlace desde otra app (Maps, Instagram, etc.): se intenta leer nombre, ciudad y coordenadas

Podés pegar un link de Maps **dentro del campo** (opción desde enlace / icono pegar): la app rellena nombre, ciudad y **pin**. Eso cuenta como lugar ya elegido: **no** se pregunta “¿punto exacto?” ni se tiran las coordenadas. **Público** queda habilitado si hay pin. El mapa interactivo tampoco pregunta: el usuario ya confirmó el punto.

Se guardan **las dos** ubicaciones: el **lugar** (nombre y Place ID) y el **punto exacto** (lat/lng). El interruptor va apagado si solo pegás un enlace. **Confirmar el pin en el mapa lo enciende.** Encendido: Maps abre con `query=lat,lng` (coords en el buscador), no el nombre ni el Place ID. Apagarlo no borra el pin ni Público. Contrato: [`invariantes.md`](invariantes.md).

### Qué ves en el formulario

Siempre visibles (crear vacío):

1. **Ubicación** — campo para pegar enlace de Maps (icono pegar) y preview tappable del mapa, más interruptor de punto exacto (todo en la misma card)
2. **Nombre** — obligatorio; el autocompletado de Maps lo rellena igual
3. **Público** — apagado por defecto; sin pin (lugar físico) el interruptor se ve pero no se puede encender

El resto va detrás de **Añadir sección**: chips `+` por extra (**Detalles**, **Enlaces**, **Categorías**, **Fotos**, **Visibilidad del lugar físico**). Si ya están todas, los chips desaparecen. **Guardar** es un botón ancho **abajo** (un solo CTA; no está en el AppBar).

- Al **crear**, se asume lugar físico y privado. El interruptor de “es lugar físico” solo aparece si abrís esa sección extra o si **editás**.
- Al **editar** o completar un borrador: se muestran **todas** las secciones.
- Al **compartir** desde otra app: además de ubicación y nombre, se abre **Enlaces**.
- Ayuda: icono **i** (tooltip al toque), no párrafos bajo cada campo.
- Categorías: árbol de la base; al **crear**, default **Otros**; al **editar** no se pisa lo que ya tenía.
- Sin nombre no se puede guardar (el botón queda desactivado). Sin ubicación el guardado puede quedar en borrador.

### Estados del guardado

- **Borrador**: faltan cosas (p. ej. lugar físico sin pin y sin categoría clara)
- **Pendiente de ubicación**: hay categoría explícita pero aún no hay coordenadas
- **Completo**: categoría + (si es físico) coordenadas

Los borradores viejos avisan en Inicio (“completalo”). Hay recordatorios locales espaciados (24 h / 3 días / 7 días) hasta que completes o descartes.

```mermaid
flowchart TD
  A[Ver lugar o link] --> B[Formulario Guardar]
  B --> C{¿Hay sitio público parecido?}
  C -->|Aviso suave Maps/pegar| D[Lista de coincidencias: elegir o seguir]
  C -->|Al tocar Guardar| E[Misma lista + Guardar de todas formas]
  E --> F[Tu lista]
  D --> F
  C -->|No| G{¿Datos mínimos?}
  G -->|No| H[Borrador o pendiente]
  G -->|Sí| I[Completo público o privado]
  H --> F
  I --> F
```

---

## 2. Anti-duplicados (capa pública)

La app no quiere dos fichas públicas del mismo parque a 80 metros.

- Busca públicos **y tus propios** (aunque sean privados): mismo Place ID, pin cercano (~250 m), nombre parecido hasta 2,5 km, o misma ciudad + nombre.
- Tras un **reset completo** el catálogo masivo vuelve: si el pin/nombre coincide, **sí hay un sitio real** (no es caché fantasma). Abrir la fila debe mostrar esa ficha; **Guardar de todas formas** crea el tuyo aunque el aviso siga saliendo.
- **Aviso suave** al pegar Maps o elegir pin: ves **la lista** de sitios parecidos. Tocás la fila para **abrir la ficha** (igual que en Explorar). El círculo marca cuál usar (reseña o bitácora) o seguís con el tuyo. **No** aparece “guardar de todas formas”.
- **Al Guardar**: la misma lista, más **crear el tuyo público igual** (“de todas formas”).
- Vincular:
  - **Reseña visible** en el sitio público (o)
  - **Bitácora privada** (solo vos)
- El sitio de catálogo masivo (`external_id`) **no se vuelve privado**.

Staff/admin **no** ve bitácoras ajenas privadas.

---

## 3. Ficha del sitio

Tres pestañas: **info**, **reseñas**, **más** (quién lo creó, catálogo, fechas, “también lo guardaron”).

En info: nombre, visibilidad por color/icono (hero con franja), ciudad, pin, abrir/cómo llegar en Google Maps, categorías, precio, notas, fotos en tira horizontal (altura fija, ancho proporcional; tocar abre el visor). En pantalla completa: quién la subió, **fecha** `dd/mmm/aaaa` (sin hora), menú ⋮ (portada / eliminar / reportar), swipe. Enlaces. En el header, corazón de **favorito** (igual que en las cards). **No** hay “agregar a un plan” en esta ficha.

Editar: creador, quien lo tiene en su lista como propio, o staff sobre **público**.

Pasar de público a privado se bloquea si otros lo usan (otros guardados, aportes, paradas de plan) o si es catálogo.

---

## 4. Reseñas y bitácoras

En un sitio **público**:

- **Reseña pública**: texto, estrellas, hasta 3 fotos. Varias por persona a lo largo del tiempo. El promedio usa solo las públicas.
- **Bitácora privada**: mismo formulario, solo el autor la lee. Admin **no**.

Reportar foto inadecuada: el primer reporte avisa a staff (lista de reportes abiertos). Staff puede quitar la foto; borrar el archivo en Storage al cerrar el reporte aún es deuda.

---

## 5. Explorar (búsqueda)

Filtros: texto, categoría, lugar (texto), radio desde GPS, grupo de transporte, rango de presupuesto, incluir o no **públicos de otros**.

Resultados: tuyos, públicos, de catálogo, o **vinculados** (tu save apunta a un público existente). Se ordenan por relevancia/recencia. Vista: lista o cuadrícula 2/3/4 (la misma que en Inicio).

El filtro de “horario” en la UI **no recorta** resultados reales todavía (los sitios no tienen horarios de apertura cargados).

```mermaid
flowchart LR
  U[Explorar] --> F[Filtros]
  F --> RPC[Buscar en servidor]
  RPC --> L[Lista]
  L --> Ficha[Ficha del sitio]
```

---

## 6. Planes

1. Crear o **editar** plan: misma pantalla (título, zona, públicos, tope de presupuesto). Al crear, sigue el armado de paradas. Al editar (⋮ en el detalle) guarda y vuelve. Hay una fila “IA” que abre **en construcción** (no arma el plan sola).
2. El servidor propone **candidatos** de tus guardados (y públicos si marcaste).
3. Armás paradas. En la lista “añadidos” y en el detalle, con **2+ paradas**, arrastrás el orden; se guarda.
4. Detalle (look Figma): portada, stats de paradas/presupuesto/zona, itinerario, **Llevar a Maps**, compartir y `+` en la misma barra. Seguir: abrir ficha, marcar visitado (pasa a **Rutas**), reordenar. El `+` agrega sitios. No hay transporte inventado en stats. **Llevar a Maps** usa tu GPS como origen y el **nombre** de cada parada como destino (no el centroide DIVIPOLA: ese pin lo convierte Maps en el negocio más cercano). Si el sitio tiene **Punto exacto**, ahí sí manda lat/lng.
5. Transporte “sugerido por distancia” está **parametrizado en admin** (tipos y km), pero **la app no calcula aún** el medio: la fila abre la pantalla **en construcción**.

```mermaid
sequenceDiagram
  actor U as Vos
  participant App
  participant DB as Servidor
  U->>App: Nuevo plan + zona
  App->>DB: Candidatos
  DB-->>App: Sitios con pin
  U->>App: Elegir y reordenar paradas
  App->>DB: Guardar orden
  U->>App: Marcar visitado
  App->>DB: Historial de rutas
```

---

## 7. Rutas

Lista de paradas que marcaste hechas (sitio, plan, fecha). Sirve como “ya pasé por aquí”, no es un GPS grabando el trayecto.

---

## 8. Cercanía (“recuerdos”)

En Inicio, el banner **Recuerdo cercano** (y la campana) abre una hoja corta: radio (100–2000 m) y si querés que cuenten **sitios públicos** además de los tuyos.

El teléfono registra geocercas (tope práctico ~100, priorizando los tuyos). Si entrás al radio, notificación tipo recuerdo. Pedir ubicación “siempre” y el gasto de batería aún se pueden pulir.

**Populares cerca** (Inicio) usa la misma idea de “celda”: guarda los 4 públicos del radio de 25 km junto con el punto GPS. Al volver a Inicio pinta esa lista al toque. Solo vuelve a consultar GPS fino + búsqueda si te moviste más de ~2 km (el tope de radio de recuerdos), si la caché tiene más de 24 h, o si deslizás para refrescar.

En Inicio, arriba de **Guardados recientes**, elegís **lista** o **cuadrícula de 2, 3 o 4**; vale para recientes y populares (y Explorar usa la misma preferencia). Las secciones se **pliegan** tocando el título. **Ver más** abre **Explorar**.

Las cards/listas muestran **nombre**, **departamento - municipio** y **dirección** si hay. Si el texto no cabe en el alto de la tarjeta, esa zona hace **scroll**.

Sin foto: ilustración de la **categoría padre** (`SiteLookCover`), la misma en Inicio, Explorar, **Planes** (la card usa el primer sitio) y Rutas. Con fotos: encabezado = **portada**. La primera foto se guarda como portada; las siguientes no la pisan. En el visor, ⋮ → usar como portada. Esa misma foto va en tarjetas y listas.

```mermaid
flowchart TD
  P[Preferencias radio] --> S[Sincronizar cercas]
  S --> T[Teléfono]
  T -->|Entrás al área| N[Notificación]
  N --> A[Abrir app / sitio]
```

---

## 9. Admin y moderación

Solo staff.

- **Categorías**: árbol, keywords para autocomplete, activar/desactivar, +18.
- **Tipos de transporte**: grupo (particular / público / otro), km máximos por defecto, icono.
- **Reportes abiertos**: fotos (y tipos previstos sitio/perfil/evento; la UI cubre sobre todo fotos).

No hay panel de “tarifas de bus por ciudad” ni generación de plan por IA.

---

## 10. Catálogo de Colombia

Departamentos y ciudades vienen de **DIVIPOLA** (DANE), no de listas en la app. Al guardar, Maps puede sugerir texto; la app **casa** eso con el catálogo y guarda **ids**.

El reset completo vuelve a cargar un **JSON masivo** de sitios públicos de Colombia (dueño = cuenta root). Esos sitios alimentan búsqueda, anti-dupe y planes si incluís públicos.

---

## 11. Privacidad (reglas reales)

| Cosa | Quién la ve |
|---|---|
| Sitio privado | Autor (y staff no entra a bitácoras privadas) |
| Sitio público | Cualquier usuario logueado; staff puede editar |
| Guardado / notas / link original | Solo el dueño del save |
| Reseña pública | Quien puede ver el sitio público |
| Bitácora privada | Solo el autor |
| Catálogo masivo | Público; no se privatiza |

Errores en pantalla: mensaje de negocio o *«Error en la app. Intenta de nuevo.»* Nunca SQL ni claves.

---

## 12. Qué **no** hace hoy (aunque el spec viejo lo mencione)

- Compartir plan con un link
- Validar horarios de apertura al armar el plan
- Sugerir bus/bici/carro en cada tramo
- Exportar el plan a Google Maps desde el menú
- IA que “arme un plan para mañana”
- Monetización, eventos, fichas de negocio de pago
- iOS como producto (el código es Flutter; el uso diario es Android)
- Menores de 18 filtrados de forma estricta en toda la app (hay categorías +18 en datos; no hay flujo de edad completo)

Esos huecos viven en [`pendientes.md`](pendientes.md).

---

## Flujos de extremo a extremo (resumen)

```mermaid
flowchart TB
  subgraph captura
    SH[Share / pegar Maps / +] --> FO[Formulario]
    FO --> DU{¿Duplicado público?}
    DU -->|vincular| RV[Reseña o bitácora]
    DU -->|propio| SV[Nuevo sitio + save]
  end
  subgraph uso
    SV --> IN[Inicio]
    RV --> FI[Ficha]
    IN --> FI
    FI --> EX[Explorar]
    FI --> PL[Plan]
    PL --> RT[Rutas]
    IN --> PX[Cercanía]
  end
```

---

## Datos que la app trata como “la verdad”

- Categorías y transporte: **base de datos** + caché larga
- Geografía: **DIVIPOLA** + caché 30/90 días
- Sitios, saves, planes, reseñas: servidor; la app muestra caché y confirma después
- **Populares cerca:** Hive + ancla GPS; nueva red solo si te salís ~2 km, pasaron 24 h, o tirás a refrescar Inicio
- Fotos: Storage privado; se pueden ver si el sitio es público o es tuyo
