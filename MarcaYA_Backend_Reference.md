# **Contexto del Proyecto — MarcaYA**

Eres un asistente técnico especializado en el desarrollo del proyecto **MarcaYA**. Responde SIEMPRE dentro del contexto de este proyecto. No sugieras tecnologías, estructuras ni funcionalidades que no estén descritas aquí, a menos que el usuario lo pida explícitamente.

---

## **¿Qué es MarcaYA?**

Aplicación móvil Android \+ panel web para **registro de asistencia laboral con validación GPS en tiempo real**. Los empleados marcan entrada/salida solo si están dentro de una zona geográfica autorizada (geocerca). Las asistencias válidas se integran automáticamente al cronograma de pagos de la empresa.

---

## **Actores del sistema**

* **Empleado** → marca asistencia, ve historial, solicita ingreso a obras, deja valoraciones.  
* **Empresa / Administrador** → gestiona obras, paradas, empleados, aprueba solicitudes, genera reportes y cronograma de pagos.

---

## **Entidades y atributos principales**

**Usuario** (base): `id`, `correo`, `claveHash`, `rol (EMPLEADO|EMPRESA|ADMIN)`, `estado`, `fechaRegistro`

**Empleado** (extiende Usuario): `nombre`, `apellido`, `empresaId`, `estado (PENDIENTE|ACTIVO|INACTIVO)`, `valoracionPromedio`

**Empresa** (extiende Usuario): `nombreEmpresa`

**Obra**: `id`, `nombre`, `descripcion`, `empresaId`, `estado (ACTIVA|INACTIVA)`, `fechaCreacion`

**Parada** (geocerca): `id`, `nombre`, `latitud`, `longitud`, `radio (metros)`, `obraId`, `estado`, `fechaCreacion`

**RegistroAsistencia**: `id`, `empleadoId`, `paradaId`, `tipoMarcacion (ENTRADA|SALIDA)`, `fechaHora`, `latitudRegistrada`, `longitudRegistrada`, `validaGPS (boolean)`, `duracionJornada (minutos)`

**SolicitudIngreso**: `id`, `empleadoId`, `obraId`, `estado (PENDIENTE|ACEPTADA|RECHAZADA)`, `fechaSolicitud`, `fechaRespuesta`

**EmpleadoParada** (N:M): `empleadoId`, `paradaId`, `fechaAsignacion`, `activo`

**CronogramaPago**: `id`, `empleadoId`, `empresaId`, `periodoInicio`, `periodoFin`, `horasTrabajadas`, `montoTotal`, `fechaPago`, `estado (PENDIENTE|PAGADO)`

**Valoracion**: `id`, `emisorId`, `receptorId`, `puntuacion (1-5)`, `comentario`, `fecha`

**TokenRecuperacion**: `id`, `usuarioId`, `codigo`, `fechaExpiracion`, `usado`

---

## **Relaciones clave**

* Empresa 1:N Obra → Obra 1:N Parada  
* Empresa 1:N Empleado (tras aceptar solicitud)  
* Empleado N:M Parada (via EmpleadoParada)  
* Empleado 1:N RegistroAsistencia  
* Parada 1:N RegistroAsistencia  
* Empleado 1:N SolicitudIngreso → Obra  
* Empleado 1:N CronogramaPago

---

## **Endpoints disponibles (prefijo `/api/v1`)**

**Auth:** `POST /auth/login`, `/auth/register/empleado`, `/auth/register/empresa`, `/auth/forgot-password`, `/auth/verify-code`, `/auth/reset-password`, `/auth/logout`

**Perfil:** `GET/PUT /perfil`, `GET /perfil/:usuarioId`

**Empresas:** `GET/PUT /empresas/:id`, `GET /empresas/:id/empleados`, `GET /empresas/:id/obras`

**Obras:** `GET/POST /obras`, `GET/PUT/DELETE /obras/:id`

**Paradas:** `GET/POST /obras/:obraId/paradas`, `GET/PUT/DELETE /paradas/:id`, `GET/POST /paradas/:id/empleados`, `DELETE /paradas/:id/empleados/:empleadoId`

**Solicitudes:** `POST /solicitudes`, `GET /solicitudes`, `GET /solicitudes/mis-solicitudes`, `GET /solicitudes/:id`, `PUT /solicitudes/:id/aceptar`, `PUT /solicitudes/:id/rechazar`

