# Tasks: Asistencia Module

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | 850-1050 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | 4 chained PRs (stacked-to-main) |
| Delivery strategy | ask-on-risk |
| Chain strategy | stacked-to-main |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Database + Domain Layer | PR 1 | Migration, entity, value object, errors, driven port, entity tests |
| 2 | Infrastructure Layer | PR 2 | ORM, mapper, repository — depends on PR 1 |
| 3 | Application Layer + DI | PR 3 | Use cases, facade, driving port, DI wiring, use case tests — depends on PR 2 |
| 4 | Presentation Layer | PR 4 | Controller, serializer, routes — depends on PR 3 |

## Phase 1: Database & Core Domain (PR 1)

- [x] **T1.1** Create migration `db/migrate/XXX_create_registro_asistencias.rb` — `registro_asistencias` table with columns: `empleado_id` (FK), `parada_id` (FK), `tipo_marcacion` (string), `fecha_hora` (datetime), `latitud_registrada` (float), `longitud_registrada` (float), `valida_gps` (boolean, default false), `duracion_jornada` (integer, nullable), `observaciones` (text, nullable). Add partial unique index on `(empleado_id)` WHERE `tipo_marcacion = 'ENTRADA' AND duracion_jornada IS NULL`. Add composite indexes `(empleado_id, fecha_hora DESC)` and `(parada_id, fecha_hora DESC)`. FKs: `ON DELETE RESTRICT`. ~40 lines.
- [x] **T1.2** Create `app/domain/value_objects/tipo_marcacion.rb` — `Domain::ValueObjects::TipoMarcacion` with constants `ENTRADA = "ENTRADA"`, `SALIDA = "SALIDA"`, methods `entrada?`, `salida?`, `==`, `to_s`. ~25 lines.
- [x] **T1.3** Create `app/domain/entities/registro_asistencia.rb` — `Domain::Entities::RegistroAsistencia` with `attr_reader` for all columns, `validar!` method enforcing: empleado_id present, parada_id present, tipo_marcacion in ENTRADA/SALIDA, fecha_hora present, latitud in [-90, 90], longitud in [-180, 180], duracion_jornada nil for ENTRADA / positive integer for SALIDA. Methods: `entrada?`, `salida?`. ~45 lines.
- [x] **T1.4** Add 4 error classes to `app/domain/errors.rb`: `AsistenciaNoEncontradaError < StandardError`, `EntradaActivaExistenteError < ValidacionError`, `EmpleadoNoAsignadoParadaError < ValidacionError`, `ParadaInactivaError < ValidacionError`. ~8 lines.
- [x] **T1.5** Create `app/ports/driven/i_asistencia_repository.rb` — `Ports::Driven::IAsistenciaRepository` module with `self.find_by_id!`, `self.buscar_entrada_activa`, `self.historial_por_empleado`, `self.ultimo_registro_por_empleado`, `self.ultimo_registro_por_parada`, `self.guardar` — all raise `NotImplementedError`. ~30 lines.
- [x] **T1.6** Create `test/domain/entities/registro_asistencia_test.rb` — test entity validations: valid entity passes `validar!`, missing empleado_id raises, missing parada_id raises, invalid tipo_marcacion raises, latitud out of range raises, duracion_jornada on ENTRADA raises. ~50 lines.
- [x] **T1.7** Create migration rollback test `test/migrations/create_registro_asistencias_test.rb` — verify migration up/down works cleanly. ~20 lines.

**Verification**: `rails db:migrate` succeeds, entity tests pass, port module loads without error.

## Phase 2: Infrastructure Layer (PR 2)

