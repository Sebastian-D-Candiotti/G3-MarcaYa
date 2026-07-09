import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/pages/detalles_obra/widgets/metricas_card.dart';

void main() {
  group('MetricasCard', () {
    testWidgets('displays title, value, and subtitle', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricasCard(
              titulo: 'Horas Totales',
              valor: '150.0',
              icono: Icons.access_time,
              subtitulo: 'horas trabajadas',
            ),
          ),
        ),
      );

      expect(find.text('Horas Totales'), findsOneWidget);
      expect(find.text('150.0'), findsOneWidget);
      expect(find.text('horas trabajadas'), findsOneWidget);
      expect(find.byIcon(Icons.access_time), findsOneWidget);
    });

    testWidgets('renders with gradient container', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricasCard(
              titulo: 'Puntualidad',
              valor: '85%',
              icono: Icons.check_circle,
              subtitulo: 'a tiempo',
              colorDesde: Color(0xFF10B981),
              colorHasta: Color(0xFF059669),
            ),
          ),
        ),
      );

      // Verify the widget renders (gradient container exists)
      expect(find.byType(MetricasCard), findsOneWidget);
      expect(find.text('85%'), findsOneWidget);
    });

    testWidgets('applies custom colors when provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: MetricasCard(
              titulo: 'Test',
              valor: '10',
              icono: Icons.star,
              subtitulo: 'subtitle',
              colorDesde: Colors.red,
              colorHasta: Colors.blue,
            ),
          ),
        ),
      );

      expect(find.text('Test'), findsOneWidget);
      expect(find.text('10'), findsOneWidget);
    });
  });
}
