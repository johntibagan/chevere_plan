# FASE 0 — Auditoría arquitectónica del frontend

**Alcance:** solo lectura de `frontend/lib/`, `frontend/test/`, `frontend/patrol_test/` y `.cursor/rules/`.  
**Fecha:** 2026-09-11.  
**Fuente de verdad visual:** código en `lib/core/widgets/` y `lib/core/theme/` (Figma descartado).  
**Objetivo:** diagnóstico para una futura reestructuración Vertical Slice (VSA). Sin cambios de código en esta fase.

---

## 1. Diagnóstico General

### Estado actual

El frontend ya está **organizado por features** (`lib/features/<nombre>/{data,domain,presentation}`) con Riverpod y un `core/` de infraestructura (caché SWR/Hive, tema, widgets compartidos, errores, notificaciones). Esa estructura es una base válida para VSA, pero **no es todavía un Vertical Slice limpio**:

| Señal | Evidencia |
|-------|-----------|
| Kernel de producto concentrado | `features/saves/` ≈ **41 archivos** (~40 % del código de features); god files `save_place_page` (~2500 LOC), `site_detail_page` (~1600), `saves_repository` (~1300) |
| Shell hub | `home/presentation/home_page.dart` importa ~10 features (navegación, prefs, admin, saves, search, plans, routes) |
| Ciclo home ↔ search | Search usa `home_cards`; Home/nearby usan `SearchHit` |
| Fan-in máximo | `saves` (`open_site_detail`, `site_look_cover`, `save_models`, Maps helpers) |
| Composition root monstruo | `core/di/providers.dart` (~1070 LOC, ~43 providers + notifiers SWR + fetch inline de `SiteLook`) |
| Capas incompletas | `plans` sin `domain/`; `settings`/`admin`/`moderation`/`legal` sin domain o solo presentation |
| Core “cajón” | Widgets de sitio/borrador en `core/widgets/`; core importa features fuera de DI (`privacy_block_format`, `local_notification_router`) |

### Nivel de acoplamiento

**Medio–alto.** La regla documentada (`core` no importa features salvo `providers.dart`) se cumple casi siempre, pero el acoplamiento **entre features** es denso alrededor del dominio Sitio:

```
                    ┌──────── home (shell) ────────┐
                    │  fan-out: saves, search,     │
                    │  plans, routes, settings, …  │
                    └─────────────┬────────────────┘
           ┌──────────────────────┼──────────────────────┐
           ▼                      ▼                      ▼
        search ◄────────────► saves ◄──────────────► plans
           │                    │                      │
           │              geo, admin,                  │
           │              auth, moderation             │
           └──────── home_cards / SiteLookCover ───────┘
```

- **Acoplamiento estructural fuerte:** modelos de lista de sitio (`UserSave` / `SearchHit` / `PlanStop` / `SiteFicha`) con campos solapados y adaptadores (`hitFromSave` en `home_cards`).
- **Acoplamiento de UI fuerte:** tarjetas canónicas viven en `home` pero las consumen `search` y `saves` (anti-dupe).
- **Acoplamiento de infra:** DI global + SWR en un solo archivo; cualquier slice nuevo pasa por ahí.

### Madurez relativa a VSA

| Dimensión | Nota | Comentario |
|-----------|------|------------|
| Partición por feature | 6/10 | Carpetas existen; límites de ownership borrosos |
| Capas data/domain/presentation | 5/10 | Domain delgado o ausente en varias features; presentation habla directo a data |
| Design System reutilizable | 7/10 | Tokens de color/l10n sólidos; radios y site-kit dispersos |
| Testabilidad ante moves | 6/10 | Unit tests en `package:` paths; Patrol acoplado a keys + tipos de widget |
| Listo para agentes IA | 4/10 | God files y DI monolítico elevan el costo de contexto por cambio |

**Veredicto:** arquitectura **feature-first pragmática**, no VSA. Excelente disciplina en tokens de color, i18n y caché; deuda principal = **límites de ownership del dominio Sitio**, **god files** y **UI compartida mal ubicada**.

---

## 2. Inconsistencias y Duplicados

### 2.1 Widgets / UI repetida

