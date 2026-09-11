# Investigaciones técnicas

Hallazgos cortos para no re-investigar. Regla: `.cursor/rules/investigar-antes-de-implementar.mdc`.

## 2026-09-07 — Fase 2 share: revoke / plans.status / plan_stops autor

**Pregunta:** ¿Soft-revoke con historial? ¿Ya hay Abierto/Cerrado en `plans`? ¿Autor de parada en `plan_stops`?

**Fuentes:** TEST `information_schema` (`plans`, `plan_stops`) + enum `plan_status`; baseline `20260808000001_schema.sql`; [RLS oficial](https://supabase.com/docs/guides/database/postgres/row-level-security) (UPDATE `using`/`with check`, SELECT requerido en UPDATE, membresía + `SECURITY DEFINER`).

**Conclusión:**
- No hay `revoked_at` ni tablas share hoy. Viable: `site_shares` / `plan_shares` con `revoked_at` (no borrar fila); SELECT del ex-invitado a filas revocadas propias para “Ya no disponible”; políticas de acceso activo = `revoked_at is null`.
- `plans.status` = `draft|active|done` — **no** es Abierto/Cerrado. Hace falta columna nueva (`collaboration_status` u equiv.).
- `plan_stops` sin autor → agregar `added_by` (backfill = dueño del plan).

Detalle de diseño temporal: `docs/_tmp/fase-2-compartir-pasos.md` (gitignored).

## 2026-09-06 — Abreviatura de día de la semana (es)

**Pregunta:** ¿Hay forma nativa de `L`/`M`/… antes de la fecha de plan, sin mapa custom?

**Fuentes:** `package:intl` DateFormat / DateSymbols; CLDR narrow weekdays; [SO one-letter weekdays](https://stackoverflow.com/questions/72090572/how-to-get-localized-one-letter-weekday-abbreviations-in-dart).

**Conclusión:** Usar `DateFormat.EEEE('es').dateSymbols.NARROWWEEKDAYS` → en `es` es **`D L M X J V S`** (miércoles = **X**, no `MI`). Índice 0 = domingo; con `DateTime.weekday` (lun=1…dom=7) usar `narrow[weekday % 7]`. Alternativa de patrón: `DateFormat('EEEEE'/'ccccc', 'es')`. Un `switch` `L/M/MI/...` reinventa CLDR; solo si producto lo pide explícito tras preguntar.

**Código:** `weekdayNarrow` en `frontend/lib/core/formatters/date_format.dart`.
