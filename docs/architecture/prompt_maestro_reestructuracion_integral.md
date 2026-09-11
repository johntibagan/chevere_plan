# PROMPT MAESTRO — REESTRUCTURACIÓN Y AUDITORÍA INTEGRAL DEL PROYECTO

## 0. ROL Y MISIÓN

Actúa como **arquitecto principal de software, ingeniero Flutter/Dart senior, arquitecto PostgreSQL/Supabase/PostGIS, especialista en seguridad y responsable de calidad**.

Tu misión es **auditar y reestructurar integralmente este repositorio**, incluyendo frontend, backend, base de datos, seguridad, testing, infraestructura local y reglas de desarrollo, para convertirlo en una base preparada para crecer durante las futuras fases del producto.

No debes limitarte a mover archivos. Debes buscar la arquitectura que mejor satisfaga, simultáneamente:

- Alta escalabilidad.
- Bajo acoplamiento.
- Alta cohesión.
- Seguridad.
- Integridad de datos.
- Ausencia de duplicación innecesaria.
- Mantenibilidad a largo plazo.
- Facilidad para pruebas.
- Buen rendimiento.
- Evolución sencilla de nuevas funcionalidades.
- Facilidad para trabajar con Cursor/IA sin generar spaghetti code.
- Consistencia visual y técnica.
- Capacidad de crecimiento de la base de datos sin rediseños constantes.

El proyecto actual **ya funciona**. Por tanto:

> **Sé agresivo con la mejora arquitectónica, pero extremadamente cuidadoso con el comportamiento existente y, especialmente, con los datos persistidos.**

No hagas cambios arbitrarios de producto, UX o comportamiento funcional durante la reestructuración.

---

# 1. CONTEXTO ACTUAL

## Stack

### Frontend

- Flutter / Dart.
- Riverpod.
- Hive para caché local/SWR.
- GoRouter / navegación.
- Firebase/Crashlytics/FCM según el código existente.
- Tests unitarios y widget.
- Patrol para E2E/aceptación.

### Backend

- Supabase.
- PostgreSQL.
- PostGIS.
- Row Level Security (RLS).
- Supabase Storage.
- Supabase Edge Functions.
- Migraciones SQL versionadas.

### Entorno

- Windows.
- PowerShell.
- Cursor.
- MCP/Conexión Supabase/Postgres cuando estén disponibles.

### Fuente visual existente

La fuente visual de verdad actual está en:

- `frontend/lib/core/theme/`
- `frontend/lib/core/widgets/`

El diseño de Figma existente **no debe tratarse como fuente de verdad**.

La reestructuración debe conservar la identidad visual actual salvo que una inconsistencia claramente identificada requiera corrección.

---

# 2. ESTADO INICIAL CONOCIDO

La estructura actual contiene, entre otras:

```text
frontend/lib/
├── app.dart
├── bootstrap.dart
├── core/
│   ├── auth/
│   ├── cache/
│   ├── config/
│   ├── design/
│   ├── di/
│   ├── distance/
│   ├── errors/
│   ├── formatters/
│   ├── l10n/
│   ├── logging/
│   ├── notifications/
│   ├── performance/
│   ├── photos/
│   ├── prefetch/
│   ├── prefs/
│   ├── shell/
│   ├── supabase/
│   ├── testing/
│   ├── theme/
│   └── widgets/
└── features/
    ├── admin/
    ├── auth/
    ├── beta/
    ├── geo/
    ├── home/
    ├── legal/
    ├── moderation/
    ├── plans/
    ├── proximity/
    ├── routes/
    ├── saves/
    ├── search/
    └── settings/
```

El repositorio también contiene:

```text
backend/
├── scripts/
├── supabase/
│   ├── functions/
│   ├── migrations/
│   └── scripts/
```

y tests:

```text
frontend/test/
frontend/patrol_test/
```

Existe actualmente un `core/di/providers.dart` grande que debe ser auditado y, si corresponde, descentralizado.

También existen reglas de Cursor bajo:

```text
.cursor/rules/
```

Estas reglas existentes deben ser auditadas, consolidadas y actualizadas para reflejar la arquitectura final.

---

# 3. PRINCIPIO FUNDAMENTAL: NO ASUMIR LA ARQUITECTURA FINAL

Los documentos existentes contienen propuestas útiles, pero **no son autoridad absoluta**.

Debes auditar el código real antes de decidir.

En particular, NO asumas automáticamente que:

