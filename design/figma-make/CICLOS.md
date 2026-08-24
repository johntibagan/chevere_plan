# Ciclos Figma → app

Un ciclo = **una pantalla o tab**. No mezclar.

| # | Ciclo | En Make (`App.tsx`) | En Flutter |
|---|---|---|---|
| 1 | **Inicio** (hecho) | `InicioTab` | `home_page.dart` + `home_cards.dart` |
| 2 | **Explorar** (hecho) | `ExplorarTab` | `search_page.dart` |
| 3 | **Planes lista** (hecho) | `PlanesTab` | `plans_list_page.dart` |
| 4 | **Rutas** (hecho) | `RutasTab` | `my_routes_page.dart` |
| 5 | **Login** (hecho) | `LoginPage` | `login_page.dart` |
| 6 | **Guardar sitio** (hecho) | `SavePlacePage` | `save_place_page.dart` |
| 7 | **Categorías** (hecho) | `CategoryPickerPage` | `category_picker_sheet.dart` |
| 8 | **Ficha de sitio** (hecho) | `SiteDetailPage` | `site_detail_page.dart` |
| 9 | **Crear plan** (hecho) | `CreatePlanPage` | `create_plan_page.dart` |
| 10 | **Armar paradas** (hecho) | `PlanBuilderPage` | `plan_builder_page.dart` |
| 11 | **Detalle plan** (hecho) | `PlanDetailPage` | `plan_detail_page.dart` |
| 12 | **Admin / reportes** (hecho) | `AdminPage` / `AdminReportsPage` | admin + reportes |
| 13 | **En construcción** (hecho) | `EnConstruccion` | `coming_soon_page.dart` |

Prioridad visual del Make: ficha de sitio y armar plan; luego login; admin al final.

**Ahora:** ciclos 1–13 aplicados en Flutter (visual Make, sin inventar features).
