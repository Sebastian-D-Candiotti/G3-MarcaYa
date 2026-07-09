import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:marcapp/models/estadisticas_obra.dart';
import 'package:marcapp/pages/detalles_obra/detalles_obra_page.dart';
import 'package:marcapp/providers/dashboard_provider.dart';

/// Fake DashboardProvider that extends the real one.
/// Sets _estadisticas and _error directly to simulate states.
class _FakeDashboardProvider extends DashboardProvider {
  _FakeDashboardProvider();

  _FakeDashboardProvider.success(EstadisticasObra stats) {
    _stats = stats;
  }

  _FakeDashboardProvider.loading() {
    _isLoading = true;
  }

  _FakeDashboardProvider.errorState(String message) {
    _errorMsg = message;
  }

  EstadisticasObra? _stats;
  bool _isLoading = false;
  String? _errorMsg;

  @override
  EstadisticasObra? get estadisticas => _stats;

  @override
  bool get cargando => _isLoading;

  @override
  String? get error => _errorMsg;
}

EstadisticasObra _mockStats() {
  return const EstadisticasObra(
    obraId: 1,
    obraNombre: 'Obra Test',
    periodo: '2026-07',
    horasPromedio: 7.5,
    horasTotales: 150.0,
    puntualidadPorcentaje: 85.0,
    diasTrabajados: 22,
    tardanzasTotal: 5,
    faltasTotal: 2,
    fakeGpsIntentos: 1,
    empleadosActivos: 20,
    empleadosConIrregularidades: 3,
    datosPorEmpleado: [
      DatosEmpleado(
        empleadoId: 1,
        nombre: 'Juan Pérez',
        horasTrabajadas: 52.0,
        tardanzas: 2,
        faltas: 1,
        fakeGps: 0,
      ),
      DatosEmpleado(
        empleadoId: 2,
        nombre: 'María López',
        horasTrabajadas: 48.0,
        tardanzas: 0,
        faltas: 0,
        fakeGps: 1,
      ),
    ],
  );
}

Widget _buildApp(DashboardProvider provider, {String? nombre}) {
  return ChangeNotifierProvider<DashboardProvider>.value(
    value: provider,
    child: MaterialApp(
      home: DetallesObraPage(obraId: 1, obraNombre: nombre),
    ),
  );
}

void main() {
  group('DetallesObraPage', () {
    testWidgets('shows loading indicator while loading', (tester) async {
      final provider = _FakeDashboardProvider.loading();

      await tester.pumpWidget(_buildApp(provider));

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Should NOT show content yet
      expect(find.text('Horas Totales'), findsNothing);
    });

    testWidgets('renders metrics cards with data', (tester) async {
      final provider = _FakeDashboardProvider.success(_mockStats());

      await tester.pumpWidget(_buildApp(provider));

      // Summary metrics should be visible
      expect(find.text('Horas Totales'), findsOneWidget);
      expect(find.text('150.0'), findsOneWidget);
      expect(find.text('Días Trabajados'), findsOneWidget);
      expect(find.text('22'), findsOneWidget);
      expect(find.text('Empleados Activos'), findsOneWidget);
      expect(find.text('20'), findsOneWidget);
    });

    testWidgets('renders punctuality chart', (tester) async {
      final provider = _FakeDashboardProvider.success(_mockStats());

      await tester.pumpWidget(_buildApp(provider));

      expect(find.text('Puntualidad'), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('renders irregularities section', (tester) async {
      final provider = _FakeDashboardProvider.success(_mockStats());

      await tester.pumpWidget(_buildApp(provider));

      expect(find.text('Irregularidades'), findsOneWidget);
      // "Tardanzas" appears in MetricasCard AND GraficoIrregularidades
      expect(find.text('Tardanzas'), findsWidgets);
    });

    testWidgets('renders employee breakdown table', (tester) async {
      final provider = _FakeDashboardProvider.success(_mockStats());

      await tester.pumpWidget(_buildApp(provider));

      expect(find.text('Desglose por Empleado'), findsOneWidget);
      expect(find.text('Juan Pérez'), findsWidgets);
      expect(find.text('María López'), findsWidgets);
    });

    testWidgets('shows error state with message', (tester) async {
      final provider = _FakeDashboardProvider.errorState('Connection timeout');

      await tester.pumpWidget(_buildApp(provider));

      expect(find.text('Error al cargar estadísticas'), findsOneWidget);
      expect(find.text('Connection timeout'), findsOneWidget);
      expect(find.text('Reintentar'), findsOneWidget);
    });

    testWidgets('shows empty state when no data', (tester) async {
      final provider = _FakeDashboardProvider();

      await tester.pumpWidget(_buildApp(provider));

      expect(find.text('Sin datos disponibles'), findsOneWidget);
    });

    testWidgets('uses obraNombre in AppBar', (tester) async {
      final provider = _FakeDashboardProvider.success(_mockStats());

      await tester.pumpWidget(_buildApp(provider, nombre: 'Mi Obra'));

      expect(find.text('Mi Obra'), findsOneWidget);
    });
  });
}
