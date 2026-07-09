# Design: Integración de Estadísticas de Obra (Joaquín)

## Technical Approach

Calcular métricas de asistencia y puntualidad por obra + periodo desde el backend con arquitectura hexagonal pura, y mostrarlas en una nueva pantalla de detalles en el frontend. El use case recibe repos vía constructor, computa las 10 métricas del spec, y devuelve una entidad de dominio `MetricasObra`. El frontend consume el endpoint tipado mediante `DashboardProvider` → `ApiService` y renderiza gráficos con `fl_chart`.

## Architecture Decisions

### Decision: Repository query methods — extender interfaces existentes vs crear IEstadisticasRepository

| Opción | Tradeoff | Decisión |
|--------|----------|----------|
| Extender IAsistenciaRepository, IParadaRepository, IEmpleadoParadaRepository | + Cohesivo con patrón existente, cada repo sabe su dominio. Use case orquesta 4 queries separadas. | ✅ **Elegido** |
| Crear IEstadisticasRepository con una query gruesa que haga JOINs | - Crea interfaz "god" que no pertenece a un solo agregado. Rompe separación hexagonal. | ❌ Rechazado |

**Rationale**: Las queries necesarias (`asistencias por paradas+periodo`, `empleados por paradas`) son consultas de lectura que cruzan agregados. El use case las orquesta — cada repo expone lo suyo. Esto mantiene repos cohesivos y testables.

### Decision: Cálculo de métricas en use case vs en repository SQL

| Opción | Tradeoff | Decisión |
|--------|----------|----------|
| Calcular en use case con datos crudos de repos | + Testable sin DB. Lógica visible. Cumple hexagonal (repo = dumb storage). | ✅ **Elegido** |
| Métrica computada via SQL pesado en repositorio | - Lógica de negocio escondida en SQL. Difícil de testear. | ❌ Rechazado |

**Rationale**: Las 10 métricas son lógica de dominio pura (cálculos de horas, conteo de tardanzas, detección de irregularidades). Pertenece al use case, no al repositorio.

### Decision: Entity MetricasObra vs hash plano

| Opción | Tradeoff | Decisión |
|--------|----------|----------|
| `Domain::Entities::MetricasObra` con attr_reader | + Tipado, validable, consistente con patrón entities existente. | ✅ **Elegido** |
| Hash plano retornado por use case | - Sin validación, sin semántica de dominio. | ❌ Rechazado |

### Decision: Eliminar legacy vs mantener

Se elimina `EstadisticasSerializer` (dead code del branch legacy). Se recrea `DetallesObraPage` desde cero — no se migra `DashboardPage`.

## Component Diagram

```
┌─────────────────────────────────────────────────────────────────┐
│                        BACKEND (Rails)                          │
│                                                                 │
│  ┌──────────┐   ┌──────────────────────┐   ┌─────────────────┐  │
│  │ Controller│──>│  EstadisticasFacade  │──>│CalcularMetricas │  │
│  │(auth:     │   │  (DI registered)     │   │Personal (UC)   │  │
│  │ empresa/  │   │                      │   │                 │  │
│  │ admin)    │   │  Rails.config.di     │   │ recibe repos   │  │
│  └──────────┘   └──────────────────────┘   └───────┬─────────┘  │
│       │                                            │            │
│       │ GET /api/v1/estadisticas/obra/:id          │            │
│       │ ?periodo=2026-06                           │            │
│       │                                            ▼            │
│       │                                  ┌──────────────────┐   │
│       │                                  │ IObraRepository  │   │
│       │                                  │ IAsistenciaRepo  │   │
│       │                                  │ IParadaRepo      │   │
│       │                                  │ IEmpleadoRepo    │   │
│       │                                  │ IEmpleadoParada  │   │
│       │                                  └──────────────────┘   │
│       ▼                                                        │
│  ┌──────────┐   Response:                                      │
│  │Serializer │   {                                              │
│  │(inline)   │     horas_promedio, horas_totales,              │
│  │           │     puntualidad_porcentaje,                      │
│  │           │     empleados_activos, dias_trabajados,          │
│  │           │     tardanzas_total, faltas_total,              │
│  │           │     fake_gps_intentos,                          │
│  │           │     empleados_con_irregularidades,              │
│  │           │     datos_por_empleado: [...]                   │
│  │           │   }                                             │
│  └──────────┘                                                  │
└─────────────────────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────────────────────┐
│                       FRONTEND (Flutter)                        │
│                                                                 │
│  ┌──────────────┐   ┌──────────────────┐   ┌─────────────────┐  │
│  │ DetallesObra │──>│ DashboardProvider │──>│ ApiService      │  │
│  │ Page         │   │ (ChangeNotifier)  │   │ .obtenerEstadis │  │
│  │              │   │                   │   │ ticasObra()     │  │
│  │ /empresa/    │   │ Usa ApiService   │   │                 │  │
│  │ obras/:id/   │   │ instance, no http │   │ GET → /api/v1/  │  │
│  │ detalles     │   │ crudo             │   │ estadisticas/   │  │
│  │              │   │                   │   │ obra/:id       │  │
│  └──────┬───────┘   └──────────────────┘   └─────────────────┘  │
│         │                                                       │
│         ▼                                                       │
│  ┌─────────────────────────────────────────────────────┐        │
│  │ Widgets: MetricasCard, GraficoHoras,                │        │
│  │         GraficoPuntualidad, GraficoIrregularidades  │        │
│  │         (consumen datos_por_empleado)               │        │
│  └─────────────────────────────────────────────────────┘        │
└─────────────────────────────────────────────────────────────────┘
```

