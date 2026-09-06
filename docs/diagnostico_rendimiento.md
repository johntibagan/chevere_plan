# Diagnóstico técnico — rendimiento y arquitectura de datos (frontend)

**Fecha:** 2026-09-05  
**Alcance original:** solo lectura del código Flutter actual (`frontend/`). **No** hay cambios de implementación en este documento.  
**Actualización:** misma fecha — se añaden notas de la **Fase 1** (Pasos 0–4 + refuerzos Wikimedia) en las secciones afectadas. El texto de línea base se conserva; lo nuevo va marcado como `> **Fase 1 …**`.  
**Objetivo:** describir con precisión cómo está resuelta hoy cada capa, para decidir después (aparte) cómo acercar la sensación de apps tipo Google Fotos / Wallet by BudgetBakers.

Fuente de producto/UI: [`aplicacion-actual.md`](aplicacion-actual.md). Lineamientos de caché: [`lineamientos-desarrollo-frontend.md`](lineamientos-desarrollo-frontend.md) §4.

---

## 1. Persistencia local / caché de datos

### 1.1 Gestor de estado

| Pieza | Dónde |
|---|---|
| Paquete | `flutter_riverpod: ^2.6.1` (`frontend/pubspec.yaml`) |
| Raíz | `ProviderScope` en `createRootApp()` — `frontend/lib/bootstrap.dart` |
| Composition root | `frontend/lib/core/di/providers.dart` (repos + `AsyncNotifier`s + families) |
| App shell | `CheverePlanApp` / `AuthGate` — `frontend/lib/app.dart` |

Patrones usados: `Provider`, `Notifier` / `AsyncNotifier`, `AsyncNotifierProvider`, `FutureProvider.family` (p. ej. `coverSignedUrlProvider`, `siteLookProvider`, `siteFichaProvider`).

No hay Bloc ni Provider (paquete) como store de dominio.

### 1.2 Almacenamiento local (qué hay y qué no)

| Tecnología | Uso real | Archivo / clase |
|---|---|---|
| **Hive CE** (`hive_ce` / `hive_ce_flutter`) | **Única** “base” de entidad en disco: box string `entity_cache_v1` con JSON + timestamp | `EntityCacheStore` — `frontend/lib/core/cache/entity_cache_store.dart` |
| **SharedPreferences** | Preferencias (tema, feed layout, radio Explorar, legales login, quotas Places, throttle notifs, geofence cards…) | Varios; p. ej. `AppThemeModeStore`, `FeedLayoutNotifier`, `ExploreRadiusStore` |
| **flutter_secure_storage** | JWT de sesión Supabase | `SecureSessionStorage` — `frontend/lib/core/auth/secure_session_storage.dart` |
| **flutter_cache_manager** | Caché de **archivos de imagen** en disco | `AppImageCacheManager` — `frontend/lib/core/cache/app_image_cache.dart` |
| SQLite / Drift / Isar / ObjectBox | **No** están en `pubspec.yaml` ni en `lib/` | — |

**Hive no es solo “Populares cerca”.** Toda la capa SWR de entidad escribe ahí vía `SwrLoader` + `EntityCacheStore`:

- Claves: `CacheKeys` en `frontend/lib/core/cache/cache_ttl.dart`  
  (`my_saves_summary_p0:…`, `plans_p0:…`, `routes_all:…`, `site_ficha_v2:…`, `search:…`, `categories:v1`, `geo_catalog:v1`, `home_nearby_v1:…`, etc.).
- TTL: clase `CacheTtl` (mismo archivo).
- Motor SWR: `SwrLoader` — `frontend/lib/core/cache/swr_loader.dart` (fresca → disco; stale → disco + `onBackgroundRefresh`; forceNetwork → red).

Caché **solo memoria** (no Hive):

- `EntityCacheStore._memory` (capa encima de Hive).
- `PaintingBinding.instance.imageCache` (límites en `AppImageCacheManager.configurePaintingCache`).

`SignedUrlCache` — memoria (LRU 200) **+ Hive** (`CacheKeys.signedUrl` / prefijo `signed_url:`), margen `skewSeconds = 120`. `get` síncrono = memoria; `getAsync` = memoria → Hive.

> **Fase 1 · Paso 1 (ajustó / mejoró):** las firmas ya no viven solo en memoria. Persistencia en Hive vía `EntityCacheStore`; `getAsync` = memoria → Hive; `clearSessionCaches` / logout las borran. TTL Storage sigue en 3600 s. Tests: `frontend/test/signed_url_cache_test.dart`.

Al cerrar sesión: `clearSessionCaches` — `frontend/lib/core/cache/session_cache_cleanup.dart` (limpia Hive entidad, signed URLs, image disk/memory, invalida providers).

### 1.3 Por pantalla principal: ¿caché primero o espera red?

