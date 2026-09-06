# Producto — visión y fases

**Qué hace la app hoy (implementar / probar):** [`aplicacion-actual.md`](aplicacion-actual.md)  
**Qué no romper:** [`invariantes.md`](invariantes.md)  
**Deuda y diseño Fase 2 (Compartir):** [`pendientes.md`](pendientes.md)

Este archivo es **solo visión de negocio y roadmap**. No es spec de lo implementado: no copies flujos ni pantallas desde aquí.

**Mercado:** Colombia · **Cliente diario:** Android (Flutter; iOS = Fase 4)

---

## 1. Resumen ejecutivo

App que centraliza el **guardado rápido** de lugares descubiertos en redes (IG, TikTok, FB, etc.) y en la vida real, organizados por categoría y ubicación, para:

- Recordarlos por **proximidad** (estilo recuerdos de Google Fotos, pero geolocalizado).
- Armar **planes** / itinerarios (hoy manual; IA = Fase 5).
- Hacer visibles sitios **públicos** a otros (búsqueda / planes), con anti-duplicados.
- A futuro: **compartir** dentro de la app (Fase 2), **monetización** (Fase 3), **expansión** (Fase 4).

**Enfoque:** turismo, gastronomía, planes de ocio y actividades sanas. Uso fuera de eso: Términos + moderación.

---

## 2. Mercado (diferenciales)

Apps similares (Mapstr, Plotline, Stashed, Spots, etc.) suelen guardar el pin y poco más.

**Diferenciales de esta propuesta:**

1. Guardado amplio + **tarjetas** no físicas (uso privado).
2. Planes (hoy manual; IA después).
3. Transporte inteligente (catálogo admin hoy; cálculo en UI = Fase 5).
4. Capa social con anti-duplicados, reseñas y atribución.
5. Compartir interno por @ (Fase 2).
6. Monetización: eventos, fichas de negocio, donaciones (Fase 3).

---

## 3. Fases

### Fase 1 — MVP

**Cerrada en producto vivo.** Detalle: [`aplicacion-actual.md`](aplicacion-actual.md).  
Pulidas / deuda chica: [`pendientes.md`](pendientes.md) (no bloquean el uso diario).

### Fase 2 — Compartir

Diseño cerrado: [`pendientes.md`](pendientes.md) → *Compartir sitios y planes* (**única fuente**).  
Resumen: @ dentro de la app, grupo cerrado en sitios privados, plan Abierto/Cerrado, revocación suave, bandeja in-app. **Aún no construido.**

### Fase 3 — Monetización

- Pagos reales (figura tributaria / facturación DIAN con contador).
- Eventos geolocalizados (alcance municipal → nacional), combos, asistencia verificada.
- Fichas enriquecidas de negocio (verificación, cobro, reportes de precio).
- Pasarelas + donaciones + Bre-B.
- Tarifas de referencia de transporte público por ciudad.

### Fase 4 — Expansión

- iOS como producto publicado.
- Moderación automática (texto, SafeSearch, strikes).
- Paquetes promocionales para negocios.
- Geografía fuera de Colombia (legal por país).
- Push / tiempo real para avisos de compartir (evolución Fase 2).

### Fase 5 — IA y transporte inteligente

Detalle: [`pendientes.md`](pendientes.md) § *Fase 5*.  
“Armame un plan” + sugerencia de medio por tramo en el detalle del plan.

---

## 4. Stack (intención)

| Pieza | Elección |
|---|---|
| Backend / Auth / Storage / DB | Supabase (Postgres + PostGIS + RLS + Storage) |
| App | Flutter (Material 3, Riverpod, i18n `es`) |
| Push / geofence | FCM + geofencing nativo |
| Maps | Places / geocoding + deep link a apps de mapas |
| Beta | GitHub Pages + APK en Storage |

PostGIS y catálogos en DB desde el día uno; plan free de Supabase puede pausarse por inactividad.

---

## Lectura al diseñar features nuevas

1. [`aplicacion-actual.md`](aplicacion-actual.md) — qué hay **hoy**.  
2. [`invariantes.md`](invariantes.md) — privacidad / límites.  
3. [`pendientes.md`](pendientes.md) — si es Compartir u otra deuda ya acordada.  
4. Este archivo — solo si necesitás el **rumbo** de fases.