## Data Flow (Request → Response)

```
1. Usuario empresa navega a /empresa/obras/1/detalles
2. DetallesObraPage.initState() → DashboardProvider.cargarEstadisticas(1, "2026-06")
3. DashboardProvider → ApiService.instance.obtenerEstadisticasObra(1, "2026-06")
4. ApiService → GET /api/v1/estadisticas/obra/1?periodo=2026-06 (JWT header)
5. Rails: JwtAuthenticatable#authenticate! → decodifica token → setea @current_user
6. EstadisticasController#show (before_action :require_empresa_or_admin!)
7. Controller → Rails.configuration.di.estadisticas_facade.obtener_metricas(1, "2026-06")
8. Facade → CalcularMetricasPersonal.new(repos).call(obra_id: 1, periodo: "2026-06")
9. Use case:
   a. obra_repo.find_by_id!(1) → Obra entity
   b. parada_repo.listar_por_obra(1) → [Parada]
   c. asistencia_repo.listar_por_paradas_y_periodo([parada_ids], "2026-06") → [RegistroAsistencia]
   d. empleado_parada_repo.listar_por_paradas([parada_ids]) → [EmpleadoParada]
   e. empleado_repo.listar_varios([empleado_ids]) → [Empleado]
   f. Computa métricas → MetricasObra entity
10. Facade retorna MetricasObra
11. Controller serializa inline → JSON response
12. ApiService retorna Map<String, dynamic>
13. DashboardProvider.parse → EstadisticasObra model + notifyListeners()
14. DetallesObraPage rebuild → widgets renderizan con datos
```

## Sequence: GET /api/v1/estadisticas/obra/:id

```
Cliente                     Controller           Facade              Use Case            Repos
   │                            │                    │                    │                 │
   │  GET /estadisticas/        │                    │                    │                 │
   │  obra/1?periodo=2026-06   │                    │                    │                 │
   │───────────────────────────>│                    │                    │                 │
   │                            │  authenticate!    │                    │                 │
   │                            │───────────────────│────────────────────│─────────────────│──→ JWT decode
   │                            │  require_empresa_ │                    │                 │
   │                            │  or_admin!        │                    │                 │
   │                            │  (current_user.   │                    │                 │
   │                            │   rol check)      │                    │                 │
   │                            │                    │                    │                 │
   │                            │ facade.obtener_   │                    │                 │
   │                            │ metricas(1, periodo)                   │                 │
   │                            │──────────────────>│                    │                 │
   │                            │                    │ UC.call(          │                 │
   │                            │                    │   obra_id: 1,     │                 │
   │                            │                    │   periodo: ..)    │                 │
   │                            │                    │──────────────────>│                 │
   │                            │                    │                    │ find_by_id!(1)  │
   │                            │                    │                    │───────────────> │
   │                            │                    │                    │ <── Obra entity │
   │                            │                    │                    │                 │
   │                            │                    │                    │ listar_por_obra │
   │                            │                    │                    │───────────────> │
   │                            │                    │                    │ <── [Parada]    │
   │                            │                    │                    │                 │
   │                            │                    │                    │ listar_por_para │
   │                            │                    │                    │ das_y_periodo   │
   │                            │                    │                    │───────────────> │
   │                            │                    │                    │ <── [Asistencia]│
   │                            │                    │                    │                 │
   │                            │                    │                    │ computa métricas│
   │                            │                    │                    │ (todo en mem)   │
   │                            │                    │                    │                 │
   │                            │                    │ <── MetricasObra   │                 │
   │                            │ <── MetricasObra  │                    │                 │
   │  <── JSON 200             │                    │                    │                 │
   │───────────────────────────│                    │                    │                 │
```

