# Chevere Plan — Visión de Negocio, Producto y Propuesta de Valor

## 1. Resumen Ejecutivo y Esencia del Producto

**Chevere Plan** es la plataforma inteligente para el descubrimiento, guardado ultrarrápido y revivencia de lugares de interés (restaurantes, turismo, planes de ocio, cultura). Funciona como el **"Google Fotos" de las experiencias físicas** y la **"Bitácora Automática" de tus viajes**, transformando el guardado pasivo de enlaces y fotos en un motor activo de recuerdos geolocalizados.

### Propuesta Única de Valor (UVP)
> *"Guarda en medio segundo lo que ves en redes o lo que descubres caminando en la calle. Viaja sin preocuparte por la señal y deja que la app registre tu bitácora de lugares visitados y te recuerde tus sitios guardados cuando estés cerca."*

---

## 2. Los Dos Corazones de la Captura (Esencia del Producto)

La app diferencia claramente entre **guardar algo digital que quieres visitar a futuro** y **guardar algo físico en el lugar donde estás parado**:

### A. Captura Digital (Desde Redes Sociales / Apps)
* **Caso de Uso:** El usuario está navegando en Instagram, TikTok, Facebook o la Web, ve un video de un restaurante o sitio turístico y quiere guardarlo inmediatamente para ir después.
* **Experiencia:** Usa la hoja de compartir nativa del celular (*Share Sheet*). En menos de **50 ms** y sin abrir la app, sin mapa y sin activar GPS ni requerir internet, la URL se guarda en una cola local. En segundo plano, cuando hay red, la app procesa la URL, extrae la información, fotos y coordenadas del lugar promocionado.

### B. Captura Presencial / En Vivo (On-The-Spot / Viajando)
* **Caso de Uso:** El usuario está viajando, caminando por un pueblo o ciudad, encuentra una cafetería o mirador bonito y quiere guardarlo al instante.
* **Experiencia:** Con un solo toque dentro de la app o desde un acceso rápido, la app toma la **ubicación GPS exacta en tiempo real**, permite tomar una foto rápida o nota corta y lo guarda instantáneamente en la base de datos local (100% offline).

---

## 3. Motor de Recuerdos y Bitácora Automática ("Visitados")

### A. Marcado Automático de "Visitado" (Efecto Google Maps Timeline)
* **Detección Pasiva de Bajo Consumo:** Usando monitoreo de red/celda celular (sin GPS continuo), cuando el usuario permanece dentro del radio de un lugar guardado, la app detecta la presencia y marca automáticamente el sitio como **"Visitado"**.
* **Bitácora y Historial de Rutas:** Se construye automáticamente un historial de viaje o mapa de recuerdos ("Tus Rutas y Sitios Visitados"), mostrando fechas, mapas de calor y líneas de tiempo sin que el usuario tenga que hacer check-in manual.

### B. Reactivación por Proximidad (Efecto Google Fotos)
* Notificaciones contextuales cuando el usuario está físicamente cerca de un sitio guardado hace tiempo: *"Estás a 200m de 'Café El Mirador', lo guardaste hace 4 meses cuando veías TikTok."*

### C. Offline-First Completo (Diseñado para Turistas - $0 Costo de Red)
* Pensado para carreteras, zonas rurales o interiores de establecimientos sin señal. Todas las lecturas, búsquedas locales, capturas GPS y registros de visitados se guardan primero en la base de datos local SQLite y se sincronizan en segundo plano al recuperar conexión.

---

## 4. Análisis de Mercado y Ventaja Competitiva

| Criterio | Apps Tradicionales (Mapstr, Google Maps) | Chevere Plan |
| :--- | :--- | :--- |
| **Captura Digital** | Lenta (abrir app, buscar nombre, guardar) | **Ultrarrápida (<50ms via Share Sheet sin GPS)** |
| **Captura Presencial** | Requiere conexión y búsqueda manual | **1-Tap con GPS exacto en tiempo real (Offline)** |
| **Registro de Visitas** | Check-in manual / Historial pasivo | **Marcado automático por geofencing pasivo** |
| **Retención** | El usuario debe recordar abrir la app | **Activa (Notificaciones por proximidad + Recuerdos)** |
| **Uso en Turismo** | Fallan sin internet | **Offline-First nativo con sincronización transparente** |

---

## 5. Roadmap Estratégico por Fases

```
[ Fase 1: MVP Core ] ──> [ Fase 2: Social & Compartir ] ──> [ Fase 3: Monetización B2B ] ──> [ Fase 4: Expansión ] ──> [ Fase 5: IA & Transport ]
 - Captura Digital + Live  - Menciones @ e In-App Inbox  - Fichas Negocio Verificadas  - Publicación en iOS       - Itinerarios con IA
 - Bitácora "Visitados"    - Grupos / Planes Abiertos    - Eventos Geolocalizados      - Moderación Auto          - Transporte Inteligente
 - PowerSync + Local DB    - Anti-Duplicados             - Pasarelas y Donaciones      - Expansión Internacional  - Cálculo por tramos
```

### Fase 1 — MVP Core (Enfoque en Captura, Offline y Bitácora - Stack $0 USD)
* Doble captura: Digital (redes sociales) y Presencial (GPS en vivo).
* Sincronización offline-first vía PowerSync (Plan Gratis) + SQLite local.
* Marcado automático de sitios visitados por geofencing de bajo consumo.
* Notificaciones locales por proximidad a lugares guardados.

### Fase 2 — Capa Social y Compartir
* Compartir sitios y planes con menciones (`@usuario`).
* Manejo de privacidad: Sitios privados vs. públicos.
* Detección de duplicados en la base de datos pública de sitios.

### Fase 3 — Monetización y Eventos
* Fichas enriquecidas para negocios locales (restaurantes, hoteles, guías).
* Publicación de eventos geolocalizados por municipio/ciudad.
* Donaciones y pasarelas de pago.

### Fase 4 — Expansión e iOS
* Cliente nativo para Apple App Store.
* Moderación automática de imágenes/textos (SafeSearch/Strikes).

### Fase 5 — IA y Transporte Inteligente
* Generación de itinerarios con IA basados en los sitios guardados.
* Sugerencia de medios de transporte por tramo (Caminata, Uber, Bus).

---

## 6. Métricas Clave de Negocio (KPIs)
1. **Time-to-Save:** Menos de 1 segundo en captura presencial y <50ms en la digital.
2. **Auto Check-in Accuracy:** Precisión de marcado automático de lugares visitados sin falso positivo ni drenaje de batería.
3. **Retention Rate (D1, D7, D30):** Retención impulsada por alertas de proximidad y recuerdos automáticos.
4. **Offline Resilience:** 100% de operaciones locales exitosas sin pérdidas de datos en zonas sin red.