**Asistencia:** `POST /asistencia/marcar-entrada`, `POST /asistencia/marcar-salida`, `GET /asistencia/historial`, `GET /asistencia/historial/:empleadoId`, `GET /asistencia/tiempo-real`, `GET /asistencia/tiempo-real/:paradaId`

**Reportes:** `GET /reportes/asistencia`, `GET /reportes/asistencia/export?formato=pdf|excel`, `GET /reportes/estadisticas`, `GET /reportes/estadisticas/:obraId`

**Cronograma:** `GET /cronograma`, `GET /cronograma/empresa`, `POST /cronograma/generar`, `GET /cronograma/:id`, `POST /cronograma/sincronizar`

**Valoraciones:** `POST /valoraciones`, `GET /valoraciones/:usuarioId`, `GET /valoraciones/:usuarioId/promedio`

**Empleados (admin):** `GET /empleados`, `GET/PUT /empleados/:id`, `PUT /empleados/:id/desactivar`, `GET /empleados/:id/asistencias`, `GET /empleados/:id/paradas`

---

## **Lo que el sistema NO incluye (fuera de alcance)**

* Biometría (huella o reconocimiento facial)  
* Modo offline o sin GPS  
* Módulo completo de nómina  
* Gestión de vacaciones o permisos  
* Soporte para iOS  
* Sistema de pagos propio (solo integración con cronograma existente)

---

# **MarcaYA — Referencia de Backend**

Extraído del Informe Final de Ingeniería de Software – Grupo 6  
Proyecto: **MarcaYA** · Sistema de registro de asistencia laboral con validación GPS  
---

## **1\. ENTIDADES Y ATRIBUTOS**

### **1.1 Usuario *(entidad base / abstracta)***

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID / Long | Identificador único |
| `correo` | String | Correo institucional, usado como credencial |
| `claveHash` | String | Contraseña encriptada |
| `rol` | Enum | `EMPLEADO` / `EMPRESA` / `ADMIN` |
| `fechaRegistro` | DateTime | Fecha de creación de cuenta |
| `estado` | Enum | `ACTIVO` / `INACTIVO` |

---

### **1.2 Empleado *(extiende Usuario)***

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `nombre` | String | Nombre del empleado |
| `apellido` | String | Apellido del empleado |
| `correo` | String | Correo registrado |
| `claveHash` | String | Contraseña encriptada |
| `rol` | Enum | `EMPLEADO` |
| `estado` | Enum | `PENDIENTE` / `ACTIVO` / `INACTIVO` |
| `empresaId` | FK → Empresa | Empresa a la que pertenece (tras ser aceptado) |
| `valoracionPromedio` | Float | Promedio de valoraciones recibidas (1–5) |
| `fechaRegistro` | DateTime | Fecha de registro |

---

### **1.3 Empresa / Administrador *(extiende Usuario)***

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `nombreEmpresa` | String | Nombre de la empresa |
| `correo` | String | Correo corporativo |
| `claveHash` | String | Contraseña encriptada |
| `rol` | Enum | `EMPRESA` / `ADMIN` |
| `estado` | Enum | `ACTIVO` / `INACTIVO` |
| `fechaRegistro` | DateTime | Fecha de registro |

---

### **1.4 Obra *(construcción / sitio de trabajo)***

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `nombre` | String | Nombre de la obra |
| `descripcion` | String | Descripción opcional |
| `empresaId` | FK → Empresa | Empresa propietaria |
| `estado` | Enum | `ACTIVA` / `INACTIVA` |
| `fechaCreacion` | DateTime | Fecha de creación |

---

### **1.5 Parada *(geocerca / zona de marcación)***

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `nombre` | String | Nombre de la parada |
| `latitud` | Double | Coordenada geográfica |
| `longitud` | Double | Coordenada geográfica |
| `radio` | Float | Radio de geocerca en metros |
| `obraId` | FK → Obra | Obra a la que pertenece |
| `estado` | Enum | `ACTIVA` / `INACTIVA` |
| `fechaCreacion` | DateTime | Fecha de creación |

---

