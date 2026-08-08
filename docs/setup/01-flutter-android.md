# Setup 01 — Flutter + Android (Windows)

Fecha: 2026-08-08  
Ciclo: 0 (prerrequisito)

## Decisiones

| Ítem | Valor |
|---|---|
| Package / applicationId | `com.chevere.plan` |
| Flutter SDK | `C:\src\flutter` (canal `stable`, clone oficial) |
| Plataforma prioritaria | Android |

## Paso 1 — Clonar Flutter

```powershell
New-Item -ItemType Directory -Force -Path "C:\src" | Out-Null
git clone https://github.com/flutter/flutter.git -b stable --depth 1 C:\src\flutter
```

## Paso 2 — Agregar al PATH del usuario

```powershell
$flutterBin = "C:\src\flutter\bin"
$userPath = [Environment]::GetEnvironmentVariable("Path", "User")
if ($userPath -notlike "*$flutterBin*") {
  [Environment]::SetEnvironmentVariable("Path", "$userPath;$flutterBin", "User")
}
```

Abrir una **nueva** terminal para que el PATH cargue.

## Paso 3 — Android Studio

Instalar con winget:

```powershell
winget install --id Google.AndroidStudio -e --accept-package-agreements --accept-source-agreements
```

Luego abrir Android Studio una vez y completar el wizard:

1. Install Standard / Recommended components.
2. Asegurar **Android SDK**, **Android SDK Platform-Tools**, **Android SDK Build-Tools**.
3. En SDK Platforms: al menos **Android 14 (API 34)** o la más reciente estable.
4. Aceptar licencias si `flutter doctor` lo pide.

Licencias desde terminal (tras tener `sdkmanager` en PATH):

```powershell
flutter doctor --android-licenses
```

## Paso 4 — Android SDK (hecho por CLI)

Además de Android Studio (winget), se instaló el SDK en:

`C:\Users\jonhf\AppData\Local\Android\Sdk`

Variables de usuario:

- `ANDROID_HOME` / `ANDROID_SDK_ROOT` → esa ruta
- `flutter config --android-sdk` apuntando ahí

Paquetes: `platform-tools`, `platforms;android-35`, `platforms;android-36`, `build-tools;35.0.0`, `build-tools;36.0.0`, `build-tools;28.0.3`, cmdline-tools.

## Paso 5 — Verificar

```powershell
flutter doctor -v
```

Estado al 2026-08-08:

- [x] Flutter SDK (`C:\src\flutter`, stable 3.44.9 / Dart 3.12.2)
- [x] Android toolchain (SDK 36.0.0)
- [x] Android Studio instalado (`C:\Program Files\Android\Android Studio`)
- [ ] Dispositivo físico o emulador (abrir AVD Manager en Android Studio cuando quieras probar)
- Chrome / Visual Studio: no necesarios para Android MVP

## Notas

- Java OpenJDK 21 (Corretto) ya estaba presente en la máquina.
- No hace falta Visual Studio si solo compilamos Android (escritorio Windows se omite).
- Node.js no es obligatorio para Flutter; sí puede hacer falta más adelante para Supabase CLI (ver doc 02).
- Abrir Android Studio una vez ayuda a instalar el plugin Flutter y crear un AVD; el SDK ya está usable desde terminal.
