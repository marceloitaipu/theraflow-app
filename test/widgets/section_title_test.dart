import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/widgets/section_title.dart';

void main() {
  group('SectionTitle Widget', () {
    testWidgets('renderiza título correto', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionTitle('Minha Seção'),
          ),
        ),
      );

      expect(find.text('Minha Seção'), findsOneWidget);
    });

    testWidgets('aplica estilo de fonte semibold (w600)', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionTitle('Título'),
          ),
        ),
      );

      final textWidget = tester.widget<Text>(find.text('Título'));
      expect(textWidget.style?.fontWeight, FontWeight.w600);
    });

    testWidgets('tem padding horizontal', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: SectionTitle('Test'),
          ),
        ),
      );

      final padding = tester.widget<Padding>(find.byType(Padding).first);
      expect(padding.padding, isA<EdgeInsets>());
    });
  });
}
