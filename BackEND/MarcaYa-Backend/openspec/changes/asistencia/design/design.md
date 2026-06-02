# Design: Asistencia Module

## Technical Approach

New `registro_asistencias` table with GPS-validated ENTRY/EXIT attendance tracking. Follows existing hexagonal architecture: domain entity + value object → driven port → AR infrastructure (record/mapper/repository) → application use cases + facade → driving port → controller + serializer. GPS validation delegates to existing `GpsValidationService.dentro_de_geocerca?`. State management enforced via partial unique index (one active entry per employee) and repository-level lookup.

## Architecture Decisions

### Decision: Partial unique index for active entry constraint

**Choice**: Database-level partial index `(empleado_id, tipo_marcacion) WHERE tipo_marcacion = 'ENTRADA' AND duracion_jornada IS NULL`
**Alternatives considered**: Application-level check only; full unique index on `(empleado_id, tipo_marcacion)`
**Rationale**: DB constraint prevents race conditions (two simultaneous entries). Partial index allows multiple ENTRADA records once `duracion_jornada` is set (completed shifts). App-level check provides early rejection with descriptive error.

### Decision: GPS validation records violations but doesn't block

**Choice**: Create the registro even when GPS is outside geofence; set `valida_gps=false` and `observaciones="Fuera de zona"`
**Alternatives considered**: Reject the mark entirely when outside geofence
**Rationale**: Spec scenarios 2 and 4 explicitly require recording marks outside geofence. Preserves audit trail. The `valida_gps` flag allows filtering/reporting invalid marks later.

### Decision: Duration calculated on SALIDA record, not ENTRADA

**Choice**: `duracion_jornada` field lives on the SALIDA registro, computed as `(exit_time - entry_time) / 60`
**Alternatives considered**: Store duration on ENTRADA record at exit time; separate duration table
**Rationale**: Each registro is self-contained. ENTRADA records always have `duracion_jornada=nil`. SALIDA records always have a positive integer. Simplifies queries and serialization.

### Decision: Facade as use-case orchestrator (not service layer)

**Choice**: `AsistenciaFacade` instantiates and delegates to individual use case classes
**Alternatives considered**: Single service class with all methods
**Rationale**: Matches existing `ParadaFacade` pattern. Each use case is independently testable with mock repos.

## Data Flow

### Marcar Entrada
```
Controller ──→ AsistenciaFacade ──→ MarcarEntrada
                                         │
                    ┌────────────────────┤
                    ▼                    ▼
              empleado_repo        parada_repo
              .find_by_id!         .find_by_id!
                    │                    │
                    ▼                    ▼
          empleado_parada_repo    GpsValidationService
          .buscar_asignacion      .dentro_de_geocerca?
                    │                    │
                    ▼                    ▼
              asistencia_repo     asistencia_repo
              .buscar_entrada_    .guardar(registro)
                activa
```

