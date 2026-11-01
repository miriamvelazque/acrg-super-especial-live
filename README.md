<div align="center">
  <img src="web/assets/logo-acrg.jpg" alt="Automóvil Club Río Grande" width="240">

  # SÚPER ESPECIAL ACRG — Live Timing

  **Cronometraje y seguimiento en vivo del Automóvil Club Río Grande.**

  <p>
    <img src="https://img.shields.io/badge/ACRG-R%C3%ADo%20Grande-6EC7FF?style=for-the-badge" alt="Automóvil Club Río Grande">
    <img src="https://img.shields.io/badge/Frontend-HTML%20%7C%20JavaScript-8a2be2?style=for-the-badge" alt="Frontend HTML y JavaScript">
    <img src="https://img.shields.io/badge/Backend-Supabase-3ecf8e?style=for-the-badge" alt="Backend Supabase">
    <img src="https://img.shields.io/badge/Deploy-Vercel-111111?style=for-the-badge" alt="Despliegue en Vercel">
  </p>

  <a href="web/index.html"><strong>Live Timing</strong></a>
  &nbsp;·&nbsp;
  <a href="web/admin.html"><strong>Panel de cronometristas</strong></a>
</div>

---

Aplicación web del **Automóvil Club Río Grande (ACRG)** para consultar las clasificaciones de la Súper Especial y cargar tiempos desde un panel privado. La web pública muestra los resultados aprobados; el personal autorizado ingresa al panel para cargar y gestionar tiempos.

## Contenido

