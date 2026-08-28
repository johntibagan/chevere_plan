# Inicio rápido

```powershell
cd frontend
copy env\test.env.example env\test.env
```

Rellena `env\test.env` (comentarios `#` → dónde sacar cada valor).

```powershell
flutter run --dart-define-from-file=env/test.env
```
