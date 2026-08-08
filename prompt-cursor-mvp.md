# Prompt para Cursor — Desarrollo del MVP por Ciclos

> Copia y pega este contenido como prompt inicial en Cursor (chat/composer), en la raíz del repositorio, con el archivo `especificacion-app-guardados-planes.md` ya presente en el repo.

---

## Contexto del proyecto

Estás ayudando a construir el MVP de una aplicación móvil (nombre a definir) enfocada en **turismo, gastronomía y planes de ocio en Colombia**. La app permite guardar lugares descubiertos en redes sociales (Instagram, TikTok, Facebook), organizarlos por categoría, recibir recordatorios por proximidad, y armar planes/itinerarios inteligentes con transporte sugerido.

**La especificación funcional completa está en el archivo `especificacion-app-guardados-planes.md` en la raíz del repositorio.** Este documento es la fuente de verdad del producto: antes de implementar cualquier funcionalidad, léelo y cita la sección exacta en la que te basas. Si algo no está claro o no está cubierto en ese documento, **pregúntame antes de asumir o inventar comportamiento**.

## Estructura del repositorio (monorepo)

```
/
├── especificacion-app-guardados-planes.md   # Fuente de verdad del producto (no modificar sin autorización)
├── frontend/                                  # App móvil en Flutter
├── backend/                                   # Lógica de negocio (Supabase Edge Functions) + esquema de base de datos
├── docs/                                       # Documentación técnica generada durante el desarrollo (decisiones, ADRs)
└── README.md
```

## Stack técnico (ya decidido, no proponer alternativas sin justificar por qué el actual no funciona)

- **Backend / Base de datos / Auth / Storage**: Supabase (PostgreSQL + PostGIS, Auth con Google Sign-In, Storage para fotos, Edge Functions para lógica de negocio).
- **App móvil**: Flutter (Android primero, preparado para iOS después).
- **Notificaciones push**: Firebase Cloud Messaging (FCM).
- **Recordatorios por ubicación**: Geofencing API de Google Play Services (nunca polling constante de GPS).
- **Geocoding de sitios**: Google Places API.
- **Exportar rutas**: deep link a Google Maps (no se renderiza mapa propio dentro de la app).
- **Algoritmo de armado de planes**: lógica propia (vecino más cercano + filtros de presupuesto/horario), sin IA para esta parte.
- **Uso puntual de IA (opcional, fase posterior)**: Gemini API (capa gratuita) solo para interpretar texto/caption cuando no se detecta ubicación/categoría automáticamente.

## Reglas de trabajo para Cursor

1. **Trabaja por ciclos cortos y verificables** (ver plan de ciclos abajo). No adelantes funcionalidad de un ciclo posterior sin que el actual esté cerrado y probado.
2. **Al finalizar cada ciclo**, presenta un resumen breve de: qué se implementó, qué archivos se tocaron, y qué falta validar manualmente antes de seguir.
3. **No inventes reglas de negocio.** Si la especificación no cubre un detalle necesario para codificar, pregunta explícitamente antes de decidir por tu cuenta.
4. **Todo lo parametrizable (categorías, vehículos, tarifas, topes de reportes) debe vivir en base de datos**, nunca hardcodeado en el código (ver sección 12 y 16.3 de la especificación).
5. **Mantén el modelo de datos preparado para multi-moneda y multi-idioma** desde el inicio, aunque el MVP solo use COP/español (sección 16.3).
6. **No implementes lógica de pagos reales todavía** — solo dejar la estructura lista para pasarela externa (Wompi/PSE) en modo sandbox/demo (secciones 13 y 15, Fase 1 vs Fase 2).
7. **Cualquier decisión de arquitectura no trivial** (ej. cómo modelar el árbol de categorías, cómo estructurar el estado "borrador") debe proponerse primero en texto antes de escribir código, para validarla conmigo.

---

## Diseño UI (Figma Make) — referencia visual

