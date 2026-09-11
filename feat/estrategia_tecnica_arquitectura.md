# Chevere Plan — Arquitectura Técnica, Estándares de Código Limpio y Estrategia de IA

## 1. Estándares de Código Limpio, SonarQube y Reglas de Calidad

Para que la inteligencia artificial escriba código de nivel profesional, el proyecto utiliza un análisis estático estricto y reglas de diseño basadas en SonarLint / SonarQube.

### A. Configuración de Análisis Estático (`analysis_options.yaml`)
```yaml
include: package:very_good_analysis/analysis_options.yaml

analyzer:
  language:
    strict-casts: true
    strict-inference: true
    strict-raw-types: true
  errors:
    missing_required_param: error
    missing_return: error
    todo: warning
    invalid_annotation_target: ignore

linter:
  rules:
    - always_declare_return_types
    - avoid_empty_else
    - avoid_relative_lib_imports
    - avoid_shadowing_type_parameters
    - cancel_subscriptions
    - close_sinks
    - prefer_const_constructors
    - prefer_const_declarations
    - prefer_final_fields
    - prefer_final_locals
    - unawaited_futures
    - unnecessary_await_in_return
```

### B. Principios de Código Limpio Aplicados
1. **Inmutabilidad Absoluta:** Toda variable o parámetro que no cambie debe ser `final`. Modelos de datos creados obligatoriamente con `@freezed`.
2. **Funciones Cortas y Compuestas (SRP):** Máximo 25-30 líneas por función. Métodos `build()` de UI con menos de 80 líneas (divididos en widgets atómicos).
3. **Cero `dynamic`:** Prohibido el uso de tipos implícitos o `dynamic` excepto en la deserialización directa de JSON.
4. **Manejo de Errores con Resultados Explícitos:** Prohibido silenciar excepciones con `catch (e) {}`. Todos los errores se capturan mediante el patrón `Result/Failure` y se envían a Firebase Crashlytics.
5. **Inyección de Dependencias (DIP):** Ningún widget o servicio crea instancias directamente; todo se provee e inyecta mediante **Riverpod**.

### C. Archivo de Reglas para IA (`.cursorrules`)
Crea este archivo en la raíz del proyecto para gobernar el comportamiento de Cursor, Claude o Copilot:
```text
# RULES FOR CODE GENERATION
- Follow Official Dart Guidelines, Clean Architecture, Vertical Slice Architecture, and SOLID principles strictly.
- Never use 'dynamic' types. Use strict typing for all variables, arguments, and return types.
- Keep functions under 30 lines and UI Widget build methods under 80 lines. Split widgets into atomic components.
- All domain models must be immutable and generated using @freezed.
- All state management must use Riverpod with @riverpod code generation.
- Never place database/API calls directly inside Flutter Widgets. Use Repositories via Riverpod.
- Always add 'const' to constructors whenever possible.
- Never swallow exceptions. Handle errors explicitly using Failure/Result pattern and log via Firebase Crashlytics.
- Write clean SQL queries using lower_snake_case for Postgres/PostGIS tables and fields.
- Ensure 100% free/open-source libraries are used (WorkManager/Geolocator instead of paid plugins).
```

---

## 2. Arquitectura de Software: Vertical Slice Architecture (VSA) + DDD

El código se organiza por **funcionalidades (Slices)** y no por capas globales. Esto optimiza el contexto enviado a los asistentes de IA:

```
lib/
├── core/                                 # Módulos globales e infraestructura
│   ├── database/                         # PowerSync + SQLite Setup
│   ├── network/                          # Supabase Client
│   ├── location/                         # Background Location & Geofencing (Free WorkManager)
│   └── theme/                            # Material 3 Design System
└── features/                             # VERTICAL SLICES
    ├── digital_capture/                  # Slice: Captura desde Redes Sociales (Share Sheet)
    ├── live_capture/                     # Slice: Captura Presencial en Vivo (GPS)
    ├── visited_timeline/                 # Slice: Bitácora de Visitados y Rutas
    ├── memories/                         # Slice: Alertas de Proximidad y Recuerdos
    └── sharing/                          # Slice: Capa Social y Compartir
```

Cada Vertical Slice contiene internamente:
* `domain/`: Entidades inmutables (`@freezed`), Value Objects y Contratos (Interfaces).
* `data/`: Repositorios de PowerSync/SQLite, Mappers y DTOs.
* `application/`: Providers de Riverpod (`@riverpod`) y Casos de Uso.
* `presentation/`: Pantallas y Widgets en Material 3.

---

## 3. Estrategia Offline-First: PowerSync (Plan $0) + Supabase (Plan $0) + SQLite

