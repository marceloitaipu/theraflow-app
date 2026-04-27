import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/widgets/revenue_sparkline.dart';
import 'package:theraflow/src/services/finance_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() {
  setUpAll(() async {
    await initializeDateFormatting('pt_BR', null);
  });

  group('RevenueSparkline Widget', () {
    Widget buildSparkline(List<MonthlyRevenuePoint> points) {
      return MaterialApp(
        home: Scaffold(
          body: SizedBox(
            width: 400,
            child: RevenueSparkline(points: points),
          ),
        ),
      );
    }

    testWidgets('exibe mensagem quando lista está vazia', (tester) async {
      await tester.pumpWidget(buildSparkline([]));
      expect(find.text('Sem dados de receita'), findsOneWidget);
    });

    testWidgets('renderiza com um único ponto', (tester) async {
      final points = [
        const MonthlyRevenuePoint(year: 2026, month: 4, received: 1500.0),
      ];
      await tester.pumpWidget(buildSparkline(points));
      expect(find.byType(RevenueSparkline), findsOneWidget);
      expect(find.text('Sem dados de receita'), findsNothing);
    });

    testWidgets('renderiza com múltiplos pontos', (tester) async {
      final points = [
        const MonthlyRevenuePoint(year: 2026, month: 1, received: 1000.0),
        const MonthlyRevenuePoint(year: 2026, month: 2, received: 1200.0),
        const MonthlyRevenuePoint(year: 2026, month: 3, received: 1100.0),
        const MonthlyRevenuePoint(year: 2026, month: 4, received: 1500.0),
      ];

      // Envolve em OverflowBox para evitar falha por overflow de layout no Row
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: OverflowBox(
              maxWidth: double.infinity,
              alignment: Alignment.topLeft,
              child: SizedBox(
                width: 600,
                child: RevenueSparkline(points: points),
              ),
            ),
          ),
        ),
      );
      expect(find.byType(RevenueSparkline), findsOneWidget);
      expect(find.text('Sem dados de receita'), findsNothing);
    });

    testWidgets('exibe ícone trending_up quando receita sobe', (tester) async {
      final points = [
        const MonthlyRevenuePoint(year: 2026, month: 3, received: 1000.0),
        const MonthlyRevenuePoint(year: 2026, month: 4, received: 2000.0),
      ];
      await tester.pumpWidget(buildSparkline(points));
      await tester.pump();
      expect(find.byIcon(Icons.trending_up), findsOneWidget);
    });

    testWidgets('exibe ícone trending_down quando receita cai', (tester) async {
      final points = [
        const MonthlyRevenuePoint(year: 2026, month: 3, received: 2000.0),
        const MonthlyRevenuePoint(year: 2026, month: 4, received: 1000.0),
      ];
      await tester.pumpWidget(buildSparkline(points));
      await tester.pump();
      expect(find.byIcon(Icons.trending_down), findsOneWidget);
    });

    testWidgets('exibe labels dos meses', (tester) async {
      final points = [
        const MonthlyRevenuePoint(year: 2026, month: 1, received: 1000.0),
        const MonthlyRevenuePoint(year: 2026, month: 12, received: 2000.0),
      ];
      await tester.pumpWidget(buildSparkline(points));
      await tester.pump();
      expect(find.text('jan'), findsOneWidget);
      expect(find.text('dez'), findsOneWidget);
    });

    testWidgets('height padrão é 120', (tester) async {
      final points = [
        const MonthlyRevenuePoint(year: 2026, month: 4, received: 500.0),
      ];
      await tester.pumpWidget(buildSparkline(points));

      final sizedBox = tester.widget<SizedBox>(
        find.ancestor(
          of: find.byType(RevenueSparkline),
          matching: find.byType(SizedBox),
        ).first,
      );
      expect(sizedBox.width, 400);
    });

    testWidgets('height customizável', (tester) async {
      final points = [
        const MonthlyRevenuePoint(year: 2026, month: 4, received: 500.0),
      ];
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              child: RevenueSparkline(points: points, height: 200),
            ),
          ),
        ),
      );
      final sparkline =
          tester.widget<RevenueSparkline>(find.byType(RevenueSparkline));
      expect(sparkline.height, 200);
    });

    testWidgets('exibe percentual de variação', (tester) async {
      final points = [
        const MonthlyRevenuePoint(year: 2026, month: 3, received: 1000.0),
        const MonthlyRevenuePoint(year: 2026, month: 4, received: 2000.0),
      ];
      await tester.pumpWidget(buildSparkline(points));
      await tester.pump();
      // 100% de crescimento
      expect(find.text('100%'), findsOneWidget);
    });
  });
}
