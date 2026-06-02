# Delta Spec: Asistencia Module

## Capability

**attendance-marking** — GPS-validated ENTRY/EXIT attendance registration with geofence checks, state management (no double-entry), and work duration calculation.

**attendance-history** — Employee personal history and company-wide employee attendance history queries.

**attendance-monitoring** — Real-time stop-level attendance status for EMPRESA/ADMIN roles.

---

## Entity: RegistroAsistencia

**Table:** `registro_asistencias`

| Column | Type | Constraints | Description |
|--------|------|-------------|-------------|
| id | bigint | PK, auto | Primary key |
| empleado_id | bigint | FK → empleados, NOT NULL | Employee who marked |
| parada_id | bigint | FK → paradas, NOT NULL | Stop where marked |
| tipo_marcacion | varchar(10) | NOT NULL, CHECK IN ('ENTRADA', 'SALIDA') | Mark type |
| fecha_hora | datetime | NOT NULL, default CURRENT_TIMESTAMP | When the mark was recorded |
| latitud registrada | float | NOT NULL | GPS latitude at mark time |
| longitud registrada | float | NOT NULL | GPS longitude at mark time |
| valida_gps | boolean | NOT NULL, default false | Whether GPS was within geofence |
| duracion_jornada | integer | nullable | Work duration in minutes (set at EXIT) |
| observaciones | text | nullable | Free-text notes (e.g. "Fuera de zona") |
| created_at | datetime | NOT NULL | Record creation timestamp |
| updated_at | datetime | NOT NULL | Record update timestamp |

**Indexes:**
- Unique partial: `(empleado_id, fecha_hora)` WHERE `tipo_marcacion = 'ENTRADA'` AND `duracion_jornada IS NULL` — enforces single active entry per employee
- Composite: `(empleado_id, fecha_hora DESC)` — for personal history queries
- Composite: `(parada_id, fecha_hora DESC)` — for real-time per-parada queries

**Foreign Keys:**
- `empleado_id` → `empleados.id` (ON DELETE RESTRICT)
- `parada_id` → `paradas.id` (ON DELETE RESTRICT)

### Validations

- `empleado_id` MUST be present
- `parada_id` MUST be present
- `tipo_marcacion` MUST be 'ENTRADA' or 'SALIDA'
- `fecha_hora` MUST be present
- `latitud` MUST be numeric, in range [-90.0, 90.0]
- `longitud` MUST be numeric, in range [-180.0, 180.0]
- `duracion_jornada` MUST be nil for ENTRADA, MUST be a positive integer for SALIDA

---

## Value Object: TipoMarcacion

**File:** `app/domain/value_objects/tipo_marcacion.rb`

```
ENTRADA = "entrada"
SALIDA = "salida"
```

Methods: `entrada?`, `salida?`, `==`, `to_s`

---

## Domain Errors

New error classes to add in `app/domain/errors.rb`:

| Error Class | Extends | When Raised |
|-------------|---------|-------------|
| `AsistenciaNoEncontradaError` | `StandardError` | Active entry not found for SALIDA |
| `EntradaActivaExistenteError` | `ValidacionError` | Employee already has active entry today |
| `EmpleadoNoAsignadoParadaError` | `ValidacionError` | Employee not assigned to the parada |
| `ParadaInactivaError` | `ValidacionError` | Parada is not active |

---

## Use Cases

### 1. MarcarEntrada

**File:** `app/application/use_cases/asistencia/marcar_entrada.rb`

**Purpose:** Register an employee's entry at a geofenced stop.

**Dependencies (constructor):**
- `asistencia_repo` — `Ports::Driven::IAsistenciaRepository`
- `empleado_repo` — `Ports::Driven::IEmpleadoRepository`
- `parada_repo` — `Ports::Driven::IParadaRepository`
- `empleado_parada_repo` — `Ports::Driven::IEmpleadoParadaRepository`

**Input:** `{ empleado_id:, parada_id:, latitud:, longitud: }`

