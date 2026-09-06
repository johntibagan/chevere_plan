# Imágenes de red (cliente)

**Dueño técnico** de cómo se descargan, cachean y muestran fotos (Storage firmado + `external_url`).  
Producto / invariantes: [`aplicacion-actual.md`](aplicacion-actual.md), [`invariantes.md`](invariantes.md).  
Contexto de rendimiento (métricas, fases): [`diagnostico_rendimiento.md`](diagnostico_rendimiento.md) — enlaza aquí, no duplicar este detalle.

---

## 1. Alcance

| Fuente | En DB | En red al pintar |
|---|---|---|
| Supabase Storage | `site_photos.storage_path` | URL firmada (`createSignedUrl`, TTL 3600 s) |
| Externa (staff/catálogo) | `site_photos.external_url` (http/s) | URL directa (suele ser el **original**) |

Invariante: exactamente **uno** de `storage_path` o `external_url` (nunca ambos ni ninguno).

El rewrite a thumbnail de Wikimedia es **solo cliente**. La fila en DB **no** cambia; **no** se copia el blob a Storage.

---

## 2. Archivos dueños (código)

| Rol | Path |
|---|---|
| Rewrite Commons + escalera de reintentos | `frontend/lib/core/photos/wikimedia_display_url.dart` |
| Memoria de sesión (ancho OK por foto) | `frontend/lib/core/photos/wikimedia_session_widths.dart` |
| Widget de pintado + fallback UI | `frontend/lib/core/widgets/app_network_image.dart` |
| Caché disco + UA HTTP | `frontend/lib/core/cache/app_image_cache.dart` |
| Prefetch / warmup portadas | `frontend/lib/core/prefetch/site_prefetch.dart` |
| Firmas Storage (memoria + Hive) | `frontend/lib/core/cache/signed_url_cache.dart` |
| Tests rewrite / ladder / cacheKey | `frontend/test/wikimedia_display_url_test.dart` |
| Portada sitio (ilustración + foto) | `site_look_cover.dart` / `site_cover.dart` |

Paquetes: `cached_network_image`, `flutter_cache_manager`.

---

## 3. Pipeline de pintado (`AppNetworkImage`)

```
url (+ cacheKey opcional) + AppImageQuality
        │
        ├─ ¿host == upload.wikimedia.org?
        │     sí → ladder Wikimedia (intento _wikiAttempt)
        │     no → URL tal cual (Storage firmada, Flickr, etc.)
        │
        ▼
displayUrl + cacheKey efectivo
        │
        ▼
CachedNetworkImage
  · cacheManager = AppImageCacheManager (images_v2)
  · headers: User-Agent CheverePlan/1.0 + Accept image/*
  · memCacheWidth/Height (un eje, tope 2048)
  · fadeIn 180 ms / fadeOut 120 ms
        │
        ├─ loading → ColoredBox(surfaceElevated) [± spinner si showLoadingIndicator]
        ├─ error + quedan peldaños Commons → avanza ladder (sigue placeholder)
        └─ error final → icono image_not_supported
```

Portadas: debajo suele haber `DefaultSiteCover` (ilustración por categoría padre); la foto hace fade encima.

`cacheKey` estable recomendado: `storage_path` o id de foto — al rotar la URL firmada **no** se re-descarga el blob. En Commons, cada ancho tiene sufijo propio (ver §5.3).

---

## 4. Calidad UI → thumb preferido Commons

| `AppImageQuality` | Ancho thumb preferido | Uso típico |
|---|---|---|
| `standard` | **500** | Cards / portadas lista y grilla |
| `photo` | **800** | Tira horizontal de ficha |
| `fullScreen` | **1280** | Visor a pantalla completa |

Método: `AppNetworkImage.wikiThumbWidthFor(quality)`.

Decode en memoria (independiente del thumb de red):

- Un solo eje (`memCacheWidth` **o** `memCacheHeight`), nunca ambos (distorsión).
- Tope **2048** px; `photo` usa factor ×2 sobre el alto lógico (mín. 720 en fitHeight); `fullScreen` ≈ lado largo de pantalla × DPR (mín. 1080).
- `FilterQuality.low` en `standard`; `medium` en el resto.