| Pantalla | Provider / carga | ¿SWR / pinta caché? | Comportamiento al abrir |
|---|---|---|---|
| **Inicio** | `mySavesProvider` (`MySavesNotifier`) + `homeNearbyProvider` (`HomeNearbyNotifier`) | **Sí** SWR en guardados; populares con lógica propia Hive + ancla GPS | `_bootstrap()` en `HomePage` (`home_page.dart`) hace `await ref.read(mySavesProvider.future)`. Si ya hay ítems en memoria/provider, **no** pone spinner full; si no, `_loading = true` hasta el future. Populares: si hay disco con hits, `state = AsyncData(disk)` **antes** de decidir refetch (`HomeNearbyNotifier._load`). |
| **Explorar** | Estado local en `SearchPage` + `SwrLoader` con `CacheKeys.search(…)` | **Sí** por query (TTL search 2 min / 45 min) | Arranca **vacío** (`_searched = false`, `_hits = []`). No hay “última búsqueda” automáticamente al entrar al tab. La búsqueda la dispara el usuario / atajos Inicio. |
| **Ficha de sitio** | `siteFichaProvider(siteId)` + seed opcional | **Sí** SWR ficha; UI puede seedear | `SiteDetailPage.initState`: si hay `initialSave` / `initialHit`, pinta ficha **sin** esperar red (`_loading = false`) y luego `await siteFichaProvider.future`. Sin seed: spinner hasta ficha. Fotos y enlaces sociales: **red aparte** (`_loadPhotos`, `_loadSocialLinks`) aunque la ficha venga de caché. |
| **Planes** | `plansProvider` (`PlansNotifier`) | **Sí** SWR | `PlansListPage` hace `unawaited(ref.read(plansProvider.future))` en `initState`; UI vía `AppAsyncBody` + `async.valueOrNull`. Primera visita sin caché → loading; con caché fresca/stale → lista al resolver el future (stale dispara refresh en background). `upsertPlan` actualiza memoria + Hive al marcar Hecho en detalle. |
| **Rutas** | `routesProvider` (`RoutesNotifier`) | **Sí** SWR | Misma idea: `listMineAll()` → RPC; caché `routes_all:$uid`. UI pagina en cliente sobre la lista completa (≤200 del RPC). |

> **Fase 1 · Paso 2 (mejoró, Rutas / listas):** tras el RPC de rutas, un batch `loadSiteLooks` adjunta portada; `SiteLookCover(..., resolveLook: false)` donde el path ya viene. Reduce N+1 de `siteLookProvider` por card. **Inicio:** las cards **siguen** con `resolveLook: true` por defecto si falta path (forzar `false` en home dejó tarjetas sin foto tras crear/editar con portada).
>
> **Fase 1 · Paso 2 (intento revertido — no está en código):** se probó forzar invalidación Hive + refresh de red tras mutación de foto/sitio (`refreshAfterMutation` / cambios en ~4 archivos). **No mejoró** Inicio; el dueño pidió revertir. No reintroducir ese patrón sin nueva evidencia.
>
> **Fase 1 (refuerzo ficha privada, entre Pasos 2 y 3):** públicos con `cover_storage_path` + firma caliente ya pintaban al toque. Privados propios a menudo llegaban sin path en el seed → spinner/`CircularProgress` en galería. Ajuste solo en privados/seed: precalentar path desde `initialSave` / `siteLookProvider` / `SignedUrlCache` (memoria+Hive); mientras la galería espera, **caja de color** (mismo placeholder que red), no spinner. **No** se cambió la lógica de carga de públicos.

Catálogos fríos (no “pantalla”, pero alimentan UI):

- `categoriesProvider`, `geoCatalogProvider`, `transportTypesProvider`, `distanceUnitsProvider` — todos SWR vía `SwrLoader` (TTL 24h/7d o 30d/90d geo).

### 1.4 ¿Primera pintura “instantánea” al abrir la app?

**Parcial, no estilo Google Fotos.**

1. **Antes de `runApp`:** tema desde disco (`AppThemeModeStore.loadBeforeRunApp`) y Hive `EntityCacheStore.init()` — evita flash de tema; **no** hidrata widgets con datos de negocio en el primer frame. En paralelo: `SecureSessionStorage.peekSession()` (Keystore, sin red).
2. **Primer frame:** `MaterialApp` → `BetaUpdateGate` → `AuthGate`.
3. **AuthGate** (`app.dart`): si hay sesión optimista del peek (mismo dispositivo) → `HomePage` **sin** spinner; confirmación con `getSession()` en background (revocada → login; red/timeout → mantener + reintento ~45 s). Solo spinner si `waiting` y **no** hay sesión ni seed.
4. **HomePage:** en `initState` lee `mySavesProvider`; `MySavesNotifier.build` hace `SwrLoader.peekSync` (Hive síncrono) y deja `AsyncData` **antes** del await SWR → primer frame con lista si hay caché usable (≤ stale). El refresh de red/SWR sigue igual en background. **Fase 2 · Paso 2.**
5. **`Supabase.initialize`:** corre en paralelo vía `SupabaseBootstrap.start` (**no** bloquea `runApp`). Repos/mutaciones esperan `isReady` / `supabaseReadyProvider`. AuthGate pinta Home optimista sin cliente; share/notifs/beta gate también aguardan.

