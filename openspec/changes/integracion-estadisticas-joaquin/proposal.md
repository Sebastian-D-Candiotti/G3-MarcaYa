# Proposal: Integración de Estadísticas de Obra (Joaquín)

## Intent

Integrar ~1500 líneas del branch `feature/Semana4/Joaquin/US-5/Estadisticas` respetando la arquitectura hexagonal. El branch original viola: use cases con ORM directo, facade hardcodea `ObraRecord.find`, controlador sin DI ni auth, provider Flutter con HTTP crudo, 0 tests.

## Scope

**In**: Backend endpoints `GET /estadisticas/obra/:obra_id` y `GET /estadisticas/resumen` (hex clean). Entity `MetricasObra`, error `ObraSinDatosError`, use case con repos vía constructor (IObra/IParada/IAsistencia/IEmpleado/IEmpleadoParada). Facade vía DI. Controller con `require_empresa_or_admin!`. Frontend: `DashboardProvider` via `ApiService`, widgets `MetricasCard`/`GraficoHoras`/`GraficoPuntualidad`/`GraficoIrregularidades`/`FiltroObra`, `DetallesObraPage` en `/empresa/obras/:obraId/detalles`, botón en `ListaObrasPage`. Tests: use case + controller + provider + page.

**Out**: Dashboard multi-obra, endpoint `personal/:empleado_id`, `EstadisticasSerializer` (muerto), `DashboardPage` (huérfana → reemplazada).

## Capabilities

**New**: `estadisticas-obra` — métricas de asistencia por obra. GET /api/v1/estadisticas/obra/:obra_id. Frontend con gráficos. Rol empresa.

**Modified**: None.

## Approach

1. Branch `feat/integracion-estadisticas` desde main
2. Backend fresh (sin copia legacy): entity + error + use case + repos + facade DI + controller auth + 2 rutas
3. Frontend fresh: ApiService.obtenerEstadisticasObra(), DashboardProvider, DetallesObraPage + widgets, ruta, botón
4. Tests: unit (use case, provider), integration (controller), widget (page)
5. Delete legacy: `estadisticas_serializer.rb`, `dashboard_page.dart`

## Affected Areas

| Area | Impact |
|------|--------|
| `routes.rb` | +2 rutas |
| `domain/errors.rb` | +error |
| `domain/entities/metricas_obra.rb` | New |
| `application/use_cases/estadisticas/` | New |
| `application/facades/estadisticas_facade.rb` | New |
| `controllers/api/v1/estadisticas_controller.rb` | New |
| `config/initializers/dependency_injection.rb` | +facade |
| `FrontEND/.../api_service.dart` | +method |
| `FrontEND/.../dashboard_provider.dart` | New |
| `FrontEND/.../pages/detalles_obra/` | New (page + 4 widgets) |
| `FrontEND/.../lista_obras_page.dart` | +botón |
| `FrontEND/.../main.dart` | +provider |
| `FrontEND/.../app_router.dart` | +ruta |

## Risks

| Risk | Likelihood | Mitigation |
|------|------------|------------|
| Widgets esperan `datos_diarios` API retorna `datos_por_empleado` | High | Adaptar widgets |
| Branch 58 commits behind — conflictos | High | Fresh desde main |
| Use case 167 líneas lógica tardanzas/faltas | Med | Refactor + test unit |
| fl_chart dependency missing | Low | Revisar pubspec.yaml |

## Rollback

`git revert` del merge commit. Todo es nuevo (sin modificar lógica existente), revert es limpio.

## Dependencies

Ninguna externa. Widgets usan fl_chart (revisar pubspec.yaml).

## Success Criteria

- [ ] GET /api/v1/estadisticas/obra/1?periodo=2026-06 → 200 con métricas
- [ ] GET /api/v1/estadisticas/obra/999 → 404
- [ ] GET sin token → 401; como empleado → 403
- [ ] `/empresa/obras/1/detalles` muestra gráficos con datos reales
- [ ] `rails test` + `flutter test` + `flutter analyze` + `rubocop` pasan