---

## 5. Wikimedia Commons (detalle)

### 5.1 Cuándo aplica

- Host exacto (case-insensitive): `upload.wikimedia.org`.
- Path parseable como commons file (`wikipedia/commons/...`).
- **No** aplica a: SVG / SVGZ, Flickr, otras CDN, URLs Storage.

### 5.2 Formas de URL

**Original:**

```text
https://upload.wikimedia.org/wikipedia/commons/{a}/{ab}/{file}
```

**Thumb (mismo host):**

```text
https://upload.wikimedia.org/wikipedia/commons/thumb/{a}/{ab}/{file}/{N}px-{file}
```

`wikimediaDisplayUrl(url, widthPx: N)` reescribe (también si la entrada ya era un thumb).  
`wikimediaOriginalUrl` quita el segmento `/thumb/…/Npx-…`.

### 5.3 Anchos permitidos

Lista fija del host (`kWikimediaThumbWidths`):

```text
20, 40, 60, 80, 100, 120, 150, 180, 200, 220, 250,
300, 320, 400, 500, 640, 800, 1024, 1280, 1920, 2560
```

`wikimediaClampThumbWidth(desired)` → menor valor de la lista **≥** desired; si desired es mayor que todos → **2560**.

### 5.4 Escalera de reintentos (`wikimediaRetryWidths`)

No es “mejorar calidad progresiva”. Solo **fallback ante error** de red/decode del intento actual.

**Lista / tira** (`fullScreen: false`), ejemplo preferido 500 (como en tests):

1. **500** (preferido, clamp)
2. Siguiente en la lista (**640**)
3. El de después (**800**)
4. **800** y **500** otra vez (dedupe; suelen estar ya en disco por cards)
5. **`null`** → archivo **original**

Resultado típico: `[500, 640, 800, null]`.

**Visor** (`fullScreen: true`), preferido 1280:

1. **1280**
2. **2560** (máximo de la lista)
3. **1920**
4. **800**, **500** (tamaños de card/tira, a menudo en disco)
5. **`null`** → original

Resultado típico: `[1280, 2560, 1920, 800, 500, null]`.

### 5.5 Avance en UI

Estado `_wikiAttempt` (índice en la ladder).  
En `errorWidget` de `CachedNetworkImage`: si Commons y `attemptIdx < ladder.length - 1` → `setState` al siguiente en post-frame; se sigue mostrando placeholder. Al agotar → caja de error.

Si cambian `url` / `cacheKey` / `quality` → se recalcula el índice inicial (no siempre 0).

**Memoria de sesión (`WikimediaSessionWidths`):** al cargar bien un intento, se guarda `base → ancho OK` (o original). Al montar / recrear el widget (tira, visor, swipe `PageView`), el índice inicial es el peldaño de ese ancho en la ladder de la `quality` actual — evita redescubrir fallos y reutilizar el blob ya en disco (`@wN`). Se limpia en `clearSessionCaches` / logout. No persiste en Hive.

**Mejora progresiva (solo Wikimedia, subir calidad):** si la sesión o el disco ya tienen un thumb **menor** que el preferido de la `quality` actual (p. ej. tira `@w800` → visor `@w1280`):

1. Capa baja: pinta ese thumb al toque (sin fade).
2. Capa alta: pide el preferido (ladder desde 0); fade 180/120 ms al llegar.
3. Si la alta falla del todo → se queda la baja (sin icono de error encima).
4. No baja resolución a propósito (visor→tira con sesión ≥ preferido de tira sigue usando el mayor ya OK).

No es progressive JPEG del mismo archivo; son dos `cacheKey` (`@wN` distintos) en un `Stack`.

### 5.6 `cacheKey` por intento (`wikimediaAttempt`)

| Intento | `cacheKey` efectivo |
|---|---|
| Thumb N px | `{base}@w{N}` (ej. `sites/…/foto.jpg@w500`) |
| Original (`widthPx == null`) | `{base}@orig` |
| Sin rewrite (no Commons) | `cacheKey` del caller o la URL |

`base` = `cacheKey` del widget si viene; si no, la `sourceUrl`.

Así cada resolución es un objeto distinto en el `CacheManager`. El prefetch **debe** usar la misma key que la card.

