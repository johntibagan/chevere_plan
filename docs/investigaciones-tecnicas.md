# Investigaciones técnicas

Hallazgos cortos para no re-investigar. Regla: `.cursor/rules/investigar-antes-de-implementar.mdc`.

## 2026-09-06 — Abreviatura de día de la semana (es)

**Pregunta:** ¿Hay forma nativa de `L`/`M`/… antes de la fecha de plan, sin mapa custom?

**Fuentes:** `package:intl` DateFormat / DateSymbols; CLDR narrow weekdays; [SO one-letter weekdays](https://stackoverflow.com/questions/72090572/how-to-get-localized-one-letter-weekday-abbreviations-in-dart).

**Conclusión:** Usar `DateFormat.EEEE('es').dateSymbols.NARROWWEEKDAYS` → en `es` es **`D L M X J V S`** (miércoles = **X**, no `MI`). Índice 0 = domingo; con `DateTime.weekday` (lun=1…dom=7) usar `narrow[weekday % 7]`. Alternativa de patrón: `DateFormat('EEEEE'/'ccccc', 'es')`. Un `switch` `L/M/MI/...` reinventa CLDR; solo si producto lo pide explícito tras preguntar.

**Código:** `weekdayNarrow` en `frontend/lib/core/formatters/date_format.dart`.
