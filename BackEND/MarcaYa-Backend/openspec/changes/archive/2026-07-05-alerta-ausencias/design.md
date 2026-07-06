# Design: Alerta-Ausencias — Real-time Absence Alerts

## Technical Approach

New `alertas-ausencia` domain capability following existing hexagonal patterns: Domain Entity → Driven Port → Repository + ORM + Mapper → Use Cases → Facade → Controller → Routes → SolidQueue recurring job. Frontend adds Provider, API methods, and UI cards to `ResumenEmpresaPage`.

**Key mapping to spec**: Periodic evaluation via SolidQueue recurring job (every 15 min). Alerts use 3 estados: `pendiente`, `resuelta`, `desestimada`. Auto-resolve on ENTRADA detection handled by the same recurring job (no coupling between Asistencia and Alerta domains at the use-case level).

## Architecture Decisions

| Option | Considered | Decision |
|--------|-----------|----------|
| **Auto-resolve on ENTRADA** | Hook inside `MarcarEntrada` use case | RECURRING JOB resolves. Avoids cross-domain coupling between Asistencia and Alerta facades/repos. |
| **Alert states** | pendiente/resuelta only | THREE states: `pendiente`, `resuelta`, `desestimada` matches spec's dismiss requirement. |
| **empresa_id on alerta** | Derive via obra join | DENORMALIZE `empresa_id` on the alerta table for efficient company-scoped queries — no join needed for listing alerts by company. |
| **Manual trigger endpoint** | `POST .../evaluar` | SKIP. Recurring job is sufficient; no operational need for manual trigger. |
| **New facade vs extend AsistenciaFacade** | Extend existing | NEW `AlertaAusenciaFacade`. Alert domain is independent — mixing would violate SRP. |
| **Port interface** | Abstract class | MODULE with `self.` methods (existing project pattern). Not formally inherited but serves as contract documentation. |

## Data Flow

```
SolidQueue (recurring.yml)
    │ every 15 min
    ▼
EvaluarAusenciasJob
    │
    ▼
EvaluarAusencias use case
    │
    ├── IObraRepository.listar_activas_con_asignaciones()
    ├── IAsistenciaRepository.buscar_entrada_hoy(empleado_id)
    │       for each active asignacion
    │   ┌── sin entrada → IAlertaAusenciaRepository.guardar( pendiente )
    │   └── con entrada → IAlertaAusenciaRepository.resolver_por_empleado( resuelta )
    │
    ▼
AlertaAusenciaRecord (DB)

── API ──────────────────────────────
    GET  /api/v1/alertas/ausencias
    PUT  /api/v1/alertas/ausencias/:id/resolver

── Flutter ─────────────────────────
    AlertasAusenciaProvider
        → ApiService.obtenerAlertasAusencia()
        → ResumenEmpresaPage (red cards section)
```

## File Changes

| File | Action | Description |
|------|--------|-------------|
| `app/domain/entities/alerta_ausencia.rb` | Create | Entity with id, empleado_id, obra_id, empresa_id, fecha, estado, evaluado_en |
| `app/ports/driven/i_alerta_ausencia_repository.rb` | Create | Driven port interface |
| `app/infrastructure/orm/alerta_ausencia_record.rb` | Create | ORM record (table: `alerta_ausencias`) |
| `app/infrastructure/mappers/alerta_ausencia_mapper.rb` | Create | Mapper to_domain / to_record_attrs |
| `app/infrastructure/repositories/ar_alerta_ausencia_repository.rb` | Create | Repository: guardar, listar_por_empresa, resolver |
| `app/infrastructure/repositories/ar_obra_repository.rb` | Modify | Add `listar_activas_con_asignaciones` method |
| `app/application/use_cases/alertas/evaluar_ausencias.rb` | Create | Core evaluation logic |
| `app/application/use_cases/alertas/obtener_alertas_ausencia.rb` | Create | List pending alerts for empresa |
| `app/application/facades/alerta_ausencia_facade.rb` | Create | Facade composing alert use cases |
| `app/controllers/api/v1/alertas_controller.rb` | Create | `GET index`, `PUT resolver` |
| `app/jobs/evaluar_ausencias_job.rb` | Create | SolidQueue recurring job |
| `app/serializers/alerta_ausencia_serializer.rb` | Create | API response serializer |
| `app/domain/errors.rb` | Modify | Add `AlertaAusenciaNoEncontradaError` |
| `config/routes.rb` | Modify | Add alertas routes |
| `config/initializers/dependency_injection.rb` | Modify | Wire AlertaAusenciaFacade |
| `config/recurring.yml` | Modify | Add `evaluar_ausencias` schedule |
| `db/migrate/xxxx_create_alerta_ausencias.rb` | Create | Migration with FK to empleados, obras, empresas |
| `FrontEND/MarcaYa/lib/src/api_service.dart` | Modify | Add `obtenerAlertasAusencia`, `resolverAlerta` methods |
| `FrontEND/MarcaYa/lib/providers/alertas_ausencia_provider.dart` | Create | ChangeNotifier for alert state |
| `FrontEND/MarcaYa/lib/pages/resumen_empresa/resumen_empresa.dart` | Modify | Add red alert cards section, load alertas provider |

## Interfaces / Contracts

```ruby
# Port driven — contract docs only (project pattern uses modules with self. methods)
module Ports::Driven::IAlertaAusenciaRepository
  def self.guardar(alerta) → Domain::Entities::AlertaAusencia; end
  def self.listar_por_empresa(empresa_id, estado:) → [AlertaAusencia]; end
  def self.resolver_por_empleado(empleado_id, obra_id, fecha); end
  def self.find_by_id!(id) → AlertaAusencia; end
  def self.actualizar_estado(id, nuevo_estado); end
end
```

**API contract** `GET /api/v1/alertas/ausencias`:
```json
[{
  "id": 1,
  "empleadoId": 42,
  "empleadoNombre": "Juan",
  "empleadoApellido": "Pérez",
  "obraId": 7,
  "obraNombre": "Obra A",
  "fecha": "2026-07-05",
  "estado": "pendiente",
  "evaluadoEn": "2026-07-05T08:20:00-05:00"
}]
```

`PUT /api/v1/alertas/ausencias/:id/resolver` → `204 No Content`

## Testing Strategy

| Layer | What | Approach |
|-------|------|----------|
| Domain | AlertaAusencia entity validation, estado transitions | Unit: construct + validar! + state predicates |
| Application | EvaluarAusencias: detects absence, no-op if entrada exists, upsert semantics | Unit: mock repos, verify guardar called / not called |
| Application | ObtenerAlertasAusencia: scoping by empresa, empty case | Unit: mock repo returns/empty list |
| Infrastructure | Repository CRUD + scoped queries | Integration: test DB with records |
| Controller | Auth enforcement, response shape, empty list | Request specs: token auth, role check |
| Job | Full evaluation flow end-to-end | Integration: DB fixtures + job execution |
| Flutter | Provider state, API call wiring | Widget test with mocked ApiService |

## Migration / Rollout

1. Create migration `CreateAlertaAusencias` with FK constraints (cascade on empresa delete)
2. Deploy backend first — routes and controller are inert until DB has the table
3. Register recurring job in `config/recurring.yml` (production only, commented in dev)
4. Deploy Flutter — new provider loads on `ResumenEmpresaPage` init; no network errors if backend hasn't rolled yet (graceful empty state)
5. No data migration needed — new table, no existing data dependency

**Rollback**: `rails db:rollback`, revert routes + DI + recurring.yml, remove files, revert Flutter.
