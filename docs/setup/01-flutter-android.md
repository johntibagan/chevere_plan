# Flutter + Android (Windows)

Package: `com.chevere.plan`. SDK esperado: `C:\src\flutter` (stable).

## Una vez

1. Clonar Flutter:

```powershell
New-Item -ItemType Directory -Force -Path "C:\src" | Out-Null
git clone https://github.com/flutter/flutter.git -b stable --depth 1 C:\src\flutter
```

2. Añadir `C:\src\flutter\bin` al PATH de usuario y abrir una terminal nueva.

3. Android Studio + SDK (API 34+). Licencias:

```powershell
flutter doctor --android-licenses
flutter doctor -v
```

4. Dispositivo USB o emulador.

## Correr la app

```powershell
cd C:\workspace\chevere_plan\frontend
copy .env.example .env   # si aún no existe; rellena valores
.\tool\run_dev.ps1
```

Release:

```powershell
flutter build apk --release --obfuscate --split-debug-info=build/symbols --dart-define-from-file=.env
```
