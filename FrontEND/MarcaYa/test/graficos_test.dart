import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/models/estadisticas_obra.dart';
import 'package:marcapp/pages/detalles_obra/widgets/grafico_horas.dart';
import 'package:marcapp/pages/detalles_obra/widgets/grafico_puntualidad.dart';
import 'package:marcapp/pages/detalles_obra/widgets/grafico_irregularidades.dart';

void main() {
  group('GraficoHoras', () {
    testWidgets('shows employee names and hours', (tester) async {
      final datos = [
        const DatosEmpleado(
          empleadoId: 1,
          nombre: 'Juan Pérez',
          horasTrabajadas: 52.0,
          tardanzas: 0,
          faltas: 0,
          fakeGps: 0,
        ),
        const DatosEmpleado(
          empleadoId: 2,
          nombre: 'María López',
          horasTrabajadas: 48.0,
          tardanzas: 0,
          faltas: 0,
          fakeGps: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GraficoHoras(datosPorEmpleado: datos),
            ),
          ),
        ),
      );

      expect(find.text('Juan Pérez'), findsOneWidget);
      expect(find.text('María López'), findsOneWidget);
      expect(find.text('52.0h'), findsOneWidget);
      expect(find.text('48.0h'), findsOneWidget);
      expect(find.byType(LinearProgressIndicator), findsNWidgets(2));
    });

    testWidgets('shows empty state when no data', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GraficoHoras(datosPorEmpleado: []),
          ),
        ),
      );

      expect(find.text('Sin datos de horas'), findsOneWidget);
    });

    testWidgets('limits display to top 10 employees', (tester) async {
      final datos = List.generate(
        15,
        (i) => DatosEmpleado(
          empleadoId: i,
          nombre: 'Empleado $i',
          horasTrabajadas: (15 - i).toDouble(),
          tardanzas: 0,
          faltas: 0,
          fakeGps: 0,
        ),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GraficoHoras(datosPorEmpleado: datos),
            ),
          ),
        ),
      );

      // Should show top 10 (Employee 0 has 15.0h, down to Employee 9 with 6.0h)
      expect(find.byType(LinearProgressIndicator), findsNWidgets(10));
      expect(find.text('Empleado 0'), findsOneWidget);
      expect(find.text('Empleado 14'), findsNothing);
    });
  });

  group('GraficoPuntualidad', () {
    testWidgets('displays percentage and label', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GraficoPuntualidad(puntualidadPorcentaje: 85.0),
          ),
        ),
      );

      expect(find.text('85%'), findsOneWidget);
      expect(find.text('a tiempo'), findsOneWidget);
      expect(find.text('Puntualidad'), findsOneWidget);
    });

    testWidgets('displays 0% for zero punctuality', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GraficoPuntualidad(puntualidadPorcentaje: 0.0),
          ),
        ),
      );

      expect(find.text('0%'), findsOneWidget);
    });

    testWidgets('clamps values above 100 to 100%', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GraficoPuntualidad(puntualidadPorcentaje: 120.0),
          ),
        ),
      );

      // Clamped to 100
      expect(find.text('100%'), findsOneWidget);
    });
  });

  group('GraficoIrregularidades', () {
    testWidgets('displays summary counts', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GraficoIrregularidades(
              tardanzasTotal: 5,
              faltasTotal: 2,
              fakeGpsIntentos: 1,
              datosPorEmpleado: [],
            ),
          ),
        ),
      );

      expect(find.text('Tardanzas'), findsOneWidget);
      expect(find.text('Faltas'), findsOneWidget);
      expect(find.text('Fake GPS'), findsOneWidget);
      expect(find.text('5'), findsOneWidget);
      expect(find.text('2'), findsOneWidget);
      expect(find.text('1'), findsOneWidget);
    });

    testWidgets('shows empty message when no irregularities', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: GraficoIrregularidades(
              tardanzasTotal: 0,
              faltasTotal: 0,
              fakeGpsIntentos: 0,
              datosPorEmpleado: [],
            ),
          ),
        ),
      );

      expect(
        find.text('Sin irregularidades registradas'),
        findsOneWidget,
      );
    });

    testWidgets('shows employees with irregularities', (tester) async {
      final datos = [
        const DatosEmpleado(
          empleadoId: 1,
          nombre: 'Juan',
          horasTrabajadas: 40,
          tardanzas: 2,
          faltas: 1,
          fakeGps: 0,
        ),
        const DatosEmpleado(
          empleadoId: 2,
          nombre: 'María',
          horasTrabajadas: 40,
          tardanzas: 0,
          faltas: 0,
          fakeGps: 0,
        ),
      ];

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SingleChildScrollView(
              child: GraficoIrregularidades(
                tardanzasTotal: 2,
                faltasTotal: 1,
                fakeGpsIntentos: 0,
                datosPorEmpleado: datos,
              ),
            ),
          ),
        ),
      );

      // Juan has irregularities, María doesn't
      expect(find.text('Juan'), findsOneWidget);
      expect(find.text('María'), findsNothing);
      // Badges for Juan
      expect(find.text('2T'), findsOneWidget);
      expect(find.text('1F'), findsOneWidget);
    });
  });
}