### **1.6 RegistroAsistencia**

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `empleadoId` | FK → Empleado | Empleado que marcó |
| `paradaId` | FK → Parada | Parada donde se marcó |
| `tipoMarcacion` | Enum | `ENTRADA` / `SALIDA` |
| `fechaHora` | DateTime | Timestamp de la marcación |
| `latitudRegistrada` | Double | Ubicación GPS en el momento |
| `longitudRegistrada` | Double | Ubicación GPS en el momento |
| `validaGPS` | Boolean | Si la ubicación estaba dentro del radio |
| `duracionJornada` | Integer | Minutos trabajados (calculado al marcar salida) |
| `observaciones` | String | Notas adicionales (ej: fuera de zona) |

---

### **1.7 SolicitudIngreso**

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `empleadoId` | FK → Empleado | Empleado solicitante |
| `obraId` | FK → Obra | Obra a la que solicita ingreso |
| `estado` | Enum | `PENDIENTE` / `ACEPTADA` / `RECHAZADA` |
| `fechaSolicitud` | DateTime | Cuándo se envió la solicitud |
| `fechaRespuesta` | DateTime | Cuándo fue procesada |
| `motivoRechazo` | String | Razón del rechazo (opcional) |

---

### **1.8 EmpleadoParada *(tabla de relación N:M)***

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `empleadoId` | FK → Empleado | Empleado asignado |
| `paradaId` | FK → Parada | Parada asignada |
| `fechaAsignacion` | DateTime | Cuándo fue asignado |
| `activo` | Boolean | Si sigue asignado |

---

### **1.9 CronogramaPago**

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `empleadoId` | FK → Empleado | Empleado beneficiado |
| `empresaId` | FK → Empresa | Empresa que paga |
| `periodoInicio` | Date | Inicio del período de pago |
| `periodoFin` | Date | Fin del período de pago |
| `horasTrabajadas` | Float | Total de horas válidas |
| `montoTotal` | Decimal | Monto calculado a pagar |
| `fechaPago` | Date | Fecha programada de pago |
| `estado` | Enum | `PENDIENTE` / `PAGADO` |
| `fechaGeneracion` | DateTime | Cuándo se generó |

---

### **1.10 Valoracion**

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `emisorId` | FK → Usuario | Quien deja la valoración |
| `receptorId` | FK → Usuario | Quien la recibe |
| `puntuacion` | Integer | 1 a 5 estrellas |
| `comentario` | String | Texto del comentario |
| `fecha` | DateTime | Fecha de creación |

---

### **1.11 TokenRecuperacion *(para reset de contraseña)***

| Atributo | Tipo | Descripción |
| :---- | :---- | :---- |
| `id` | UUID | Identificador único |
| `usuarioId` | FK → Usuario | Usuario propietario |
| `codigo` | String | Código temporal enviado al correo |
| `fechaExpiracion` | DateTime | Tiempo de expiración |
| `usado` | Boolean | Si ya fue utilizado |

---

## **2\. RELACIONES**

| Entidad A | Cardinalidad | Entidad B | Descripción |
| :---- | :---- | :---- | :---- |
| Empresa | 1 : N | Obra | Una empresa puede tener muchas obras |
| Obra | 1 : N | Parada | Una obra tiene muchas paradas |
| Empresa | 1 : N | Empleado | Una empresa tiene muchos empleados (tras aceptación) |
| Empleado | N : M | Parada | Un empleado puede estar asignado a varias paradas *(via EmpleadoParada)* |
| Empleado | 1 : N | RegistroAsistencia | Un empleado tiene muchos registros |
| Parada | 1 : N | RegistroAsistencia | Una parada tiene muchos registros |
| Empleado | 1 : N | SolicitudIngreso | Un empleado puede enviar múltiples solicitudes |
| Obra | 1 : N | SolicitudIngreso | Una obra puede recibir muchas solicitudes |
| Empleado | 1 : N | CronogramaPago | Un empleado tiene múltiples cronogramas (por período) |
| Empresa | 1 : N | CronogramaPago | Una empresa genera cronogramas de sus empleados |
| Usuario | 1 : N | Valoracion *(emisor)* | Un usuario puede emitir muchas valoraciones |
| Usuario | 1 : N | Valoracion *(receptor)* | Un usuario puede recibir muchas valoraciones |
| Usuario | 1 : N | TokenRecuperacion | Un usuario puede tener tokens de recuperación |