**Output:** `Domain::Entities::RegistroAsistencia` (persisted)

#### Scenarios

**Scenario 1: Successful entry mark within geofence**

```
Given an active employee "Juan" with id=1
  And an active parada "Entrada Principal" with id=10, latitud=-12.0, longitud=-77.0, radio_metros=50
  And employee "Juan" is assigned to parada "Entrada Principal" with activo=true
  And employee "Juan" has no active entry (no ENTRADA without matching SALIDA) for today
  And GPS coordinates (-12.001, -77.001) are within 50m of the parada
When MarcarEntrada is executed with empleado_id=1, parada_id=10, latitud=-12.001, longitud=-77.001
Then a RegistroAsistencia SHALL be created with tipo_marcacion=ENTRADA
  And valida_gps SHALL be true
  And duracion_jornada SHALL be nil
  And observaciones SHALL be nil
  And the record SHALL be persisted with the provided GPS coordinates and fecha_hora set to current time
```

**Scenario 2: Entry mark outside geofence (still recorded)**

```
Given an active employee "Juan" with id=1
  And an active parada "Entrada Principal" with id=10, latitud=-12.0, longitud=-77.0, radio_metros=50
  And employee "Juan" is assigned to parada "Entrada Principal" with activo=true
  And employee "Juan" has no active entry for today
  And GPS coordinates (-12.010, -77.010) are outside 50m of the parada
When MarcarEntrada is executed with empleado_id=1, parada_id=10, latitud=-12.010, longitud=-77.010
Then a RegistroAsistencia SHALL be created with tipo_marcacion=ENTRADA
  And valida_gps SHALL be false
  And observaciones SHALL be "Fuera de zona"
```

**Scenario 3: Duplicate entry prevention — active entry already exists**

```
Given an active employee "Juan" with id=1
  And employee "Juan" already has an ENTRADA record today without a matching SALIDA
When MarcarEntrada is executed with empleado_id=1, parada_id=10, latitud=-12.001, longitud=-77.001
Then an EntradaActivaExistenteError SHALL be raised
  And no new RegistroAsistencia SHALL be created
```

**Scenario 4: Employee does not exist**

```
Given no employee with id=999 exists
When MarcarEntrada is executed with empleado_id=999, parada_id=10, latitud=-12.001, longitud=-77.001
Then an ActiveRecord::RecordNotFound (or domain equivalent) SHALL be raised
  And no RegistroAsistencia SHALL be created
```

**Scenario 5: Parada does not exist**

```
Given no parada with id=999 exists
When MarcarEntrada is executed with empleado_id=1, parada_id=999, latitud=-12.001, longitud=-77.001
Then an ActiveRecord::RecordNotFound (or domain equivalent) SHALL be raised
  And no RegistroAsistencia SHALL be created
```

**Scenario 6: Employee not assigned to parada**

```
Given an active employee "Juan" with id=1
  And an active parada "Entrada Principal" with id=10
  And employee "Juan" is NOT assigned to parada "Entrada Principal"
When MarcarEntrada is executed with empleado_id=1, parada_id=10, latitud=-12.001, longitud=-77.001
Then an EmpleadoNoAsignadoParadaError SHALL be raised
  And no RegistroAsistencia SHALL be created
```

**Scenario 7: Employee assigned to parada but assignment is inactive (activo=false)**

```
Given an active employee "Juan" with id=1
  And an active parada "Entrada Principal" with id=10
  And employee "Juan" is assigned to parada "Entrada Principal" with activo=false
When MarcarEntrada is executed with empleado_id=1, parada_id=10, latitud=-12.001, longitud=-77.001
Then an EmpleadoNoAsignadoParadaError SHALL be raised
```

**Scenario 8: Parada is inactive**

```
Given an active employee "Juan" with id=1
  And an inactive parada "Entrada Principal" with id=10, estado="inactiva"
  And employee "Juan" is assigned to parada "Entrada Principal" with activo=true
When MarcarEntrada is executed with empleado_id=1, parada_id=10, latitud=-12.001, longitud=-77.001
Then a ParadaInactivaError SHALL be raised
```

