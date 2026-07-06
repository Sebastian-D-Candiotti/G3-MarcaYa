# Alertas-Ausencia Specification

## Purpose

Automatic detection of employees who fail to mark attendance within configured tolerances. Defines periodic evaluation, alert persistence, company-facing API, and dashboard display.

## Requirements

### Requirement: Periodic Absence Evaluation

The system MUST periodically evaluate active employee-obra assignments to detect absences.

| Property | Value |
|----------|-------|
| Trigger | SolidQueue recurring job |
| Scope | Obras `activa`, Asignaciones `activo`, Empleados `activo` |

#### Scenario: Employee absent is flagged

- GIVEN an active obra with `hora_inicio: 08:00` and `tolerancia_entrada_min: 15`
- AND an employee assigned to that obra with no `ENTRADA` for today
- WHEN the evaluation job runs after `08:15`
- THEN the system creates an `AlertaAusencia` (`estado: pendiente`) for that employee + obra + today

#### Scenario: Employee who marked on time is NOT flagged

- GIVEN an employee who marked `ENTRADA` at `07:55` (before `hora_inicio` + tolerance)
- WHEN the evaluation job runs
- THEN the system does NOT create an alert for that employee

#### Scenario: Employee within tolerance is NOT flagged

- GIVEN an employee who marked `ENTRADA` at `08:10` (obra starts `08:00`, tolerance `15min`)
- WHEN the evaluation job runs after the tolerance window
- THEN the system does NOT create an alert for that employee

#### Scenario: No duplicate alerts

- GIVEN an `AlertaAusencia` already exists for employee + obra + today
- WHEN the evaluation job runs again
- THEN no second alert is created (UPSERT semantics)

#### Scenario: Inactive contexts generate no alerts

- GIVEN an obra `inactiva`, OR an employee `inactivo`, OR an obra with no assignments
- WHEN the evaluation job runs
- THEN the system creates no alerts for that obra/employee

### Requirement: Company Alert API

The system MUST expose `GET /api/v1/alertas/ausencias` for EMPRESA and ADMIN roles, scoped to the authenticated company's obras.

#### Scenario: Company retrieves pending alerts

- GIVEN an authenticated user (`rol: empresa`) with pending `AlertaAusencia` records
- WHEN they call `GET /api/v1/alertas/ausencias`
- THEN the response includes `empleado_nombre`, `empleado_apellido`, `obra_nombre`, `fecha`, and `estado`

#### Scenario: Empty list when none exist

- GIVEN an authenticated empresa user with zero alerts for their company
- WHEN they call `GET /api/v1/alertas/ausencias`
- THEN the response is `[]` with HTTP 200

#### Scenario: Other company's alerts excluded

- GIVEN a user from company A with alerts only for company B
- WHEN they call `GET /api/v1/alertas/ausencias`
- THEN the response is `[]`

#### Scenario: Unauthorized role rejected

- GIVEN an authenticated user with `rol: empleado`
- WHEN they call `GET /api/v1/alertas/ausencias`
- THEN the response is HTTP 403

### Requirement: Alert Auto-Resolution

The system SHOULD auto-resolve alerts when the employee marks ENTRADA after an alert was created.

#### Scenario: Late mark resolves alert

- GIVEN an `AlertaAusencia` with `estado: pendiente` for employee + obra + today
- WHEN the employee marks `ENTRADA` for today on that obra
- THEN the alert's `estado` changes to `resuelta`

### Requirement: Alert Dismissal

The system MAY allow dismissing alerts via `POST /api/v1/alertas/ausencias/:id/desestimar`.

#### Scenario: Company dismisses an alert

- GIVEN an authenticated empresa user and a pending alert for their obra
- WHEN they call `POST /api/v1/alertas/ausencias/:id/desestimar`
- THEN the alert's `estado` changes to `desestimada`

### Requirement: Dashboard UI Display

The company dashboard MUST display pending absence alerts as red cards with the employee's full name and obra name.

#### Scenario: Active alerts on dashboard

- GIVEN an authenticated empresa user on `ResumenEmpresaPage` with pending `AlertaAusencia` records
- THEN red alert cards show `"{nombre} {apellido}"` and obra name
- AND a count of pending alerts is visible

#### Scenario: No alerts shows empty state

- GIVEN an authenticated empresa user on `ResumenEmpresaPage` with zero alerts
- THEN no alert cards are shown
- AND an empty-state message appears (e.g., "Sin alertas de ausencia")