- `sites_ui` debe existir exactamente como está propuesto.
- `reviews` debe convertirse obligatoriamente en módulo compartido.
- `geo` debe contener absolutamente todos los geocoders.
- `home_cards.dart` pertenece necesariamente a `sites_ui`.
- Todas las features deben adoptar exactamente la misma estructura.
- `data/domain/presentation` sea siempre incorrecto.
- VSA sea una regla dogmática.
- Clean Architecture deba aplicarse completa.
- Todo deba estar en `core`.
- Todo deba estar dentro de `features`.
- Una abstracción sea buena solamente porque evita duplicación textual.

La arquitectura final debe surgir de:

> **responsabilidad + eje de cambio + cohesión + acoplamiento + reutilización real + seguridad + evolución futura.**

---

# 4. ARQUITECTURA OBJETIVO

La estrategia arquitectónica base será:

> **Feature-first + Vertical Slices + principios selectivos de Clean Architecture + MVVM/Riverpod + Repository Pattern cuando aporte valor + infraestructura transversal bien aislada.**

No aplicar capas por dogma.

## Regla

Una abstracción solamente debe existir si aporta al menos una de estas ventajas:

- encapsula una decisión importante;
- evita acoplamiento real;
- permite sustitución/testing útil;
- contiene lógica de negocio significativa;
- representa una frontera estable;
- evita duplicación semántica;
- protege una dependencia externa;
- facilita evolución futura.

Evita:

```text
UI → Controller → UseCase → Repository → DataSource → Supabase
```

cuando cada capa solamente retransmite la llamada.

Prefiere una cadena más directa cuando no exista lógica que justifique las capas.

---

# 5. VERTICAL SLICES

Organiza las funcionalidades principalmente alrededor de **capacidades de negocio y casos de uso completos**, no solamente por tipo técnico.

Ejemplo conceptual:

```text
features/
└── sites/
    ├── create_site/
    ├── edit_site/
    ├── site_detail/
    ├── site_photos/
    └── ...
```

Pero esto es ilustrativo.

La estructura final debe determinarse después de auditar:

- dependencias;
- tamaño;
- frecuencia de cambio;
- responsabilidades;
- reutilización;
- relaciones entre funcionalidades;
- impacto en testing.

No fragmentes excesivamente.

Una feature pequeña puede permanecer simple.

Una feature compleja puede tener sub-slices.

---

# 6. SHARED KERNELS / COMPONENTES COMPARTIDOS

Evalúa explícitamente candidatos como:

```text
features/sites_ui/
features/reviews/
features/geo/
```

pero solamente conviértelos en módulos compartidos cuando exista **reutilización real y estable**.

## `sites_ui`

Debe contener UI específica de sitios si es realmente compartida:

- tarjetas;
- portadas;
- métricas;
- badges;
- elementos visuales de sitio.

No debe convertirse en un cajón de sastre.

## `reviews`

Determina si las reseñas de sitios y planes:

- comparten suficiente modelo;
- reglas;
- comportamiento;
- UI;
- persistencia;

para justificar un módulo común.

Si no, mantén responsabilidades separadas y comparte solamente componentes realmente estables.

## `geo`

Evalúa la responsabilidad de:

- geocodificación;
- búsqueda geográfica;
- PostGIS;
- DIVIPOLA;
- proveedores externos;
- modelos geográficos.

Evita acoplar dominio de negocio con proveedores externos.

---

# 7. CORE

`core` debe contener exclusivamente infraestructura transversal y conceptos verdaderamente compartidos.

Candidatos:

```text
core/
├── theme/
├── ui/
├── formatters/
├── network/
├── storage/
├── errors/
├── logging/
├── performance/
├── config/
├── localization/
└── ...
```

No conviertas `core` en un depósito de cualquier cosa reutilizable.

Pregunta siempre:

> ¿Esto es transversal a todo el producto o pertenece realmente a una capacidad de negocio?

Si pertenece al negocio, debe permanecer cerca de esa capacidad.

---

# 8. DESIGN SYSTEM Y UI

Conserva la identidad visual existente.

Centraliza:

- colores;
- tipografía;
- radios;
- spacing;
- tamaños;
- estados;
- componentes repetidos;
- patrones de interacción.

Evita valores visuales arbitrarios dispersos.

Ejemplo:

```dart
BorderRadius.circular(12)
```

debe evaluarse para sustituirse por tokens cuando represente una decisión de diseño repetida.

Pero no conviertas cada número aislado en un token artificial.

## Regla

Crear tokens cuando exista una decisión de diseño reutilizable.

No crear abstracciones solamente para evitar escribir un literal una vez.

## Widgets

Distingue:

### Primitivas globales

Ejemplo:

- botones;
- inputs;
- cards genéricas;
- loaders;
- overlays;
- dialogs;
- controles genéricos.

### UI específica de dominio

Ejemplo:

- SiteCover;
- SiteOriginTags;
- SiteReviewCard;
- SiteMetrics.

