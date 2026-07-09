# Estadísticas de Obra — Specification

## Purpose

Proveer métricas de asistencia y puntualidad por obra, calculadas a partir de registros de asistencia y paradas. Backend expone endpoint REST protegido. Frontend muestra dashboard de detalle con gráficos.

## Functional Requirements

### REQ-01: Cálculo de métricas por obra

The system SHALL compute the following metrics for a given obra + periodo (YYYY-MM):

| Metric | Type | Description |
|--------|------|-------------|
| `horas_promedio` | Float | Average hours worked per employee |
| `horas_totales` | Float | Sum of all hours across employees |
| `puntualidad_porcentaje` | Float | % of asistencia records marked on-time |
| `empleados_activos` | Integer | Unique employees with at least one record |
| `dias_trabajados` | Integer | Unique calendar days with records |
| `tardanzas_total` | Integer | Count of tardy records |
| `faltas_total` | Integer | Count of absences |
| `fake_gps_intentos` | Integer | Count of GPS-fakery attempts |
| `empleados_con_irregularidades` | Integer | Unique employees with any irregularity |
| `datos_por_empleado` | Array | Per-employee breakdown: `empleado_id`, `nombre`, `horas_trabajadas`, `tardanzas`, `faltas`, `fake_gps` |

#### Scenario: Happy path — obra con datos en el periodo

- GIVEN obra 1 exists with 3 employees, each having 20 asistencias in 2026-06
- WHEN `GET /api/v1/estadisticas/obra/1?periodo=2026-06`
- THEN response is 200 with all 10 metrics populated
- AND `datos_por_empleado` contains 3 entries with calculated values

#### Scenario: Obra sin datos en el periodo

- GIVEN obra 2 exists with no asistencias or paradas in 2026-06
- WHEN `GET /api/v1/estadisticas/obra/2?periodo=2026-06`
- THEN response is 200 with `horas_totales: 0`, `empleados_activos: 0`, `puntualidad_porcentaje: 0`
- AND `datos_por_empleado` is an empty array

#### Scenario: Obra inexistente

- GIVEN obra 999 does not exist
- WHEN `GET /api/v1/estadisticas/obra/999?periodo=2026-06`
- THEN response is 404 with error message

#### Scenario: Periodo sin registros para obra existente

- GIVEN obra 1 exists but has no records in 2025-01
- WHEN `GET /api/v1/estadisticas/obra/1?periodo=2025-01`
- THEN response is 200 with zero-valued metrics and empty `datos_por_empleado`

### REQ-02: Frontend — Detalles de obra

The system SHALL render a detail page at `/empresa/obras/:obraId/detalles` showing obra statistics.

#### Scenario: Navegar a detalles de obra

- GIVEN user is in ListaObrasPage
- WHEN user taps "Detalles" on an obra card
- THEN router navigates to `/empresa/obras/:obraId/detalles`
- AND DetallesObraPage shows MetricasCard, GraficoHoras, GraficoPuntualidad, GraficoIrregularidades

#### Scenario: Vista sin datos

- GIVEN the obra has no statistics for the selected period
- WHEN DetallesObraPage loads
- THEN all charts display empty state with "Sin datos" indicator

## Non-Functional Requirements

### NFR-01: Hexagonal architecture (backend)

The use case `CalcularMetricasPersonal` MUST receive repositories via constructor injection (IObraRepository, IAsistenciaRepository, IParadaRepository, IEmpleadoRepository, IEmpleadoParadaRepository). It MUST NOT query ORM directly. The facade `EstadisticasFacade` MUST also use constructor DI and MUST be registered in `Rails.configuration.di`.

### NFR-02: Authentication and authorization

The controller action MUST require a valid JWT token (returns 401 if missing/invalid). It MUST require `empresa` or `admin` role (returns 403 if `empleado`).

### NFR-03: Frontend provider isolation

`DashboardProvider` MUST use `ApiService.instance` for HTTP calls and MUST reference `kBaseUrl` from `api_service.dart`. It MUST NOT use raw `http` or hardcoded URLs.

### NFR-04: Widget data contract

All chart widgets (`GraficoHoras`, `GraficoPuntualidad`, `GraficoIrregularidades`) MUST consume `datos_por_empleado` from the API response. They MUST NOT expect `datos_diarios`.

### NFR-05: Provider registration

The system SHALL register `DashboardProvider` in `main.dart`'s `MultiProvider` alongside all existing providers without removing any.

### NFR-06: Route naming convention

The frontend route SHALL follow existing path conventions: `/empresa/obras/:obraId/detalles`.

## Out of Scope

| Item | Reason |
|------|--------|
| `GET /api/v1/estadisticas/personal/:empleado_id` | Route not implemented, endpoint reserved for future |
| `GET /api/v1/estadisticas/resumen` | Not in this change |
| `DashboardPage` full dashboard screen | Orphan page, no route — not included |
| `EstadisticasSerializer` | Dead code from legacy branch |
| `dashboard_page.dart` and its widgets | Replaced by `detalles_obra/` components |
| Test coverage tool configuration | Not part of this change |