| Patrón | Ubicaciones | Severidad | Nota |
|--------|-------------|-----------|------|
| Cards de sitio (lista/grilla + textos + métricas) | `home/presentation/home_cards.dart` (~962 LOC, ~11 clases); usado por `search_page`, `same_site_picker_page` | **Alta** | Ownership incorrecto: no es “home”, es kit de Sitio |
| Portada de sitio | `saves/.../site_look_cover.dart` + `core/widgets/site_cover.dart` | **Alta** | Consumido por home, plans, routes, saves; regla `ui-portada-sitio` |
| Review list card | `_ReviewCard` en `site_reviews_tab` vs `_PlanReviewCard` en `plan_reviews_tab` | **Alta** | Mismo flujo load / signed URL / sort / ⋮ / viewer |
| Review editor | `site_review_editor_page` (~344) vs `plan_review_editor_page` (~236) | **Alta** | Mismo slot de fotos / dirty / pick; site añade estrellas + público |
| Prefs bottom sheets | `proximity_prefs_sheet`, `distance_unit_prefs_sheet`, `duplicate_radius_prefs_sheet` | **Media** | Misma chrome (surface, handle, slider/lista, toast); knobs distintos |
| Banner staff | `_StaffPrivilegesBanner` en `site_detail_page` y `site_reviews_tab` | **Media** | Duplicado local |
| `BorderRadius.circular(N)` | Decenas de usos en features + varios `core/widgets` | **Media** | `AppRadius` existe pero casi no se usa en features |
| `AppCreateCtaCard` | Solo definición en `core/widgets/app_create_cta_card.dart` | **Baja** | **Sin callers** (leftover; planes usan FAB) |

### 2.2 Modelos y proyecciones solapadas

Campos comunes (`siteId`, nombre, ciudad/depto, dirección, categorías, cover, flags public/own/catalog/linked, lat/lng, físico):

| Tipo | Feature | Rol |
|------|---------|-----|
| `UserSave` (+ satélites) | `saves/data/save_models.dart` | Guardado del usuario |
| `SearchHit` | `search/data/search_models.dart` | Proyección Explorar / nearby |
| `SiteFicha` | `saves/data/site_ficha.dart` | Detalle (importa `SearchHit`) |
| `PlanStop` | `plans/data/plan_models.dart` | Parada de plan |
| `SiteLook` | `save_models` + provider en DI | Portada/categoría |

No hay un tipo de dominio compartido de “ítem de lista de sitio”; se compensan con adaptadores y parsers JSON paralelos.

Reviews: `site_review_models` ≈ `plan_review_models` (foto + autor vía `ProfilePublicDisplay`; site añade rating / isPublic / summary).

### 2.3 Lógicas / data duplicadas o mal ubicadas

| Área | Hallazgo |
|------|----------|
| Reviews repos | `site_reviews_repository` ≈ `plan_reviews_repository` (CRUD + signed URLs) |
| Geocoders | Cadena intencional en `saves/data` (`place_geocoder` + Google/Geoapify/BigDataCloud/Nominatim) — no es copy-paste, pero **geo está partido** (DIVIPOLA en `geo/`, geocode en `saves/`) |
| `DeviceLocation` | Vive en `home/data` pero lo usa `saves` (`location_picker_page`) |
| `PlanHoursPolicy` | En `plans/data`; stub que siempre retorna `true`; lo importa `search_repository` |
| `geo/data/geo_models.dart` | Re-export de `domain` (capa pasapapeles) |
| Policies cruzadas | `auth/profile_repository` importa `proximity_policies` y `save_policies` |

### 2.4 Inconsistencias de capa

- Presentation importa data directamente de forma sistemática (aceptable con Riverpod, pero sin puertos de dominio).
- `plans` y varias features satélite **no tienen `domain/`**.
- `settings` es solo presentation que habla a `auth` + `saves` policies.
- `legal_texts.dart` fuera de `data/domain/presentation`.

---

## 3. Análisis de Features

### 3.1 Clasificación por complejidad

| Feature | Archivos | Complejidad | Capas | Rol actual |
|---------|----------|-------------|-------|------------|
| **saves** | 41 | **Crítica** | d/dom/p | Kernel de producto (CRUD sitio, Maps, anti-dupe, ficha, reviews, fotos) |
| **plans** | 15 | **Alta** | d/p (sin domain) | Planes, timeline, reviews, export Maps |
| **home** | 7 | **Alta** (shell) | d/dom/p | Composition root UI + cards compartidas mal ubicadas |
| **search** | 6 | **Media–alta** | d/dom/p | Explorar; depende de cards de home |
| **proximity** | 7 | **Media** | d/dom/p | Geofence + prefs |
| **auth** | 6 | **Media** | d/dom/p | Login + profile; policies filtradas a peers |
| **geo** | 5 | **Media** | d/dom/p | DIVIPOLA + fuzzy + typeahead |
| **routes** | 4 | **Baja–media** | d/dom/p | Lista rutas → detalle plan |
| **settings** | 3 | **Baja** | solo p | Perfil + sheets de preferencias |
| **admin** | 3 | **Baja** | d/p | Catálogo staff |
| **moderation** | 3 | **Baja** | d/p | Reportes |
| **beta** | 3 | **Baja** | d/dom/p | Gate de actualización |
| **legal** | 2 | **Baja** | atípico | Textos + página |

