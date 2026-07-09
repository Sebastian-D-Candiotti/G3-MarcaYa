import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/providers/dashboard_provider.dart';

/// Minimal ApiService stub for testing the provider in isolation.
/// The provider accepts an ApiService instance via constructor for testability.
class _FakeApiService {
  _FakeApiService({required this.handler});

  final Future<Map<String, dynamic>> Function(int obraId, {String? periodo})
      handler;

  Future<Map<String, dynamic>> obtenerEstadisticasObra(
    int obraId, {
    String? periodo,
  }) {
    return handler(obraId, periodo: periodo);
  }
}

void main() {
  group('DashboardProvider', () {
    test('initial state has no data, not loading, no error', () {
      final provider = DashboardProvider();

      expect(provider.estadisticas, isNull);
      expect(provider.cargando, isFalse);
      expect(provider.error, isNull);
    });

    test('cargarEstadisticas sets estadisticas on success', () async {
      final fakeApi = _FakeApiService(
        handler: (obraId, {periodo}) async {
          return {
            'obra_id': obraId,
            'obra_nombre': 'Obra Test',
            'periodo': periodo ?? '',
            'horas_promedio': 8.0,
            'horas_totales': 160.0,
            'puntualidad_porcentaje': 90.0,
            'dias_trabajados': 20,
            'tardanzas_total': 3,
            'faltas_total': 1,
            'fake_gps_intentos': 0,
            'empleados_activos': 15,
            'empleados_con_irregularidades': 2,
            'datos_por_empleado': [
              {
                'empleado_id': 1,
                'nombre': 'Ana García',
                'horas_trabajadas': 40.0,
                'tardanzas': 1,
                'faltas': 0,
                'fake_gps': 0,
              },
            ],
          };
        },
      );

      final provider = DashboardProvider(api: fakeApi as dynamic);
      await provider.cargarEstadisticas(1, periodo: '2026-07');

      expect(provider.cargando, isFalse);
      expect(provider.error, isNull);
      expect(provider.estadisticas, isNotNull);
      expect(provider.estadisticas!.obraId, equals(1));
      expect(provider.estadisticas!.obraNombre, equals('Obra Test'));
      expect(provider.estadisticas!.horasTotales, equals(160.0));
      expect(provider.estadisticas!.datosPorEmpleado, hasLength(1));
      expect(provider.estadisticas!.datosPorEmpleado[0].nombre, equals('Ana García'));
    });

    test('cargarEstadisticas sets error on failure', () async {
      final fakeApi = _FakeApiService(
        handler: (obraId, {periodo}) async {
          throw Exception('Network error');
        },
      );

      final provider = DashboardProvider(api: fakeApi as dynamic);
      await provider.cargarEstadisticas(1);

      expect(provider.cargando, isFalse);
      expect(provider.estadisticas, isNull);
      expect(provider.error, isNotNull);
      expect(provider.error, contains('Network error'));
    });

    test('cargarEstadisticas notifies listeners during loading', () async {
      final notifyCount = <bool>[];
      final fakeApi = _FakeApiService(
        handler: (obraId, {periodo}) async {
          return {
            'obra_id': obraId,
            'obra_nombre': '',
            'periodo': '',
            'horas_promedio': 0.0,
            'horas_totales': 0.0,
            'puntualidad_porcentaje': 0.0,
            'dias_trabajados': 0,
            'tardanzas_total': 0,
            'faltas_total': 0,
            'fake_gps_intentos': 0,
            'empleados_activos': 0,
            'empleados_con_irregularidades': 0,
            'datos_por_empleado': [],
          };
        },
      );

      final provider = DashboardProvider(api: fakeApi as dynamic);
      provider.addListener(() => notifyCount.add(provider.cargando));

      await provider.cargarEstadisticas(1);

      // Should have been notified: once with true (loading), once with false (done)
      expect(notifyCount.length, greaterThanOrEqualTo(2));
      expect(notifyCount.first, isTrue);
      expect(notifyCount.last, isFalse);
    });
  });
}
