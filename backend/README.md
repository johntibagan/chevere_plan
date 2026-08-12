# Backend Supabase

Reset: borra datos, remigra, carga DIVIPOLA, deja `johnftmovil@gmail.com` como root.

```powershell
powershell -File C:\workspace\chevere_plan\backend\reset_all.ps1
```

Requisito: `backend/.env` con `SUPABASE_DB_URL`.

En Windows (sin IPv6) usa la URI **Session pooler** del dashboard (no la directa `db.…:5432`).