Las segundas deben vivir cerca de su dominio/shared feature correspondiente.

---

# 9. RIVERPOD Y DI

Audita completamente:

```text
frontend/lib/core/di/providers.dart
```

No hagas una división mecánica.

Busca una composición donde:

- cada feature posea sus providers;
- las dependencias estén cerca de su responsabilidad;
- la composición global sea pequeña;
- no existan providers duplicados;
- no existan dependencias circulares;
- los tests puedan reemplazar dependencias fácilmente.

Si resulta mejor una composition root pequeña más providers locales, úsala.

No conviertas `core/di` en un nuevo monolito.

---

# 10. ESTADO Y PRESENTACIÓN

Los widgets no deben contener lógica de negocio compleja.

Usa una separación clara entre:

```text
View
ViewModel / Notifier / Controller
Repository / Data access
```

cuando realmente sea necesaria.

La UI debe:

- representar estado;
- emitir eventos;
- delegar decisiones;
- manejar composición visual.

El estado debe tener una única fuente de verdad.

Evita estados duplicados entre:

- widget;
- provider;
- repository;
- cache;
- backend.

---

# 11. MODELOS Y DOMINIO

No dupliques modelos sin necesidad.

Distingue cuidadosamente entre:

- modelo de persistencia;
- DTO/API;
- modelo de dominio;
- modelo de presentación.

No crees conversiones entre cuatro modelos si todos representan exactamente lo mismo y no existe una frontera real.

Pero tampoco expongas indiscriminadamente modelos de persistencia a toda la aplicación si eso crea acoplamiento peligroso.

La decisión debe basarse en la responsabilidad real.

---

# 12. REPOSITORIES

Usa Repository Pattern cuando proteja una frontera real.

Especialmente útil para:

- Supabase;
- APIs externas;
- almacenamiento;
- caché;
- fuentes de datos múltiples;
- testing.

No crear interfaces `abstract` solamente para cumplir una regla arquitectónica.

---

# 13. CACHÉ / SWR

Audita:

```text
core/cache/
```

y todas sus implementaciones.

Determina:

- quién es propietario del caché;
- TTL;
- invalidación;
- stale-while-revalidate;
- sincronización;
- session cleanup;
- signed URLs;
- caché de entidades;
- duplicación de estrategias.

Debe existir una estrategia coherente.

Evita que cada feature invente su propio sistema de caché.

Pero tampoco fuerces toda caché a una implementación global si su ciclo de vida es específico de una feature.

---

# 14. NAVEGACIÓN

Audita GoRouter/navigation.

Define claramente:

- rutas;
- guards;
- deep links;
- navegación entre features;
- parámetros;
- ownership de rutas.

Evita que widgets conozcan detalles innecesarios de infraestructura de navegación.

Preserva los flujos existentes.

---

# 15. ERRORES

Debe existir una estrategia coherente para:

- errores técnicos;
- errores de red;
- errores de backend;
- errores de validación;
- errores de autenticación;
- errores visibles al usuario.

No mostrar excepciones técnicas directamente.

Los errores deben traducirse a mensajes apropiados en el borde de UI.

Mantén errores inline cuando el patrón actual lo requiera.

---

# 16. LOGGING, CRASHLYTICS Y PRIVACIDAD

Audita:

```text
core/logging/
core/performance/
```

y todos los logs.

Nunca registrar innecesariamente:

- tokens;
- credenciales;
- información sensible;
- ubicación precisa;
- payloads privados;
- datos de sesión.

Crashlytics debe recibir información útil para diagnosticar problemas sin convertirse en un canal de filtración de datos.

---

# 17. SEGURIDAD

Audita frontend y backend bajo principios de seguridad reales.

Revisa:

- secretos;
- API keys;
- service role keys;
- autenticación;
- autorización;
- RLS;
- Storage;
- RPC;
- Edge Functions;
- validación de entrada;
- exposición de datos;
- logs;
- sesiones;
- permisos.

Nunca asumas que:

```sql
auth.uid() = user_id
```

es la política correcta para todas las tablas.

Cada tabla debe tener una política derivada de su modelo real de acceso.

---

# 18. BASE DE DATOS: OBJETIVO FINAL

Esta parte debe tratarse como una **auditoría arquitectónica completa**, no como limpieza cosmética.

Objetivo:

> Dejar la base de datos preparada para la evolución prevista del producto, minimizando duplicación, anomalías de actualización y deuda estructural.

## Normalización

Evalúa las tablas respecto a:

- atomicidad;
- dependencias funcionales;
- claves;
- foreign keys;
- duplicación;
- entidades repetidas;
- relaciones N:N;
- datos derivados;
- valores calculados;
- historial;
- ownership.

