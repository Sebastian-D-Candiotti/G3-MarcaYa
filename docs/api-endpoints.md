# MarcaYA — API Endpoints Reference

> **Backend:** Rails 8.1 · PostgreSQL · JWT + bcrypt  
> **Base URL:** `http://localhost:3000/api/v1`  
> **Auth:** Bearer token in `Authorization` header

---

## Autenticación

### POST `/auth/login`

Login con correo y contraseña. Devuelve JWT.

**Request:**
```json
{
  "correo": "usuario@ejemplo.com",
  "clave": "password123"
}
```

**Response 200:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "usuario": {
    "id": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "correo": "usuario@ejemplo.com",
    "rol": "empleado"
  }
}
```

**Errors:**
- `401` — Credenciales inválidas

---

### POST `/auth/registro`

Registrar nuevo usuario.

**Request:**
```json
{
  "nombre": "Juan",
  "apellido": "Pérez",
  "correo": "juan@ejemplo.com",
  "clave": "password123",
  "telefono": "1234567890",
  "rol": "empleado"
}
```

**Response 201:**
```json
{
  "token": "eyJhbGciOiJIUzI1NiJ9...",
  "usuario": { ... }
}
```

---

## Usuarios

### GET `/usuarios`

Listar todos los usuarios.

**Response 200:**
```json
[
  {
    "id": 1,
    "nombre": "Juan",
    "apellido": "Pérez",
    "correo": "juan@ejemplo.com",
    "rol": "empleado",
    "activo": true
  }
]
```

---

### GET `/usuarios/:id`

Ver perfil de usuario.

**Response 200:**
```json
{
  "id": 1,
  "nombre": "Juan",
  "apellido": "Pérez",
  "correo": "juan@ejemplo.com",
  "telefono": "1234567890",
  "rol": "empleado",
  "activo": true,
  "created_at": "2026-01-15T10:00:00Z"
}
```

---

### PUT `/usuarios/:id`

Actualizar usuario.

**Request:**
```json
{
  "nombre": "Juan Carlos",
  "telefono": "0987654321"
}
```

**Response 200:** Usuario actualizado

---

### PATCH `/usuarios/:id/desactivar`

Desactivar cuenta (baja lógica).

**Response 200:**
```json
{ "mensaje": "Usuario desactivado correctamente" }
```

---

## Obras

### GET `/obras`

Listar obras.

**Response 200:**
```json
[
  {
    "id": 1,
    "nombre": "Edificio Central",
    "direccion": "Av. Principal 123",
    "latitud": -34.6033,
    "longitud": -58.3816,
    "activa": true
  }
]
```

---

### POST `/obras`

Crear obra (EMPRESA/ADMIN).

**Request:**
```json
{
  "nombre": "Nuevo Edificio",
  "direccion": "Calle Secundaria 456",
  "latitud": -34.6050,
  "longitud": -58.3820
}
```

**Response 201:** Obra creada

---

### GET `/obras/:id`

Ver detalle de obra.

---

### PUT `/obras/:id`

Actualizar obra (EMPRESA/ADMIN).

---

### DELETE `/obras/:id`

Eliminar obra (EMPRESA/ADMIN).

---

### GET `/obras/:id/paradas`

Listar paradas de una obra.

**Response 200:**
```json
[
  {
    "id": 1,
    "nombre": "Entrada Principal",
    "latitud": -34.6033,
    "longitud": -58.3816,
    "radioMetros": 100,
    "obraId": 1
  }
]
```

---

### POST `/obras/:id/paradas`

Crear parada en una obra (EMPRESA/ADMIN).

**Request:**
```json
{
  "nombre": "Parada Norte",
  "latitud": -34.6040,
  "longitud": -58.3810,
  "radio_metros": 50
}
```

**Response 201:** Parada creada

---

## Paradas

### GET `/paradas/:id`

Ver detalle de parada.

---

### PUT `/paradas/:id`

Actualizar parada (EMPRESA/ADMIN).

**Request:**
```json
{
  "nombre": "Entrada Principal (actualizado)",
  "latitud": -34.6035,
  "longitud": -58.3818,
  "radio_metros": 120
}
```

---

### DELETE `/paradas/:id`

Eliminar parada (EMPRESA/ADMIN).

---

### GET `/paradas/:id/empleados`

Listar empleados asignados a una parada (EMPRESA/ADMIN).

**Response 200:**
```json
[
  {
    "id": 1,
    "empleadoId": 1,
    "paradaId": 1,
    "activo": true,
    "created_at": "2026-01-15T10:00:00Z"
  }
]
```

---

### POST `/paradas/:id/empleados`

Asignar empleado a parada (EMPRESA/ADMIN).

**Request:**
```json
{
  "empleado_id": 1
}
```

**Response 201:** Asignación creada

**Errors:**
- `422` — Empleado no pertenece a la obra
- `422` — Empleado ya está asignado activamente

---

### DELETE `/paradas/:id/empleados/:empleado_id`

Desasignar empleado de parada (EMPRESA/ADMIN). Desactivación lógica.

**Response 200:**
```json
{ "mensaje": "Empleado desasignado correctamente" }
```

---

## Solicitudes de Ingreso

### GET `/solicitudes`

Listar solicitudes pendientes.

---

### POST `/solicitudes`

Crear solicitud de ingreso a una obra.

**Request:**
```json
{
  "obra_id": 1,
  "mensaje": "Solicito ingreso al proyecto"
}
```

---

### PUT `/solicitudes/:id/aceptar`

Aceptar solicitud (EMPRESA/ADMIN).

---

### PUT `/solicitudes/:id/rechazar`

Rechazar solicitud (EMPRESA/ADMIN).

---

### GET `/empleados/:id/obras`

Ver obras asignadas a un empleado.

---

### GET `/empleados/:id/historial_solicitudes`

Historial de solicitudes de un empleado.

---

## Empleados

### GET `/empleados`

Listar empleados (EMPRESA/ADMIN).

---

### GET `/empleados/actuales`

Listar empleados activos.

---

### GET `/empleados/:id`

Ver detalle de empleado.

---

### POST `/empleados`

Crear empleado (EMPRESA/ADMIN).

---

### PUT `/empleados/:id`

Actualizar empleado (EMPRESA/ADMIN).

---

### DELETE `/empleados/:id`

Eliminar empleado (EMPRESA/ADMIN).

---

## Asistencia

### POST `/asistencia/marcar-entrada`

Registrar entrada con validación GPS. Solo EMPLEADO.

**Headers:**
```
Authorization: Bearer <token>
Content-Type: application/json
```

**Request:**
```json
{
  "parada_id": 1,
  "latitud": -34.6033,
  "longitud": -58.3816
}
```

**Response 201:**
```json
{
  "id": 1,
  "empleadoId": 1,
  "paradaId": 1,
  "tipoMarcacion": "ENTRADA",
  "fechaHora": "2026-06-01T08:00:00Z",
  "latitudRegistrada": -34.6033,
  "longitudRegistrada": -58.3816,
  "validaGps": true,
  "duracionJornada": null,
  "observaciones": null
}
```

**Errors:**
- `404` — No se encontró empleado asociado al usuario
- `404` — Parada no encontrada
- `422` — Empleado no asignado a esta parada
- `422` — Ya existe una entrada activa para hoy
- `403` — No autorizado (no es empleado)

**Notas:**
- `validaGps` será `false` si las coordenadas están fuera del radio de la parada
- Si es fuera de zona, se guarda el registro pero con `observaciones: "Fuera de zona"`

---

### POST `/asistencia/marcar-salida`

Registrar salida con validación GPS. Solo EMPLEADO.

**Request:**
```json
{
  "parada_id": 1,
  "latitud": -34.6033,
  "longitud": -58.3816
}
```

**Response 201:**
```json
{
  "id": 2,
  "empleadoId": 1,
  "paradaId": 1,
  "tipoMarcacion": "SALIDA",
  "fechaHora": "2026-06-01T17:00:00Z",
  "latitudRegistrada": -34.6033,
  "longitudRegistrada": -58.3816,
  "validaGps": true,
  "duracionJornada": 540,
  "observaciones": null
}
```

**Errors:**
- `404` — No hay entrada activa para hoy
- `403` — No autorizado

**Notas:**
- `duracionJornada` está en **minutos** (540 = 9 horas)
- Se calcula automáticamente: `(hora_salida - hora_entrada) / 60`

---

### GET `/asistencia/historial`

Ver historial personal de asistencia. Solo EMPLEADO.

**Response 200:**
```json
[
  {
    "id": 1,
    "empleadoId": 1,
    "paradaId": 1,
    "tipoMarcacion": "ENTRADA",
    "fechaHora": "2026-06-01T08:00:00Z",
    "latitudRegistrada": -34.6033,
    "longitudRegistrada": -58.3816,
    "validaGps": true,
    "duracionJornada": null,
    "observaciones": null
  },
  {
    "id": 2,
    "empleadoId": 1,
    "paradaId": 1,
    "tipoMarcacion": "SALIDA",
    "fechaHora": "2026-06-01T17:00:00Z",
    "latitudRegistrada": -34.6033,
    "longitudRegistrada": -58.3816,
    "validaGps": true,
    "duracionJornada": 540,
    "observaciones": null
  }
]
```

---

### GET `/asistencia/historial/:empleado_id`

Ver historial de asistencia de un empleado. EMPRESA/ADMIN.

**Response 200:** Mismo formato que historial personal.

---

### GET `/asistencia/tiempo-real`

Estado actual de asistencia en todas las paradas. EMPRESA/ADMIN.

**Response 200:**
```json
{
  "1": {
    "empleado_id": 1,
    "parada_id": 1,
    "tipo_marcacion": "ENTRADA",
    "fecha_hora": "2026-06-01T08:00:00Z",
    "latitud_registrada": -34.6033,
    "longitud_registrada": -58.3816,
    "valida_gps": true
  },
  "2": {
    "empleado_id": 2,
    "parada_id": 1,
    "tipo_marcacion": "ENTRADA",
    "fecha_hora": "2026-06-01T08:15:00Z",
    "latitud_registrada": -34.6035,
    "longitud_registrada": -58.3818,
    "valida_gps": true
  }
}
```

**Notas:**
- Retorna el **último registro** de cada empleado (el más reciente)
- Si el último registro es ENTRADA → el empleado está "presente"
- Si el último registro es SALIDA → el empleado se fue

---

### GET `/asistencia/tiempo-real/:parada_id`

Estado actual de una parada específica. EMPRESA/ADMIN.

**Response 200:** Mismo formato, solo empleados de esa parada.

---

## Errores Generales

Todos los endpoints pueden devolver:

| Código | Significado |
|--------|-------------|
| `401` | No autenticado (token inválido o ausente) |
| `403` | No autorizado (rol insuficiente) |
| `404` | Recurso no encontrado |
| `422` | Error de validación |
| `500` | Error interno del servidor |

**Formato de error:**
```json
{
  "error": "Mensaje descriptivo del error"
}
```

---

## Roles

| Rol | Permisos |
|-----|----------|
| `empleado` | Marcar entrada/salida, ver historial propio |
| `empresa` | Ver historial de cualquier empleado, tiempo real, CRUD obras/paradas/empleados |
| `admin` | Todo lo de empresa + gestión de usuarios |

---

## GPS Validation

El sistema valida si las coordenadas GPS están dentro del radio configurado de la parada:

- **Fórmula:** Haversine (distancia en metros entre dos puntos)
- **Radio configurable:** Cada parada tiene un `radio_metros` (ej: 100m)
- **Comportamiento:**
  - Dentro del radio → `validaGps: true`
  - Fuera del radio → `validaGps: true` BUT `observaciones: "Fuera de zona"`
  - El registro **siempre se guarda**, no se bloquea por GPS

---

## Estado de Implementación

| Módulo | Estado | Endpoints |
|--------|--------|-----------|
| Auth | ✅ Completo | 2 |
| Usuarios | ✅ Completo | 4 |
| Obras | ✅ Completo | 5 + 2 paradas |
| Paradas | ✅ Completo | 3 + 3 empleados |
| Solicitudes | ✅ Completo | 4 |
| Empleados | ✅ Completo | 6 |
| **Asistencia** | ✅ **Completo** | **6** |
| Reportes | ❌ Pendiente | 0 |
| Cronograma | ❌ Pendiente | 0 |
| Valoraciones | ❌ Pendiente | 0 |
| Suscripciones | ❌ Pendiente | 0 |
| Password Reset | ❌ Pendiente | 0 |

**Total endpoints implementados: 33**
