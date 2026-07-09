import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/models/estadisticas_obra.dart';

void main() {
  group('EstadisticasObra.fromJson', () {
    test('parses full JSON response correctly', () {
      final json = <String, dynamic>{
        'obra_id': 1,
        'obra_nombre': 'Obra Central',
        'periodo': '2026-07',
        'horas_promedio': 7.5,
        'horas_totales': 150.0,
        'puntualidad_porcentaje': 85.0,
        'dias_trabajados': 22,
        'tardanzas_total': 5,
        'faltas_total': 2,
        'fake_gps_intentos': 1,
        'empleados_activos': 20,
        'empleados_con_irregularidades': 3,
        'datos_por_empleado': [
          {
            'empleado_id': 1,
            'nombre': 'Juan Pérez',
            'horas_trabajadas': 52.0,
            'tardanzas': 2,
            'faltas': 1,
            'fake_gps': 0,
          },
          {
            'empleado_id': 2,
            'nombre': 'María López',
            'horas_trabajadas': 48.0,
            'tardanzas': 0,
            'faltas': 0,
            'fake_gps': 1,
          },
        ],
      };

      final stats = EstadisticasObra.fromJson(json);

      expect(stats.obraId, equals(1));
      expect(stats.obraNombre, equals('Obra Central'));
      expect(stats.periodo, equals('2026-07'));
      expect(stats.horasPromedio, equals(7.5));
      expect(stats.horasTotales, equals(150.0));
      expect(stats.puntualidadPorcentaje, equals(85.0));
      expect(stats.diasTrabajados, equals(22));
      expect(stats.tardanzasTotal, equals(5));
      expect(stats.faltasTotal, equals(2));
      expect(stats.fakeGpsIntentos, equals(1));
      expect(stats.empleadosActivos, equals(20));
      expect(stats.empleadosConIrregularidades, equals(3));
      expect(stats.datosPorEmpleado, hasLength(2));
    });

    test('parses DatosEmpleado fields correctly', () {
      final json = <String, dynamic>{
        'empleado_id': 5,
        'nombre': 'Carlos Ruiz',
        'horas_trabajadas': 40.0,
        'tardanzas': 3,
        'faltas': 0,
        'fake_gps': 2,
      };

      final empleado = DatosEmpleado.fromJson(json);

      expect(empleado.empleadoId, equals(5));
      expect(empleado.nombre, equals('Carlos Ruiz'));
      expect(empleado.horasTrabajadas, equals(40.0));
      expect(empleado.tardanzas, equals(3));
      expect(empleado.faltas, equals(0));
      expect(empleado.fakeGps, equals(2));
    });

    test('handles zero-valued metrics (obra sin datos)', () {
      final json = <String, dynamic>{
        'obra_id': 2,
        'obra_nombre': 'Obra Vacía',
        'periodo': '2026-07',
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

      final stats = EstadisticasObra.fromJson(json);

      expect(stats.obraId, equals(2));
      expect(stats.horasTotales, equals(0.0));
      expect(stats.empleadosActivos, equals(0));
      expect(stats.datosPorEmpleado, isEmpty);
    });

    test('handles null datos_por_empleado as empty list', () {
      final json = <String, dynamic>{
        'obra_id': 3,
        'obra_nombre': 'Obra Sin Lista',
        'periodo': '2026-07',
        'horas_promedio': 0.0,
        'horas_totales': 0.0,
        'puntualidad_porcentaje': 0.0,
        'dias_trabajados': 0,
        'tardanzas_total': 0,
        'faltas_total': 0,
        'fake_gps_intentos': 0,
        'empleados_activos': 0,
        'empleados_con_irregularidades': 0,
      };

      final stats = EstadisticasObra.fromJson(json);

      expect(stats.datosPorEmpleado, isEmpty);
    });
  });
}