Usa normalización hasta donde sea apropiado.

**No conviertas 3NF en una religión.**

Una desnormalización puede mantenerse si existe una razón técnica clara, medible y documentada, por ejemplo:

- rendimiento crítico;
- read model;
- materialización;
- reporting;
- integración;
- cache persistente;
- requisito de PostGIS.

Toda excepción debe documentarse.

---

# 19. BASE DE DATOS: CRECIMIENTO FUTURO

Antes de modificar tablas, analiza las funcionalidades actuales y las futuras indicadas en:

```text
feat/
docs/
README.md
```

Busca relaciones que puedan crecer:

- usuarios;
- sitios;
- categorías;
- reseñas;
- planes;
- rutas;
- favoritos/saves;
- fotografías;
- ubicación;
- moderación;
- notificaciones;
- proximidad/geofencing;
- beta/releases;
- integraciones externas.

No diseñes solamente para el estado actual.

Diseña el esquema para que nuevas fases puedan crecer sin duplicar entidades existentes.

---

# 20. MIGRACIONES DE BASE DE DATOS

## Regla principal

> **Agresivo en arquitectura; conservador con los datos.**

Cursor puede:

- crear nuevas tablas;
- renombrar tablas;
- dividir tablas;
- fusionar entidades;
- cambiar relaciones;
- agregar constraints;
- crear índices;
- modificar RLS;
- modificar Storage;
- crear funciones;
- migrar datos;
- retirar estructuras obsoletas.

Pero todos los cambios deben quedar versionados mediante migraciones.

---

# 21. TABLAS NUEVAS Y PREFIJOS `t_` / `p_`

La idea de utilizar:

```text
t_<tabla>
p_<tabla>
```

para Test/Producción **NO debe adoptarse automáticamente**.

Primero determina cómo está gestionado realmente el entorno:

- Supabase project;
- migraciones;
- test;
- producción;
- CI/CD;
- scripts existentes;
- configuración de ambientes.

### Regla

**No usar prefijos de entorno en nombres de tablas si el aislamiento correcto debe realizarse mediante proyectos/bases de datos/esquemas separados.**

Si existe un caso concreto donde crear tablas temporales o paralelas con prefijo sea la estrategia más segura, puede utilizarse, pero debe documentarse.

Preferencia general:

```text
migración versionada
→ nueva estructura
→ migración/transformación de datos
→ validación
→ compatibilidad temporal si es necesaria
→ cambio de aplicación
→ verificación
→ eliminación de estructura antigua en migración posterior
```

No crear `t_` o `p_` simplemente por costumbre.

---

# 22. MIGRACIONES SEGURAS DE TABLAS

Cuando una transformación pueda romper la aplicación, considera un patrón expand/contract:

### Expand

Crear nueva estructura compatible.

### Migrate

Copiar/transformar datos.

### Verify

Comprobar:

- cantidad de filas;
- claves;
- relaciones;
- valores;
- nullability;
- duplicados;
- integridad.

### Switch

Actualizar la aplicación para usar la nueva estructura.

### Contract

Eliminar la estructura antigua solamente cuando se haya comprobado que ya no existe dependencia.

Para cambios simples y seguros, una migración directa es preferible.

No complicar innecesariamente.

---

# 23. PROTECCIÓN DE DATOS

Antes de cualquier migración destructiva:

1. Identifica los datos afectados.
2. Determina si existe pérdida potencial.
3. Crea estrategia de rollback/recuperación.
4. Valida la transformación.
5. Comprueba counts y relaciones.
6. Ejecuta migración.
7. Vuelve a comprobar invariantes.

**Nunca eliminar datos solamente porque parecen duplicados sin determinar cuál es el registro canónico.**

---

# 24. ÍNDICES

Audita índices reales mediante el esquema y consultas.

Considera:

- PK;
- FK;
- columnas de búsqueda;
- filtros frecuentes;
- ordenamientos;
- `created_at`;
- `user_id`;
- `site_id`;
- relaciones N:N;
- PostGIS;
- geofencing;
- proximidad.

Para PostGIS evalúa índices espaciales apropiados, normalmente `GIST` cuando corresponda.

No agregues índices indiscriminadamente.

Cada índice tiene:

- coste de almacenamiento;
- coste de escritura;
- mantenimiento.

La estrategia debe basarse en consultas reales y previstas.

---

# 25. RLS

Audita **todas las tablas y Storage**.

Para cada recurso documenta:

- quién puede leer;
- quién puede insertar;
- quién puede actualizar;
- quién puede eliminar;
- bajo qué condiciones.

Busca especialmente:

- acceso entre usuarios;
- datos públicos;
- datos privados;
- datos de propietario;
- datos administrativos;
- datos de moderación;
- recursos compartidos;
- archivos Storage.

