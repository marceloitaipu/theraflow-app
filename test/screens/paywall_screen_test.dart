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

    testWidgets('exibe o plano Gratuito', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Gratuito'), findsOneWidget);
    });

    testWidgets('exibe o plano Profissional', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Profissional'), findsOneWidget);
    });

    testWidgets('exibe o plano Premium', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('Premium'), findsOneWidget);
    });

    testWidgets('exibe preço R\$ 0 do plano gratuito', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('R\$ 0'), findsOneWidget);
    });

    testWidgets('exibe preço R\$ 49,90 do plano profissional', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('R\$ 49,90'), findsOneWidget);
    });

    testWidgets('exibe preço R\$ 99,90 do plano premium', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      expect(find.text('R\$ 99,90'), findsOneWidget);
    });

    testWidgets('plano atual mostra botão diferenciado', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: PaywallScreen(),
        ),
      );

      // O plano free deve mostrar "Plano Atual"
      expect(find.text('Plano Atual'), findsOneWidget);
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
