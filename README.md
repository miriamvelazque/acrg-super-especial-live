# Rally Fueguino Live Timing — A.PI.TU.R.

Sistema de cronometraje y transmisión de tiempos en vivo para las competencias de rally de A.PI.TU.R. (Tierra del Fuego). Diseñado para una carga ultrarrápida en campo y una visualización pública de alto rendimiento.

## 🚀 Arquitectura y Tecnologías
- **Frontend:** HTML5, Tailwind CSS, JavaScript (ES Modules). Desplegado en **Vercel**.
- **Backend & Base de Datos:** **Supabase** (PostgreSQL).
- **Seguridad & Roles:** Row Level Security (RLS) habilitado. Autenticación con JWT para tres roles (`timekeeper`, `commissioner`, `admin`).
- **Sincronización:** Supabase Realtime (WebSockets) para actualización instantánea sin refresco de página.

## 📁 Estructura del Proyecto

```text
rally-fueguino-live/
├── web/                        # Aplicación web pública y panel admin
│   ├── index.html              # Dashboard público de tiempos y posiciones
│   ├── admin.html              # Panel de carga para cronometristas y comisarios
│   ├── 03_public-live-timing.js# Cliente público Supabase
│   └── 04_admin-client.js      # Lógica de autenticación, máscaras y carga
├── base_de_datos_sql/          # Scripts de estructura y mantenimiento
│   ├── 01_schema.sql           # Tablas, relaciones y triggers
│   ├── 02_rls_auth.sql         # Políticas de seguridad (RLS) y roles
│   ├── 05_ensayo_seed.sql      # Datos de prueba/ensayo
│   ├── 06_ensayo_cleanup.sql   # Limpieza de datos de prueba
│   └── 07_nueva_carrera_plantilla.sql # Plantilla para nuevas fechas
└── README.md

## 🛠️ Configuración y Despliegue

### 1. Base de Datos (Supabase)
Ejecutar los scripts de la carpeta `base_de_datos_sql/` en el SQL Editor de Supabase en orden numérico:
1. `01_schema.sql`
2. `02_rls_auth.sql`

### 2. Frontend (Vercel)
- Conectar el repositorio o subir la carpeta `web/`.
- Configurar el **Root Directory** en Vercel como `web`.
- No requiere secretos de backend expuestos (`sb_publishable` es

## 🔒 Flujo de Trabajo y Seguridad
1. **Cronometrista (`timekeeper`):** Carga hora de largada, llegada o DNF.
2. **Validación:** Los tiempos quedan en estado no validado hasta que un **Comisario (`commissioner`)** aprueba la entrada.
3. **Publicación:** Un trigger en PostgreSQL publica el tiempo calculated en `results` y notifica vía WebSocket al dashboard público.