No asumir una única política universal.

Prueba las políticas.

---

# 26. SUPABASE STORAGE

Audita:

- buckets;
- paths;
- ownership;
- lectura pública/privada;
- subida;
- actualización;
- eliminación;
- URLs firmadas;
- expiración;
- exposición de archivos.

Alinea Storage con RLS y el modelo de datos.

---

# 27. EDGE FUNCTIONS / RPC

Audita:

- validación;
- autorización;
- entradas;
- salidas;
- errores;
- secretos;
- dependencias;
- permisos;
- consultas;
- duplicación de lógica.

Evita duplicar reglas de negocio entre:

```text
Flutter
Edge Function
RPC
Database
```

La lógica debe vivir en la frontera que corresponda.

---

# 28. TESTING

No sacrifiques tests durante la migración.

El repositorio contiene:

```text
frontend/test/
frontend/patrol_test/
```

y pruebas de:

- plumbing;
- sesión/home;
- planes;
- privacidad;
- reseñas;
- rutas;
- saves;
- búsqueda.

Los `WidgetKeys` utilizados por Patrol son parte del contrato de testing.

Antes de mover widgets:

1. identificar dependencias;
2. preservar keys;
3. actualizar imports;
4. ejecutar tests afectados;
5. ejecutar E2E correspondiente.

---

# 29. CALIDAD DE CÓDIGO

Evalúa compatibilidad actual antes de añadir herramientas.

Puedes adoptar:

- `very_good_analysis`;
- `custom_lint`;

si son compatibles con las versiones actuales y aportan valor.

No agregues paquetes únicamente por moda.

El objetivo es:

- análisis estático;
- consistencia;
- detectar errores;
- prevenir código muerto;
- mejorar seguridad;
- reducir complejidad;
- facilitar mantenimiento.

---

# 30. COMPLEJIDAD Y TAMAÑO

Los valores de:

- 300 líneas;
- complejidad 10;

son **guardrails**, no leyes matemáticas.

Si un archivo o función supera un umbral razonable:

1. revisa si realmente existe una mejor división;
2. refactoriza cuando mejore la arquitectura;
3. si existe una excepción válida, documenta el motivo.

No fragmentes artificialmente una pantalla coherente en 20 archivos solamente para cumplir un número.

---

# 31. CÓDIGO MUERTO

Detecta y elimina:

- imports no usados;
- variables;
- métodos;
- clases;
- widgets;
- providers;
- archivos;
- modelos;
- helpers;
- migraciones obsoletas cuando corresponda.

Pero antes de eliminar algo:

- buscar referencias;
- revisar rutas dinámicas;
- revisar tests;
- revisar generación;
- revisar reflexión/configuración;
- revisar backend;
- revisar Patrol.

Nunca asumir que un archivo está muerto por no encontrar una referencia textual simple.

---

# 32. DUPLICACIÓN

La regla no es:

> "No puede existir código parecido."

La regla es:

> "No debe existir duplicación de una misma responsabilidad que deba evolucionar conjuntamente."

Antes de abstraer, pregunta:

1. ¿Tienen la misma responsabilidad?
2. ¿Cambiarán por las mismas razones?
3. ¿Comparten invariantes?
4. ¿La abstracción reduce o aumenta acoplamiento?

Si la respuesta es negativa, puede ser mejor mantener código separado.

---

# 33. DOCUMENTACIÓN

Mantén documentación útil, no documentación redundante.

Audita:

```text
README.md
docs/
feat/
.cursor/rules/
```

Actualiza documentación cuando cambie:

- arquitectura;
- base de datos;
- seguridad;
- flujo de desarrollo;
- testing;
- deployment;
- estructura de features.

Elimina documentación obsoleta.

No dupliques la misma información en cinco archivos.

---

# 34. REGLAS PARA CURSOR / IA

El repositorio debe quedar preparado para que futuras sesiones de IA no destruyan la arquitectura.

Actualiza `.cursor/rules/` para establecer:

### Antes de implementar

- investigar;
- localizar código existente;
- buscar reutilización;
- revisar reglas;
- revisar arquitectura;
- revisar tests.

### Antes de crear

Preguntar:

> ¿Ya existe algo que haga esto?

### Antes de abstraer

Preguntar:

> ¿Esta abstracción reduce acoplamiento real o solamente mueve código?

### Antes de mover

Buscar:

- imports;
- referencias;
- tests;
- rutas;
- providers;
- claves;
- backend;
- documentación.

### Antes de eliminar

Demostrar que no existe dependencia relevante.

---

# 35. REGLAS DE DEPENDENCIA

Establece una matriz explícita.

Regla general:

