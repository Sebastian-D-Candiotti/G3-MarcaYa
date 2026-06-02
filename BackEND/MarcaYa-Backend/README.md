# MarcaYa-Backend 🚀

API REST de MarcaYA — Ruby on Rails 8.1 + PostgreSQL.

## Requisitos

- Ruby 4.0.x
- Rails 8.1.x
- PostgreSQL 16+
- Bundler

## Inicio rápido

```bash
# 1. Dependencias
bundle install

# 2. Configurar database.yml (cambiar password de PostgreSQL)
#    Ver: config/database.yml

# 3. Crear BD y migrar
rails db:create
rails db:migrate

# 4. Sembrar datos de prueba
rails db:seed

# 5. Iniciar servidor
rails s -b 0.0.0.0 -p 3000
```

## Credenciales de prueba (después de db:seed)

| Rol       | Correo                  | Contraseña |
|-----------|------------------------|------------|
| Empresa   | empresa@marcaya.com    | 123456     |
| Empleado  | empleado@marcaya.com   | 123456     |

## Tests

```bash
rails test
```

## Arquitectura

```
app/
├── controllers/api/v1/    → Endpoints REST
├── application/
│   ├── facades/           → Fachadas (punto de entrada a use cases)
│   └── use_cases/         → Casos de uso
├── domain/
│   ├── entities/          → Entidades de dominio
│   ├── value_objects/     → Value Objects (CoordenadaGps, etc.)
│   └── services/          → Servicios de dominio (GPS validation, etc.)
├── infrastructure/
│   ├── repositories/      → Implementaciones AR de repositorios
│   ├── orm/               → Active Record models (persistencia)
│   ├── mappers/           → Mappers ORM ←→ Entidad
│   └── services/          → Servicios infra (BCrypt, JWT)
├── ports/
│   ├── driving/           → Interfaces de entrada (facades)
│   └── driven/            → Interfaces de salida (repos)
└── models/                → Active Record models (solo para queries directas)
```

Ver el `README.md` raíz del proyecto para instrucciones completas de setup.
