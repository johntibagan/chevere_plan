# Setup 02 — Supabase (guía para principiantes)

Fecha: 2026-08-08  
Package Android: `com.chevere.plan`

**Regla:** no pegues en el chat ni en git tus keys reales. El archivo `frontend/.env` queda solo en tu PC.

---

## Qué ya hiciste tú (estado)

| Paso | Qué es | Estado |
|---|---|---|
| 1 | Proyecto en supabase.com | OK |
| 2 | `frontend/.env` con URL + anon key | OK |
| 3.2 | Google activado en Supabase Auth | OK |
| 4 | Bucket Storage `site-photos` | OK |
| 3.1 | SHA-1 del teléfono/debug | Pendiente (ver abajo; el keystore aún no existía) |
| 3.3 | Código Flutter de login | **No lo haces tú** — lo hace Cursor en Ciclo 0 |
| 5 | Supabase CLI (`npm`) | Opcional; Node se instala aparte |

---

## 3.1 SHA-1 — por qué falló y qué hacer

### Por qué el error

1. El archivo `%USERPROFILE%\.android\debug.keystore` **aún no existe**. Se crea la **primera vez** que compilas la app Android.
2. En PowerShell, a veces pegar la ruta con `$env:USERPROFILE` dentro de comillas raras rompe el path.

### SHA-1 de debug (ya generado en esta máquina)

```
26:39:0F:7D:ED:18:CA:58:A2:74:C6:ED:90:47:9B:30:3E:72:FB:4E
```

Úsalo en Google Cloud Console → Credentials → cliente OAuth **Android**:

- Package name: `com.chevere.plan`
- SHA-1: el de arriba

Comando por si lo necesitas otra vez:

```powershell
keytool -list -v -keystore "C:\Users\jonhf\.android\debug.keystore" -alias androiddebugkey -storepass android -keypass android
```

**Mientras no tengas SHA-1 en Google Cloud:** el login con Google en el teléfono/emulador puede fallar. Puedes seguir con Firebase.

---

## 3.3 Flutter — aclaración

Ese apartado del doc anterior **no es una tarea tuya en la consola**. Significa:

> Cuando Cursor programe el Ciclo 0, usará los paquetes `supabase_flutter` y `google_sign_in` para el botón “Entrar con Google”.

Tú solo necesitas: proyecto Supabase + Google provider + `.env` + (luego) SHA-1.

---

## 5. CLI de Supabase — opcional

Sirve para migraciones SQL desde la carpeta `backend/`. **No bloquea** el Ciclo 0 si usas el dashboard web.

Requisitos:

1. Tener Node.js instalado (`node -v` y `npm -v` deben responder).
2. Luego:

```powershell
npm install -g supabase
```

Si `npm` no existe, primero instalar Node LTS (winget / https://nodejs.org). Cursor puede instalarlo por ti.

---

## Checklist mínimo para Ciclo 0 (código)

- [x] Proyecto Supabase
- [x] `frontend/.env` con `SUPABASE_URL` y `SUPABASE_ANON_KEY`
- [ ] **`GOOGLE_WEB_CLIENT_ID` en `frontend/.env`** ← Client ID del OAuth **Web** (Google Cloud → Credentials). Sin esto el login falla.
- [x] Provider Google en Supabase
- [x] Bucket `site-photos`
- [ ] SHA-1 en cliente OAuth Android (ver valor en este doc)
- [x] Firebase + `google-services.json` en `frontend/android/app/`