```text
UI
 ↓
estado/orquestación
 ↓
dominio cuando exista
 ↓
repositorio/fuente de datos
 ↓
infraestructura
```

Pero VSA permite que una slice sea más directa cuando no existe complejidad que justifique capas adicionales.

## Prohibido

Dependencias circulares.

Ejemplo:

```text
sites → reviews → sites
```

Si aparece una dependencia circular:

1. identificar la responsabilidad compartida;
2. moverla a una frontera correcta;
3. o rediseñar la relación.

No resolver ciclos creando un `shared.dart` gigante.

---

# 36. PLAN DE EJECUCIÓN

## FASE 0 — AUDITORÍA

Antes de modificar arquitectura:

Audita:

- todo el repositorio;
- Flutter;
- pubspec;
- analysis_options;
- Riverpod;
- navegación;
- caché;
- tests;
- Patrol;
- Supabase;
- migraciones;
- RLS;
- Storage;
- Edge Functions;
- scripts;
- documentación;
- Cursor rules.

Genera:

```text
docs/architecture/
├── current-architecture.md
├── dependency-map.md
├── database-audit.md
├── security-audit.md
├── test-map.md
└── target-architecture.md
```

No migres todavía si la auditoría no está suficientemente completa.

---

# FASE 1 — BASELINE

Antes de cambios estructurales:

Ejecuta, según disponibilidad:

```powershell
flutter pub get
dart format --output=none --set-exit-if-changed .
flutter analyze
flutter test
patrol test
```

Usa comandos compatibles con el proyecto real.

Registra:

- errores;
- warnings;
- tests fallando;
- estado de compilación;
- estado de Patrol.

Si algo ya falla antes de la migración, documentarlo como baseline.

No atribuirlo a la refactorización.

---

# FASE 2 — ARQUITECTURA Y REGLAS

Definir:

- estructura objetivo;
- ownership;
- matriz de dependencias;
- estrategia de DI;
- estrategia UI;
- estrategia cache;
- estrategia repository;
- estrategia domain;
- reglas Cursor.

Crear/actualizar:

```text
docs/architecture/target-architecture.md
.cursor/rules/
```

No ejecutar una migración masiva todavía.

---

# FASE 3 — FUNDACIÓN FRONTEND

Migrar primero aquello que reduzca riesgo posterior:

- design tokens;
- UI transversal;
- infraestructura;
- errores;
- storage;
- cache;
- logging;
- configuración;
- navegación;
- DI.

Mantener compatibilidad mientras sea útil.

Validar.

---

# FASE 4 — SHARED CAPABILITIES

Auditar y decidir definitivamente sobre:

- `sites_ui`;
- `reviews`;
- `geo`.

No crear abstracciones solamente porque estaban previstas en documentos anteriores.

Migrar únicamente lo que tenga ownership claro.

Validar.

---

# FASE 5 — FEATURES

Migrar progresivamente:

1. `plans`
2. `search/explore`
3. `saves/sites`
4. `home`
5. `auth`
6. `proximity`
7. `routes`
8. `admin`
9. `moderation`
10. `beta`
11. `legal`
12. `settings`

El orden puede cambiar si la auditoría demuestra que otro orden reduce riesgo.

Para cada feature:

```text
auditar
→ definir slice
→ mover
→ corregir imports
→ revisar DI
→ revisar tests
→ revisar navegación
→ validar
→ documentar
```

No continuar con una migración defectuosa solamente para mantener el calendario.

---

# 6. BACKEND Y BASE DE DATOS

Esta fase puede ejecutarse agresivamente.

## Proceso

```text
auditar
→ diseñar esquema objetivo
→ identificar problemas
→ clasificar cambios
→ diseñar migraciones
→ migrar datos
→ validar
→ adaptar aplicación
→ validar nuevamente
→ retirar estructuras antiguas
```

Cuando sea más seguro:

```text
old_table
    ↓
new_table
    ↓
data migration
    ↓
verification
    ↓
application switch
    ↓
old_table removal
```

Usar expand/contract cuando la migración directa pueda romper producción.

---

# 7. CHECKPOINTS

Cursor debe trabajar autónomamente.

No pedir aprobación para cada archivo.

Pero crear checkpoints después de cada bloque significativo.

Ejemplos:

```text
CHECKPOINT:
Frontend foundation completed
Tests: PASS
Analyze: PASS
Patrol: PASS
No known regression
```

y:

```text
CHECKPOINT:
Database migration completed
Rows before: X
Rows after: X
Integrity checks: PASS
RLS checks: PASS
Application compatibility: PASS
```

---

# 8. CUÁNDO DETENERSE

Detente y solicita intervención humana únicamente ante un **riesgo real**, como:

