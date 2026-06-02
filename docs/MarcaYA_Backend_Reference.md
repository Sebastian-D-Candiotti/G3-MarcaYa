# MarcaYA — Backend: Arquitectura Hexagonal (Rails 8)

> **Proyecto:** MarcaYA · Sistema de registro de asistencia laboral con validación GPS  
> **Stack:** Ruby on Rails 8 · PostgreSQL · JWT + bcrypt  
> **Patrón:** Arquitectura Hexagonal (Puertos y Adaptadores)

---

## Tabla de Contenidos

1. [Principios de la Arquitectura](#1-principios-de-la-arquitectura)
2. [Estructura de Carpetas (Implementada)](#2-estructura-de-carpetas-implementada)
3. [Capas y Responsabilidades](#3-capas-y-responsabilidades)
4. [Módulos Implementados](#4-módulos-implementados)
5. [Hoja de Ruta — Próximos Módulos](#5-hoja-de-ruta--próximos-módulos)
6. [Referencia de Entidades y Endpoints](#6-referencia-de-entidades-y-endpoints)
7. [Convenciones y Reglas](#7-convenciones-y-reglas)

---

## 1. Principios de la Arquitectura

El backend de MarcaYA implementa la **Arquitectura Hexagonal (Puertos y Adaptadores)** sobre Rails 8. El objetivo central es aislar completamente el núcleo de negocio de los detalles de infraestructura.

```
┌────────────────────────────────────────────────────────────────┐
│  [HTTP Request]                                                │
│       │                                                       │
│       ▼                                                       │
│  ┌────────────────────┐  ┌────────────────────────────────┐   │
│  │  BaseController    │──│ JwtAuthenticatable (concern)    │   │
│  │  (JWT auth via     │  │ → decode JWT → set @current_user│   │
│  │   before_action)   │  └────────────────────────────────┘   │
│       │                                                       │
│       ▼ (thin delegate)                                       │
│  ┌────────────────────┐                                       │
│  │  Controller        │  (5 controllers, sin lógica negocio)  │
│  └─────────┬──────────┘                                       │
│            │                                                   │
│            ▼                                                   │
│  ┌────────────────────┐                                       │
│  │  Facade            │  (orquestación opcional)              │
│  └─────────┬──────────┘                                       │
│            │                                                   │
│            ▼                                                   │
│  ┌────────────────────┐                                       │
│  │  Use Case          │  ← implements Driving Port Interface  │
│  │  (app/application) │                                       │
│  └─────────┬──────────┘                                       │
│            │                                                   │
│            ▼                                                   │
│  ┌────────────────────┐                                       │
│  │  Domain Entity     │  ← pure Ruby, no Rails               │
│  │  + Service + VO    │                                       │
│  └─────────┬──────────┘                                       │
│            │                                                   │
│            ▼                                                   │
│  ┌────────────────────┐                                       │
│  │  Driven Port       │  ← interface (e.g., IUsuarioRepo)    │
│  │  (app/ports/)      │                                       │
│  └─────────┬──────────┘                                       │
│            │                                                   │
│            ▼                                                   │
│  ┌─────────────────┐  ┌──────────────┐  ┌───────────────┐    │
│  │  ArRepository   │──│   Mapper     │──│  ORM Record   │    │
│  │  (infra)        │  │ Record→Entity│  │  (ActiveRecord)│    │
│  └─────────────────┘  └──────────────┘  └───────┬───────┘    │
│                                                  │            │
│                                                  ▼            │
│                                            ┌──────────┐      │
│                                            │PostgreSQL│      │
│                                            └──────────┘      │
└────────────────────────────────────────────────────────────────┘
```

**Regla fundamental:** las dependencias siempre apuntan hacia adentro. El Dominio no conoce Rails, no conoce ActiveRecord, no conoce HTTP.

---

## 2. Estructura de Carpetas (Implementada)

```
marcaya-backend/
│
├── app/
│   │
│   ├── # ────────────────────────────────────────────────────
│   ├── # DRIVING ADAPTERS (entrada — controllers)
│   ├── # ────────────────────────────────────────────────────
│   ├── controllers/
│   │   ├── concerns/
│   │   │   └── jwt_authenticatable.rb      # JWT decode + current_user
│   │   │
│   │   └── api/v1/
│   │       ├── base_controller.rb          # Include JwtAuthenticatable
│   │       ├── auth_controller.rb          # POST /auth/login, /registro
│   │       ├── usuarios_controller.rb      # CRUD usuarios
│   │       ├── obras_controller.rb         # CRUD obras
│   │       ├── solicitudes_controller.rb   # Solicitudes de ingreso
│   │       └── empleados_controller.rb     # Gestión admin de empleados
│   │
│   ├── # ────────────────────────────────────────────────────
│   ├── # DRIVING PORTS (interfaces de entrada)
│   ├── # ────────────────────────────────────────────────────
│   ├── ports/
│   │   └── driving/
│   │       ├── i_autenticar_usuario.rb     # login / registro
│   │       ├── i_gestionar_usuario.rb      # CRUD usuario
│   │       ├── i_gestionar_obra.rb         # CRUD obra
│   │       ├── i_gestionar_solicitud.rb    # solicitar / aceptar / rechazar
│   │       └── i_gestionar_empleado.rb     # obtener_obras / listar_actuales
│   │
│   ├── # ────────────────────────────────────────────────────
│   ├── # CAPA DE APLICACIÓN (orquestación)
│   ├── # ────────────────────────────────────────────────────
│   ├── application/
│   │   │
│   │   ├── facades/
│   │   │   ├── auth_facade.rb              # login + registro + perfil
│   │   │   ├── usuario_facade.rb           # CRUD usuarios
│   │   │   ├── obra_facade.rb              # CRUD obras
│   │   │   ├── solicitud_facade.rb         # CRUD solicitudes + transiciones
│   │   │   └── empleado_facade.rb          # obtener_obras + listar_actuales
│   │   │
│   │   └── use_cases/
│   │       ├── auth/
│   │       │   ├── login_usuario.rb        # bcrypt verify + JWT
│   │       │   ├── registrar_usuario.rb    # bcrypt hash + creación
│   │       │   └── cerrar_sesion.rb        # invalidación
│   │       │
│   │       ├── usuarios/
│   │       │   ├── obtener_usuario.rb
│   │       │   ├── listar_usuarios.rb
│   │       │   ├── actualizar_usuario.rb
│   │       │   └── desactivar_usuario.rb
│   │       │
│   │       ├── obras/
│   │       │   ├── crear_obra.rb
│   │       │   ├── obtener_obra.rb
│   │       │   ├── listar_obras.rb
│   │       │   ├── actualizar_obra.rb
│   │       │   └── eliminar_obra.rb
│   │       │
│   │       ├── solicitudes/
│   │       │   ├── crear_solicitud.rb
│   │       │   ├── listar_solicitudes.rb
│   │       │   ├── aceptar_solicitud.rb
│   │       │   └── rechazar_solicitud.rb
│   │       │
│   │       ├── empleados/
│   │       │   ├── obtener_obras_empleado.rb
│   │       │   └── listar_empleados_actuales.rb
│   │       │
│   │       ├── empresa/
│   │       │   └── obtener_empresa.rb
│   │       │
│   │       └── valoraciones/
│   │           ├── listar_valoraciones_empresa.rb
│   │           └── calcular_promedio_valoracion.rb
│   │
│   ├── # ────────────────────────────────────────────────────
│   ├── # CAPA DE DOMINIO (núcleo puro — sin Rails)
│   ├── # ────────────────────────────────────────────────────
│   ├── domain/
│   │   │
│   │   ├── entities/
│   │   │   ├── usuario.rb
│   │   │   ├── empleado.rb
│   │   │   ├── empresa.rb
│   │   │   ├── obra.rb
│   │   │   ├── solicitud.rb
│   │   │   └── valoracion.rb
│   │   │
│   │   ├── value_objects/
│   │   │   ├── coordenada_gps.rb
│   │   │   ├── rol_usuario.rb
│   │   │   └── estado_solicitud.rb
│   │   │
│   │   ├── services/
│   │   │   ├── gps_validation_service.rb
│   │   │   └── valoracion_promedio_service.rb
│   │   │
│   │   └── errors.rb                       # Todos los errores de dominio
│   │
│   ├── # ────────────────────────────────────────────────────
│   ├── # DRIVEN PORTS (interfaces de salida)
│   ├── # ────────────────────────────────────────────────────
│   ├── ports/
│   │   └── driven/
│   │       ├── i_usuario_repository.rb
│   │       ├── i_empleado_repository.rb
│   │       ├── i_empresa_repository.rb
│   │       ├── i_obra_repository.rb
│   │       ├── i_solicitud_repository.rb
│   │       └── i_valoracion_repository.rb
│   │
│   ├── # ────────────────────────────────────────────────────
│   ├── # DRIVEN ADAPTERS (infraestructura)
│   ├── # ────────────────────────────────────────────────────
│   ├── infrastructure/
│   │   │
│   │   ├── orm/                             # Modelos ActiveRecord (solo mapeo)
│   │   │   ├── usuario_record.rb
│   │   │   ├── empleado_record.rb
│   │   │   ├── empresa_record.rb
│   │   │   ├── obra_record.rb
│   │   │   ├── solicitud_record.rb
│   │   │   └── valoracion_record.rb
│   │   │
│   │   ├── mappers/                         # Traducen ORM Record ↔ Domain Entity
│   │   │   ├── usuario_mapper.rb
│   │   │   ├── empleado_mapper.rb
│   │   │   ├── empresa_mapper.rb
│   │   │   ├── obra_mapper.rb
│   │   │   ├── solicitud_mapper.rb
│   │   │   └── valoracion_mapper.rb
│   │   │
│   │   ├── repositories/                    # Implementan Driven Ports
│   │   │   ├── ar_usuario_repository.rb
│   │   │   ├── ar_empleado_repository.rb
│   │   │   ├── ar_empresa_repository.rb
│   │   │   ├── ar_obra_repository.rb
│   │   │   ├── ar_solicitud_repository.rb
│   │   │   └── ar_valoracion_repository.rb
│   │   │
│   │   └── services/                        # Servicios de infraestructura
│   │       ├── jwt_token_service.rb         # Codifica / decodifica JWT (HS256)
│   │       └── bcrypt_password_service.rb   # Hash + lazy migration
│   │
│   ├── # ────────────────────────────────────────────────────
│   ├── # SERIALIZERS (respuesta HTTP)
│   ├── # ────────────────────────────────────────────────────
│   └── serializers/
│       ├── usuario_serializer.rb
│       ├── empleado_serializer.rb
│       ├── empresa_serializer.rb
│       ├── obra_serializer.rb
│       ├── solicitud_serializer.rb
│       └── valoracion_serializer.rb
│
├── config/
│   ├── routes.rb
│   ├── initializers/
│   │   ├── dependency_injection.rb          # Container con facades + repos
│   │   └── zeitwerk_overrides.rb            # Loaders para namespaces anidados
│   └── environments/
│       └── test.rb
│
├── db/
│   ├── migrate/                             # Schema existente (sin cambios)
│   └── schema.rb
│
├── test/                                    # Minitest (local, gitignored)
│   ├── controllers/api/v1/
│   ├── application/
│   │   ├── facades/
│   │   └── use_cases/
│   ├── infrastructure/
│   │   ├── repositories/
│   │   └── services/
│   ├── domain/
│   │   ├── entities/
│   │   ├── services/
│   │   └── value_objects/
│   └── fixtures/
│
└── Gemfile
```

---

## 3. Capas y Responsabilidades

### 3.1 Driving Adapters — Controllers

**Ubicación:** `app/controllers/api/v1/`

Reciben peticiones HTTP, delegan a facades/use cases, serializan respuestas.

**Reglas:**
- **No contienen lógica de negocio.** Solo orquestan la llamada.
- Heredan de `BaseController` que incluye `JwtAuthenticatable` con `before_action :authenticate!`
- `AuthController` usa `skip_before_action :authenticate!, only: [:login, :registro]`
- Traducen errores de dominio a códigos HTTP (401, 404, 422, etc.)

### 3.2 Driving Ports — Interfaces de Entrada

**Ubicación:** `app/ports/driving/`

Clases abstractas con `NotImplementedError` que definen el contrato entre controllers y use cases.

### 3.3 Capa de Aplicación

**Ubicación:** `app/application/`

- **Facades:** orquestan flujos complejos que involucran múltiples repositorios (Auth: usuario + empleado/empresa + perfil)
- **Use Cases:** una clase = una acción de negocio. Reciben repositorios por inyección de dependencias.

### 3.4 Capa de Dominio

**Ubicación:** `app/domain/`

Núcleo puro del sistema. **Sin dependencias de Rails, ActiveRecord, ni HTTP.**

- **Entities:** objetos con identidad (Usuario, Empleado, Empresa, Obra, Solicitud, Valoracion)
- **Value Objects:** inmutables, con validación (CoordenadaGps, RolUsuario, EstadoSolicitud)
- **Services:** lógica de negocio sin I/O (GpsValidationService, ValoracionPromedioService)
- **Errors:** clases de error específicas del dominio

### 3.5 Driven Ports — Interfaces de Salida

**Ubicación:** `app/ports/driven/`

Interfaces para repositorios que la capa de aplicación necesita.

### 3.6 Driven Adapters — Infraestructura

**Ubicación:** `app/infrastructure/`

- **ORM Records:** ActiveRecord puro con associations (Infrastructure::Orm::*Record)
- **Mappers:** traducción Record → Domain Entity y viceversa
- **Repositories:** implementan los Driven Ports usando ActiveRecord
- **Services:** JwtTokenService (HS256), BcryptPasswordService (hash + lazy migration)

### 3.7 Dependency Injection

**Ubicación:** `config/initializers/dependency_injection.rb`

`DependencyContainer` módulo con lazy access via `Rails.configuration.di.<facade>`. Implementa lazy initialization para evitar resolver constantes autoloaded en boot.

### 3.8 Zeitwerk

**Ubicación:** `config/initializers/zeitwerk_overrides.rb`

Los directorios namespaced (app/domain/, app/infrastructure/, app/ports/, app/application/, app/serializers/) necesitan loaders Zeitwerk custom porque Rails 8.1 mapea todos los subdirectorios de `app/` al namespace `Object`.

---

## 4. Módulos Implementados

| Módulo | Entidades | Endpoints | Estado |
|--------|-----------|-----------|--------|
| **Auth** | Usuario | POST /auth/login, /auth/registro | ✅ Completo (bcrypt + JWT) |
| **Usuarios** | Usuario | GET/PUT /usuarios/:id, PATCH /desactivar | ✅ Completo |
| **Obras** | Obra | CRUD /obras | ✅ Completo |
| **Solicitudes** | Solicitud | POST /solicitudes, PUT /aceptar, /rechazar | ✅ Completo |
| **Empleados** | Empleado | GET /empleados/actuales, GET /:id/obras | ✅ Completo |
| **Valoraciones** | Valoracion | (vía repositorio, sin controller propio) | ⚠️ Parcial |
| **Empresa** | Empresa | (vía repositorio, sin controller propio) | ⚠️ Parcial |

### Auth Flow

```
POST /auth/login {correo, clave}
  → AuthController#login (skip auth)
    → AuthFacade.login(correo, clave)
      → LoginUsuario.ejecutar(correo, clave)
        → BcryptPasswordService.verify(clave, hash)
        → JwtTokenService.encode(user_id:, rol:)
        → build_perfil(usuario) [empresa o empleado]
    ← {token, rol, perfil}
```

Protected endpoints requieren header: `Authorization: Bearer <jwt_token>`

---

## 5. Hoja de Ruta — Próximos Módulos

Estos módulos están definidos en el diseño del sistema pero **no implementados aún**:

| Módulo | Entidades faltantes | Endpoints planeados |
|--------|--------------------|--------------------|
| Paradas | Parada, EmpleadoParada | CRUD paradas, asignar/desasignar empleados |
| Asistencia | RegistroAsistencia | Marcar entrada/salida con validación GPS |
| Reportes | — | Reportes de asistencia con filtros, exportación PDF/Excel |
| Cronograma | CronogramaPago | Generar cronograma de pagos, sincronizar |
| Suscripciones | PlanSuscripcion, Suscripcion | Catálogo de planes, contratar/cancelar |
| Recuperación | TokenRecuperacion | Forgot/reset password con código |

---

## 6. Referencia de Entidades y Endpoints

### Entidades (schema actual en DB)

| Tabla | Atributos clave |
|-------|----------------|
| `usuarios` | id, correo, clave_hash, rol (empresa/empleado), estado, created_at |
| `empleados` | id, usuario_id, nombre, apellido, dni, telefono, descripcion, foto_url, estado |
| `empresas` | id, usuario_id, nombre_empresa, ruc, descripcion, direccion, telefono, foto_url, estado |
| `obras` | id, empresa_id, nombre, descripcion_ubicacion, latitud, longitud, radio_metros, hora_inicio, hora_fin, tolerancia_entrada_min, tolerancia_salida_min, estado, fecha_inicio, fecha_fin, direccion, capacidad_empleados, codigo_obra |
| `solicitudes` | id, empleado_id, obra_id, estado (pendiente/aceptada/rechazada), created_at |
| `valoraciones` | id, empleado_id, empresa_id, puntuacion, comentario, created_at |

### Endpoints implementados

| Método | Endpoint | Auth | Descripción |
|--------|----------|------|-------------|
| `POST` | `/api/v1/auth/login` | Público | Login con correo+clave → JWT |
| `POST` | `/api/v1/auth/registro` | Público | Registro de nuevo usuario |
| `GET` | `/api/v1/usuarios` | JWT | Listar usuarios |
| `GET` | `/api/v1/usuarios/:id` | JWT | Ver perfil completo |
| `PUT` | `/api/v1/usuarios/:id` | JWT | Actualizar usuario |
| `PATCH` | `/api/v1/usuarios/:id/desactivar` | JWT | Desactivar cuenta |
| `GET` | `/api/v1/obras` | JWT | Listar obras |
| `POST` | `/api/v1/obras` | JWT | Crear obra |
| `GET` | `/api/v1/obras/:id` | JWT | Ver obra |
| `PUT` | `/api/v1/obras/:id` | JWT | Actualizar obra |
| `DELETE` | `/api/v1/obras/:id` | JWT | Eliminar obra |
| `GET` | `/api/v1/solicitudes` | JWT | Listar solicitudes pendientes |
| `POST` | `/api/v1/solicitudes` | JWT | Crear solicitud de ingreso |
| `PUT` | `/api/v1/solicitudes/:id/aceptar` | JWT | Aceptar solicitud |
| `PUT` | `/api/v1/solicitudes/:id/rechazar` | JWT | Rechazar solicitud |
| `GET` | `/api/v1/empleados/actuales` | JWT | Listar empleados activos |
| `GET` | `/api/v1/empleados/:id/obras` | JWT | Obras de un empleado |
| `GET` | `/api/v1/empleados/:id/historial_solicitudes` | JWT | Historial de solicitudes |

---

## 7. Convenciones y Reglas

### Namespaces

| Directorio | Namespace |
|-----------|-----------|
| `app/domain/entities/` | `Domain::Entities` |
| `app/domain/value_objects/` | `Domain::ValueObjects` |
| `app/domain/services/` | `Domain::Services` |
| `app/domain/errors.rb` | `Domain::Errors` |
| `app/ports/driven/` | `Ports::Driven` |
| `app/ports/driving/` | `Ports::Driving` |
| `app/infrastructure/orm/` | `Infrastructure::Orm` |
| `app/infrastructure/repositories/` | `Infrastructure::Repositories` |
| `app/infrastructure/mappers/` | `Infrastructure::Mappers` |
| `app/infrastructure/services/` | `Infrastructure::Services` |
| `app/application/use_cases/` | `Application::UseCases` |
| `app/application/facades/` | `Application::Facades` |
| `app/serializers/` | `Serializer` |

### Naming

- **Inglés** para dominio, aplicación, puertos, infraestructura, serializers
- **Español** para nombres de tablas en DB, controllers (por convención Rails)

### Autenticación

- JWT con algoritmo HS256, expiración 24h
- Secret: `Rails.application.secret_key_base`
- Payload: `{ "user_id": int, "rol": string, "exp": timestamp }`
- Header: `Authorization: Bearer <token>`

### Contraseñas

- bcrypt via `BCrypt::Password.create` / `BCrypt::Password.new`
- Migración lazy: si `clave_hash` no tiene prefijo bcrypt (`$2a$`, `$2b$`, `$2y$`), se compara como texto plano y se re-hashea en el primer login exitoso

### Tests

- Minitest (no RSpec)
- Tests locales (gitignored, no se commitean)
- 217 tests, 0 failures, 0 errors

---

## 8. Diseño Original — Módulos Futuros

> Esta sección documenta el diseño completo de los módulos planificados pero **no implementados aún**. Sirve como referencia para desarrollo futuro.

---

### 8.1 Parada (geocerca / zona de marcación)

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `id` | UUID / Long | Identificador único |
| `nombre` | String | Nombre de la parada |
| `latitud` | Double | Coordenada geográfica |
| `longitud` | Double | Coordenada geográfica |
| `radio` | Float | Radio de geocerca en metros |
| `obraId` | FK → Obra | Obra a la que pertenece |
| `estado` | Enum | `ACTIVA` / `INACTIVA` |
| `fechaCreacion` | DateTime | Fecha de creación |

**Relaciones:** Obra 1:N Parada | Empleado N:M Parada (via EmpleadoParada)

**Endpoints planeados:**

| Método | Endpoint | Rol | Descripción |
|--------|----------|-----|-------------|
| `GET` | `/obras/:obraId/paradas` | Autenticado | Listar paradas de una obra |
| `POST` | `/obras/:obraId/paradas` | EMPRESA / ADMIN | Crear nueva parada |
| `GET` | `/paradas/:id` | Autenticado | Ver detalle |
| `PUT` | `/paradas/:id` | EMPRESA / ADMIN | Editar nombre, coordenadas, radio |
| `DELETE` | `/paradas/:id` | EMPRESA / ADMIN | Eliminar (validar que no esté en uso) |
| `GET` | `/paradas/:id/empleados` | EMPRESA / ADMIN | Listar empleados asignados |
| `POST` | `/paradas/:id/empleados` | EMPRESA / ADMIN | Asignar empleado |
| `DELETE` | `/paradas/:id/empleados/:empleadoId` | EMPRESA / ADMIN | Desasignar empleado |

---

### 8.2 EmpleadoParada (relación N:M)

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `id` | UUID | Identificador único |
| `empleadoId` | FK → Empleado | Empleado asignado |
| `paradaId` | FK → Parada | Parada asignada |
| `fechaAsignacion` | DateTime | Cuándo fue asignado |
| `activo` | Boolean | Si sigue asignado |

---

### 8.3 RegistroAsistencia

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `id` | UUID | Identificador único |
| `empleadoId` | FK → Empleado | Empleado que marcó |
| `paradaId` | FK → Parada | Parada donde marcó |
| `tipoMarcacion` | Enum | `ENTRADA` / `SALIDA` |
| `fechaHora` | DateTime | Timestamp de la marcación |
| `latitudRegistrada` | Double | GPS al momento de marcar |
| `longitudRegistrada` | Double | GPS al momento de marcar |
| `validaGPS` | Boolean | Si estaba dentro del radio |
| `duracionJornada` | Integer | Minutos trabajados (calculado al salida) |
| `observaciones` | String | Notas (ej: fuera de zona) |

**Relaciones:** Empleado 1:N RegistroAsistencia | Parada 1:N RegistroAsistencia

**Endpoints planeados:**

| Método | Endpoint | Rol | Descripción |
|--------|----------|-----|-------------|
| `POST` | `/asistencia/marcar-entrada` | EMPLEADO | Registrar entrada con validación GPS |
| `POST` | `/asistencia/marcar-salida` | EMPLEADO | Registrar salida con validación GPS |
| `GET` | `/asistencia/historial` | EMPLEADO | Historial personal |
| `GET` | `/asistencia/historial/:empleadoId` | EMPRESA / ADMIN | Historial de un empleado |
| `GET` | `/asistencia/tiempo-real` | EMPRESA / ADMIN | Estado actual en paradas |
| `GET` | `/asistencia/tiempo-real/:paradaId` | EMPRESA / ADMIN | Monitoreo de una parada |

---

### 8.4 Reportes

| Método | Endpoint | Rol | Descripción |
|--------|----------|-----|-------------|
| `GET` | `/reportes/asistencia` | EMPRESA / ADMIN | Reporte con filtros (fecha, empleado, parada, obra) |
| `GET` | `/reportes/asistencia/export` | EMPRESA / ADMIN | Exportar PDF o Excel |
| `GET` | `/reportes/estadisticas` | EMPRESA / ADMIN | KPIs: asistencias, tardanzas, horas, ausencias |
| `GET` | `/reportes/estadisticas/:obraId` | EMPRESA / ADMIN | Estadísticas por obra |

---

### 8.5 CronogramaPago

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `id` | UUID | Identificador único |
| `empleadoId` | FK → Empleado | Empleado beneficiado |
| `empresaId` | FK → Empresa | Empresa que paga |
| `periodoInicio` | Date | Inicio del período |
| `periodoFin` | Date | Fin del período |
| `horasTrabajadas` | Float | Total de horas válidas |
| `montoTotal` | Decimal | Monto calculado |
| `fechaPago` | Date | Fecha programada |
| `estado` | Enum | `PENDIENTE` / `PAGADO` |
| `fechaGeneracion` | DateTime | Cuándo se generó |

**Relaciones:** Empleado 1:N CronogramaPago | Empresa 1:N CronogramaPago

**Endpoints planeados:**

| Método | Endpoint | Rol | Descripción |
|--------|----------|-----|-------------|
| `GET` | `/cronograma` | EMPLEADO | Ver cronograma propio |
| `GET` | `/cronograma/empresa` | EMPRESA / ADMIN | Ver todos los cronogramas |
| `POST` | `/cronograma/generar` | EMPRESA / ADMIN | Generar para un período |
| `GET` | `/cronograma/:id` | Autenticado | Ver detalle |
| `POST` | `/cronograma/sincronizar` | EMPRESA / ADMIN | Enviar al sistema de pagos |

---

### 8.6 Valoracion (completo)

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `id` | UUID | Identificador único |
| `emisorId` | FK → Usuario | Quien deja la valoración |
| `receptorId` | FK → Usuario | Quien la recibe |
| `puntuacion` | Integer | 1 a 5 estrellas |
| `comentario` | String | Texto del comentario |
| `fecha` | DateTime | Fecha de creación |

**Endpoints planeados:**

| Método | Endpoint | Rol | Descripción |
|--------|----------|-----|-------------|
| `POST` | `/valoraciones` | Autenticado | Crear valoración |
| `GET` | `/valoraciones/:usuarioId` | Autenticado | Ver valoraciones de un usuario |
| `GET` | `/valoraciones/:usuarioId/promedio` | Autenticado | Obtener promedio |

---

### 8.7 TokenRecuperacion (reset de contraseña)

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `id` | UUID | Identificador único |
| `usuarioId` | FK → Usuario | Usuario propietario |
| `codigo` | String | Código temporal enviado al correo |
| `fechaExpiracion` | DateTime | Tiempo de expiración |
| `usado` | Boolean | Si ya fue utilizado |

**Endpoints planeados:**

| Método | Endpoint | Rol | Descripción |
|--------|----------|-----|-------------|
| `POST` | `/auth/forgot-password` | Público | Solicitar código de recuperación |
| `POST` | `/auth/verify-code` | Público | Verificar código temporal |
| `POST` | `/auth/reset-password` | Público | Establecer nueva contraseña |

---

### 8.8 PlanSuscripcion (catálogo de planes)

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `id` | UUID | Identificador único |
| `nombre` | Enum | `BRONCE` / `PLATA` / `ORO` |
| `precio` | Decimal | Precio del plan por período |
| `limiteEmpleados` | Integer | Máximo de empleados activos |
| `descripcion` | String | Descripción del plan |

### 8.9 Suscripcion (vincula Empresa + Plan)

| Atributo | Tipo | Descripción |
|----------|------|-------------|
| `id` | UUID | Identificador único |
| `empresaId` | FK → Empresa | Empresa suscriptora |
| `planId` | FK → PlanSuscripcion | Plan contratado |
| `fechaInicio` | DateTime | Inicio de vigencia |
| `fechaFin` | DateTime | Fin de vigencia |
| `estado` | Enum | `ACTIVA` / `VENCIDA` |

**Endpoints planeados:**

| Método | Endpoint | Rol | Descripción |
|--------|----------|-----|-------------|
| `GET` | `/suscripciones/planes` | Público | Listar catálogo de planes |
| `GET` | `/suscripciones/planes/:id` | Público | Ver detalle de un plan |
| `POST` | `/suscripciones/contratar` | EMPRESA | Contratar un plan |
| `GET` | `/suscripciones/mi-suscripcion` | EMPRESA | Ver suscripción activa |
| `PUT` | `/suscripciones/:id/cancelar` | EMPRESA / ADMIN | Cancelar suscripción |

---

### 8.10 Empleados (gestión admin) — endpoints extendidos

| Método | Endpoint | Rol | Descripción |
|--------|----------|-----|-------------|
| `GET` | `/empleados` | EMPRESA / ADMIN | Listar con filtros |
| `GET` | `/empleados/:id` | EMPRESA / ADMIN | Ver detalle |
| `PUT` | `/empleados/:id` | EMPRESA / ADMIN | Editar información |
| `PUT` | `/empleados/:id/desactivar` | EMPRESA / ADMIN | Desactivar empleado |
| `GET` | `/empleados/:id/asistencias` | EMPRESA / ADMIN | Ver asistencias |
| `GET` | `/empleados/:id/paradas` | EMPRESA / ADMIN | Ver paradas asignadas |

---

### 8.11 Relaciones Completas (futuras)

| Entidad A | Cardinalidad | Entidad B | Descripción |
|-----------|-------------|-----------|-------------|
| Empresa | 1 : N | Obra | Una empresa tiene muchas obras |
| Obra | 1 : N | Parada | Una obra tiene muchas paradas |
| Empresa | 1 : N | Empleado | Una empresa tiene muchos empleados |
| Empleado | N : M | Parada | Via EmpleadoParada |
| Empleado | 1 : N | RegistroAsistencia | Un empleado tiene muchos registros |
| Parada | 1 : N | RegistroAsistencia | Una parada tiene muchos registros |
| Empleado | 1 : N | SolicitudIngreso | Un empleado puede enviar muchas solicitudes |
| Obra | 1 : N | SolicitudIngreso | Una obra recibe muchas solicitudes |
| Empleado | 1 : N | CronogramaPago | Un empleado tiene múltiples cronogramas |
| Empresa | 1 : N | CronogramaPago | Una empresa genera cronogramas |
| Usuario | 1 : N | Valoracion (emisor) | Un usuario emite muchas valoraciones |
| Usuario | 1 : N | Valoracion (receptor) | Un usuario recibe muchas valoraciones |
| Usuario | 1 : N | TokenRecuperacion | Un usuario puede tener tokens |
| Empresa | 1 : N | Suscripcion | Una empresa tiene múltiples suscripciones |
| PlanSuscripcion | 1 : N | Suscripcion | Un plan puede estar contratado por muchas empresas |
| Empresa | 1 : 1 | Suscripcion (activa) | Una empresa tiene una suscripción activa a la vez |

---

*Documento actualizado — Junio 2026. Versión actual refleja módulos implementados (Auth, Usuarios, Obras, Solicitudes, Empleados). Secciones 8.x documentan el diseño original de módulos futuros.*
