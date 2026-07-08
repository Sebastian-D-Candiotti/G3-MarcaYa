# MarcaYA 🏗️

Sistema de registro de asistencia laboral con validación GPS en tiempo real.

- **Backend**: Ruby on Rails 8.1 + PostgreSQL (API REST)
- **Frontend**: Flutter (Web / Android / iOS)

---

## 📋 Requisitos previos

| Herramienta  | Versión    | Windows                          | Mac                               |
|-------------|-----------|----------------------------------|-----------------------------------|
| Ruby        | 4.0.x     | [rubyinstaller.org](https://rubyinstaller.org) + **Devkit** | `brew install ruby@4.0` |
| Rails       | 8.1.x     | `gem install rails`              | `gem install rails`               |
| PostgreSQL  | 16+       | [postgresql.org/download/windows](https://www.postgresql.org/download/windows/) | `brew install postgresql@16` |
| Flutter     | 3.x       | [docs.flutter.dev/get-started](https://docs.flutter.dev/get-started/install/windows) | [docs.flutter.dev/get-started](https://docs.flutter.dev/get-started/install/macos) |
| Bundler     | —         | `gem install bundler`            | `gem install bundler`             |

---

## 🚀 Inicio rápido — Backend

### 1. Clonar e instalar dependencias

```bash
# Entrar al proyecto backend
cd BackEND/MarcaYa-Backend

# Instalar gems
bundle install
```

### 2. Configurar PostgreSQL

Editar `config/database.yml` y cambiar `password` por tu contraseña local de PostgreSQL:

```yaml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  host: 127.0.0.1
  username: postgres
  password: TU_CONTRASEÑA    # ← cambiar esto
  port: 5432
```

### 3. Crear base de datos y migrar

```bash
# Windows (PowerShell)
rails db:create; if ($?) { rails db:migrate }

# Mac / Linux
rails db:create && rails db:migrate
```

### 4. Sembrar datos de prueba

```bash
rails db:seed
```

Esto crea los usuarios por defecto (ver más abajo).

### 5. Iniciar servidor

```bash
rails s -b 0.0.0.0 -p 3000
```

El backend queda disponible en `http://localhost:3000/api/v1`.

---

## 🚀 Inicio rápido — Frontend (Flutter)

### 1. Entrar al proyecto

```bash
cd FrontEND/MarcaYa
```

### 2. Obtener dependencias

```bash
flutter pub get
```

### 3. Configurar URL del backend

Editar `lib/src/api_service.dart` y verificar la constante `kBaseUrl`:

```dart
const String kBaseUrl = 'http://localhost:3000/api/v1';
```

### 4. Ejecutar

```bash
# Web
flutter run -d chrome

# O web-server en un puerto específico
flutter run -d web-server --web-hostname 127.0.0.1 --web-port 5174
```

---

## 🔐 Credenciales de prueba

Después de ejecutar `rails db:seed`, tenés estos usuarios:

| Rol       | Correo                  | Contraseña |
|-----------|------------------------|------------|
| Empresa   | `empresa@marcaya.com`  | `123456`   |
| Empleado  | `empleado@marcaya.com` | `123456`   |
| Empleado  | `maria@marcaya.com`    | `123456`   |
| Empleado  | `juan@marcaya.com`     | `123456`   |

### ¿Qué incluye el seed?

- **Empresa**: Constructora Lima S.A.C. (RUC 20123456789)
- **Empleado 1**: Carlos García — asignado a obra #1, con marca de entrada registrada
- **Empleado 2**: María López — asignada a ambas obras, con marca de entrada registrada
- **Obra #1**: "Edificio Corporativo Miraflores" (Av. Larco 456, Lima)
  - Coordenadas: -12.119, -77.034 | Radio: 100 m | Horario: 08:00 – 18:00
  - Parada: "Puerta principal" (geocerca de 50 m)
- **Obra #2**: "Centro Comercial San Isidro" (Av. Javier Prado 789)
  - Coordenadas: -12.098, -77.032 | Radio: 80 m | Horario: 07:00 – 19:00
  - Parada: "Ingreso vehicular" (geocerca de 40 m)
- **Asignaciones**: Carlos → obra #1, María → obra #1 y obra #2
- **Empleado-Parada**: cada empleado puede marcar en las paradas de sus obras
- **Registros de asistencia**: marcas de entrada de prueba para Carlos y María
- **Empleado sin empresa**: Juan Pérez — usuario sin asignaciones ni solicitudes, ideal para probar el flujo de "Solicitar ingreso"

---

## 📡 Endpoints principales

### Autenticación
| Método | Ruta                    |
|--------|-------------------------|
| POST   | `/api/v1/auth/login`    |
| POST   | `/api/v1/auth/registro` |

### Asistencia
| Método | Ruta                                      | Descripción                        |
|--------|-------------------------------------------|------------------------------------|
| POST   | `/api/v1/asistencia/marcar-entrada`       | Marcar entrada del empleado        |
| POST   | `/api/v1/asistencia/marcar-salida`        | Marcar salida del empleado         |
| GET    | `/api/v1/asistencia/historial`            | Historial del empleado autenticado |
| GET    | `/api/v1/asistencia/historial/:empleado_id` | Historial de un empleado (empresa) |
| GET    | `/api/v1/asistencia/tiempo-real`          | Estado en tiempo real (empresa)    |
| GET    | `/api/v1/asistencia/tiempo-real/:parada_id` | Asistencia por parada (empresa)  |

### Perfil
| Método | Ruta                     | Descripción                     |
|--------|--------------------------|---------------------------------|
| GET    | `/api/v1/perfil`         | Perfil del usuario autenticado  |
| PUT    | `/api/v1/perfil`         | Actualizar perfil propio        |
| GET    | `/api/v1/usuarios/:id`   | Perfil público de un usuario    |

### Obras y Paradas
| Método | Ruta                              | Descripción                       |
|--------|-----------------------------------|-----------------------------------|
| GET    | `/api/v1/obras`                   | Listar obras (filtro ?empresa_id=)|
| POST   | `/api/v1/obras`                   | Crear obra                        |
| GET    | `/api/v1/obras/:id`               | Detalle de obra                   |
| PUT    | `/api/v1/obras/:id`               | Actualizar obra                   |
| DELETE | `/api/v1/obras/:id`               | Eliminar obra                     |
| GET    | `/api/v1/obras/:id/paradas`       | Paradas de una obra               |
| POST   | `/api/v1/obras/:id/paradas`       | Crear parada en obra              |
| GET    | `/api/v1/paradas/:id`             | Detalle de parada                 |
| PUT    | `/api/v1/paradas/:id`             | Actualizar parada                 |
| DELETE | `/api/v1/paradas/:id`             | Eliminar parada                   |
| GET    | `/api/v1/paradas/:id/empleados`   | Empleados asignados a parada      |
| POST   | `/api/v1/paradas/:id/empleados`   | Asignar empleado a parada         |
| DELETE | `/api/v1/paradas/:id/empleados/:empleado_id` | Desasignar empleado    |

### Solicitudes de Ingreso
| Método | Ruta                                      | Descripción                        |
|--------|-------------------------------------------|------------------------------------|
| GET    | `/api/v1/solicitudes`                     | Listar solicitudes (empresa)       |
| POST   | `/api/v1/solicitudes`                     | Crear solicitud (empleado)         |
| GET    | `/api/v1/solicitudes/mis-solicitudes`     | Solicitudes del empleado autent.   |
| GET    | `/api/v1/solicitudes/:id`                 | Detalle de solicitud               |
| PUT    | `/api/v1/solicitudes/:id/aceptar`         | Aceptar solicitud (empresa)        |
| PUT    | `/api/v1/solicitudes/:id/rechazar`        | Rechazar solicitud (empresa)       |

### Empleados
| Método | Ruta                                   | Descripción                        |
|--------|----------------------------------------|------------------------------------|
| GET    | `/api/v1/empleados`                    | Listar empleados                   |
| GET    | `/api/v1/empleados/actuales`           | Empleados activos de la empresa    |
| GET    | `/api/v1/empleados/:id`                | Detalle de empleado                |
| PUT    | `/api/v1/empleados/:id`                | Actualizar empleado                |
| PUT    | `/api/v1/empleados/:id/desactivar`     | Desactivar empleado                |
| GET    | `/api/v1/empleados/:id/asistencias`    | Asistencias de un empleado         |
| GET    | `/api/v1/empleados/:id/paradas`        | Paradas asignadas a un empleado    |
| GET    | `/api/v1/empleados/:id/obras`          | Obras de un empleado               |
| GET    | `/api/v1/empleados/:id/historial_solicitudes` | Solicitudes de un empleado  |

### Valoraciones
| Método | Ruta                                     | Descripción                    |
|--------|------------------------------------------|--------------------------------|
| POST   | `/api/v1/valoraciones`                   | Crear valoración               |
| GET    | `/api/v1/valoraciones/:usuario_id`       | Listar valoraciones            |
| GET    | `/api/v1/valoraciones/:usuario_id/promedio` | Promedio de puntuación     |

Ver `BackEND/MarcaYa-Backend/config/routes.rb` para la lista completa.

---

## 🧪 Tests

### Backend (Rails)

```bash
cd BackEND/MarcaYa-Backend
rails test
```

### Frontend (Flutter)

```bash
cd FrontEND/MarcaYa
flutter test
```

---

## 🏗️ Arquitectura

### Backend (Rails — Hexagonal / Puertos y Adaptadores)

```
app/
├── domain/          # Entidades, Value Objects, Servicios de dominio
│   ├── entities/
│   └── services/
├── application/     # Casos de uso, Fachadas
│   ├── use_cases/
│   └── facades/
├── infrastructure/  # Adaptadores (ORM repos, servicios externos)
│   ├── repositories/
│   └── services/
├── ports/           # Interfaces de puertos (driving / driven)
└── controllers/     # API endpoints (Rails controllers)
```

### Frontend (Flutter — Provider + GoRouter)

```
lib/
├── src/
│   ├── api_service.dart    → Cliente HTTP singleton con JWT
│   ├── app_state.dart      → Estado global de la app
│   └── app_user.dart       → Modelo de usuario
├── providers/
│   └── auth_provider.dart  → Provider de autenticación
├── pages/                  → Pantallas organizadas por funcionalidad
├── components/             → Widgets reutilizables (BottomNav, etc.)
└── router/
    └── app_router.dart     → Configuración de go_router
```

---

## 📁 Estructura del repositorio

```
MarcaYa/
├── BackEND/
│   └── MarcaYa-Backend/    → Rails API (arquitectura hexagonal)
└── FrontEND/
    └── MarcaYa/             → Flutter app (Provider + go_router)
```

### Frontend — páginas principales

| Ruta | Descripción |
|------|-------------|
| `/login` | Inicio de sesión |
| `/empleado` | Home empleado con BottomNav (5 tabs) |
| `/empleado/perfil` | Perfil del empleado |
| `/empleado/perfil/editar` | Editar perfil del empleado |
| `/empresa` | Home empresa con BottomNav (5 tabs: Inicio, Buscar, Solicitudes, Obras, Perfil) |
| `/empresa/perfil` | Perfil de la empresa |
| `/empresa/perfil/editar` | Editar perfil empresa |
| `/empresa/obras` | Lista de obras de la empresa |
| `/empresa/obras/:obraId/paradas` | Paradas de una obra |
| `/empresa/obras/editar-parada/:paradaId` | Editar parada |
| `/empresa/obras/ver-asistencia/:paradaId` | Asistencia por parada |
| `/empresa/empleados` | Empleados actuales (agrupados por obra) |
| `/empresa/nueva-obra` | Crear nueva obra |
| `/perfil-publico` | Perfil público de usuario (con solicitar-ingreso) |
| `/solicitudes` | Gestionar solicitudes (empresa) |

---

## ⚠️ Solución de problemas comunes

### PostgreSQL — "FATAL: password authentication failed"
- Verificá que el password en `config/database.yml` coincida con tu PostgreSQL local
- En Windows: pgAdmin → Properties → Connection → Password
- En Mac: `brew services restart postgresql@16`

### Flutter — "No Flutter SDK found"
- Descargalo de [flutter.dev](https://docs.flutter.dev/get-started/install)
- O usá el PATH completo: `C:\ruta\a\flutter\bin\flutter.bat` (Windows)

### BCrypt — "LoadError: cannot load such file"
```bash
gem install bcrypt --platform=ruby
```

### "No autorizado" al crear obra o ver asistencia
- Verificá que el frontend use `ApiService.instance.crearObra()` (no `http.post` directo)
- Si el backend devuelve 401, el token puede haber expirado (vigencia: 24 h). Re-login.
- Si es un endpoint de asistencia, asegurate de que las rutas usen `'asistencia/...'` (sin `namespace`), porque el controlador es `Api::V1::AsistenciasController`, no `Api::V1::Asistencia::AsistenciasController`.

### "Error al cargar empleados" en EmpleadosActualesPage
- El backend trae TODOS los empleados activos (sin filtrar por empresa). Si un empleado no tiene datos de asistencia, igual funciona, pero si el endpoint `GET /asistencia/historial/:id` falla, se dispara el error genérico.
- Verificá que el servidor Rails esté corriendo y las rutas de asistencia estén correctas.

### Al reiniciar el backend, los tokens anteriores dejan de funcionar
- Si cambiás `secret_key_base` (ej: nuevo `credentials.yml.enc`), todos los tokens JWT existentes se invalidan.
- Solución: volvé a iniciar sesión desde la app.