- posible pérdida de datos;
- corrupción de datos;
- migración irreversible sin recuperación segura;
- ambigüedad sobre el registro canónico;
- posible exposición de datos privados;
- RLS inseguro;
- ruptura de autenticación;
- ruptura de Storage;
- ruptura de producción;
- incompatibilidad crítica;
- comportamiento funcional ambiguo;
- dependencia externa no verificable;
- decisión de producto que no pueda inferirse de forma segura;
- conflicto entre invariantes existentes.

No detenerse por:

- un archivo grande;
- imports cambiados;
- una refactorización normal;
- mover una feature;
- actualizar documentación;
- corregir lint;
- reordenar código.

---

# 9. VALIDACIÓN CONTINUA

Después de cada fase significativa:

```powershell
flutter analyze
flutter test
patrol test
```

cuando aplique.

También validar:

- compilación;
- navegación;
- auth;
- persistencia;
- cache;
- Storage;
- RLS;
- funciones;
- migraciones.

Nunca esperar hasta el final para descubrir que la migración rompió todo.

---

# 10. VALIDACIÓN DE BASE DE DATOS

Para cada migración importante comprobar:

### Estructura

- tablas;
- columnas;
- tipos;
- PK;
- FK;
- constraints.

### Datos

- row counts;
- nulls inesperados;
- duplicados;
- relaciones huérfanas;
- datos transformados correctamente.

### Performance

- índices;
- consultas críticas;
- PostGIS;
- planes de consulta cuando sea necesario.

### Seguridad

- RLS;
- Storage policies;
- permisos;
- RPC;
- Edge Functions.

---

# 11. NO HACER

Nunca:

- reescribir todo sin baseline;
- borrar código sin demostrar que está muerto;
- crear interfaces por obligación;
- crear UseCases vacíos;
- crear repositories pasapapeles;
- convertir `core` en cajón de sastre;
- crear barrels monolíticos;
- duplicar modelos sin razón;
- duplicar lógica de negocio;
- duplicar datos en DB sin justificación;
- asumir que todas las tablas necesitan la misma RLS;
- asumir que 3NF exige eliminar toda desnormalización;
- introducir paquetes sin comprobar compatibilidad;
- cambiar producto durante la refactorización;
- cambiar diseño visual arbitrariamente;
- romper WidgetKeys;
- hacer migraciones destructivas sin estrategia;
- usar prefijos `t_`/`p_` como sustituto de un correcto aislamiento de ambientes;
- dejar migraciones manuales sin versionar.

---

# 12. CRITERIO PARA CAMBIOS AGRESIVOS

Antes de un cambio importante, evalúa:

```text
Beneficio arquitectónico
+
Reducción de deuda
+
Seguridad
+
Escalabilidad
+
Mantenibilidad
-
Riesgo de regresión
-
Complejidad introducida
```

No necesitas una fórmula numérica.

Necesitas justificar la decisión técnicamente.

---

# 13. ESTRUCTURA FINAL

La estructura final debe ser descubierta mediante auditoría.

Una forma posible podría ser:

```text
frontend/lib/
├── app/
├── core/
│   ├── theme/
│   ├── ui/
│   ├── formatters/
│   ├── storage/
│   ├── network/
│   ├── errors/
│   ├── logging/
│   └── ...
└── features/
    ├── sites/
    ├── sites_ui/
    ├── reviews/
    ├── geo/
    ├── explore/
    ├── plans/
    ├── home/
    ├── auth/
    ├── proximity/
    ├── routes/
    ├── moderation/
    ├── admin/
    ├── beta/
    ├── legal/
    └── settings/
```

**Esto no es una orden rígida.**

Si la auditoría demuestra que otra estructura es mejor, utiliza la mejor y documenta por qué.

---

# 14. CRITERIO DE "MEJOR ARQUITECTURA"

Cuando existan varias soluciones posibles, prioriza:

1. Correctitud.
2. Seguridad.
3. Integridad de datos.
4. Bajo acoplamiento.
5. Alta cohesión.
6. Evolución futura.
7. Testabilidad.
8. Rendimiento.
9. Simplicidad.
10. Consistencia.

No optimices solamente para reducir número de archivos.

No optimices solamente para reducir líneas.

No optimices solamente para "verse limpio".

La arquitectura debe ser fácil de comprender y difícil de romper.

---

# 15. RESULTADOS FINALES OBLIGATORIOS

Al terminar, entregar:

```text
docs/architecture/
├── current-architecture.md
├── target-architecture.md
├── dependency-map.md
├── migration-log.md
├── database-audit.md
├── database-migration-plan.md
├── security-audit.md
├── test-map.md
└── final-review.md
```

Además:

```text
.cursor/rules/
```