### 3.2 Mapeo sugerido hacia Vertical Slices

Propuesta de **ownership** (no implementación). Un slice = carpeta con API pública estrecha (barrel) + interior libre.

| Slice candidato | Contenido principal | Extrae / absorbe |
|-----------------|---------------------|------------------|
| **`sites` (kernel)** | Crear/editar (`SavePlacePage`), ficha, fotos, favoritos, anti-dupe, policies, Maps import, share parse | Hoy `saves` + partes de core (`draft_*`, `non_physical_*`, photo viewer) |
| **`sites_ui` (kit compartido)** | `SiteLookCover`, `SiteCover`, cards (`HomePopularCard`…), origin tags, visibility badge, métricas de card | Hoy `home_cards` + widgets `site_*` en core + `site_look_cover` |
| **`site_list_projection` (tipos)** | Tipo común de ítem de lista + mappers desde UserSave / SearchHit / PlanStop | Reduce adaptadores |
| **`explore`** | Search page, radius, SearchHit repo/policies | Consume `sites_ui` + projection; no importa home |
| **`plans`** | Lista, builder, detalle, timeline, maps export | Domain propio; reviews plan vía kit review compartido |
| **`reviews` (compartido o submódulo)** | List item + editor de fotos parametrizado | Factor común site/plan |
| **`shell` / `app_nav`** | `HomePage` tabs, drawer, FAB, IndexedStack | Solo orquesta; no posee cards |
| **`geo`** | DIVIPOLA + (opcional) fachada de geocoders | Unificar con geocoders hoy en saves |
| **`location`** | `DeviceLocation` | Sacarlo de home |
| **`auth` / `profile`** | Login, profile, username | Settings UI puede vivir aquí o como `settings` delgado |
| **`proximity`** | Geofence + prefs | — |
| **`routes`** | My routes | — |
| **`admin` + `moderation`** | Staff | Pueden fusionarse en un slice `staff` |
| **`beta` / `legal`** | Satélites | Quedan thin |

### 3.3 Prioridad de desenredo

1. Extraer **`sites_ui`** de `home` (rompe ciclo home↔search).
2. Definir proyección / API pública de **`sites`** (open detail, cover, models).
3. Factorizar **reviews** site/plan.
4. Partir **`providers.dart`** por slice (composition root por feature + un aggregator).
5. Mover geocoders junto a **`geo`** o documentar `saves` como dueño explícito del “place resolve”.

---

## 4. Propuesta para Design System

### 4.1 Estado

- **Colores / tipografía / l10n / formatters:** bien centralizados (`ChevereThemeColors`, `AppColors`, `app_es.arb`, `core/formatters/*`). Casi cero `Color(0x…)` fuera de theme.
- **Barrel `core/design/design_system.dart`:** documentado como mapa único, pero **ningún** `import` lo usa; el código importa granularmente `core/theme/*` y formatters.
- **Radios:** `AppRadius` infrautilizado; predominan `BorderRadius.circular(...)`.
- **`core/widgets`:** mezcla de UI genérica (`app_*`) y dominio de sitio (`site_*`, banners de borrador/tarjeta).
- **`AppCreateCtaCard`:** muerto (candidata a depurar en Fase 1+).

### 4.2 Estrategia: `core/widgets` como verdad visual genérica

```
lib/core/
  theme/          ← tokens (única fuente de color/tipo/spacing/radius)
  formatters/     ← fechas, moneda, distancia, lugar
  widgets/        ← SOLO primitivas genéricas (app_*)
  design/         ← barrel opcional O se documenta “imports granulares”

lib/features/sites_ui/   (o shared/sites_ui)
  ← SiteCover, SiteLookCover, cards, origin tags, photo viewer
```

**Reglas objetivo**

