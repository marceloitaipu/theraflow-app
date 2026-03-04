import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/screens/billing/paywall_screen.dart';

void main() {
  group('PaywallScreen Widget', () {
    testWidgets('renderiza título corretamente', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Escolha seu Plano'), findsOneWidget);
    });

    testWidgets('exibe o plano Starter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Starter'), findsOneWidget);
    });

    testWidgets('exibe o plano Pro', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Pro'), findsOneWidget);
    });

    testWidgets('exibe o plano Clinic', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Clinic'), findsOneWidget);
    });

    testWidgets('exibe preço Grátis do plano Starter', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Grátis'), findsOneWidget);
    });

    testWidgets('exibe preço R\$ 49,90 do plano Pro', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('R\$ 49,90'), findsOneWidget);
    });

    testWidgets('exibe preço R\$ 99,90 do plano Clinic', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('R\$ 99,90'), findsOneWidget);
    });

    testWidgets('plano starter mostra Plano Atual por padrão', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Plano Atual'), findsOneWidget);
    });

    testWidgets('exibe seção de módulos disponíveis', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      await tester.scrollUntilVisible(
        find.text('Módulos disponíveis'),
        200,
        scrollable: find.byType(Scrollable).first,
      );

      expect(find.text('Módulos disponíveis'), findsOneWidget);
    });

    testWidgets('tem AppBar com botão de voltar', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.byType(AppBar), findsOneWidget);
    });
  });
}