---

### 2. MarcarSalida

**File:** `app/application/use_cases/asistencia/marcar_salida.rb`

**Purpose:** Register an employee's exit at a stop and calculate work duration.

**Dependencies (constructor):**
- `asistencia_repo` — `Ports::Driven::IAsistenciaRepository`

**Input:** `{ empleado_id:, parada_id:, latitud:, longitud: }`

**Output:** `Domain::Entities::RegistroAsistencia` (persisted, with `duracion_jornada` set)

#### Scenarios

**Scenario 1: Successful exit mark with duration calculation**

```
Given an active employee "Juan" with id=1
  And employee "Juan" has an active entry (ENTRADA without matching SALIDA) at parada_id=10
    recorded at 2026-06-01 08:00:00
When MarcarSalida is executed with empleado_id=1, parada_id=10, latitud=-12.001, longitud=-77.001
  at time 2026-06-01 17:00:00
Then a RegistroAsistencia SHALL be created with tipo_marcacion=SALIDA
  And duracion_jornada SHALL be 540 (minutes between 08:00 and 17:00)
  And fecha_hora SHALL be 2026-06-01 17:00:00
  And the entry record's duracion_jornada SHALL NOT be modified (duration is on the SALIDA record)
```

**Scenario 2: Exit mark — no active entry exists**

```
Given an active employee "Juan" with id=1
  And employee "Juan" has no active entry (no ENTRADA without matching SALIDA) for today
When MarcarSalida is executed with empleado_id=1, parada_id=10, latitud=-12.001, longitud=-77.001
Then an AsistenciaNoEncontradaError SHALL be raised with message "No se encontró una entrada activa para registrar salida"
  And no RegistroAsistencia SHALL be created
```

**Scenario 3: Exit mark when previous exit already recorded today**

```
Given an active employee "Juan" with id=1
  And employee "Juan" has an ENTRADA at 08:00 and a SALIDA at 12:00 for today
  And employee "Juan" has no active entry
When MarcarSalida is executed with empleado_id=1, parada_id=10, latitud=-12.001, longitud=-77.001
Then an AsistenciaNoEncontradaError SHALL be raised
```

**Scenario 4: Exit mark — GPS outside geofence (still recorded)**

```
Given an active employee "Juan" with id=1
  And employee "Juan" has an active entry at parada_id=10 recorded at 08:00
  And GPS coordinates (-12.010, -77.010) are outside 50m of the parada
When MarcarSalida is executed with empleado_id=1, parada_id=10, latitud=-12.010, longitud=-77.010
Then a RegistroAsistencia SHALL be created with tipo_marcacion=SALIDA
  And valida_gps SHALL be false
  And observaciones SHALL be "Fuera de zona"
  And duracion_jornada SHALL be calculated normally
```

---

### 3. HistorialPersonal

**File:** `app/application/use_cases/asistencia/historial_personal.rb`

**Purpose:** Return all attendance records for the authenticated employee.

**Dependencies (constructor):**
- `asistencia_repo` — `Ports::Driven::IAsistenciaRepository`

**Input:** `{ empleado_id: }`

**Output:** `Array<Domain::Entities::RegistroAsistencia>` ordered by `fecha_hora DESC`

#### Scenarios

**Scenario 1: Employee with attendance records**

```
Given employee "Juan" with id=1
  And "Juan" has 5 attendance records across multiple days
When HistorialPersonal is executed with empleado_id=1
Then 5 RegistroAsistencia records SHALL be returned
  And records SHALL be ordered by fecha_hora descending (most recent first)
  And each record SHALL include all fields (tipo_marcacion, fecha_hora, duracion_jornada, etc.)
```

**Scenario 2: Employee with no attendance records**