### Flujo de Datos Bidireccional
```
[ App Flutter ] <---> [ SQLite Local ] <---> [ PowerSync SDK ] <===(WebSocket)===> [ PowerSync Service ] <---> [ Supabase Postgres ]
```
* **Escritura y Lectura Local Instantánea:** La app lee y escribe en la base de datos SQLite local en < 5ms.
* **Sincronización Automática:** PowerSync se encarga de replicar los cambios hacia Supabase cuando hay red. Si no hay conexión, las transacciones quedan encoladas localmente.
* **Resolución de Conflictos:** Estrategia *Last-Write-Wins (LWW)* basada en marcas de tiempo UTC (`updated_at`).

---

## 4. Arquitectura de los Dos Modos de Captura

### A. Pipeline de Captura Digital (Redes Sociales)
1. **Recepción:** El paquete `receive_sharing_intent` intercepta la URL compartida.
2. **Persistencia Local:** Se inserta inmediatamente en SQLite en la tabla `pending_digital_captures`. La UI responde en **<50ms** confirmando el guardado (no requiere GPS ni mapa).
3. **Enriquecimiento Asíncrono (Edge Function):**
   * Al sincronizar con Supabase, un Database Trigger activa una Edge Function.
   * La Edge Function extrae metadatos OpenGraph (nombre del sitio, fotos, dirección/coordenadas).
   * Supabase actualiza el registro y PowerSync sincroniza los datos enriquecidos de vuelta al celular.

### B. Pipeline de Captura Presencial / En Vivo (GPS Local)
1. **Ubicación Instantánea:** El servicio local de GPS (`geolocator`) obtiene las coordenadas exactas actualizadas del dispositivo.
2. **Guardado Directo:** Se crea la entidad `Place` guardando el punto `PostGIS` (`geography(POINT, 4326)`) directamente en SQLite local.
3. **100% Offline:** No requiere llamadas a APIs externas para guardar el sitio en vivo.

---

## 5. Motor de Proximidad y Detección Automática de "Visitados" (100% Gratis)

### A. Auto Check-in / Bitácora de Visitados
* **Servicio de Fondo:** Combinación de `geolocator` y `workmanager` (código abierto, gratis). Se evalúan los cambios de posición mediante eventos programados eficientes en batería.
* **Verificación Espacial:** Al detectar que el usuario permanece en un radio determinado cerca de un lugar guardado, el sistema genera automáticamente un registro en la tabla `visited_logs`.
* **Consulta Spatial en Postgres/SQLite:**
```sql
-- Función PostGIS para detectar si la posición del usuario está cerca de un lugar guardado
SELECT id, title
FROM places
WHERE ST_DWithin(
    geom,
    ST_SetSRID(ST_MakePoint(:user_lon, :user_lat), 4326)::geography,
    :radius_meters
);
```

### B. Notificaciones de Recuerdos
* Si un lugar visitado o guardado coincide con una fecha especial o el usuario vuelve a estar cerca, el motor de eventos dispara una notificación local (`flutter_local_notifications`).

---

## 6. Stack Tecnológico 100% Gratuito ($0 USD)

| Módulo | Tecnología / Librería | Licencia / Plan | Propósito |
| :--- | :--- | :--- | :--- |
| **Framework** | Flutter (Dart) | Open Source (BSD) | Multiplataforma, interfaz a 60/120 FPS |
| **Backend & DB** | Supabase (Postgres + PostGIS) | Free Tier ($0) | Autenticación, Storage, DB espacial |
| **Engine Offline-First** | `powersync_flutter` | Free Tier ($0) | Réplica bidireccional SQLite <-> Postgres |
| **Gestión de Estado** | `flutter_riverpod` + `riverpod_generator` | Open Source (MIT) | Reactividad inmutable y DI |
| **Modelos de Datos** | `freezed` + `json_serializable` | Open Source (MIT) | Inmutabilidad estricta y autogeneración |
| **Share Sheet (Digital)** | `receive_sharing_intent` | Open Source (MIT) | Captura de enlaces compartidos desde otras apps |
| **Ubicación & Background** | `geolocator` + `workmanager` | Open Source (Apache 2.0) | Monitoreo continuo sin costos de licencia |
| **Telemetría & Crash** | Firebase Crashlytics + Performance | Spark Plan ($0) | Reporte de errores y latencias |

---

## 7. Monitoreo de Calidad y Metodología de Pruebas
1. **Pruebas Unitarias en Dominio:** Validar casos de uso sin depender de la UI ni de la base de datos.
2. **Crash-Free Goal:** > 99.5% de sesiones sin fallos en Crashlytics.
3. **Rendimiento de Renderizado:** Mantenimiento de 60 FPS en listas de lugares mediante la optimización de widgets e imágenes en caché.
