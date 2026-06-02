# Proposal: Asistencia Module

## Intent

Implement a GPS-validated attendance system for MarcaYa. Employees mark ENTRY/EXIT at geofenced stops (Paradas), with real-time monitoring for companies. Addresses core workforce tracking need — currently no attendance tracking exists in the codebase. The legacy `asistencias` table uses a different schema (obra-level, no per-marking GPS) and will NOT be reused.

## Scope

### In Scope
- RegistroAsistencia entity (new table: `registro_asistencias`)
- GPS validation using existing GpsValidationService.dentro_de_geocerca?
- POST /asistencia/marcar-entrada — employee marks entry with GPS
- POST /asistencia/marcar-salida — employee marks exit, calculates duration
- GET /asistencia/historial — personal history (EMPLEADO) / all history (EMPRESA/ADMIN)
- GET /asistencia/tiempo-real — real-time stop monitoring (EMPRESA/ADMIN)
- Full hexagonal architecture: domain entity, ports, infrastructure, application, controllers

### Out of Scope
- ActionCable real-time push (start with polling)
- Report generation/download (US-0001-0009 deferred to Sprint 4)
- Legacy `asistencias` table migration or removal
- Notification system for late arrivals

## Capabilities

### New Capabilities
- `attendance-marking`: GPS-validated ENTRY/EXIT registration with geofence checks, state management (no double-entry), and work duration calculation
- `attendance-history`: Employee personal history and company-wide employee history queries
- `attendance-monitoring`: Real-time stop-level attendance status for EMPRESA/ADMIN roles

### Modified Capabilities
None — no existing specs in openspec/specs/.

## Approach

Create new `registro_asistencias` table (not reuse legacy `asistencias`). Follow existing hexagonal patterns: domain entity with validations, driven port (IAsistenciaRepository), AR infrastructure (AsistenciaRecord, AsistenciaMapper, ArAsistenciaRepository), application layer (MarcarEntrada/MarcarSalida use cases + AsistenciaFacade), driving port (IGestionarAsistencia), API controller (AsistenciasController), and serializer. GPS validation fetches Parada entity and delegates to GpsValidationService.dentro_de_geocerca?. State management: check no active entry before new entry; find active entry for exit. Duration calculated at exit as difference in minutes.

## Affected Areas

| Area | Impact | Description |
|------|--------|-------------|
| `app/domain/entities/` | New | RegistroAsistencia entity |
| `app/ports/driven/` | New | IAsistenciaRepository port |
| `app/ports/driving/` | New | IGestionarAsistencia port |
| `app/infrastructure/repositories/` | New | AsistenciaRecord, AsistenciaMapper, ArAsistenciaRepository |
| `app/infrastructure/services/` | New | AsistenciaFacade |
| `app/application/use_cases/` | New | MarcarEntrada, MarcarSalida, HistorialPersonal, HistorialEmpleado, TiempoReal |
| `app/controllers/api/v1/` | New | AsistenciasController |
| `app/serializers/` | New | AsistenciaSerializer |
| `db/migrate/` | New | Create registro_asistencias table |
| `config/initializers/` | Modified | Register asistencia_facade + asistencia_repo in DI |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| GPS accuracy issues at building edges | Medium | Use configurable radio_metros per Parada; allow observaciones for edge cases |
| Race condition: two entry marks simultaneously | Low | Database-level unique constraint on active entry; use transaction locking |
| Legacy asistencias table confusion | Low | Document decision clearly; new table uses distinct name `registro_asistencias` |

## Rollback Plan

1. Remove migration: `rails destroy migration CreateRegistroAsistencias`
2. Remove new files: domain entity, ports, infrastructure, application, controller, serializer
3. Remove DI registrations from initializer
4. No data loss — new table only, legacy untouched

## Dependencies

- Existing GpsValidationService (already implemented)
- Existing Parada entity (latitud, longitud, radio_metros, obra_id)
- Existing Empleado entity (usuario_id)
- Existing JwtAuthenticatable concern (current_user)
- Existing rol gem for role-based access (EMPLEADO, EMPRESA, ADMIN)

## Success Criteria

- [ ] Employee can mark ENTRY at a Parada with GPS validation
- [ ] Employee can mark EXIT with duration calculated automatically
- [ ] Double-entry prevention: cannot mark ENTRY without prior EXIT
- [ ] GPS validation correctly rejects marks outside geofence radius
- [ ] Personal history returns employee's own attendance records
- [ ] Company admin can view any employee's history
- [ ] Real-time endpoint shows current status at each Parada
- [ ] All roles enforced: EMPLEADO for marking, EMPRESA/ADMIN for monitoring
- [ ] Tests pass across all hexagonal layers (domain, application, controller, infrastructure)