---

## 6. Caché en disco y User-Agent

| Pieza | Valor |
|---|---|
| Store key | `chevere_plan_images_v2` (v1 invalidada: pudo cachear fallos 429 sin UA) |
| Máx. objetos | 400 |
| Stale | 14 días |
| Memoria Flutter | máx. 120 imágenes / **64 MiB** (`configurePaintingCache` en bootstrap) |

**User-Agent** (obligatorio; Wikimedia y otros rechazan el UA default de Dart):

```text
CheverePlan/1.0 (com.chevere.plan; +https://github.com/johntibagan/chevere_plan)
```

- `CachedNetworkImage.httpHeaders`
- `ChevereHttpFileService.get` (prefetch / `downloadFile`) — el UA se fuerza **después** de mergear headers del caller para que no lo pisen.

También: `Accept: image/*,*/*;q=0.8`.

---

## 7. Firmas Storage (paralelo a externas)

| Pieza | Comportamiento |
|---|---|
| Emisión | `ModerationRepository.signedPhotoUrl` / `signedPhotoUrlsParallel` (fallback `SavesRepository`) |
| TTL Storage | 3600 s |
| Cliente | `SignedUrlCache`: memoria LRU 200 + Hive; margen `skewSeconds = 120` |
| Logout | `clearSessionCaches` borra firmas |

Tras firmar, si la URL resultante es Commons (raro en Storage), el mismo `AppNetworkImage` aplicaría ladder; el caso normal Storage es path del bucket → URL firmada no-Commons.

Externas (`external_url`): se pueden guardar en `SignedUrlCache` con TTL lógico igual, pero la “firma” es la URL misma.

---

## 8. Prefetch (`SitePrefetchCoordinator`)

| Regla | Valor |
|---|---|
| Idle antes de lote | 400 ms |
| Máx. sitios por lote | 3 |
| Red | Solo Wi‑Fi / Ethernet |
| Warmup portadas | Hasta 8 paths |

`warmupCoverPaths`:

1. Resuelve URL (caché de firma → firmar si hace falta).
2. `wikimediaDisplayUrl(url, widthPx: 500)` (mismo que `AppImageQuality.standard`).
3. `downloadFile(displayUrl, key: …@w500)` alineado a la card.

Errores: silenciados (`catch`).

---

## 9. Placeholders y feedback visual

- **No** blur-hash / shimmer (decisión actual).
- Loading: `ColoredBox(AppColors.surfaceElevated)`.
- Portada: ilustración de categoría debajo hasta que llega la foto.
- Fade corto al pintar (180/120 ms) — no sustituye progressive JPEG multi-resolución.

---

## 10. Qué queda fuera (huecos para mejorar)

| Tema | Estado hoy |
|---|---|
| Progressive upgrade (pintar menor → mayor encima) | **Hecho** — `AppNetworkImage` Stack + probe disco (§5.5) |
| Recordar ancho OK en sesión (evitar redescubrir ladder) | **Hecho** — `WikimediaSessionWidths` + arranque de `_wikiAttempt` (§5.5) |
| Hosts no-Commons (Flickr, etc.) | Archivo completo; sin ladder |
| Thumbs / transform en Storage | No; bytes = original subido (lado largo ≤ ~1920 en lineamientos de subida) |
| Métricas de ladder (cuántos peldaños, 429, latencia) | No instrumentado |
| Backoff / timeout propios del ladder | Depende de `CachedNetworkImage` / cache manager |
| SVG Commons | Excluidos del rewrite |
| Doc de producto largo | Resumen en `aplicacion-actual.md`; detalle **aquí** |

---

## 11. Checklist al tocar esta zona

1. ¿Cambió el ladder o anchos? → actualizar tests en `wikimedia_display_url_test.dart` + este doc.
2. ¿Cambió `cacheKey` / UA / store key? → prefetch y `AppNetworkImage` deben seguir alineados; valorar bump de `images_vN`.
3. ¿Comportamiento visible (fade, placeholders, hosts)? → `aplicacion-actual.md` / invariantes en el mismo pase.
4. No inventar thumbs en servidor sin diseño backend explícito.
