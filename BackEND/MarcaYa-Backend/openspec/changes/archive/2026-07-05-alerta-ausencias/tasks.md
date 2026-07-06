# Tasks: alerta-ausencias

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~950–1050 |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Delivery strategy | ask-on-risk |
| Chain strategy | pending |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: pending
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Domain + Infrastructure (entity, ports, ORM, migration, mapper, repo, DI, recurring.yml) | PR 1 | Base: feature-tracker branch |
| 2 | Application + API + Job (use cases, facade, controller, serializer, routes) | PR 2 | Depends on PR 1 infrastructure |
| 3 | Frontend (ApiService, provider, ResumenEmpresaPage UI) | PR 3 | Independent timeline |
| 4 | Tests (entity, use cases, controller, repo, job) | PR 4 | Tests across all layers |

## Phase 1: Domain + Infrastructure

- [x] 1.1 Create `app/domain/entities/alerta_ausencia.rb` — entity with id, empleado_id, obra_id, empresa_id, fecha, estado, evaluado_en
- [x] 1.2 Add `AlertaAusenciaNoEncontradaError` to `app/domain/errors.rb`
- [x] 1.3 Create `app/ports/driven/i_alerta_ausencia_repository.rb` — 5 self methods with NotImplementedError
- [x] 1.4 Create `db/migrate/XXXXX_create_alerta_ausencias.rb` — table with FK to empleados, obras, empresas; unique index on (empleado_id, obra_id, fecha)
- [x] 1.5 Create `app/infrastructure/orm/alerta_ausencia_record.rb` — AR record with belongs_to associations
- [x] 1.6 Create `app/infrastructure/mappers/alerta_ausencia_mapper.rb` — to_domain / to_record_attrs methods
- [x] 1.7 Create `app/infrastructure/repositories/ar_alerta_ausencia_repository.rb` — guardar, listar_por_empresa, resolver_por_empleado, find_by_id!, actualizar_estado
- [x] 1.8 Modify `app/infrastructure/repositories/ar_obra_repository.rb` — add `listar_activas_con_asignaciones` method
- [x] 1.9 Register `alerta_ausencia` repo in `config/initializers/dependency_injection.rb` under `repos` hash
- [x] 1.10 Run migration: `rails db:migrate`

## Phase 2: Application

- [x] 2.1 Create `app/application/use_cases/alertas/evaluar_ausencias.rb` — queries active obras, checks ENTRADA_hoy per asignacion, upserts AlertaAusencia or resolves existing
- [x] 2.2 Create `app/application/use_cases/alertas/obtener_alertas_ausencia.rb` — lists pending alerts for empresa_id scoped via obra join
- [x] 2.3 Create `app/application/use_cases/alertas/resolver_alerta.rb` — finds alert by id, changes estado to resuelta
- [x] 2.4 Create `app/application/facades/alerta_ausencia_facade.rb` — composes 3 use cases, delegate methods for each
- [x] 2.5 Wire `alerta_ausencia_facade` in `config/initializers/dependency_injection.rb` — instantiate with new repo + obra_repo + asistencia_repo

## Phase 3: API + Job

- [x] 3.1 Create `app/controllers/api/v1/alertas_controller.rb` — GET index (scoped by empresa), PUT resolver; auth require_empresa_or_admin!
- [x] 3.2 Create `app/serializers/alerta_ausencia_serializer.rb` — camelCase JSON for empleado_nombre, empleado_apellido, obra_nombre, fecha, estado
- [x] 3.3 Add routes in `config/routes.rb` — resources :alertas, only: [:index] + member put :resolver under `/api/v1/alertas/ausencias`
- [x] 3.4 Create `app/jobs/evaluar_ausencias_job.rb` — SolidQueue job calling facade.evaluar_ausencias
- [x] 3.5 Add recurring schedule in `config/recurring.yml` — evaluate_ausencias class, every 15 min, queue: default

## Phase 4: Frontend

- [x] 4.1 Add `obtenerAlertasAusencia()` and `resolverAlerta(id)` methods to `FrontEND/MarcaYa/lib/src/api_service.dart`
- [x] 4.2 Create `FrontEND/MarcaYa/lib/providers/alertas_ausencia_provider.dart` — ChangeNotifier with list, loading, error state; calls ApiService on init
- [x] 4.3 Modify `FrontEND/MarcaYa/lib/pages/resumen_empresa/resumen_empresa.dart` — instantiate provider, add red alert cards section before accion rapida, show count badge

## Phase 5: Tests

- [x] 5.1 Write `test/domain/entities/alerta_ausencia_test.rb` — construct, estado predicates (pendiente?, resuelta?, desestimada?)
- [x] 5.2 Write `test/application/use_cases/alertas/evaluar_ausencias_test.rb` — mock repos; verify absence detection, no-op with entrada today, upsert dedup, auto-resolve
- [x] 5.3 Write `test/application/use_cases/alertas/obtener_alertas_ausencia_test.rb` — scoped by empresa, empty list, multiple alerts returned
- [x] 5.4 Write `test/controllers/api/v1/alertas_controller_test.rb` — GET index auth/role checks, response shape, 403 for empleado role, 204 on resolver
- [x] 5.5 Write `test/infrastructure/repositories/ar_alerta_ausencia_repository_test.rb` — create, list by empresa, resolver, upsert uniqueness
- [x] 5.6 Write `test/jobs/evaluar_ausencias_job_test.rb` — integration test with fixtures, verify alert creation after job run
- [x] 5.7 Run `rails test` — verify all tests pass across new and existing tests