- [Funciones](#funciones)
- [Tecnologías](#tecnologías)
- [Estructura](#estructura)
- [Configuración de Supabase](#configuración-de-supabase)
- [Ejecución local](#ejecución-local)
- [Despliegue](#despliegue)
- [Operación](#operación)
- [Datos y seguridad](#datos-y-seguridad)

## Funciones

### Live Timing

- Clasificación general acumulada y por categoría.
- Vistas separadas por etapa y podio final por categoría.
- Inscripciones con número, piloto, navegante, piloto invitado, vehículo, categoría y peña.
- Banderas según nacionalidad del piloto y del navegante; si no se especifica, se muestra Argentina.
- Actualización en vivo de resultados validados, con consulta periódica de respaldo si Realtime se desconecta.
- Descarga en PDF de las vistas de clasificación.
- Espacios reservados para sponsors y enlaces a información legal.

### Panel de cronometristas

- Ingreso del personal por usuario y contraseña.
- Carga de largada, llegada, penalización y estado DNF/abandono.
- Cola compartida de tiempos, validación y reapertura según el rol.
- Cola local de respaldo cuando no hay conexión; los tiempos pendientes se envían al recuperar internet.
- Los usuarios con rol de comisario o administrador publican al guardar, porque `AUTO_VALIDAR` está activado en `web/admin.html`. El rol de cronometrista deja los tiempos pendientes para validación.

## Tecnologías

- **Interfaz:** HTML, Tailwind CSS y JavaScript con módulos ES.
- **Datos, autenticación y tiempo real:** Supabase (PostgreSQL, Auth y Realtime).
- **Hosting:** Vercel.

Es un sitio estático, sin paso de compilación ni dependencias locales de Node. Tailwind, Supabase JS y las fuentes se cargan desde CDN.

## Estructura

```text
.
├── base_de_datos_sql/
│   ├── 00_reset_proyecto_nuevo.sql
│   ├── 01_schema.sql
│   ├── 02_rls_auth.sql
│   ├── 07_nueva_carrera_plantilla.sql
│   ├── 08_login_por_usuario.sql
│   ├── 09_nacionalidad_y_vehiculo.sql
│   ├── 10_trazabilidad.sql
│   ├── 11_evento_super_especial_acrg.sql
│   ├── 12_inscriptos_super_especial_acrg.sql
│   ├── 13_limpiar_pruebas_acrg.sql
│   ├── 14_usuarios_acrg.sql
│   ├── 15_piloto_invitado.sql
│   └── 16_tiempos_etapa1_acrg.sql
├── web/
│   ├── index.html
│   ├── admin.html
│   ├── legal.html
│   ├── 03_public-live-timing.js
│   ├── 04_admin-client.js
│   ├── ranking.js
│   ├── footer.js
│   └── assets/
│       ├── logo-acrg.jpg
│       └── brands/
├── vercel.json
└── README.md
```

El logo oficial utilizado por la aplicación está en `web/assets/logo-acrg.jpg`. Los logos de fabricantes se guardan en `web/assets/brands/`; el nombre del archivo corresponde a la primera palabra del modelo (por ejemplo, `Ford Fiesta` usa `ford.png`). Si no existe un logo de fabricante, el modelo se muestra igualmente.

## Configuración de Supabase

En un proyecto Supabase nuevo, abre **SQL Editor** y ejecuta:

1. `01_schema.sql`: crea tablas, tipos, funciones y triggers.
2. `02_rls_auth.sql`: configura RLS, roles y las tablas de Realtime.
3. `08_login_por_usuario.sql`: habilita el inicio de sesión con el nombre guardado en `staff_roles.display_name`.
4. `09_nacionalidad_y_vehiculo.sql`: agrega nacionalidades de piloto y navegante.
5. `10_trazabilidad.sql`: agrega metadatos de validación y el historial de cambios.
6. `11_evento_super_especial_acrg.sql`: crea y activa el evento actual, con sus etapas y pruebas especiales.
7. `15_piloto_invitado.sql`: agrega el campo de piloto invitado; debe ejecutarse antes de cargar inscriptos.
8. `12_inscriptos_super_especial_acrg.sql`: carga las tripulaciones de este evento.

Para habilitar el panel:

1. Crea las cuentas en **Supabase → Authentication → Users**.
2. Edita `14_usuarios_acrg.sql` con los correos y nombres de usuario que correspondan y ejecútalo para asignar roles. No lo ejecutes sin revisar esos valores.
3. El usuario escribe en el panel el `display_name` asignado. El inicio de sesión por nombre requiere `08_login_por_usuario.sql`; también se aceptan correos.

`16_tiempos_etapa1_acrg.sql` carga los tiempos publicados de las PE1 a PE3 de este evento. Ejecútalo solo si quieres importar esos resultados oficiales; al ejecutarlo inserta o actualiza las entradas correspondientes y las publica como validadas.

### Precauciones con los scripts

- **No ejecutes `00_reset_proyecto_nuevo.sql` sobre una base con datos que quieras conservar.** Borra todas las tablas, funciones y tipos del esquema `public`. Está destinado únicamente a preparar el proyecto nuevo del ACRG.
- `13_limpiar_pruebas_acrg.sql` elimina los tiempos y el historial de prueba de las PE4 en adelante del evento indicado. Revisa que sea el momento adecuado antes de ejecutarlo.
- `07_nueva_carrera_plantilla.sql` es una plantilla para preparar otra carrera; edita sus datos antes de usarla.

El cliente Supabase está configurado en `web/03_public-live-timing.js`. Para conectar otro proyecto, cambia allí `SUPABASE_URL` y `SUPABASE_ANON_KEY` por los valores de Supabase. La clave publicable puede usarse en el navegador; nunca expongas una clave `service_role`. La protección de los datos depende de las políticas RLS.

## Ejecución local

Desde la raíz del proyecto, inicia un servidor HTTP estático que sirva `web/`, por ejemplo:

```bash
python -m http.server 8000 --directory web
```

Luego abre `http://localhost:8000`. No abras `index.html` directamente con `file://`, porque la aplicación utiliza módulos JavaScript.

## Despliegue

En Vercel, configura el repositorio como raíz del proyecto, selecciona el framework **Other**, deja vacío el comando de build y establece `web` como directorio de salida. `vercel.json` contiene la opción `cleanUrls`.

## Operación

- **Público y prensa:** consulta las clasificaciones desde [Live Timing](web/index.html). Solo se publican resultados validados; las horas originales de largada y llegada no se exponen.
- **Cronometristas:** ingresa al [panel](web/admin.html), selecciona la PE y el auto, y carga los tiempos. Si no hay conexión, las entradas quedan en la cola local del dispositivo.
- **Comisarios y administradores:** revisa la cola, valida o reabre los tiempos. Al reabrir uno, deja de aparecer en la clasificación pública hasta que vuelva a validarse.

## Datos y seguridad

- `time_entries` almacena las horas originales y los datos de operación; los tiempos se representan en centésimas.
- El resultado neto se calcula como `llegada - largada + penalización`. Los DNF no suman tiempo ni participan del ordenamiento.
- `results` contiene los resultados publicados. Un trigger los actualiza al validar un tiempo y los retira al reabrirlo.
- Las políticas RLS separan la lectura pública del catálogo y los resultados del acceso del personal a las cargas y funciones operativas.
- Los roles son `timekeeper`, `commissioner` y `admin`.
- `time_entries_log` registra cargas, correcciones, validaciones, reaperturas y borrados desde que se instala `10_trazabilidad.sql`. La vista `v_historial_tiempos` facilita consultar ese historial; solo comisarios y administradores pueden leerlo.
