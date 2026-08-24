# Figma Make — snapshot local

Fuente viva: [Guardados app diseño](https://www.figma.com/make/HhANLxoeQuTr5YJZnTAfG7/Guardados-app-dise%C3%B1o)  
`fileKey`: `HhANLxoeQuTr5YJZnTAfG7` (Figma **Make**, no `/design/`).

Este folder es una **copia de trabajo** para alinear Flutter sin reconsultar Figma en cada pase. Si el Make cambia, volver a bajar `App.tsx` y tokens.

## Qué hay aquí

| Archivo | Qué es |
|---|---|
| [`src/app/App.tsx`](src/app/App.tsx) | Prototipo completo (pantallas, tokens `C`, navegación) |
| [`src/styles/theme.css`](src/styles/theme.css) | Tokens CSS del Make |
| [`CICLOS.md`](CICLOS.md) | Orden de réplica en la app |

No copiamos el kit shadcn del Make. Flutter ya tiene tema y widgets.

## Tokens (Make → Flutter)

| Token Make | Hex | `AppColors` |
|---|---|---|
| bg | `#0B0D15` | `background` |
| surface | `#141A24` | `surface` |
| surfaceEl | `#1C2333` | `surfaceElevated` |
| sidebar | `#0E1120` | `sidebar` |
| fg | `#F0F4FF` | `foreground` |
| muted | `#8E93AC` | `muted` |
| mutedDk | `#5A607A` | `mutedDark` |
| primary | `#FFBB33` | `primary` |
| soft | `#FF8C42` | `primarySoft` |
| accent | `#FF5252` | `accent` |
| success (público) | `#00D68F` | `success` |
| purple (privado) | `#8B7FFF` | `purple` |
| border | blanco 6% | `border` |

Tipos: títulos **Plus Jakarta Sans ExtraBold**; cuerpo **DM Sans**.

## Pantallas en `App.tsx`

Login · Inicio · Explorar · Planes · Rutas · Guardar sitio · Categorías · Ficha sitio · Crear plan · Armar paradas · Detalle plan · Admin · Reportes · En construcción.

Barra: Inicio · Explorar · **FAB +** · Planes · Rutas.

## Cómo se usa en Cursor

1. Leer `App.tsx` de la pantalla del ciclo (buscar `InicioTab`, `ExplorarTab`, etc.).
2. Adaptar a Flutter (tokens y widgets del proyecto). No pegar React.
3. No inventar flujos (IA, tab Admin, lista de favoritos).
