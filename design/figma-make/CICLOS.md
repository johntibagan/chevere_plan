# Ciclos Figma → app

Un ciclo = **una pantalla o tab**. No mezclar.

| # | Ciclo | En Make (`App.tsx`) | En Flutter |
|---|---|---|---|
| 1 | **Inicio** (hecho) | `InicioTab` | `home_page.dart` + `home_cards.dart` |
| 2 | **Explorar** (hecho) | `ExplorarTab` | `search_page.dart` |
| 3 | **Planes lista** (hecho) | `PlanesTab` | `plans_list_page.dart` |
| 4 | Rutas | `RutasTab` | `my_routes_page.dart` |
| 5 | Login | `LoginPage` | login |
| 6 | Guardar sitio | `SavePlacePage` | `save_place_page.dart` |
| 7 | Categorías | `CategoryPickerPage` | selector de categorías |
| 8 | Ficha de sitio | `SiteDetailPage` | `site_detail_page.dart` |
| 9 | Crear plan | `CreatePlanPage` | crear plan |
| 10 | Armar paradas | `PlanBuilderPage` | builder de plan |
| 11 | Detalle plan | `PlanDetailPage` | `plan_detail_page.dart` |
| 12 | Admin / reportes | `AdminPage` / `AdminReportsPage` | admin |
| 13 | En construcción | `EnConstruccion` | placeholder único |

Prioridad visual del Make: ficha de sitio y armar plan; luego login; admin al final.

**Ahora:** ciclos 1–3 (Inicio, Explorar, Planes lista) aplicados en Flutter. Siguiente = **ciclo 4 Rutas**.