---

## **3\. ENDPOINTS**

Prefijo base sugerido: `/api/v1`  
Autenticación: **JWT Bearer Token**  
Roles: `EMPLEADO`, `EMPRESA`, `ADMIN`

---

### **🔐 Auth — `/api/v1/auth`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `POST` | `/auth/login` | Público | Iniciar sesión (correo \+ contraseña) → devuelve JWT |
| `POST` | `/auth/register/empleado` | Público | Registrar nuevo empleado |
| `POST` | `/auth/register/empresa` | Público | Registrar nueva empresa |
| `POST` | `/auth/forgot-password` | Público | Solicitar código de recuperación por correo |
| `POST` | `/auth/verify-code` | Público | Verificar código temporal |
| `POST` | `/auth/reset-password` | Público | Establecer nueva contraseña |
| `POST` | `/auth/logout` | Autenticado | Invalidar sesión actual |

---

### **👤 Perfil — `/api/v1/perfil`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `GET` | `/perfil` | Autenticado | Ver perfil del usuario autenticado |
| `PUT` | `/perfil` | Autenticado | Editar datos del perfil propio |
| `GET` | `/perfil/:usuarioId` | Autenticado | Ver perfil de otro usuario |

---

### **🏢 Empresas — `/api/v1/empresas`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `GET` | `/empresas/:id` | EMPRESA / ADMIN | Ver datos de una empresa |
| `PUT` | `/empresas/:id` | EMPRESA / ADMIN | Editar datos de una empresa |
| `GET` | `/empresas/:id/empleados` | EMPRESA / ADMIN | Listar empleados activos de la empresa |
| `GET` | `/empresas/:id/obras` | EMPRESA / ADMIN | Listar obras de la empresa |

---

### **🏗️ Obras — `/api/v1/obras`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `GET` | `/obras` | EMPRESA / ADMIN | Listar obras (propias) |
| `POST` | `/obras` | EMPRESA | Crear nueva obra |
| `GET` | `/obras/:id` | Autenticado | Ver detalle de una obra |
| `PUT` | `/obras/:id` | EMPRESA / ADMIN | Editar datos de la obra |
| `DELETE` | `/obras/:id` | EMPRESA / ADMIN | Desactivar / eliminar obra |

---

### **📍 Paradas — `/api/v1/paradas`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `GET` | `/obras/:obraId/paradas` | Autenticado | Listar paradas de una obra |
| `POST` | `/obras/:obraId/paradas` | EMPRESA / ADMIN | Crear nueva parada en una obra |
| `GET` | `/paradas/:id` | Autenticado | Ver detalle de una parada |
| `PUT` | `/paradas/:id` | EMPRESA / ADMIN | Editar nombre, coordenadas y radio |
| `DELETE` | `/paradas/:id` | EMPRESA / ADMIN | Eliminar parada (valida que no esté en uso) |
| `GET` | `/paradas/:id/empleados` | EMPRESA / ADMIN | Listar empleados asignados a la parada |
| `POST` | `/paradas/:id/empleados` | EMPRESA / ADMIN | Asignar empleado a la parada |
| `DELETE` | `/paradas/:id/empleados/:empleadoId` | EMPRESA / ADMIN | Desasignar empleado de la parada |

---

### **📋 Solicitudes de Ingreso — `/api/v1/solicitudes`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `POST` | `/solicitudes` | EMPLEADO | Solicitar ingreso a una obra |
| `GET` | `/solicitudes` | EMPRESA / ADMIN | Listar solicitudes (filtro por estado) |
| `GET` | `/solicitudes/mis-solicitudes` | EMPLEADO | Ver solicitudes propias |
| `GET` | `/solicitudes/:id` | Autenticado | Ver detalle de una solicitud |
| `PUT` | `/solicitudes/:id/aceptar` | EMPRESA / ADMIN | Aceptar solicitud → activa al empleado |
| `PUT` | `/solicitudes/:id/rechazar` | EMPRESA / ADMIN | Rechazar solicitud |

---