1. **Genérico en core:** dialogs, toasts, search field, async body, retry callout, chips, FAB layout, feed toggle, form/list cards genéricas, tab header.
2. **Dominio Sitio fuera de core:** todo lo gobernado por `ui-portada-sitio`, `ui-sin-redundancia`, `guardar-sitio` banners.
3. **Tokens:** nuevo UI usa `AppRadius` / `AppSpacing` / `AppColors` + `watchAppThemeMode()`; migrar radios oportunistamente en god files.
4. **Barrel:** o bien (A) adoptar `design_system.dart` como API pública de tokens, o (B) actualizar lineamientos para oficializar imports granulares — hoy hay **desalineación docs ↔ código**.
5. **Prefs sheet scaffold:** un widget genérico de chrome (surface + SafeArea + handle) en core; contenido inyectado (patrón ya alineado con `flutter-modals-visibility`).
6. **Review kit:** widget parametrizado (rating/privacy opcionales) en módulo compartido, no en core genérico.
7. **Sin inventar look** durante el refactor (`no-decidir-solo-producto`): extraer y reubicar, no rediseñar.

### 4.3 Checklist de consolidación (Fase 1+)

- [ ] Clasificar cada archivo de `core/widgets` → stay / move to `sites_ui` / delete
- [ ] Mover `home_cards` → `sites_ui` y actualizar search/saves
- [ ] Unificar consumo de `SiteLookCover`
- [ ] Depurar `AppCreateCtaCard` si sigue sin uso
- [ ] Resolver barrel `design_system.dart`
- [ ] Plan de migración `BorderRadius.circular` → `AppRadius` en páginas tocadas

---

## 5. Riesgos y Consideraciones (tests / Patrol)

### 5.1 Unit tests (`frontend/test/`)

~29 tests, mayoría **domain/data puros** vía `package:chevere_plan/...`.

| Riesgo | Detalle | Mitigación |
|--------|---------|------------|
| Path moves | Casi todos apuntan a `features/<x>/...` | Barrel por feature + codemod de imports |
| Presentation en test | `plan_reorder_test` importa helpers desde `plan_timeline.dart` (presentation) | Extraer a `plans/domain` **antes** de mover carpetas |
| Core↔admin | `site_cover_test` acopla `core/widgets/site_cover` a `admin_models.Category` | Mantener API de cover estable al mover |

Los tests de policies (saves, reviews, home nearby), Maps, share parse, geo fuzzy y cache son **aliados** de VSA: validan invariantes sin árbol de widgets.

### 5.2 Patrol (`frontend/patrol_test/`)

Cobertura (ver `docs/e2e.md`): P0 plumbing/smoke/session/regla8; P1 saves/privacy/plans/routes/search; reviews skipped (galería nativa).

| Riesgo | Severidad | Por qué |
|--------|-----------|---------|
| `WidgetKeys` con índices de tab (`home_tab_0`…`3`) | **Alta** | Reordenar tabs rompe suite |
| Keys densas de `SavePlacePage` (~20) | **Alta** | Corazón P1; mover el form exige mover keys con el widget |
| Robots tipados (`FilledButton`, `Switch`, `SwitchListTile`) | **Alta** | Cambio de widget type sin actualizar robot → falso rojo |
| `p1_saves_test` importa `SavePlacePage` + providers | **Alta** | Share-intent push acoplado al constructor/package |
| `SiteDetailRobot` usa `Icons.more_vert.first` | **Media** | Frágil ante menús extra |
| Harness duplica strings de keys | **Baja–media** | `login_google_button` / `home_shell` en harness vs `WidgetKeys` |
| Asserts negativos por copy (`punto exacto`, PostgREST) | **Media** | Protegen `guardar-sitio` / regla 8; no cambiar copy en refactor |
| Sesión e2e / tokens | **Alta (ops)** | Sin `E2E_SUPABASE_REFRESH_TOKEN` los critical se skippean |

### 5.3 Invariantes de producto que un move no puede romper

Reglas `.cursor/rules` que deben quedar verdes tras cualquier reubicación:

- **guardar-sitio** — paste Maps conserva pin; Público con coords; punto exacto default off; un CTA Guardar abajo; create≡edit.
- **ui-portada-sitio** — siempre `SiteLookCover` (padre + cover_photo).
- **design-tokens-centralizados** — sin colores/formatters/l10n sueltos.
- **reuso-sin-duplicar** — un card/CTA, no clones Explorar vs Inicio.
- **frontend-lineamientos** — core sin features (salvo composition root); SWR; errores genéricos en UI.
- **flutter-modals-visibility** — fotos = tira + página; sheets cortos con surface.
- **ui-sin-overflow / ui-responsive / ui-sin-redundancia** — al tocar cards.
- **codigo-sin-uso** — no dejar leftovers del move.

### 5.4 Estrategia de prueba durante el refactor

