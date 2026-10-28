<div align="center">
  <img src="web/assets/logo-rally-fueguino.png" alt="Rally Fueguino A.PI.TU.R." width="320">

  # Rally Fueguino Live Timing

  **Cronometraje, clasificación y seguimiento en vivo para el rally fueguino.**

  <p>
    <img src="https://img.shields.io/badge/A.PI.TU.R.-Tierra%20del%20Fuego-00bfb5?style=for-the-badge" alt="A.PI.TU.R. — Tierra del Fuego">
    <img src="https://img.shields.io/badge/Frontend-HTML%20%7C%20JavaScript-8a2be2?style=for-the-badge" alt="Frontend HTML y JavaScript">
    <img src="https://img.shields.io/badge/Backend-Supabase-3ecf8e?style=for-the-badge" alt="Backend Supabase">
    <img src="https://img.shields.io/badge/Deploy-Vercel-111111?style=for-the-badge" alt="Despliegue en Vercel">
  </p>

  <a href="web/index.html"><strong>Live Timing</strong></a>
  &nbsp;·&nbsp;
  <a href="web/admin.html"><strong>Panel operativo</strong></a>
</div>

---

Plataforma web de A.PI.TU.R. para cargar, validar y publicar los tiempos de cada prueba especial. Combina un panel de operación para el personal autorizado con una vista pública en vivo y clasificaciones.

## Contenido