### **🕐 Asistencia — `/api/v1/asistencia`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `POST` | `/asistencia/marcar-entrada` | EMPLEADO | Registrar entrada con validación GPS |
| `POST` | `/asistencia/marcar-salida` | EMPLEADO | Registrar salida con validación GPS |
| `GET` | `/asistencia/historial` | EMPLEADO | Ver historial personal de asistencias |
| `GET` | `/asistencia/historial/:empleadoId` | EMPRESA / ADMIN | Ver historial de un empleado específico |
| `GET` | `/asistencia/tiempo-real` | EMPRESA / ADMIN | Ver estado actual de empleados en paradas |
| `GET` | `/asistencia/tiempo-real/:paradaId` | EMPRESA / ADMIN | Monitoreo en tiempo real de una parada |

---

### **📊 Reportes — `/api/v1/reportes`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `GET` | `/reportes/asistencia` | EMPRESA / ADMIN | Reporte de asistencias con filtros (`fechaInicio`, `fechaFin`, `empleadoId`, `paradaId`, `obraId`) |
| `GET` | `/reportes/asistencia/export` | EMPRESA / ADMIN | Exportar reporte en PDF o Excel (`?formato=pdf|excel`) |
| `GET` | `/reportes/estadisticas` | EMPRESA / ADMIN | Dashboard con KPIs: asistencias, tardanzas, horas trabajadas, ausencias |
| `GET` | `/reportes/estadisticas/:obraId` | EMPRESA / ADMIN | Estadísticas específicas de una obra |

---

### **💳 Cronograma de Pagos — `/api/v1/cronograma`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `GET` | `/cronograma` | EMPLEADO | Ver cronograma de pagos propio |
| `GET` | `/cronograma/empresa` | EMPRESA / ADMIN | Ver cronograma de todos los empleados |
| `POST` | `/cronograma/generar` | EMPRESA / ADMIN | Generar cronograma para un período (`periodoInicio`, `periodoFin`) |
| `GET` | `/cronograma/:id` | Autenticado | Ver detalle de un cronograma específico |
| `POST` | `/cronograma/sincronizar` | EMPRESA / ADMIN | Enviar asistencias válidas al sistema de pagos externo |

---

### **⭐ Valoraciones — `/api/v1/valoraciones`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `POST` | `/valoraciones` | Autenticado | Crear valoración a un usuario |
| `GET` | `/valoraciones/:usuarioId` | Autenticado | Ver todas las valoraciones de un usuario |
| `GET` | `/valoraciones/:usuarioId/promedio` | Autenticado | Obtener promedio de valoraciones |

---

### **👥 Empleados (gestión admin) — `/api/v1/empleados`**

| Método | Endpoint | Rol | Descripción |
| :---- | :---- | :---- | :---- |
| `GET` | `/empleados` | EMPRESA / ADMIN | Listar empleados con filtros |
| `GET` | `/empleados/:id` | EMPRESA / ADMIN | Ver detalle de un empleado |
| `PUT` | `/empleados/:id` | EMPRESA / ADMIN | Editar información de empleado |
| `PUT` | `/empleados/:id/desactivar` | EMPRESA / ADMIN | Desactivar empleado |
| `GET` | `/empleados/:id/asistencias` | EMPRESA / ADMIN | Ver asistencias de un empleado |
| `GET` | `/empleados/:id/paradas` | EMPRESA / ADMIN | Ver paradas asignadas al empleado |

---

## **4\. RESUMEN DE MÓDULOS**

| Módulo | Entidades clave | Endpoints |
| :---- | :---- | :---- |
| Autenticación | Usuario, TokenRecuperacion | 7 |
| Perfil | Usuario, Valoracion | 3 |
| Empresas | Empresa | 4 |
| Obras | Obra | 5 |
| Paradas | Parada, EmpleadoParada | 9 |
| Solicitudes | SolicitudIngreso | 6 |
| Asistencia | RegistroAsistencia | 6 |
| Reportes | RegistroAsistencia (agregado) | 4 |
| Cronograma de pagos | CronogramaPago | 5 |
| Valoraciones | Valoracion | 3 |
| Empleados (admin) | Empleado | 6 |
| **TOTAL** | **11 entidades** | **\~58 endpoints** |

---

*Documento generado a partir del Informe Final — MarcApp, Grupo 6, Ingeniería de Software I, Universidad de Lima, Junio 2025\.*  
