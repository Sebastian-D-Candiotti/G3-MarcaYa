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

### ¿Qué incluye el seed?

- **Empresa**: Constructora Lima S.A.C. (RUC 20123456789)
- **Empleado**: Carlos García, asignado a la obra
- **Obra**: Edificio Corporativo Miraflores (Av. Larco 456, Lima)
  - Coordenadas: -12.119, -77.034
  - Radio de geocerca: 100 m
  - Horario: 08:00 – 18:00
- **Parada**: Puerta principal (geocerca de 50 m)
- **Asignación**: empleado → obra (activa)
- **Empleado-Parada**: empleado puede marcar en la parada

---

## 📡 Endpoints principales

### Autenticación
| Método | Ruta                    |
|--------|-------------------------|
| POST   | `/api/v1/auth/login`    |
| POST   | `/api/v1/auth/registro` |

### Asistencia
| Método | Ruta                                      |
|--------|-------------------------------------------|
| POST   | `/api/v1/asistencia/marcar-entrada`       |
| POST   | `/api/v1/asistencia/marcar-salida`        |
| GET    | `/api/v1/asistencia/historial`            |
| GET    | `/api/v1/asistencia/tiempo-real`          |

### Perfil
| Método | Ruta                     |
|--------|--------------------------|
| GET    | `/api/v1/perfil`         |
| PUT    | `/api/v1/perfil`         |

### Obras y Paradas
| Método | Ruta                              |
|--------|-----------------------------------|
| GET    | `/api/v1/obras`                   |
| GET    | `/api/v1/obras/:id/paradas`       |
| POST   | `/api/v1/obras/:id/paradas`       |
| GET    | `/api/v1/empleados/:id/paradas`   |

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

## 🏗️ Arquitectura — Backend

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

---

## 📁 Estructura del repositorio

```
MarcaYa/
├── BackEND/
│   └── MarcaYa-Backend/    → Rails API
└── FrontEND/
    └── MarcaYa/             → Flutter app
```

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