> **Fase 2 · Paso 1 (ajustó):** restauración optimista de sesión — `peekSession` + `AuthGate(optimisticSession)` + confirmación en background. No cambia TTL ni refresh de token; solo el orden (pintar → confirmar).
>
> **Fase 2 · Paso 1 · medición (Motorola, debug, Hive caliente, 2026-09-06):** Activity COLD TotalTime **3642–4993 ms** (antes 4.3–6.2 s); `home_time_to_content` **242–256 ms** (antes ~245 ms). El Activity sigue dominado por bootstrap + `Supabase.initialize` bloqueante (Paso 3); el Paso 1 evita el spinner de AuthGate cuando hay JWT local, pero no acorta mucho el TotalTime hasta diferir initialize.
>
> **Fase 2 · Paso 2 (ajustó):** `EntityCacheStore.peekSync` + `SwrLoader.peekSync`; `MySavesNotifier` siembra `AsyncData` al build; `HomePage` pinta `_saves` y corta el trace TTFC en `initState` si hay peek.
>
> **Fase 2 · Paso 2 · medición (Motorola, debug, Hive caliente, 2026-09-06):** Activity COLD **~3.6–3.7 s** (antes Paso 1: 3.6–5.0 s; sin cambio relevante); `home_time_to_content` **25–38 ms** (antes Paso 1: **234–256 ms**). Ganancia clara en TTFC; Activity sigue esperando Paso 3.
>
> **Fase 2 · Paso 3 (ajustó):** `SupabaseBootstrap` — initialize diferido; `peekMySavesSummarySync` en Home sin cliente.
>
> **Fase 2 · Paso 3 · medición (Motorola, debug, Hive caliente, 2026-09-06):** Activity COLD **~3.9–4.2 s** (antes Paso 2: 3.6–4.6 s; **sin bajón grande** — con red OK el init ya era corto vs engine/Hive/tema/Davey). `home_time_to_content` **4–25 ms** (antes Paso 2: 25–38 ms). En cold start el log muestra TTFC **antes** de `Supabase init completed` (~2 s después) → initialize ya no bloquea el primer contenido.
>
> **Fase 2 · Paso 4 (investigó — no implementado):** Baseline Profiles **no** se integran en este pase.
>
> **Motivo exacto (no forzar integración frágil):**
> 1. Flutter **no** tiene soporte de framework para Baseline Profiles. Issue abierta [`flutter/flutter#143129`](https://github.com/flutter/flutter/issues/143129) (P3, team-android; último comentario útil nov-2025: generación falla).
> 2. El camino “oficial Android” (módulo `com.android.test` + plugin `androidx.baselineprofile` + Macrobenchmark) choca con el Gradle de Flutter: reportes de fallo en `:baselineprofile:connectedNonMinifiedReleaseAndroidTest` y **configuration cache** — `FlutterTask` usa `Task.project` en execution time (incompatible).
> 3. Este repo: Flutter **3.44.9** / AGP **9.0.1** (AGP sí podría *consumir* un `baseline-prof.txt`), pero **generar** el perfil de arranque de la app (DEX Dart/Flutter + plugins) no está soportado de forma estable. Un `baseline-prof.txt` inventado o un módulo Macrobenchmark a medias no aporta el 30–40 % documentado y ensucia el build de release/beta.
> 4. `profileinstaller` solo instala perfiles ya empaquetados; sin perfil generado de nuestra app no hay ganancia medible de Activity COLD que justificaría el cambio.
>
> **Medición Paso 4:** N/A (sin cambio de código). Activity COLD / TTFC = mismos números post–Paso 3 (**~3.9–4.2 s** / **3–25 ms**). Revisitár cuando Flutter cierre #143129 o documente un flujo soportado.
>
> **Fase 2 · Paso 5 (confirmó — sin cambio de código):** Impeller **ya activo** en Android.
>
> - Flutter **3.44.9** (stable): Impeller es default en Android API 29+ ([docs](https://docs.flutter.dev/perf/impeller)). Motorola = Android 16.
> - Manifest **sin** opt-out (`EnableImpeller=false`). No hace falta forzar `true`.
> - Logcat: `Using the Impeller rendering backend (Vulkan)`.
>
> **Davey con Impeller (debug, 3 cold starts):** `Davey! duration` **≈2.0–2.2 s**; `Skipped` **~50–130** frames en el arranque. El jank de primer frame **sigue** con Impeller → no es (solo) compilación de shaders Skia; es saturación del hilo UI (bootstrap/layout). No activar de nuevo ni desactivar.
>
> **Fase 2 · Paso 6 (ajustó):** splash moderno — `androidx.core:core-splashscreen:1.2.0`, `Theme.SplashScreen`, `installSplashScreen()` en `MainActivity`. Fondo = `splash_background` (claro `#F7F9FC` / oscuro `#0B0D15`); icono = `ic_launcher`. Sustituye el template Flutter (`Theme.Light/Black` + `windowBackground` blanco/sistema) que en Android 12+ podía verse como flash/negro. **No** acorta el tiempo real de arranque; cubre la espera.
>
> **Fase 2 · Paso 6 · medición (Motorola, debug):** Activity COLD **~3.9–4.1 s** (sin cambio material vs Paso 5); TTFC **~3 ms** (Hive caliente). Splash es cosmético intencional.
>
> **Fase 2 · hotfix (Inicio):** `mySavesProvider` / `homeNearbyProvider` escuchados en el primer frame (antes de `SupabaseBootstrap.isReady`) lanzaban `StateError` y quedaban en `AsyncError` → «Error en la app» / Populares vacío. Ahora esperan `ready` antes de tocar el cliente; Home invalida si había error residual y no tapa el peek de Hive con el callout.

---

## 2. Imágenes

**Dueño técnico (detalle completo):** [`imagenes-red.md`](imagenes-red.md) — pipeline `AppNetworkImage`, ladder Wikimedia, UA, caché `images_v2`, prefetch, firmas Storage, huecos.

### 2.1 Resumen

| Pieza | Dónde |
|---|---|
| Widget | `AppNetworkImage` |
| Commons thumbs | 500 / 800 / 1280 + fallback (ver doc dueño) |
| Disco | `chevere_plan_images_v2`, UA `CheverePlan/1.0` |
| Firmas | `SignedUrlCache` memoria + Hive (~1 h) |
| Placeholders | color + ilustración categoría; fade ~180 ms; sin blur-hash |

> **Fase 1:** UA + `images_v2` + ladder Commons + prefetch `@w500` + fade. Detalle y límites → [`imagenes-red.md`](imagenes-red.md).

### 2.2 ¿Thumbnails en servidor o archivo completo?

Storage / no-Commons: **archivo completo** en red; ahorro solo en **decode** (`memCacheWidth`/`Height`).  
Commons: excepción — thumbs en el mismo host (`upload.wikimedia.org`); ver ladder en el doc dueño.

### 2.3 URLs firmadas (Storage privado)

Emisión `ModerationRepository.signedPhotoUrl` / batch; TTL 3600 s; `SignedUrlCache` + Hive. Detalle → [`imagenes-red.md`](imagenes-red.md) §7.

> **Fase 1 · Paso 1:** firmas también en Hive (cold start).

### 2.4 Placeholders / prefetch

Sin blur-hash. Prefetch: idle 400 ms, Wi‑Fi, warmup thumbs Commons alineados a la card. Detalle → [`imagenes-red.md`](imagenes-red.md) §8–9.

---

## 3. Red / Supabase

### 3.1 Llamadas al abrir cada pantalla (órdenes de magnitud)

Conteos = **requests distintos de datos** en el camino feliz (sin contar retries de selects “NoCover/Lite”). Firmas Storage van aparte (N paths).

#### Inicio (`HomePage` + providers)

| # | Qué | Cómo |
|---|---|---|
| 1 | Guardados recientes (página 0, limit 20) | `SavesRepository.listMineSummary` → `from('user_saves').select(_saveSelectSummary)` |
| 2 | Categorías (si aún no frescas) | `CategoriesNotifier` → tabla categorías (SWR) |
| 3 | Populares cerca (si caché inválida / GPS fuera de celda) | `SearchRepository.search` → RPC `search_sites` (~25 km; UI toma 4) |
| 4 | Perfil (no bloquea lista) | `ProfileRepository.fetchCurrent` |
| 5 | Geofences (no bloquea lista) | sync vía `GeofenceSyncService` (incluye lecturas propias) |
| 6 | Firmas de portadas visibles | `coverSignedUrlProvider` / warmup |
| (opc.) | Favoritos ids | `favoriteSiteIdsProvider` si algún widget lo watch |
| (opc.) | `siteLookProvider` por card sin `coverStoragePath` | 1–2 selects por sitio |

`AuthGate` además dispara `unawaited(categoriesProvider.future)` al haber sesión.

> **Fase 1 · Paso 3 (mejoró):** el select de guardados recientes ya no embebe **todas** las `site_photos`. Slim: portada por FK `cover:site_photos!sites_cover_photo_id_fkey` + **1** `first_photo` de respaldo. Fallback legacy → noCover → lite si el slim falla.

#### Explorar (`SearchPage`)

| Momento | Llamadas |
|---|---|
| Entrar al tab (sin buscar) | Casi ninguna de sitios; categorías desde provider/caché; radio desde SharedPreferences |
| Cada búsqueda / “Cargar más” | **1×** RPC `search_sites` (`SearchRepository._searchRpc`) con `p_limit=15` (`SearchPolicies.pageSize`) |
| Resultados en UI | Firmas por `cover_storage_path` de cada hit |

Mis guardados / favoritos en filtros: el RPC sigue siendo uno; parámetros `p_include_public` / `p_favorites_only`. Fallback local (`_searchLocalFallback`) puede hacer selects adicionales **solo si falla el RPC**.

#### Ficha (`SiteDetailPage` + `SavesRepository.loadSiteFicha`)

| # | Qué |
|---|---|
| 1 | `from('sites').select(_siteSelect)` (o lite) |
| 2 | `findMineBySiteId` (save propio) |
| 3 | RPC `get_site_coords` |
| 4 | `listSitePhotos` |
| 5 | `signedPhotoUrlsParallel` (batch Storage o N firmas) |
| 6 | `listSocialLinks` |
| 7 | Perfil (staff flag) |

Con seed desde lista: la UI pinta ya; igual se disparan 1–3 + fotos/enlaces. Prefetch previo de ficha (Wi‑Fi) puede hacer que (1–3) salgan de Hive.

#### Planes (`PlansListPage`)

| # | Qué |
|---|---|
| 1 | `PlansRepository.listMine` — `from('plans').select(_planListSelect)` con embed `plan_stops` + `sites` (+ fotos / `cover_photo_id` / categorías / `visited_at`) |

Paginación: `PagedItems.defaultPageSize = 20`. `loadMore` = otro range.

Detalle de un plan: `fetchById` con `_planSelect` (más columnas: lat/lng, place id, precios, etc.) — **otra** ida a red al abrir detalle (no reusa el listado completo como única fuente).

#### Rutas (`MyRoutesPage`)

| # | Qué |
|---|---|
| 1 | RPC `list_my_route_history` — hasta **200** filas (`RoutesRepository.listMineAll`) |

Portadas: tras el RPC, **un** select batch (`loadSiteLooks`) adjunta `coverStoragePath` + categorías; `SiteLookCover(..., resolveLook: false)` — sin N+1 de `siteLookProvider`.

> **Fase 1 · Paso 2 (agregó / mejoró):** el batch `loadSiteLooks` + `resolveLook: false` en Rutas (y patrones similares en anti-dupe / planes donde el path ya viene enriquecido).

### 3.2 ¿Repeticiones innecesarias en la misma navegación?

| Caso | Observación |
|---|---|
| Inicio: guardados + populares | Populares = otro `search_sites`; no comparte payload con `listMineSummary`. Correcto semánticamente; dos viajes. |
| Card → ficha | Ficha vuelve a pedir sitio + coords aunque el hit/save ya traía nombre/coords/portada. Mitigado por SWR ficha + seed UI. |
| Plan lista → detalle | Listado liviano vs `fetchById` completo: segunda carga esperable; tras Hecho, lista se actualiza con `upsertPlan` sin refetch inmediato. |
| `siteLookProvider` | Listas (Inicio, Rutas, anti-dupe, planes) traen portada en la consulta/lote y usan `resolveLook: false`. Fallback por card solo si la ficha/widget no trae path. |

> **Fase 1 (corrección a la fila de arriba):** Rutas / anti-dupe / planes (con path en lote) → `resolveLook: false`. **Inicio** → **no** forzar `false` (default true si falta path). Ver nota Paso 2 en §1.3.
| Firmas | `SignedUrlCache` (memoria + Hive) + `keepAlive` en provider. |
| Categorías | Una carga SWR compartida; AuthGate + Inicio no duplican red si TTL fresco. |

> **Fase 1 · Pasos 1–2:** firmas y portadas en lote reducen repeticiones típicas al reabrir la app o al pintar Rutas.

### 3.3 Tamaño / sobre-fetch de payloads

**No hay mediciones de bytes en el repo.** Inferencia por shape:

| Endpoint | Qué trae | ¿Más de lo que pinta? |
|---|---|---|
| `listMineSummary` (`_saveSelectSummary`) | Save + site (nombre, geo, flags) + **portada** (`cover` por FK `cover_photo_id`) + **1** `first_photo` de respaldo | Card solo necesita una portada; ya no trae todas las `site_photos`. Fallback legacy si el select slim falla. |
| `search_sites` | Columnas fijas del RPC (id, nombre, geo, flags, categories[], `cover_storage_path`, distancia…) — **sin** blob de fotos | Alineado a cards; default SQL `p_limit` 100, app usa 15 en Explorar; Inicio/populares no pasa limit → backend default hasta 100, luego `take(4)`. |

> **Pre-Fase 2 (ajustó):** populares cerca ahora pasan `p_limit = HomeNearbyPolicies.rpcLimit` (**8**); la UI sigue mostrando `take` (**4**). Evita el default ~100 del backend.
| `_planListSelect` | Plan + **todas** las paradas con site name/cats/fotos | Listado pinta título + **una** portada (`coverStop`); hidratar todas las paradas+fotos es **más pesado** que lo visible, pero necesario para portada por visitado sin segundo round-trip. |
| `list_my_route_history` | ≤200 filas livianas (sin fotos) | UI pagina en cliente; payload acotado. |
| `loadSiteFicha` `_siteSelect` | Ficha rica (perfiles, contributors, fotos…) | Necesario para tabs; más pesado que un hit de búsqueda. |

> **Fase 1 · Paso 3:** fila `listMineSummary` arriba refleja el select slim (antes: todas las fotos del sitio).

---

## 4. Arranque de la app (cold start)

Orden real en `main.dart` → `createRootApp` (`bootstrap.dart`) → `CheverePlanApp` (`app.dart`):

| Paso | Bloquea primer frame / `runApp`? | Notas |
|---|---|---|
| `WidgetsFlutterBinding.ensureInitialized` | Sí | |
| Validación `Env` (Supabase URL/key) | Sí | Si falla → `BootstrapErrorApp` |
| `AppThemeModeStore.loadBeforeRunApp` | Sí | Preferencia tema en disco |
| `EntityCacheStore.instance.init()` (Hive) | Sí (try/catch; no tumba app) | |
| `AppImageCacheManager.configurePaintingCache` | Sí (sync) | |
| Firebase + FCM + local notifs | **No** (`unawaited`, timeout 12 s) | Comentario: esperar permisos pegaba el splash nativo |
| `Supabase.initialize` + `SecureSessionStorage` | **Sí**, timeout 15 s | Sesión JWT disponible después |
| `runApp(ProviderScope(CheverePlanApp))` | — | |
| `BetaUpdateGate` | Solo builds beta/PDN | Puede mostrar pantalla de actualización **antes** de AuthGate |
| `AuthGate` StreamBuilder | Puede mostrar spinner | Sesión null + waiting |
| `HomePage` + `_bootstrap` | Spinner si no hay saves en memoria | `await mySavesProvider.future` |
| Perfil / geofence / prefetch | No | `unawaited` / post-lista |

**¿Deferred first frame?** No. El primer frame de Flutter llega **después** de tema + Hive + Supabase init. Ese frame aún puede ser spinner de auth o de Inicio; **no** espera la red de `search_sites` de populares (van en paralelo vía provider), pero **sí** espera resolver el future de guardados (aunque sea solo lectura Hive).

> **Fase 1 · Paso 0 (agregó, no cambia orden de arranque):** `firebase_performance` (paquete Flutter) + traces en `frontend/lib/core/performance/app_performance.dart` (`home_time_to_content`, `search_time_to_first_results`, `site_detail_time_to_content`). Colección habilitada en `bootstrapFcm` tras `Firebase.initializeApp` (sin tocar `bootstrap.dart`). **No** se tocó `AuthGate` (Fase 2).
>
> **Fase 1 · Paso 0 (ajustó tras error de build):** el plugin Gradle `com.google.firebase.firebase-perf` **1.4.2** chocó con AGP 9 (`Transform`). Se quitó temporalmente.
>
> **Pre-Fase 2 (recuperó):** plugin Gradle **`2.0.2`** (fix AGP 9, firebase-android-sdk#7293) + BoM `34.18.0` + `firebase-perf` en `app/build.gradle.kts`. `assembleDebug` **OK** (2026-09-05). Un primer `assembleRelease` falló por AAPT2/UCRT en este entorno; **2026-09-06** el dueño corrió `.\gradlew assembleRelease` y **terminó bien** → `frontend/build/app/outputs/apk/release/app-release.apk` (~72 MiB). Traces custom + instrumentación nativa de arranque/HTTP quedan en release.

---

## 5. Navegación / UI

### 5.1 `const` y rebuilds (lectura estática)

- Muchos widgets de diseño son `const` donde el API lo permite (`AppNetworkImage`, headers, etc.).
- Pantallas principales son `ConsumerStatefulWidget` / `StatefulWidget` con controllers en el **State** (`SearchPage`: `_queryCtrl` en state, no recreados en `build`) — bien.
- Riesgo de rebuilds: `ref.watch` amplios. Hay uso correcto de `.select` en varios sitios (p. ej. categorías en `SiteLookCover`, `SearchPage`). `HomePage` hace `setState` con `_saves` locales además de escuchar providers → doble fuente de verdad a vigilar, no necesariamente lento.
- `SiteLookCover` hace `ref.watch(coverSignedUrlProvider(path))` por card → rebuild cuando llega la firma (esperado).

> **Fase 1 (nota):** `AppNetworkImage` pasó a `StatefulWidget` (reintentos Wikimedia + fade). Deja de ser `const` en uso; el costo es menor frente a la descarga de imagen.

### 5.2 Tabs e `IndexedStack`

`HomePage` (`home_page.dart`):

- `IndexedStack` con slots 0–3.
- Explorar / Planes / Rutas se **crean lazy** en `_goTab` (`_exploreTab ??= SearchPage(...)`, etc.) y **no se destruyen** al cambiar de tab.
- Placeholder `SizedBox.expand` si el tab aún no se abrió (evita colapsar el stack).

Efecto: **conservan State** (scroll, texto de búsqueda, etc.). Los hijos **siguen montados** → pueden seguir escuchando providers y repintarse si el provider notifica, aunque el tab no sea el visible. No es “reconstruir desde cero al tocar el tab”; tampoco es “congelar pintado”.

### 5.3 JSON / hilo principal

- `EntityCacheStore.read`: `jsonDecode` en el isolate UI.
- Decoders `_decodePagedPlans`, `_decodePagedSaves`, `SearchHit.fromJson`, etc. en el mismo isolate.
- **No** hay usos de `compute(` / `Isolate.spawn` en `frontend/lib` para decodificar caché o listas.
- Lineamientos (§4) mencionan `compute`/isolates para JSON/geo pesado; el catálogo DIVIPOLA llega async y el fuzzy se considera barato — **no** hay isolate dedicado hoy.
- Dedupe de Explorar (`SearchRepository._dedupeHits`) corre en UI isolate tras el RPC (listas de página ≤15, o hasta 100 en fallback).

---

## 6. Métricas actuales

**Línea base en dispositivo real — 2026-09-05 (noche, UTC−5)**

| Campo | Valor |
|---|---|
| Dispositivo | Motorola edge 60 fusion (`ZY22MW45BV`) |
| Build | debug `1.0.0+8` (`com.chevere.plan`), Impeller/Vulkan |
| Proyecto Firebase | `chevere-plan-a9a96` |
| Método TTFC | traces `AppPerformance` + `debugPrint` en logcat (`perf <name> <ms>ms`) |
| Método arranque Activity | `adb shell am start -W` (`LaunchState` COLD/HOT) |
| Frames | `Davey!` HWUI en logcat (cold first frame); swipes scriptados **no** emitieron Davey (scroll fluido o Impeller no reporta igual). Consola Firebase Performance abierta en IDE para cruzar; el agente no pudo leer el panel (MCP browser caído) — si ves percentiles distintos ahí, anotalos debajo. |

### 6.1 Cold start → Activity / Inicio interactivo

| Escenario | Resultado | Notas |
|---|---|---|
| Proceso COLD → Activity displayed | **6223 ms** (1.ª) / **4438 ms** (2.ª) / **4252 ms** (3.ª) | `am start -W`, `LaunchState: COLD` |
| HOT (traer a frente desde Home) | **80 ms** | `LaunchState: HOT` |
| Hive **vacío** → `home_time_to_content` | **3122 ms** | Se borró `entity_cache_v1.hive` con `run-as`; TTFC del trace (no incluye todo el TotalTime del Activity) |
| Hive **caliente** + proceso COLD → `home_time_to_content` | **245 ms** | Tras uso normal; Activity TotalTime ~4.3 s pero contenido de Inicio casi al toque |

Interpretación: el cuello de “Activity displayed” (~4–6 s en debug) incluye splash/engine; el gap grande Hive vacío vs caliente en el **trace de contenido** (3.1 s → 0.25 s) es el que Fase 2 debe atacar (peek / paint síncrono).

### 6.2 Time-to-first-content (traces instrumentados)

| Trace | ms | Condición |
|---|---|---|
| `home_time_to_content` | **3122** | Hive vacío |
| `home_time_to_content` | **245** | Hive caliente, cold process |
| `search_time_to_first_results` | **576** | Explorar, query `tunja` (1.ª búsqueda) |
| `site_detail_time_to_content` | **249** | Abrir card desde Inicio (seed / path ya en lista) |

### 6.3 Frames al scrollear

| Observación | Valor |
|---|---|
| First frame tras cold (HWUI `Davey!`) | **1839–2362 ms** (arranque; no es scroll) |
| Scroll Inicio / Explorar (10 swipes scriptados) | **0** `Davey!` en logcat |
| `dumpsys gfxinfo` | **0** frames (Flutter/Impeller no llena el histogram clásico en esta prueba) |

Pendiente opcional: capturar DevTools Timeline (Build/Raster >16 ms) en sesión profile y pegar percentiles aquí. Cruzar con [Firebase Console → Performance](https://console.firebase.google.com/project/chevere-plan-a9a96/performance) cuando haya muestras agregadas (app start + HTTP del plugin `2.0.2`).

> Texto previo (línea base 2026-09-05 mañana): *“No hay métricas… no inventa números”* — **reemplazado** por la tabla de arriba tras medición en Motorola.
>
> **Fase 1 · Paso 0 / Pre-Fase 2:** plugin Gradle `firebase-perf` **2.0.2** restaurado (ver §4). Traces custom + log local; auto HTTP/app-start vía plugin nativo en **debug y release**.

---

## Resumen ejecutivo (solo hechos)

1. **Riverpod + Hive CE (JSON) + SWR** es el corazón de datos; no hay SQLite/Isar.
2. **SWR está implementado** en guardados, planes, rutas, ficha, búsqueda, catálogos; Inicio intenta no bloquear si ya hay saves; Explorar **no** restaura la última query sola.
3. **Cold start** bloquea en tema + Hive + Supabase; el primer contenido de Inicio espera el future de saves (caché o red), no un paint síncrono tipo Fotos.
4. **Imágenes:** disco sí; decode acotado sí; Wikimedia Commons → thumb en cliente (500/800/1280) con fallback a siguiente/máximo/original; placeholders de color + ilustración de categoría; fade ~180 ms al pintar; firmas 1 h en memoria + Hive.
5. **Red:** Inicio suele ser 1 select pesado + 1 RPC populares (si aplica) + firmas; ficha suma 3+ lecturas; planes list embed todas las paradas/fotos; rutas 1 RPC ≤200.
6. **IndexedStack lazy** preserva tabs; JSON de caché en hilo UI; **línea base Motorola 2026-09-05** en §6 (Activity cold ~4–6 s debug; TTFC Inicio 3.1 s Hive vacío / 0.25 s caliente).

> **Fase 1 (cierre Pasos 0–4 + extras) + pre-Fase 2:** medir · firmas Hive · N+1 portadas · seed ficha privada · `listMineSummary` slim · UA + thumbs Wikimedia · fade · **`firebase-perf` 2.0.2 restaurado** · populares `p_limit=8`.
>
> **Fase 2 (cierre Pasos 1–6, 2026-09-06):** sesión optimista · peek Hive sync · Supabase diferido · Baseline Profiles *no* (Flutter #143129) · Impeller ya Vulkan · splash `Theme.SplashScreen`. **TTFC caliente:** 245 ms → **0–25 ms**. **Activity COLD:** 4.3–6.2 s → **~3.8–4.2 s** (engine/Hive/tema/Davey UI ~2 s siguen).

---

## Fase 1 — checklist de lo aplicado (2026-09-05)

Incluye desde el diagnóstico + **Paso 0** (y el arreglo del error Gradle `firebase-perf`) hasta el **Paso 4**, más refuerzos Wikimedia y ficha privada. **No** hubo “Fase 3/4” de rendimiento: solo **Fase 1** (pasos 0–4) y **Fase 2** (arranque) pendiente.

| Paso / ítem | Qué se agregó / ajustó / mejoró | Archivos ancla |
|---|---|---|
| **0** | Paquete `firebase_performance`; traces `home_time_to_content`, `search_time_to_first_results`, `site_detail_time_to_content`; enable en `bootstrapFcm` | `app_performance.dart`, `fcm_bootstrap.dart`, Home / Search / SiteDetail, `pubspec.yaml` |
| **0 · build** | Plugin **1.4.2** falló AGP 9 → quitado; **Pre-Fase 2:** restaurado **2.0.2** + BoM `34.18.0` — debug OK; **release OK** (2026-09-06, `app-release.apk`) | `settings.gradle.kts`, `app/build.gradle.kts` |
| **1** | Firmas Storage en Hive (`get` / `getAsync` / `put` / `clear` en logout) | `signed_url_cache.dart`, `cache_ttl.dart`, `session_cache_cleanup.dart`, repos firma |
| **2** | Batch `loadSiteLooks`; Rutas (+ anti-dupe / planes con path) sin N+1; Inicio **sin** `resolveLook: false` forzado | `saves_repository.dart`, `providers.dart` (rutas), `site_look_cover.dart`, cards rutas/planes/anti-dupe |
| **2 · revert** | Intento `refreshAfterMutation` / invalidate post-foto en Inicio → **revertido** (no ayudó) | — (no está en árbol) |
| **2↔3** | Seed portada ficha privada + placeholder sin spinner en galería vacía (públicos intactos) | `site_detail_page.dart` |
| **3** | Select slim de guardados recientes (cover FK + 1 `first_photo`; fallbacks legacy/noCover/lite) | `saves_repository.dart`, `save_models.dart` |
| **Extra UA** | User-Agent `CheverePlan/1.0`; disco `chevere_plan_images_v2` | `app_image_cache.dart`, `app_network_image.dart` |
| **Extra thumbs** | Rewrite Wikimedia → thumb 500/800/1280; prefetch alineado | `wikimedia_display_url.dart`, `site_prefetch.dart` |
| **Extra fallback** | Si thumb falla → siguiente / máximo (fullscreen) / 800·500 cacheados / original | `wikimedia_display_url.dart`, `app_network_image.dart` |
| **4** | Fade ~180 / ~120 ms en `AppNetworkImage` | `app_network_image.dart` |

Commits locales de referencia (`main`, ahead): `fc64075` métricas+Paso1 · `4a557f9` Paso2 (+ficha) · `4ab92fe` Paso3+Wikimedia · `d4ee4c9` Paso4 fade.

---

## Huecos relevantes para seguir mejorando (toda la app)

Prioridad sugerida; **no** son trabajo hecho — checklist de producto/técnica abierta tras Fase 1:

| Área | Hueco | Notas |
|---|---|---|
| **Fase 2 — arranque** | **Hecha (2026-09-06).** TTFC caliente ~245→~3 ms; Activity COLD ~4.3–6.2→~3.8–4.2 s. Baseline Profiles pendiente de Flutter. |
| **Métricas en doc** | ~~pegar línea base~~ → **hecho** §6 (2026-09-05 Motorola) | Completar con percentiles Firebase Console / DevTools profile si hace falta. |
| **Planes list** | Sobre-fetch de todas las paradas+fotos en listado | Sigue siendo el payload más pesado visible vs lo pintado. |
| **Populares Inicio** | ~~sin `p_limit`~~ → **hecho:** `rpcLimit = 8`, UI `take = 4` | Ver §3.3. |
| **Ficha** | Sigue pidiendo sitio + coords + fotos + social aunque venga seed | SWR mitiga; se puede hidratar más desde card / unificar round-trips. |
| **Explorar** | Tab vacío; no restaura última búsqueda | Decisión de producto + SWR de última query. |
| **Storage thumbs** | Bucket sigue sirviendo original | [`imagenes-red.md`](imagenes-red.md) §10; transform servidor = fase aparte. |
| **Placeholders** | Sin blur-hash / shimmer | Opcional tras el fade; más costo de diseño/datos. |
| **Externas no-Commons** | Flickr u otras URLs sin rewrite de thumb | [`imagenes-red.md`](imagenes-red.md) §10 — solo Commons tiene ladder. |
| **JSON en UI isolate** | `jsonDecode` de Hive/listas en hilo principal | `compute` para listas grandes / DIVIPOLA si se mide jank. |
| **Home dual state** | `_saves` local + providers | Riesgo de desync / rebuilds; unificar fuente. |
| **Prefetch** | Solo Wi‑Fi; máx. 3 fichas / 8 covers | Valorar política en datos móviles (conservadora hoy). |
| **Anti-dupe / otras listas** | Vigilar que todo path de card traiga cover en el select/lote | Evitar regressiones de `resolveLook`. |

---

## Mapa rápido de archivos ancla

```
frontend/lib/bootstrap.dart                 # cold start
frontend/lib/app.dart                       # AuthGate, MaterialApp
frontend/lib/core/di/providers.dart         # Riverpod + notifiers SWR
frontend/lib/core/cache/entity_cache_store.dart
frontend/lib/core/cache/swr_loader.dart
frontend/lib/core/cache/cache_ttl.dart
frontend/lib/core/cache/signed_url_cache.dart
frontend/lib/core/cache/app_image_cache.dart
frontend/lib/core/widgets/app_network_image.dart
frontend/lib/core/photos/wikimedia_display_url.dart
frontend/lib/core/performance/app_performance.dart
frontend/lib/core/prefetch/site_prefetch.dart
frontend/lib/features/home/presentation/home_page.dart
frontend/lib/features/search/presentation/search_page.dart
frontend/lib/features/search/data/search_repository.dart
frontend/lib/features/saves/presentation/site_detail_page.dart
frontend/lib/features/plans/presentation/plans_list_page.dart
frontend/lib/features/routes/data/routes_repository.dart
```