```
Given employee "Juan" with id=1
  And "Juan" has 0 attendance records
When HistorialPersonal is executed with empleado_id=1
Then an empty array SHALL be returned
```

---

### 4. HistorialEmpleado

**File:** `app/application/use_cases/asistencia/historial_empleado.rb`

**Purpose:** Return all attendance records for a specific employee (company/admin view).

**Dependencies (constructor):**
- `asistencia_repo` — `Ports::Driven::IAsistenciaRepository`

**Input:** `{ empleado_id: }`

**Output:** `Array<Domain::Entities::RegistroAsistencia>` ordered by `fecha_hora DESC`

#### Scenarios

**Scenario 1: Company admin views employee history**

```
Given employee "Juan" with id=1
  And "Juan" has 10 attendance records
When HistorialEmpleado is executed with empleado_id=1
Then 10 RegistroAsistencia records SHALL be returned
  And records SHALL be ordered by fecha_hora descending
```

**Scenario 2: Employee has no records**

```
Given employee "Maria" with id=2
  And "Maria" has 0 attendance records
When HistorialEmpleado is executed with empleado_id=2
Then an empty array SHALL be returned
```

---

### 5. TiempoReal

**File:** `app/application/use_cases/asistencia/tiempo_real.rb`

**Purpose:** Return current attendance status of all employees (last registro per employee), optionally filtered by parada.

**Dependencies (constructor):**
- `asistencia_repo` — `Ports::Driven::IAsistenciaRepository`

**Input:** `{ parada_id: nil }` (optional)

**Output:** `Array<Hash>` — each hash contains `:empleado_id`, `:empleado_nombre`, `:parada_id`, `:parada_nombre`, `:tipo_marcacion`, `:fecha_hora`, `:estado` (where estado is 'activo' if last mark is ENTRADA, 'inactivo' if SALIDA)

#### Scenarios

**Scenario 1: Real-time status across all paradas**

```
Given employee "Juan" (id=1) with last record: ENTRADA at parada 10 at 08:00
  And employee "Maria" (id=2) with last record: SALIDA at parada 20 at 12:00
  And employee "Pedro" (id=3) with no records
When TiempoReal is executed without parada_id
Then the result SHALL contain 2 entries (Juan and Maria; Pedro has no records)
  And Juan's entry SHALL show estado='activo', tipo_marcacion=ENTRADA, parada_id=10
  And Maria's entry SHALL show estado='inactivo', tipo_marcacion=SALIDA, parada_id=20
```

**Scenario 2: Real-time status for a specific parada**

```
Given employee "Juan" (id=1) with last record: ENTRADA at parada 10 at 08:00
  And employee "Maria" (id=2) with last record: ENTRADA at parada 10 at 09:00
  And employee "Pedro" (id=3) with last record: SALIDA from parada 10 at 11:00
When TiempoReal is executed with parada_id=10
Then the result SHALL contain 2 entries (Juan and Maria — currently at parada 10)
  And Pedro SHALL NOT be included (his last mark was SALIDA from parada 10)
```

**Scenario 3: No employees at any parada**

```
Given all employees have SALIDA as their last record
When TiempoReal is executed without parada_id
Then the result SHALL contain entries for each employee with estado='inactivo'
```

**Scenario 4: Empty database**

```
Given no attendance records exist
When TiempoReal is executed
Then an empty array SHALL be returned
```

---

## Ports

### Driven Port: IAsistenciaRepository

**File:** `app/ports/driven/i_asistencia_repository.rb`

| Method | Signature | Description |
|--------|-----------|-------------|
| `guardar` | `(registro)` → `RegistroAsistencia` | Persist a new attendance record |
| `entrada_activa` | `(empleado_id)` → `RegistroAsistencia \| nil` | Find active entry (ENTRADA without SALIDA today) |
| `historial_por_empleado` | `(empleado_id)` → `Array<RegistroAsistencia>` | All records for employee, ordered fecha_hora DESC |
| `ultimo_registro_por_empleado` | `()` → `Array<Hash>` | Last record per employee (for real-time) |
| `ultimo_registro_por_parada` | `(parada_id)` → `Array<Hash>` | Last record per employee at a specific parada |

