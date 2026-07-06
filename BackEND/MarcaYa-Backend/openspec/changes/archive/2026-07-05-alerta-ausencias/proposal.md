# Proposal: Alerta-Ausencias — Real-time Absence Alerts for Companies

## Intent

Companies need real-time visibility into employee absences. Currently, attendance monitoring shows who marked IN/OUT, but does NOT flag employees who failed to mark within the configured tolerance window. This change adds automatic periodic evaluation of absences and a visual alert system on the company dashboard.

## Scope

### In Scope
- SolidQueue recurring job to evaluate absences after tolerance
- New `alerta_ausencias` table + domain entity + repository
- API endpoint `GET /api/v1/alertas/ausencias` (empresa role)
- Red alert UI component on `ResumenEmpresaPage` showing employee name + obra
- Hexagonal architecture: domain, ports, infrastructure, application, controller

### Out of Scope
- Push notifications to company (future iteration)
- Auto-resolve alerts when employee eventually marks (future iteration)
- Historical absence reports or exports
- Multi-day absence patterns (focus on current-day evaluation only)

## Capabilities

> This is a NEW capability independent of existing `asistencia` capabilities.

### New Capabilities
- `alertas-ausencia`: Periodic evaluation of employees who failed to mark attendance within tolerance, alert persistence, and company-facing alert API + UI

### Modified Capabilities
None — existing `attendance-marking`, `attendance-history`, and `attendance-monitoring` capabilities are unchanged.

## Approach

1. Create **AlertaAusencia** domain entity with `empleado_id`, `obra_id`, `empresa_id`, `fecha`, `estado` (pendiente/resuelta), `evaluado_en`
2. Add **IAlertaAusenciaRepository** driven port + **ArAlertaAusenciaRepository**
3. Create **EvaluarAusencias** use case: queries active `Asignacion` records, checks if each employee has an ENTRADA for today within the obra's `hora_inicio + tolerancia_entrada_min`, generates `AlertaAusencia` if absent
4. Create **ListarAlertas** use case: returns active pending alerts for a company
5. Register **EvaluarAusenciasJob** as SolidQueue recurring job in `config/recurring.yml` (every 5 min)
6. Add `POST /api/v1/alertas/ausencias/evaluar` (trigger) + `GET /api/v1/alertas/ausencias` (list)
7. Add `AlertasAusenciaProvider` + red alert banner/list on `ResumenEmpresaPage`
8. Update `ApiService` in Flutter with new alert methods

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `app/domain/entities/alerta_ausencia.rb` | New | AlertaAusencia entity |
| `app/domain/errors.rb` | Modified | New `AlertaAusenciaError` |
| `app/ports/driven/i_alerta_ausencia_repository.rb` | New | Driven port interface |
| `app/infrastructure/repositories/` | New | AlertaAusenciaRecord, mapper, repository |
| `app/application/use_cases/alertas/` | New | EvaluarAusencias, ListarAlertas |
| `app/application/facades/` | New/Modified | AlertaFacade (new) or extend AsistenciaFacade |
| `app/controllers/api/v1/alertas_controller.rb` | New | API controller |
| `app/jobs/evaluar_ausencias_job.rb` | New | SolidQueue recurring job |
| `config/recurring.yml` | Modified | Register recurring schedule |
| `db/migrate/` | New | Create alerta_ausencias table |
| `FrontEND/MarcaYa/lib/src/api_service.dart` | Modified | Add alert API methods |
| `FrontEND/MarcaYa/lib/pages/resumen_empresa/` | Modified | Add alert UI component |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Evaluation frequency too high (DB load) | Low | Configurable interval in recurring.yml; batch processing |
| False positives if employee marks late but within tolerance | Low | Tolerance values per Obra already exist — evaluation uses them |
| Duplicate alerts for same absence | Low | UPSERT logic: one alert per employee+obra+fecha |

## Rollback Plan

1. Remove migration: `rails destroy migration CreateAlertaAusencias`
2. Remove new files: entity, ports, infrastructure, use cases, controller, job, facade
3. Revert `config/recurring.yml` to previous state
4. Revert Flutter `api_service.dart` and `resumen_empresa.dart`
5. No data loss — alerts table only, no production data dependency

## Dependencies

- Existing `Obra#tolerancia_entrada_min`, `Obra#hora_inicio`
- Existing `Empleado` entity + `Asignacion` entity
- Existing `IAsistenciaRepository#buscar_entrada_hoy`
- SolidQueue recurring_executions table (already in schema)
- DI container for repository registrations

## Success Criteria

- [ ] Recurring job runs on schedule and correctly identifies absent employees
- [ ] Employees who marked ENTRADA within tolerance are NOT flagged
- [ ] Employees who did NOT mark ENTRADA within tolerance generate an alert
- [ ] `GET /api/v1/alertas/ausencias` returns pending alerts for the company
- [ ] Company dashboard shows red alerts with employee name + obra name
- [ ] Alerts respect obra-level tolerancia_entrada_min per obra
- [ ] No duplicate alerts for same employee+obra+date
- [ ] All roles enforced: EMPRESA/ADMIN only for alert endpoints
- [ ] Tests pass across domain, application, controller layers