- [ ] **T2.1** Create `app/infrastructure/orm/asistencia_record.rb` — `Infrastructure::Orm::AsistenciaRecord < ActiveRecord::Base`, `self.table_name = 'registro_asistencias'`, `belongs_to :empleado`, `belongs_to :parada`. ~12 lines.
- [ ] **T2.2** Create `app/infrastructure/mappers/asistencia_mapper.rb` — `Infrastructure::Mappers::AsistenciaMapper` with `self.to_domain(record)` converting `AsistenciaRecord` → `RegistroAsistencia` entity, and `self.to_record_attrs(entity)` converting entity → attributes hash. Follow `ParadaMapper` pattern. ~40 lines.
- [ ] **T2.3** Create `app/infrastructure/repositories/ar_asistencia_repository.rb` — `Infrastructure::Repositories::ArAsistenciaRepository` implementing `IAsistenciaRepository` with 5 methods: `find_by_id!` (raises `AsistenciaNoEncontradaError`), `buscar_entrada_activa(empleado_id)` (query ENTRADA without SALIDA today), `historial_por_empleado(empleado_id)` (ordered fecha_hora DESC), `ultimo_registro_por_empleado` (last record per employee), `ultimo_registro_por_parada(parada_id)` (last record per employee at parada), `guardar(registro)`. ~65 lines.
- [ ] **T2.4** Create `test/infrastructure/mappers/asistencia_mapper_test.rb` — test `to_domain` and `to_record_attrs` round-trip. ~40 lines.
- [ ] **T2.5** Create `test/infrastructure/repositories/ar_asistencia_repository_test.rb` — test `buscar_entrada_activa` returns nil when no active entry, `historial_por_empleado` returns ordered records, `guardar` persists. ~60 lines.

**Verification**: `rails test test/infrastructure/` passes, repository methods work against test DB.

## Phase 3: Application Layer & DI (PR 3)

- [x] **T3.1** Create `app/ports/driving/i_gestionar_asistencia.rb` — `Ports::Driving::IGestionarAsistencia` module with `self.marcar_entrada`, `self.marcar_salida`, `self.historial_personal`, `self.historial_empleado`, `self.tiempo_real` — all raise `NotImplementedError`. ~25 lines.
- [x] **T3.2** Create `app/application/use_cases/asistencias/marcar_entrada.rb` — `Application::UseCases::Asistencias::MarcarEntrada` with constructor taking `asistencia_repo`, `empleado_repo`, `parada_repo`, `empleado_parada_repo`. `ejecutar(empleado_id:, parada_id:, latitud:, longitud:)`: validates empleado exists, parada exists and is active, assignment exists and is activo, no active entry exists. Uses `GpsValidationService.dentro_de_geocerca?` to set `valida_gps` and `observaciones`. Creates and persists `RegistroAsistencia`. ~60 lines.
- [x] **T3.3** Create `app/application/use_cases/asistencias/marcar_salida.rb` — `Application::UseCases::Asistencias::MarcarSalida` with constructor taking `asistencia_repo`. `ejecutar(empleado_id:, parada_id:, latitud:, longitud:)`: finds active entry, calculates `duracion_jornada` as minutes between entry and now, creates SALIDA registro. Raises `AsistenciaNoEncontradaError` if no active entry. ~45 lines.
- [x] **T3.4** Create `app/application/use_cases/asistencias/historial_personal.rb` — delegates to `asistencia_repo.historial_por_empleado(empleado_id)`. ~15 lines.
- [x] **T3.5** Create `app/application/use_cases/asistencias/historial_empleado.rb` — same as personal, but for admin view. ~15 lines.
- [x] **T3.6** Create `app/application/use_cases/asistencias/tiempo_real.rb` — calls `ultimo_registro_por_empleado` or `ultimo_registro_por_parada` based on optional `parada_id`. ~30 lines.
- [x] **T3.7** Create `app/application/facades/asistencia_facade.rb` — `Application::Facades::AsistenciaFacade` implementing `IGestionarAsistencia`. Constructor takes `asistencia_repo`, `empleado_repo`, `parada_repo`, `empleado_parada_repo`. Each method instantiates and delegates to the corresponding use case. ~55 lines.
- [x] **T3.8** Modify `config/initializers/dependency_injection.rb` — add `asistencia` key to `repos` hash and `asistencia_facade` method. ~12 lines.
- [x] **T3.9** Create `test/application/use_cases/asistencias/marcar_entrada_test.rb` — test: successful entry within geofence, entry outside geofence (valida_gps=false), duplicate entry prevention, empleado not found, parada not found, empleado not assigned, assignment inactive, parada inactive. Use mock repos with `define_singleton_method`. ~80 lines.
- [x] **T3.10** Create `test/application/use_cases/asistencias/marcar_salida_test.rb` — test: successful exit with duration, no active entry raises error, exit when previous exit already recorded. ~50 lines.
- [x] **T3.11** Create `test/application/use_cases/asistencias/historial_personal_test.rb` — test: returns records ordered DESC, empty array when no records. ~30 lines.
- [x] **T3.12** Create `test/application/use_cases/asistencias/historial_empleado_test.rb` — test: returns records, empty array. ~25 lines.
- [x] **T3.13** Create `test/application/use_cases/asistencias/tiempo_real_test.rb` — test: all paradas, specific parada, empty database. ~45 lines.