### Driving Port: IGestionarAsistencia

**File:** `app/ports/driving/i_gestionar_asistencia.rb`

| Method | Signature | Description |
|--------|-----------|-------------|
| `marcar_entrada` | `(empleado_id:, parada_id:, latitud:, longitud:)` → `RegistroAsistencia` | Mark entry |
| `marcar_salida` | `(empleado_id:, parada_id:, latitud:, longitud:)` → `RegistroAsistencia` | Mark exit |
| `historial_personal` | `(empleado_id:)` → `Array<RegistroAsistencia>` | Personal history |
| `historial_empleado` | `(empleado_id:)` → `Array<RegistroAsistencia>` | Employee history (admin) |
| `tiempo_real` | `(parada_id: nil)` → `Array<Hash>` | Real-time status |

---

## Endpoints

### POST /api/v1/asistencia/marcar-entrada

| Property | Value |
|----------|-------|
| Auth | JWT required |
| Role | EMPLEADO |
| Request body | `{ empleado_id: int, parada_id: int, latitud: float, longitud: float }` |
| Success response | `201 Created` — serialized RegistroAsistencia |
| Error: validation | `422 Unprocessable Entity` — `{ errors: ["..."] }` |
| Error: duplicate entry | `422 Unprocessable Entity` — `{ error: "Ya existe una entrada activa para hoy" }` |
| Error: not assigned | `422 Unprocessable Entity` — `{ error: "El empleado no está asignado a esta parada" }` |
| Error: inactive parada | `422 Unprocessable Entity` — `{ error: "La parada no está activa" }` |
| Error: not found | `404 Not Found` — `{ error: "..." }` |

**Role enforcement:** Controller MUST verify `current_user.rol == 'empleado'`. The `empleado_id` MUST be derived from `current_user` (the employee associated with the JWT user), NOT from the request body — employees can only mark for themselves.

### POST /api/v1/asistencia/marcar-salida

| Property | Value |
|----------|-------|
| Auth | JWT required |
| Role | EMPLEADO |
| Request body | `{ parada_id: int, latitud: float, longitud: float }` |
| Success response | `201 Created` — serialized RegistroAsistencia |
| Error: no active entry | `422 Unprocessable Entity` — `{ error: "No se encontró una entrada activa para registrar salida" }` |

**Role enforcement:** Same as marcar-entrada — `empleado_id` derived from JWT.

### GET /api/v1/asistencia/historial

| Property | Value |
|----------|-------|
| Auth | JWT required |
| Role | EMPLEADO |
| Query params | None |
| Success response | `200 OK` — `Array<RegistroAsistencia>` |

**Behavior:** Returns attendance records for the authenticated employee only.

### GET /api/v1/asistencia/historial/:empleado_id

| Property | Value |
|----------|-------|
| Auth | JWT required |
| Role | EMPRESA or ADMIN |
| Path params | `empleado_id` (integer) |
| Success response | `200 OK` — `Array<RegistroAsistencia>` |
| Error: not found | `404 Not Found` — `{ error: "..." }` |

**Role enforcement:** Controller MUST verify `current_user.rol` is 'empresa' or 'admin'.

### GET /api/v1/asistencia/tiempo-real

| Property | Value |
|----------|-------|
| Auth | JWT required |
| Role | EMPRESA or ADMIN |
| Query params | None |
| Success response | `200 OK` — `Array<Hash>` (last record per employee) |

### GET /api/v1/asistencia/tiempo-real/:parada_id

| Property | Value |
|----------|-------|
| Auth | JWT required |
| Role | EMPRESA or ADMIN |
| Path params | `parada_id` (integer) |
| Success response | `200 OK` — `Array<Hash>` (employees currently at this parada) |
| Error: parada not found | `404 Not Found` — `{ error: "..." }` |

---

