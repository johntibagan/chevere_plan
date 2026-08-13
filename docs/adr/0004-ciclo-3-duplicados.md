# ADR 0004 — Anti-duplicados, atribución y reseñas

## Contexto

Especificación §5 y §8.1. Objetivo de producto: **no tener sitios públicos duplicados**.

## Decisiones

1. **Radio de duplicado:** 100 m (`ST_DWithin` sobre `geography`).
2. **Nombre:** extensión `pg_trgm`; umbral `similarity >= 0.35` (con coords) o `>= 0.45` + ciudad (sin coords).
3. **Si hay match público:** se ofrece vincular al existente (“compartido también por”) con **reseña visible** o **bitácora privada**. En el **Guardar** (chequeo duro) también **“Guardar de todas formas”** (crear sitio propio). En soft-check (Maps / pegar enlace) no se ofrece crear de todas formas.
4. **Chequeo doble:** aviso al detectar datos suficientes (Maps pin + pegar enlace Google) y **reiteración al guardar**.
5. **Reseñas:** tabla `site_reviews` (varias por usuario/sitio, `is_public`) + `site_review_photos` (máx. 3). Promedio solo con reseñas públicas.
6. **Privilegios de ficha:** creador del sitio público y staff editan; descartar = quitar guardado/aporte propio sin borrar el sitio si hay asociaciones de terceros.
7. **Coords:** RPC `set_site_location(site_id, lng, lat)`.

## Historial

- Ciclo 3 inicial permitía “Es uno nuevo”; reemplazado por política de cero duplicados públicos + reseñas.