## File Changes

### Backend

| File | Action | What it does |
|------|--------|-------------|
| `app/domain/entities/metricas_obra.rb` | **Create** | Entity con attr_reader para las 10 métricas + validación |
| `app/domain/errors.rb` | **Modify** | Agrega `ObraSinDatosError` (aunque obra sin datos retorna 200 con ceros, el error sirve si obra no existe) |
| `app/ports/driven/i_asistencia_repository.rb` | **Modify** | Agrega `listar_por_paradas_y_periodo(parada_ids, periodo)` |
| `app/ports/driven/i_parada_repository.rb` | — | Ya tiene `listar_por_obra(obra_id)` — sin cambios |
| `app/ports/driven/i_empleado_repository.rb` | **Modify** | Agrega `listar_varios(empleado_ids)` |
| `app/ports/driven/i_empleado_parada_repository.rb` | **Modify** | Agrega `listar_por_paradas(parada_ids)` |
| `app/infrastructure/repositories/ar_asistencia_repository.rb` | **Modify** | Implementa `listar_por_paradas_y_periodo` (filtra por parada_ids + fecha between) |
| `app/infrastructure/repositories/ar_empleado_repository.rb` | **Modify** | Implementa `listar_varios` (where id IN) |
| `app/infrastructure/repositories/ar_empleado_parada_repository.rb` | **Modify** | Implementa `listar_por_paradas` (where parada_id IN) |
| `app/application/use_cases/estadisticas/calcular_metricas_personal.rb` | **Create** | Use case que recibe 5 repos, computa métricas, retorna MetricasObra |
| `app/application/facades/estadisticas_facade.rb` | **Create** | Facade con constructor DI, método `obtener_metricas(obra_id, periodo)` |
| `app/controllers/api/v1/estadisticas_controller.rb` | **Create** | `show` action con auth empresa/admin, serialización inline |
| `config/initializers/dependency_injection.rb` | **Modify** | Registra `estadisticas_facade` con los 5 repos |
| `config/routes.rb` | **Modify** | Agrega `get 'estadisticas/obra/:obra_id', to: 'estadisticas#show'` |

### Frontend

| File | Action | What it does |
|------|--------|-------------|
| `lib/src/api_service.dart` | **Modify** | Agrega `obtenerEstadisticasObra(int obraId, String periodo)` |
| `lib/models/estadisticas_obra.dart` | **Create** | Dart model con `fromJson`, tipado: `EmpleadoMetricas` inner class |
| `lib/providers/dashboard_provider.dart` | **Create** | ChangeNotifier con `cargarEstadisticas()`, estado loading/error/data |
| `lib/pages/detalles_obra/detalles_obra_page.dart` | **Create** | `StatefulWidget` que consume DashboardProvider, muestra widgets |
| `lib/pages/detalles_obra/widgets/metricas_card.dart` | **Create** | Widget resumen: horas, puntualidad, etc. |
| `lib/pages/detalles_obra/widgets/grafico_horas.dart` | **Create** | fl_chart BarChart con horas por empleado |
| `lib/pages/detalles_obra/widgets/grafico_puntualidad.dart` | **Create** | fl_chart PieChart: puntual vs tardanza |
| `lib/pages/detalles_obra/widgets/grafico_irregularidades.dart` | **Create** | fl_chart BarChart: faltas/fake_gps por empleado |
| `lib/pages/lista_obras/lista_obras_page.dart` | **Modify** | Agrega botón "Detalles" en cada Card → navega a `/empresa/obras/:obraId/detalles` |
| `lib/main.dart` | **Modify** | Agrega `DashboardProvider` al `MultiProvider` |
| `lib/router/app_router.dart` | **Modify** | Agrega ruta `/empresa/obras/:obraId/detalles` → `DetallesObraPage` |

### Delete

| File | Rationale |
|------|-----------|
| — | `EstadisticasSerializer` no existe en main (solo en branch legacy). No se elimina nada en main. |

## Interfaces / Contracts

### JSON Response (GET /api/v1/estadisticas/obra/:obra_id?periodo=YYYY-MM)