1. Tras cada move de carpeta: `flutter test` + `flutter analyze`.
2. Tras tocar shell / SavePlace / cards: `patrol test --tags critical`.
3. No cambiar semántica de `WidgetKeys` en el mismo PR que mueve archivos (o actualizar robots en el mismo commit).
4. Preferir keys nuevas antes que finders por icono/texto en robots nuevos.

---

## 6. Plan Sugerido para Fase 1 (Diseño de Arquitectura Objetivo)

Entregable de Fase 1: **documento de arquitectura objetivo** (sin refactor masivo aún), alineado a agentes IA y a las reglas del repo.

### 6.1 Decisiones a cerrar con el dueño

1. ¿Nombre del kernel: `saves` se renombra a `sites` o se mantiene?
2. ¿`sites_ui` es feature compartida, `lib/shared/`, o paquete interno?
3. ¿Geocoders migran a `geo` o quedan en sites con fachada?
4. ¿Reviews compartidos = slice propio o librería interna de sites/plans?
5. ¿`providers.dart` se parte por feature ahora o en Fase 2?
6. ¿Barrel `design_system.dart` obligatorio o se actualiza la doc?

### 6.2 Artefactos de Fase 1

| # | Artefacto | Contenido |
|---|-----------|-----------|
| 1 | `docs/architecture/target.md` | Diagrama de slices, reglas de dependencia (quién puede importar a quién), APIs públicas por barrel |
| 2 | Mapa de migración | Archivo actual → destino; orden de PRs |
| 3 | Contrato `sites_ui` | Lista de widgets públicos + métricas de card (no romper overflow/portada) |
| 4 | Contrato composition root | Cómo se registran providers por slice sin un solo archivo de 1k LOC |
| 5 | Matriz Patrol | Keys / robots afectados por cada PR de move |
| 6 | Criterios “listo para agentes” | Tamaño máx. de archivo, god-file budget, “un slice = un contexto” |

### 6.3 Orden de implementación propuesto (Fases 2+)

| Paso | Acción | Riesgo Patrol |
|------|--------|---------------|
| A | Extraer helpers de `plan_timeline` → domain; ajustar `plan_reorder_test` | Bajo |
| B | Crear `sites_ui` moviendo `home_cards` + `site_look_cover` + widgets `site_*` de core | Medio (imports) |
| C | Barrel público de `sites` (`openSiteDetail`, models, repos) | Medio |
| D | Factorizar review list/editor compartido | Bajo–medio |
| E | Partir `providers.dart` por feature | Alto (DI harness) |
| F | Mover geocoders / `DeviceLocation` | Bajo |
| G | Depurar leftovers (`AppCreateCtaCard`, re-exports vacíos) | Bajo |
| H | Migración oportunista `AppRadius` + alinear doc del barrel | Bajo |

### 6.4 Principios para agentes (objetivo)

- Un cambio de feature no debería requerir abrir `home_page` + `providers.dart` + tres features peer.
- God files (`save_place_page`, `site_detail_page`, `plan_detail_page`) se parten por **sección/caso de uso** dentro del slice, no solo se mueven de carpeta.
- Toda UI reutilizable de sitio tiene **un solo dueño** (`sites_ui`).
- Tests unitarios viven junto al domain del slice; Patrol sigue siendo aceptación de producto, no de paths.

### 6.5 Fuera de alcance hasta decisión explícita

- Nuevas features de producto.
- Rediseño visual / Figma.
- Introducción de GoRouter (lineamientos lo prohíben en este pase).
- Cambios de comportamiento de Guardar sitio, privacidad o portada.

---

## Apéndice A — Inventario rápido

**Features:** admin, auth, beta, geo, home, legal, moderation, plans, proximity, routes, saves, search, settings.  
**Core widgets (29):** 22 genéricos `app_*` / shell; 6 dominio sitio/borrador; 1 CTA sin uso.  
**DI:** `core/di/providers.dart` importa features; además `core/formatters/privacy_block_format.dart` y `core/notifications/local_notification_router.dart` importan saves.  
**Tests unitarios:** 29. **Patrol acceptance:** 10 archivos (+ robots/harness).

## Apéndice B — Fuentes consultadas

- Árbol `frontend/lib/features/*` y `frontend/lib/core/**`
- Imports cruzados entre features (grep relativo `../../<feature>/`)
- Tamaños LOC de god files
- `docs/lineamientos-desarrollo-frontend.md`, `docs/e2e.md`
- Reglas `.cursor/rules/` citadas en §5.3
- `frontend/lib/core/testing/widget_keys.dart`, `patrol_test/robots/`, harnesses

---

*Fin Fase 0. Siguiente paso acordado: Fase 1 — diseño de arquitectura objetivo (sin refactor de código).*
