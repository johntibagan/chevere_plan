# Setup 03 — Firebase FCM (guía paso a paso, desde cero)

Package Android: **`com.chevere.plan`**  
Objetivo: solo notificaciones push. Auth y datos siguen en Supabase.

Haz **una fila a la vez**. Cuando termines cada bloque, márcalo mentalmente OK.

---

## Bloque A — Crear el proyecto Firebase (5 minutos)

1. Abre el navegador en: https://console.firebase.google.com/
2. Inicia sesión con la **misma cuenta Google** que usas en Google Cloud / OAuth.
3. Pulsa **Agregar proyecto** / **Add project**.
4. Nombre del proyecto: `chevere-plan`
5. Si te pregunta por Google Analytics:
   - Para el MVP puedes elegir **No habilitar** (más simple).
6. Pulsa **Crear proyecto** y espera a que termine.
7. Pulsa **Continuar**.

**Listo el Bloque A cuando** veas el panel principal del proyecto (iconos: Build, etc.).

---

## Bloque B — Registrar la app Android (5 minutos)

1. En la página de inicio del proyecto, pulsa el icono **Android** (o “Add app” → Android).
2. Rellena **exactamente**:
   - **Android package name:** `com.chevere.plan`  
     (tiene que ser idéntico; sin mayúsculas, sin espacios)
   - **App nickname (opcional):** `Chevere Plan`
   - **Debug signing certificate SHA-1:** déjalo vacío **por ahora** (lo añadimos cuando exista el keystore).
3. Pulsa **Registrar app**.
4. En la siguiente pantalla verás **Descargar google-services.json**.
5. Pulsa **Descargar google-services.json** y guárdalo donde lo encuentres fácil (Descargas).
6. Puedes pulsar **Siguiente** / **Continuar en la consola** en los pasos de “añadir SDK”; Cursor ya lo cableará en el código.

**Listo el Bloque B cuando** tengas el archivo `google-services.json` en tu PC.

---

## Bloque C — Dónde poner el archivo (1 minuto)

Cuando exista la carpeta del proyecto Flutter (Cursor la crea), el archivo debe quedar aquí:

```
C:\workspace\chevere_plan\frontend\android\app\google-services.json
```

Cómo copiarlo en PowerShell (ajusta la ruta de Descargas si hace falta):

```powershell
Copy-Item "$env:USERPROFILE\Downloads\google-services.json" "C:\workspace\chevere_plan\frontend\android\app\google-services.json"
```

**Listo el Bloque C cuando** ese path exista (puedes comprobar con `Test-Path` en PowerShell).

---

## Bloque D — Qué NO tienes que hacer todavía

- No instales “FlutterFire CLI” a mano.
- No copies código de Firebase a `main.dart`.
- No configures Geofencing (eso es Ciclo 4).

Eso lo hace Cursor en el Ciclo 0 cuando confirmes que ya tienes el `google-services.json` en su sitio.

---

## Checklist

- [ ] Bloque A: proyecto Firebase `chevere-plan` creado
- [ ] Bloque B: app Android `com.chevere.plan` registrada
- [ ] Archivo `google-services.json` descargado
- [ ] Bloque C: archivo copiado a `frontend\android\app\`

Cuando A+B+C estén listos, escribe en el chat: **“Firebase listo”**.