### Marcar Salida
```
Controller ──→ AsistenciaFacade ──→ MarcarSalida
                                         │
                    ┌────────────────────┤
                    ▼                    ▼
              asistencia_repo     GpsValidationService
              .buscar_entrada_    .dentro_de_geocerca?
                activa                  │
                    │                   ▼
                    ▼             asistencia_repo
              registro with      .guardar(registro)
              duracion_jornada
              = (salida-entrada)/60
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `db/migrate/XXX_create_registro_asistencias.rb` | Create | New table with partial unique index |
| `app/domain/entities/registro_asistencia.rb` | Create | Entity with `validar!`, `entrada?`, `salida?` |
| `app/domain/value_objects/tipo_marcacion.rb` | Create | ENTRADA/SALIDA value object |
| `app/domain/errors.rb` | Modify | Add `AsistenciaNoEncontradaError`, `EntradaActivaExistenteError`, `EmpleadoNoAsignadoParadaError`, `ParadaInactivaError` |
| `app/ports/driven/i_asistencia_repository.rb` | Create | Driven port interface |
| `app/ports/driving/i_gestionar_asistencia.rb` | Create | Driving port interface |
| `app/infrastructure/orm/asistencia_record.rb` | Create | AR model for `registro_asistencias` |
| `app/infrastructure/mappers/asistencia_mapper.rb` | Create | Bidirectional domain↔record mapping |
| `app/infrastructure/repositories/ar_asistencia_repository.rb` | Create | AR implementation of driven port |
| `app/application/use_cases/asistencias/marcar_entrada.rb` | Create | Entry marking use case |
| `app/application/use_cases/asistencias/marcar_salida.rb` | Create | Exit marking use case |
| `app/application/use_cases/asistencias/historial_personal.rb` | Create | Personal history query |
| `app/application/use_cases/asistencias/historial_empleado.rb` | Create | Employee history query (admin) |
| `app/application/use_cases/asistencias/tiempo_real.rb` | Create | Real-time status query |
| `app/application/facades/asistencia_facade.rb` | Create | Facade orchestrating all use cases |
| `app/controllers/api/v1/asistencias_controller.rb` | Create | API endpoints with role enforcement |
| `app/serializers/asistencia_serializer.rb` | Create | camelCase JSON serialization |
| `config/initializers/dependency_injection.rb` | Modify | Register `asistencia` repo + facade |
| `config/routes.rb` | Modify | Add asistencia namespace routes |

## Interfaces / Contracts

### Entity: RegistroAsistencia
```ruby
Domain::Entities::RegistroAsistencia.new(
  id:, empleado_id:, parada_id:, tipo_marcacion:, fecha_hora:,
  latitud_registrada:, longitud_registrada:, valida_gps:,
  duracion_jornada: nil, observaciones: nil,
  created_at: nil, updated_at: nil
)
# Methods: validar!, entrada?, salida?
```

### Value Object: TipoMarcacion
```ruby
Domain::ValueObjects::TipoMarcacion::ENTRADA  # "ENTRADA"
Domain::ValueObjects::TipoMarcacion::SALIDA   # "SALIDA"
# Methods: entrada?, salida?, ==, to_s
```

### Driven Port: IAsistenciaRepository
```ruby
module Ports::Driven::IAsistenciaRepository
  def find_by_id!(id)                    → RegistroAsistencia
  def buscar_entrada_activa(empleado_id) → RegistroAsistencia | nil
  def historial_por_empleado(empleado_id) → Array<RegistroAsistencia>
  def ultimo_registro_por_empleado        → Array<Hash>
  def ultimo_registro_por_parada(parada_id) → Array<Hash>
  def guardar(registro)                   → RegistroAsistencia
end
```

### Driving Port: IGestionarAsistencia
```ruby
module Ports::Driving::IGestionarAsistencia
  def marcar_entrada(empleado_id:, parada_id:, latitud:, longitud:)  → RegistroAsistencia
  def marcar_salida(empleado_id:, parada_id:, latitud:, longitud:)   → RegistroAsistencia
  def historial_personal(empleado_id:)                                → Array<RegistroAsistencia>
  def historial_empleado(empleado_id:)                                → Array<RegistroAsistencia>
  def tiempo_real(parada_id: nil)                                     → Array<Hash>
end
```

### API Endpoints
| Method | Path | Role | Body/Params | Response |
|--------|------|------|-------------|----------|
| POST | `/api/v1/asistencia/marcar-entrada` | EMPLEADO | `{parada_id, latitud, longitud}` | 201 + registro |
| POST | `/api/v1/asistencia/marcar-salida` | EMPLEADO | `{parada_id, latitud, longitud}` | 201 + registro |
| GET | `/api/v1/asistencia/historial` | EMPLEADO | — | 200 + records |
| GET | `/api/v1/asistencia/historial/:empleado_id` | EMPRESA/ADMIN | — | 200 + records |
| GET | `/api/v1/asistencia/tiempo-real` | EMPRESA/ADMIN | — | 200 + status |
| GET | `/api/v1/asistencia/tiempo-real/:parada_id` | EMPRESA/ADMIN | — | 200 + status |

**Note**: `empleado_id` for marcar-entrada/salida is derived from `current_user` (JWT), NOT from request body.

## Testing Strategy

| Layer | What to Test | Approach |
|-------|-------------|----------|
| Unit (entity) | `RegistroAsistencia` validations, `TipoMarcacion` value object | Direct instantiation, `validar!` raises |
| Unit (use cases) | All 5 use cases | Mock repos via `define_singleton_method`, no DB |
| Integration (controller) | Endpoints, role enforcement, error mapping | Fixture-based, `authenticate_as` helper |
| Integration (repository) | `buscar_entrada_activa`, `guardar`, queries | DB-backed, Minitest with fixtures |

**Test pattern** (from existing `CrearParadaTest`):
```ruby
# Mock repos — no DB needed
empleado_repo = Object.new
empleado_repo.define_singleton_method(:find_by_id!) { |id| empleado }
use_case = MarcarEntrada.new(asistencia_repo: ..., empleado_repo: empleado_repo, ...)
```

## Migration / Rollout

Single migration: `CreateRegistroAsistencias`. Adds new table only — no changes to existing tables. Partial unique index created concurrently-safe. Legacy `asistencias` table untouched.

## Open Questions

- None — all design decisions resolved from proposal, spec, and codebase patterns.