## State Machine

### Employee Attendance State

```
                    ┌─────────────────────────────────────┐
                    │                                     │
                    ▼                                     │
              ┌──────────┐    MarcarSalida     ┌──────────┐
              │  SIN_MARCA├───────────────────►│ MARCADO  │
              │  (idle)   │                    │ (active  │
              └──────────┘                    │  entry)  │
                    ▲                         └──────────┘
                    │                              │
                    │       MarcarSalida           │
                    │◄─────────────────────────────┘
                    │
              (after SALIDA recorded)
```

**Rules:**
- An employee MAY have at most ONE active entry (ENTRADA without matching SALIDA) at any time
- MarcarEntrada is REJECTED if an active entry already exists
- MarcarSalida is REJECTED if no active entry exists
- Each SALIDA records `duracion_jornada` as the difference in minutes from its matching ENTRADA

---

## Infrastructure Layer

### AR Model: AsistenciaRecord

**File:** `app/models/asistencia_record.rb`

- `self.table_name = 'registro_asistencias'`
- `belongs_to :empleado`
- `belongs_to :parada`

### Mapper: AsistenciaMapper

**File:** `app/infrastructure/mappers/asistencia_mapper.rb`

Bidirectional mapping between `AsistenciaRecord` and `Domain::Entities::RegistroAsistencia`.

Methods:
- `self.to_domain(record)` → `RegistroAsistencia`
- `self.to_record(entity)` → `AsistenciaRecord`

### Repository: ArAsistenciaRepository

**File:** `app/infrastructure/repositories/ar_asistencia_repository.rb`

Implements `Ports::Driven::IAsistenciaRepository` using ActiveRecord.

### Facade: AsistenciaFacade

**File:** `app/infrastructure/services/asistencia_facade.rb`

Implements `Ports::Driving::IGestionarAsistencia`. Wires use cases with repositories.

### Serializer: AsistenciaSerializer

**File:** `app/serializers/asistencia_serializer.rb`

JSON serialization in camelCase (consistent with existing serializers):

```json
{
  "id": 1,
  "empleadoId": 1,
  "paradaId": 10,
  "tipoMarcacion": "ENTRADA",
  "fechaHora": "2026-06-01T08:00:00.000Z",
  "latitudRegistrada": -12.001,
  "longitudRegistrada": -77.001,
  "validaGps": true,
  "duracionJornada": null,
  "observaciones": null,
  "createdAt": "2026-06-01T08:00:00.000Z",
  "updatedAt": "2026-06-01T08:00:00.000Z"
}
```

### DI Registration

Add to `config/initializers/dependency_injection.rb`:

```ruby
def asistencia_facade
  @asistencia_facade ||= Application::Facades::AsistenciaFacade.new(
    asistencia_repo: repos[:asistencia],
    empleado_repo: repos[:empleado],
    parada_repo: repos[:parada],
    empleado_parada_repo: repos[:empleado_parada]
  )
end
```

Add `asistencia:` key to `repos` hash:

```ruby
asistencia: Infrastructure::Repositories::ArAsistenciaRepository.new
```

---

## Testing Requirements

### Unit Tests (Domain Layer)
- `test/domain/entities/registro_asistencia_test.rb` — entity validations
- `test/domain/value_objects/tipo_marcacion_test.rb` — value object

### Application Tests
- `test/application/use_cases/asistencia/marcar_entrada_test.rb`
- `test/application/use_cases/asistencia/marcar_salida_test.rb`
- `test/application/use_cases/asistencia/historial_personal_test.rb`
- `test/application/use_cases/asistencia/historial_empleado_test.rb`
- `test/application/use_cases/asistencia/tiempo_real_test.rb`

### Controller Tests
- `test/controllers/api/v1/asistencias_controller_test.rb`

### Infrastructure Tests
- `test/infrastructure/repositories/ar_asistencia_repository_test.rb`
- `test/infrastructure/mappers/asistencia_mapper_test.rb`