```json
{
  "obra_id": 1,
  "periodo": "2026-06",
  "horas_promedio": 7.5,
  "horas_totales": 150.0,
  "puntualidad_porcentaje": 85.0,
  "empleados_activos": 3,
  "dias_trabajados": 22,
  "tardanzas_total": 5,
  "faltas_total": 2,
  "fake_gps_intentos": 1,
  "empleados_con_irregularidades": 2,
  "datos_por_empleado": [
    {
      "empleado_id": 1,
      "nombre": "Juan Pérez",
      "horas_trabajadas": 52.0,
      "tardanzas": 2,
      "faltas": 1,
      "fake_gps": 0
    }
  ]
}
```

### Repository contracts (new methods)

```ruby
# Ports::Driven::IAsistenciaRepository
def self.listar_por_paradas_y_periodo(parada_ids, periodo)
# @param parada_ids [Array<Integer>]
# @param periodo [String] "YYYY-MM"
# @return [Array<Domain::Entities::RegistroAsistencia>]
```

```ruby
# Ports::Driven::IEmpleadoRepository
def self.listar_varios(empleado_ids)
# @param empleado_ids [Array<Integer>]
# @return [Array<Domain::Entities::Empleado>]
```

```ruby
# Ports::Driven::IEmpleadoParadaRepository
def self.listar_por_paradas(parada_ids)
# @param parada_ids [Array<Integer>]
# @return [Array<Domain::Entities::EmpleadoParada>]
```

### Domain entity

```ruby
module Domain::Entities
  class MetricasObra
    attr_reader :obra_id, :periodo, :horas_promedio, :horas_totales,
                :puntualidad_porcentaje, :empleados_activos, :dias_trabajados,
                :tardanzas_total, :faltas_total, :fake_gps_intentos,
                :empleados_con_irregularidades, :datos_por_empleado

    # datos_por_empleado = Array of EmpleadoMetrica (value object inline)
  end
end
```

## Integration Points

| Punto | Código existente | Cómo conecta |
|-------|------------------|-------------|
| Auth | `Api::V1::BaseController` + `JwtAuthenticatable` | `EstadisticasController < BaseController`, hereda `authenticate!` + agrega `require_empresa_or_admin!` |
| DI | `Rails.configuration.di` + `DependencyContainer` | Nuevo método `estadisticas_facade` con lazy init, repos desde hash existente |
| Routes | `config/routes.rb` dentro de `namespace :api/v1` | Ruta directa `get 'estadisticas/obra/:obra_id'` igual que las rutas de cronograma |
| API Client | `ApiService.instance` singleton | Nuevo método siguiendo patrón `obtenerObras()`, `obtenerParadas()` |
| Provider Tree | `MultiProvider` en `main.dart` | Nuevo `ChangeNotifierProvider(create: (_) => DashboardProvider())` |
| Router | `GoRouter` en `app_router.dart` | Ruta nueva `/empresa/obras/:obraId/detalles` siguiendo patrón de rutas empresa existentes |
| Navegación | `ListaObrasPage` con `context.push(...)` | Botón "Detalles" en cada Card → push a nueva ruta |

## Testing Strategy

| Layer | Qué probar | Cómo |
|-------|-----------|------|
| Unit (use case) | `CalcularMetricasPersonal#call` con repos mockeados (mock de array en memoria). Happy path, obra sin datos, obra inexistente | Test unitario con repos falsos que retornan arrays predecibles |
| Unit (provider) | `DashboardProvider.cargarEstadisticas()` con `ApiService` mockeado | Mock `ApiService.createForTesting`, verificar notifyListeners cambios de estado |
| Integration (controller) | `GET /estadisticas/obra/:id` con token empresa, token empleado (403), sin token (401) | Request test con `ActionDispatch::IntegrationTest` |
| Widget (page) | `DetallesObraPage` renderiza MetricasCard + gráficos con datos mock | Provider con `DashboardProvider` mockeado, `pumpWidget` + finder |
| Widget (lista) | Botón "Detalles" en `ListaObrasPage` navega correctamente | Pump lista, tap button, verificar ruta |

No se requieren nuevas gems ni packages. `fl_chart` debe confirmarse en `pubspec.yaml`.

## Open Questions

- [ ] Confirmar que `fl_chart` está en `pubspec.yaml` del frontend. Si no, agregarlo como dependencia.
- [ ] Confirmar nombre del endpoint con el equipo: `estadisticas/obra/:obra_id` vs `obras/:obra_id/estadisticas` (elegí el primero para mantener separación de concerns).