- [Experiencia y funcionalidades](#experiencia-y-funcionalidades)
- [Tecnologías](#tecnologías)
- [Estructura del proyecto](#estructura-del-proyecto)
- [Puesta en marcha](#puesta-en-marcha)
- [Operación](#operación)
- [Seguridad y datos](#seguridad-y-datos)
- [Sponsors](#sponsors)

## Experiencia y funcionalidades

| Live Timing | Panel operativo |
| --- | --- |
| Clasificación general, por categoría y por etapa; inscriptos y resultados validados en tiempo real. | Carga de tiempos y penalizaciones, gestión de DNF, cola compartida y validación por rol. |

También incluye:

- Tiempos almacenados en centésimas y cálculo neto automático.
- Publicación controlada: un resultado aparece en el sitio público después de ser validado.
- Nacionalidad de piloto y navegante, con banderas en la vista de inscriptos.
- Marca y modelo del vehículo en la clasificación.
- Historial de cargas, correcciones, validaciones, reaperturas y borrados.
- Login del personal por nombre de usuario; los usuarios existentes también pueden ingresar con email.
- Configuración centralizada de marcas y espacios de sponsors.

## Tecnologías

- **Interfaz:** HTML, Tailwind CSS y JavaScript ES Modules.
- **Datos, autenticación y tiempo real:** Supabase (PostgreSQL, Auth y Realtime).
- **Hosting:** Vercel.
La aplicación es estática y carga sus dependencias de interfaz desde CDN; no requiere un paso de compilación.

## Estructura del proyecto

```text
.
├── base_de_datos_sql/
│   ├── 01_schema.sql
│   ├── 02_rls_auth.sql
│   ├── 05_ensayo_seed.sql
│   ├── 06_ensayo_cleanup.sql
│   ├── 07_nueva_carrera_plantilla.sql
│   ├── 08_login_por_usuario.sql
│   ├── 09_nacionalidad_y_vehiculo.sql
│   └── 10_trazabilidad.sql
├── web/
│   ├── index.html
│   ├── admin.html
│   ├── legal.html
│   ├── 03_public-live-timing.js
│   ├── 04_admin-client.js
│   ├── ranking.js
│   ├── sponsors.js
│   └── assets/
├── vercel.json
└── README.md
```

## Puesta en marcha

### 1. Preparar Supabase

En un proyecto Supabase, abre **SQL Editor** y ejecuta los scripts en este orden:

1. `01_schema.sql` — crea el esquema, los roles, los triggers y el evento inicial.
2. `02_rls_auth.sql` — habilita RLS, define permisos y agrega las tablas a Realtime.
3. `08_login_por_usuario.sql` — habilita el acceso por nombre de usuario.
4. `09_nacionalidad_y_vehiculo.sql` — añade la nacionalidad de piloto y navegante.
5. `10_trazabilidad.sql` — registra quién validó un tiempo y mantiene el historial de cambios.

Los scripts `08`, `09` y `10` son migraciones adicionales: ejecútalos después de `01` y `02`. El primero requiere que `staff_roles` ya tenga nombres de usuario (`display_name`) asignados.

Para habilitar el acceso del personal:

1. Crea cada usuario en **Supabase → Authentication → Users**.
2. Asigna su rol en `staff_roles`. El comentario final de `02_rls_auth.sql` incluye el ejemplo para crear el primer administrador.
3. Para usar login por nombre, completa `display_name` con el nombre que ingresará en el panel.
4. Carga las etapas, pruebas especiales y tripulaciones del evento. `07_nueva_carrera_plantilla.sql` sirve como plantilla editable para una nueva carrera.
5. Asegúrate de que haya un solo evento con `is_live = true`.

### 2. Configurar el cliente

El cliente Supabase se inicializa en `web/03_public-live-timing.js`. Si vas a conectar otro proyecto, actualiza allí `SUPABASE_URL` y `SUPABASE_ANON_KEY` con los valores de **Project URL** y la clave publicable de Supabase.

La clave publicable puede estar en el código del navegador; **nunca** pongas una clave `service_role` en la web. La seguridad de los datos depende de mantener correctamente configuradas las políticas RLS.

### 3. Probar localmente

Sirve la carpeta `web/` con un servidor HTTP local y abre `index.html`. Como la aplicación usa módulos JavaScript, no la abras directamente como archivo `file://`.

### 4. Desplegar en Vercel

1. Importa el repositorio en Vercel.
2. Configura **Root Directory** como `web`.
3. Despliega como sitio estático, sin comando de build.

La configuración de URLs limpias está en `vercel.json`.

## Operación

### Cronometristas

Entra al [panel operativo](web/admin.html), selecciona evento y PE, indica el auto y carga largada, llegada y penalización cuando corresponda. La interfaz admite DNF/abandono. Los tiempos se guardan como pendientes de validación.

### Comisarios

Revisa la cola de carga y valida las entradas aprobadas. Si una entrada necesita corrección, puede reabrirla; al hacerlo, deja de publicarse hasta una nueva validación.

### Público y prensa

Consulta el [Live Timing](web/index.html) para las clasificaciones. Solo se exponen resultados validados; las horas originales de largada y llegada permanecen privadas.

## Seguridad y datos

- Los tiempos originales se guardan en `time_entries`; los resultados públicos se publican en `results` mediante triggers.
- RLS separa el acceso público al catálogo y los resultados del acceso autenticado a los tiempos y funciones operativas.
- Los roles disponibles son `timekeeper`, `commissioner` y `admin`.
- `time_entries_log` conserva las acciones y sus valores anteriores y nuevos. La vista `v_historial_tiempos` facilita consultar el historial; solo comisarios y administradores pueden leerlo.
- Las horas y los resultados se guardan en centésimas. El cálculo es `llegada - largada + penalización`. Un DNF no suma tiempo ni participa del ordenamiento.

## Sponsors

Edita `web/sponsors.js` para agregar o modificar marcas. Guarda sus logos en `web/assets/sponsors/` y actualiza las listas `top` o `bottom`, incluyendo nombre, archivo y, opcionalmente, URL.

## Scripts de ensayo

- `05_ensayo_seed.sql` crea un evento de prueba, carga datos de ejemplo y cambia cuál evento está en vivo.
- `06_ensayo_cleanup.sql` elimina eventos cuyo nombre comienza con `ENSAYO`.

Úsalos solo cuando corresponda y revisa sus efectos antes de ejecutarlos en una base con datos reales.
