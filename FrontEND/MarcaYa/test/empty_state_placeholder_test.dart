import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:marcapp/components/empty_state_placeholder.dart';

void main() {
  group('EmptyStatePlaceholder Tests', () {
    testWidgets('Renders correctly with icon, title, and description', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatePlaceholder(
              icon: Icons.search,
              title: 'No results found',
              description: 'Try adjusting your search criteria.',
            ),
          ),
        ),
      );

      expect(find.text('No results found'), findsOneWidget);
      expect(find.text('Try adjusting your search criteria.'), findsOneWidget);
      expect(find.byIcon(Icons.search), findsOneWidget);
      // Action button should not be displayed
      expect(find.byType(ElevatedButton), findsNothing);
    });

    testWidgets('Renders action button when actionLabel and onActionPressed are provided', (tester) async {
      bool actionPressed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: EmptyStatePlaceholder(
              icon: Icons.refresh,
              title: 'Connection error',
              description: 'Failed to load data from server.',
              actionLabel: 'Retry',
              onActionPressed: () {
                actionPressed = true;
              },
            ),
          ),
        ),
      );

      expect(find.text('Connection error'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);
      expect(find.byType(ElevatedButton), findsOneWidget);

      await tester.tap(find.byType(ElevatedButton));
      await tester.pump();

      expect(actionPressed, isTrue);
    });

    testWidgets('Respects isCompact mode layout constraints', (tester) async {
      // Build compact layout
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatePlaceholder(
              icon: Icons.info_outline,
              title: 'Compact state',
              description: 'This is a compact empty state.',
              isCompact: true,
            ),
          ),
        ),
      );

      expect(find.text('Compact state'), findsOneWidget);

      // Verify the size of the icon container or text sizing using constraints
      final Text titleText = tester.widget(find.text('Compact state'));
      expect(titleText.style?.fontSize, 14); // 14 for compact, 18 for regular

      final Text descText = tester.widget(find.text('This is a compact empty state.'));
      expect(descText.style?.fontSize, 12); // 12 for compact, 14 for regular
    });

    testWidgets('Regular layout uses correct font sizes', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: EmptyStatePlaceholder(
              icon: Icons.info_outline,
              title: 'Regular state',
              description: 'This is a regular empty state.',
              isCompact: false,
            ),
          ),
        ),
      );

      final Text titleText = tester.widget(find.text('Regular state'));
      expect(titleText.style?.fontSize, 18);

      final Text descText = tester.widget(find.text('This is a regular empty state.'));
      expect(descText.style?.fontSize, 14);
    });
  });
}