actualizado y consolidado.

Y, si resulta útil:

```text
scripts/validate.ps1
```

para ejecutar las validaciones locales.

---

# 16. INFORME FINAL

`docs/architecture/final-review.md` debe incluir:

- arquitectura anterior;
- arquitectura final;
- principales decisiones;
- decisiones descartadas;
- features migradas;
- archivos eliminados;
- duplicaciones eliminadas;
- abstracciones eliminadas;
- abstracciones creadas;
- estado de DI;
- estado de cache;
- estado de navegación;
- estado de testing;
- estado de Patrol;
- estado de DB;
- migraciones ejecutadas;
- datos migrados;
- índices;
- RLS;
- Storage;
- Edge Functions;
- seguridad;
- deuda técnica restante;
- excepciones justificadas;
- riesgos pendientes;
- recomendaciones para próximas fases.

No inventar métricas.

Si una métrica no fue medida, indicarlo.

---

# 17. DEFINICIÓN DE ÉXITO

El trabajo solamente se considera terminado cuando:

- la aplicación conserva su comportamiento;
- Flutter analiza correctamente;
- tests relevantes pasan;
- Patrol relevante pasa;
- navegación funciona;
- auth funciona;
- cache funciona;
- datos existentes están íntegros;
- migraciones están versionadas;
- DB tiene estructura coherente;
- duplicación innecesaria fue eliminada;
- RLS fue auditado;
- Storage fue auditado;
- secretos están protegidos;
- logs no filtran información sensible;
- DI no es monolítico;
- features tienen ownership claro;
- UI compartida tiene ownership claro;
- no existen abstracciones pasapapeles innecesarias;
- documentación refleja la realidad;
- Cursor rules protegen la arquitectura;
- las excepciones importantes están justificadas.

---

# 18. REGLA ESPECIAL PARA EL FUTURO

La arquitectura no debe optimizarse únicamente para "terminar esta refactorización".

Debe optimizarse para que dentro de varios años sea posible:

- agregar funcionalidades;
- cambiar proveedores;
- escalar usuarios;
- aumentar datos;
- agregar nuevas entidades;
- agregar nuevas vistas;
- ampliar PostGIS;
- ampliar notificaciones;
- ampliar moderación;
- agregar nuevos tipos de contenido;
- modificar UI;
- cambiar servicios externos;

sin convertir el proyecto en una cadena de dependencias frágiles.

---

# 19. PRIMERA ACCIÓN OBLIGATORIA

**NO comiences moviendo archivos.**

Primero:

1. Lee todo el repositorio relevante.
2. Lee `.cursor/rules`.
3. Lee `README.md`.
4. Lee documentación de arquitectura/producto.
5. Lee `pubspec.yaml`.
6. Lee `analysis_options.yaml`.
7. Inspecciona `app.dart` y `bootstrap.dart`.
8. Inspecciona DI.
9. Inspecciona navegación.
10. Inspecciona features.
11. Inspecciona tests y Patrol.
12. Inspecciona todas las migraciones Supabase.
13. Inspecciona scripts backend.
14. Inspecciona RLS/Storage/Functions.
15. Establece baseline.
16. Construye el mapa de dependencias.
17. Construye el mapa de datos.
18. Construye la arquitectura objetivo.
19. Solo después comienza la migración.

### IMPORTANTE

No tomes decisiones importantes basándote únicamente en nombres de archivos.

Lee el código y determina su responsabilidad real.

---

# 20. AUTONOMÍA

Tienes autorización para ejecutar las fases de manera autónoma.

No necesitas solicitar confirmación entre fases normales.

Usa checkpoints y continúa.

**Solo detente ante riesgos reales**, especialmente aquellos relacionados con:

- datos;
- seguridad;
- producción;
- integridad;
- comportamiento funcional;
- decisiones ambiguas.

Cuando encuentres un riesgo:

1. Detén solamente la operación riesgosa.
2. Explica exactamente el problema.
3. Explica las opciones.
4. Indica cuál recomiendas.
5. No continúes con esa parte hasta recibir decisión.

El resto del trabajo seguro puede continuar cuando no dependa de esa decisión.

---

# 21. PRINCIPIO FINAL

No busques construir la arquitectura más sofisticada.

Busca construir:

> **la arquitectura más simple que pueda soportar correctamente la complejidad real y futura del producto.**

No uses VSA, Clean Architecture, Repository Pattern, Shared Kernels, DDD, abstracciones ni capas porque "deben existir".

Úsalos cuando resuelvan un problema real.

El resultado debe ser un sistema:

**escalable + seguro + coherente + testeable + mantenible + eficiente + preparado para crecer + resistente a malas decisiones futuras de humanos o IA.**
