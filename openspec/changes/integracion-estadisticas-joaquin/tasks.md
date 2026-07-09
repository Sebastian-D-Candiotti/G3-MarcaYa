# Tasks: Integración de Estadísticas de Obra (Joaquín)

## Review Workload Forecast

| Field | Value |
|-------|-------|
| Estimated changed lines | ~870 additions, 0 deletions |
| 400-line budget risk | High |
| Chained PRs recommended | Yes |
| Suggested split | PR 1: Backend (repos + domain + use case + facade + controller + routes + DI + tests) → PR 2: Frontend (model + provider + widgets + page + wiring + tests) |
| Delivery strategy | ask-on-risk |
| Chain strategy | stacked-to-main |

Decision needed before apply: Yes
Chained PRs recommended: Yes
Chain strategy: stacked-to-main
400-line budget risk: High

### Suggested Work Units

| Unit | Goal | Likely PR | Notes |
|------|------|-----------|-------|
| 1 | Backend hexagonal core | PR 1 | Repos + domain + use case + facade + controller + routes + DI + BE tests. Independent of frontend. |
| 2 | Frontend UI + provider | PR 2 | Model + ApiService + DashboardProvider + DetallesObraPage + widgets + route + tests. Depends on PR 1 for API contract. |

## Phase 1: Backend Repositories

- [ ] 1.1 Add `listar_por_paradas_y_periodo(parada_ids, periodo)` to `app/ports/driven/i_asistencia_repository.rb` (S)
- [ ] 1.2 Add `listar_varios(empleado_ids)` to `app/ports/driven/i_empleado_repository.rb` (S)
- [ ] 1.3 Add `listar_por_paradas(parada_ids)` to `app/ports/driven/i_empleado_parada_repository.rb` (S)
- [ ] 1.4 Implement `listar_por_paradas_y_periodo` in `app/infrastructure/repositories/ar_asistencia_repository.rb` (where parada_id IN + fecha between) (M)
- [ ] 1.5 Implement `listar_varios` in `app/infrastructure/repositories/ar_empleado_repository.rb` (where id IN) (M)
- [ ] 1.6 Implement `listar_por_paradas` in `app/infrastructure/repositories/ar_empleado_parada_repository.rb` (where parada_id IN) (M)

## Phase 2: Backend Domain & Use Case

- [ ] 2.1 Add `ObraSinDatosError` to `app/domain/errors.rb` (S)
- [ ] 2.2 Create `app/domain/entities/metricas_obra.rb` with 10 attr_readers + `EmpleadoMetrica` inner value object + validation (M)
- [ ] 2.3 Create `app/application/use_cases/estadisticas/calcular_metricas_personal.rb` receiving 5 repos via constructor; compute all 10 metrics in memory (L)
- [ ] 2.4 Create `app/application/facades/estadisticas_facade.rb` with constructor DI, `obtener_metricas(obra_id, periodo)` method (S)
- [ ] 2.5 Create `app/controllers/api/v1/estadisticas_controller.rb` inheriting `BaseController`, `before_action :require_empresa_or_admin!`, inline serialization (M)

## Phase 3: Backend Wiring

- [ ] 3.1 Add `get 'estadisticas/obra/:obra_id', to: 'estadisticas#show'` to `config/routes.rb` (S)
- [ ] 3.2 Register `estadisticas_facade` with 5 repos in `config/initializers/dependency_injection.rb` (S)

## Phase 4: Frontend Service Layer

- [x] 4.1 Create `lib/models/estadisticas_obra.dart` with `EstadisticasObra` and `EmpleadoMetricas` classes + `fromJson` (M)
- [x] 4.2 Add `obtenerEstadisticasObra(int obraId, String periodo)` to `lib/src/api_service.dart` (S)
- [x] 4.3 Create `lib/providers/dashboard_provider.dart` — ChangeNotifier using `ApiService.instance`, states: loading/error/data, `cargarEstadisticas(obraId, periodo)` (M)

## Phase 5: Frontend UI

- [x] 5.1 Create `lib/pages/detalles_obra/widgets/metricas_card.dart` — summary card (horas, puntualidad, empleados, etc.) (M)
- [x] 5.2 Create `lib/pages/detalles_obra/widgets/grafico_horas.dart` — custom LinearProgressIndicator bars per employee (no fl_chart) (M)
- [x] 5.3 Create `lib/pages/detalles_obra/widgets/grafico_puntualidad.dart` — custom progress widget: % on-time vs tardanzas (M)
- [x] 5.4 Create `lib/pages/detalles_obra/widgets/grafico_irregularidades.dart` — custom bars for faltas/fake_gps per employee (M)
- [x] 5.5 Create `lib/pages/detalles_obra/detalles_obra_page.dart` — StatefulWidget consuming DashboardProvider, uses all 4 widgets (L)
- [x] 5.6 Add route `/empresa/obras/:obraId/detalles` → `DetallesObraPage` in `lib/router/app_router.dart` (S)
- [x] 5.7 Add `DashboardProvider` to `MultiProvider` in `lib/main.dart` (S)
- [x] 5.8 Add "Detalles" button to each obra Card in `lib/pages/lista_obras/lista_obras_page.dart` navigating via `context.push` (S)

## Phase 6: Tests

- [ ] 6.1 Backend use case test: `test/application/use_cases/estadisticas/calcular_metricas_personal_test.rb` — mock repos, test happy path / obra sin datos / obra inexistente (L)
- [ ] 6.2 Backend controller test: `test/controllers/api/v1/estadisticas_controller_test.rb` — 200 with token empresa, 403 with empleado, 401 sin token, 404 obra inexistente (L)
- [x] 6.3 Frontend provider test: `test/dashboard_provider_test.dart` — mock ApiService, verify states (S)
- [x] 6.4 Frontend page/widget test: `test/detalles_obra_page_test.dart` — pump with mock provider, verify MetricasCard + charts render (M)

## Phase 7: Verify & Branch

- [ ] 7.1 Run `rails test` + `rubocop` + `flutter test` + `flutter analyze` — all green (M)
- [ ] 7.2 Create branch `feat/integracion-estadisticas` from main, commit backend slice (PR 1) then frontend slice (PR 2) (S)
- [ ] 7.3 Verify integration: hit endpoint with curl, navigate page on emulator (S)