**Verification**: `rails test test/application/use_cases/asistencias/` all pass, DI container loads without error.

## Phase 4: Presentation Layer (PR 4)

- [x] **T4.1** Create `app/serializers/asistencia_serializer.rb` — `Serializer::AsistenciaSerializer.as_json(registro)` returning camelCase hash: `id`, `empleadoId`, `paradaId`, `tipoMarcacion`, `fechaHora`, `latitudRegistrada`, `longitudRegistrada`, `validaGps`, `duracionJornada`, `observaciones`, `createdAt`, `updatedAt`. ~30 lines.
- [x] **T4.2** Create `app/controllers/api/v1/asistencias_controller.rb` — `Api::V1::AsistenciasController < Api::V1::BaseController` with 6 actions: `marcar_entrada` (POST, EMPLEADO role, derive empleado_id from current_user), `marcar_salida` (POST, EMPLEADO), `historial` (GET, EMPLEADO — personal), `historial_empleado` (GET, EMPRESA/ADMIN), `tiempo_real` (GET, EMPRESA/ADMIN), `tiempo_real_por_parada` (GET, EMPRESA/ADMIN). Error handling for domain errors → appropriate HTTP status. ~80 lines.
- [x] **T4.3** Modify `config/routes.rb` — add asistencia namespace: `namespace :asistencia do ... end` with 6 endpoints. ~15 lines.
- [ ] **T4.4** Create `test/controllers/api/v1/asistencias_controller_test.rb` — test: marcar_entrada success (201), marcar_entrada duplicate entry (422), marcar_entrada outside geofence (201 with valida_gps=false), marcar_salida success (201), marcar_salida no active entry (422), historial returns records (200), historial_empleado role enforcement (403 for EMPLEADO), tiempo_real returns status (200). ~100 lines.

**Verification**: `rails test test/controllers/api/v1/asistencias_controller_test.rb` passes, manual curl tests against all 6 endpoints work.

## Total Estimated Lines

| PR | Files | Estimated Lines |
|----|-------|-----------------|
| PR 1 | 7 files | ~218 |
| PR 2 | 5 files | ~217 |
| PR 3 | 13 files | ~432 |
| PR 4 | 4 files | ~225 |
| **Total** | **29 files** | **~1092** |

## Dependency Graph

```
T1.1 (migration) ─┐
T1.2 (value obj) ─┤
T1.3 (entity) ────┼─→ T1.6 (entity tests)
T1.4 (errors) ────┤   T1.7 (migration test)
T1.5 (port) ──────┘
         │
         ▼
T2.1 (ORM) ───────┐
T2.2 (mapper) ────┼─→ T2.4 (mapper test)
T2.3 (repository) ─┘   T2.5 (repo test)
         │
         ▼
T3.1 (driving port) ─┐
T3.2 (marcar_entrada) ┤
T3.3 (marcar_salida) ─┤
T3.4 (historial_personal)
T3.5 (historial_empleado)
T3.6 (tiempo_real) ───┤
T3.7 (facade) ────────┤
T3.8 (DI wiring) ─────┘
         │
         ▼
T3.9-T3.13 (use case tests)
         │
         ▼
T4.1 (serializer) ──┐
T4.2 (controller) ──┼─→ T4.4 (controller tests)
T4.3 (routes) ──────┘
```