**Archivo:** [Guardados app diseño](https://www.figma.com/make/HhANLxoeQuTr5YJZnTAfG7/Guardados-app-dise%C3%B1o)  
**fileKey:** `HhANLxoeQuTr5YJZnTAfG7` (Figma Make; node raíz `0:1`)  
**Nota de marca:** el prototipo usa el nombre *Chebre Plan*; el producto en código/package es **Chevere Plan** (`com.chevere.plan`). Preferir Chevere Plan salvo que se decida renombrar.

Al implementar UI de cada ciclo, **adaptar** este prototipo a Flutter (no copiar React/shadcn tal cual). Pantallas del Make → ciclo:

| Pantalla Figma | Ciclo | Notas |
|---|---|---|
| Shell login / sesión | 0 | Ya entregado (Material 3 mínimo; alinear look Figma en pulido) |
| **Panel Administrador** (`admin`: General, Usuarios, Categorías, Reportes) | **1** (mínimo) + 7 | Ciclo 1: **Categorías + Vehículos/transporte** (especificación §12). Tabs Overview/Usuarios/Reportes del mock: placeholders o Ciclo 7 |
| Inicio, detalle de lugar, **Guardar** (FAB) | **2** | Captura/share sheet, borrador, fotos |
| Privado / público en cards y detalle | **3** | Capa social y anti-duplicados |
| Banner “cerca de mí” / recuerdos | **4** | Geofencing |
| Planes, detalle plan, crear plan, Abrir en Maps | **5** | Planes + transporte |
| Explorar + búsqueda/filtros | **6** | Búsqueda general y avanzada |
| Rutas / historial visitados; reportes en admin | **7** | Mis rutas + moderación |

Tokens útiles del prototipo (orientativos): fondo `#0B0D15`, superficie `#141A24`, acento `#FFBB33`, OK `#00D68F`, alerta `#FF5252`.

---

## Plan de ciclos del MVP (Fase 1, según sección 15 de la especificación)

### Ciclo 0 — Setup base
- Inicializar estructura del monorepo (`frontend/`, `backend/`, `docs/`).
- Configurar proyecto Supabase (base de datos, Auth con Google Sign-In, Storage).
- Configurar proyecto Flutter base (estructura de carpetas, tema Material 3, navegación).
- Configurar Firebase Cloud Messaging.
- Entregable: app que compila, con login por Google funcionando, sin funcionalidad de negocio todavía.

### Ciclo 1 — Modelo de datos y panel de administración base
- Diseñar y migrar el esquema de base de datos: usuarios, roles (root/admin/usuario), árbol de categorías (sección 4.1), tipos de transporte (sección 7.2), sitios, fotos, guardados.
- Implementar el árbol de categorías fijo y parametrizable desde base de datos.
- Implementar panel de administración mínimo (sección 12): gestión de categorías y vehículos — UI alineada al tab **Categorías** (y sección vehículos) del Figma Make anterior.
- Entregable: base de datos poblada con el árbol de categorías inicial y tipos de transporte; panel de admin accesible solo para root/admin.

### Ciclo 2 — Captura y guardado de sitios
- Implementar recepción de "compartir" desde el sistema (share sheet de Android) hacia la app.
- Flujo de guardado: detección automática de ubicación (o estado "pendiente"), selección de categoría/subcategoría (autocompletable), carga de fotos (máx. 15 por sitio, prioridad Google Places).
- Implementar estado "borrador" con notificación de recordatorio para completar (sección 3.1).
- Entregable: un usuario puede compartir un post desde otra app, guardarlo, categorizarlo y verlo en su lista personal.

### Ciclo 3 — Privacidad, capa social y anti-duplicados
- Guardado privado por defecto, con opción de hacerlo público.
- Detección de duplicados por coordenadas + nombre (sección 5), con confirmación manual del usuario.
- Vista de "compartido también por" en sitios públicos.
- Entregable: dos usuarios de prueba pueden guardar el mismo sitio y el sistema los detecta como posible duplicado.

### Ciclo 4 — Recordatorios por ubicación
- Implementar Geofencing API alrededor de los sitios guardados (propios y públicos si el usuario activó la opción).
- Notificación tipo "recuerdo" al acercarse a un sitio guardado.
- Entregable: notificación funcional al simular proximidad a un sitio de prueba.

### Ciclo 5 — Planes inteligentes
- Algoritmo de armado de plan (vecino más cercano + validación de horarios + presupuesto por sitio).
- Transporte inteligente en vivo con rangos configurables (particular/público/otro, sección 7.2).
- Pantalla de plan como lista ordenable, con edición manual.
- Botón "Enviar a Maps" consciente del progreso (solo paradas pendientes, sección 7.3).
- Entregable: un usuario puede pedir un plan para una ubicación con sus guardados, editarlo, y exportarlo a Maps.

### Ciclo 6 — Búsqueda
- Búsqueda general (texto simple).
- Búsqueda avanzada por filtros: categoría, transporte, presupuesto, ubicación, horario (sección 7.5).
- Entregable: ambas búsquedas devuelven resultados coherentes sobre datos de prueba.

### Ciclo 7 — Trazabilidad y moderación básica
- Historial de rutas/planes visitados ("Mis rutas", sección 7.6).
- Botón de reportar en fotos, con alarma a administradores desde el primer reporte (sección 9).
- Aviso al subir fotos recordando los Términos de Uso.
- Entregable: historial visible por usuario; reportes de fotos visibles en el panel de admin.

### Ciclo 8 — Pulido y cierre de Fase 1
- Revisión de rendimiento (batería, tiempos de carga).
- Revisión de textos legales mínimos (aviso de privacidad, Términos de Uso básicos) integrados en el flujo de registro.
- Entregable: MVP navegable de punta a punta para el círculo cerrado de prueba.

---

## Cómo debe responder Cursor en cada ciclo

Al empezar un ciclo, Cursor debe:
1. Releer las secciones relevantes de `especificacion-app-guardados-planes.md`.
2. Proponer brevemente el enfoque técnico antes de escribir código.
3. Implementar en pasos pequeños, no todo el ciclo de una sola vez.
4. Señalar explícitamente cualquier supuesto que esté haciendo por falta de detalle en la especificación.

**No pases al siguiente ciclo hasta que el actual esté confirmado como cerrado.**
