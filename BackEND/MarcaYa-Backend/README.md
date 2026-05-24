# MarcaYa-Backend 🚀

Backend desarrollado en Ruby on Rails para el sistema MarcaYa.  
Este proyecto funciona como API REST conectada a PostgreSQL y consumida desde Flutter.

---

# 📋 Requisitos Previos

Antes de ejecutar el proyecto, instalar:

- Ruby 4.x
- Ruby on Rails 8.x
- PostgreSQL
- Git
- Bundler

---

# 📦 Instalación del Proyecto

## 1. Clonar repositorio

```bash
git clone URL_DEL_REPOSITORIO
```

## 2. Entrar al proyecto

```bash
cd MarcaYa-Backend
```

## 3. Instalar dependencias

```bash
bundle install
```

---

# 🐘 Configuración PostgreSQL

## Crear base de datos PostgreSQL

Abrir pgAdmin o SQL Shell y ejecutar:

```sql
CREATE DATABASE "MarcaYa";
```

---

# ⚙️ Configurar `database.yml`

Abrir:

```text
config/database.yml
```

y verificar:

```yml
default: &default
  adapter: postgresql
  encoding: unicode
  pool: 5
  host: 127.0.0.1
  username: postgres
  password: TU_PASSWORD
  port: 5432

development:
  <<: *default
  database: MarcaYa
```

⚠️ Reemplazar `TU_PASSWORD` por la contraseña local de PostgreSQL.

---

# 🛠️ Migraciones

Crear tablas automáticamente:

```bash
rails db:create
```

Luego:

```bash
rails db:migrate
```

---

# 🌱 Datos Iniciales (Opcional)

Insertar datos de prueba:

```bash
rails db:seed
```

---

# ▶️ Levantar Backend

Ejecutar:

```bash
rails s -b 0.0.0.0
```

El backend quedará disponible en:

```text
http://localhost:3000
```

---

# 🌐 API Base URL

```text
http://localhost:3000/api/v1
```

---

# 🔑 Login de Prueba

## Empresa

```text
Correo:
empresa@markaya.com

Contraseña:
123456
```

## Empleado

```text
Correo:
empleado@markaya.com

Contraseña:
123456
```

---

# 📁 Estructura Principal

```text
app/
 ├── controllers/
 ├── models/
 ├── services/
 └── views/

db/
 ├── migrate/
 └── seeds.rb
```

---

# 🚀 Tecnologías Utilizadas

- Ruby on Rails
- PostgreSQL
- Flutter
- Git