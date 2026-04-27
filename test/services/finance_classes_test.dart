import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/services/finance_service.dart';

void main() {
  group('MonthlyReport extended', () {
    MonthlyReport makeReport({
      int year = 2026,
      int month = 1,
      int totalSessions = 10,
      int sessionsConfirmed = 8,
      int sessionsMissed = 1,
      int sessionsRescheduled = 1,
      double totalReceived = 1000.0,
      double totalPending = 200.0,
    }) {
      return MonthlyReport(
        year: year,
        month: month,
        totalSessions: totalSessions,
        sessionsConfirmed: sessionsConfirmed,
        sessionsMissed: sessionsMissed,
        sessionsRescheduled: sessionsRescheduled,
        totalReceived: totalReceived,
        totalPending: totalPending,
        total: totalReceived + totalPending,
      );
    }

    group('monthName todos os meses', () {
      const expected = {
        1: 'Janeiro',
        2: 'Fevereiro',
        3: 'Março',
        4: 'Abril',
        5: 'Maio',
        6: 'Junho',
        7: 'Julho',
        8: 'Agosto',
        9: 'Setembro',
        10: 'Outubro',
        11: 'Novembro',
        12: 'Dezembro',
      };

      expected.forEach((month, name) {
        test('mês $month → $name', () {
          final report = makeReport(month: month);
          expect(report.monthName, name);
        });
      });
    });

    test('total é a soma de received + pending', () {
      final report = makeReport(totalReceived: 850.0, totalPending: 150.0);
      expect(report.total, 1000.0);
    });

    test('totalSessions é fornecido corretamente', () {
      final report = makeReport(totalSessions: 20);
      expect(report.totalSessions, 20);
    });
  });

  group('MonthComparison extended', () {
    MonthlyReport makeReport(double received, int sessions) {
      return MonthlyReport(
        year: 2026,
        month: 1,
        totalSessions: sessions,
        sessionsConfirmed: sessions,
        sessionsMissed: 0,
        sessionsRescheduled: 0,
        totalReceived: received,
        totalPending: 0,
        total: received,
      );
    }

    test('isReceivedUp true quando percentChange > 0', () {
      final comp = MonthComparison(
        currentMonth: makeReport(1200, 12),
        previousMonth: makeReport(1000, 10),
        receivedPercentChange: 20.0,
        sessionsPercentChange: 20.0,
      );
      expect(comp.isReceivedUp, true);
      expect(comp.isSessionsUp, true);
    });

    test('isReceivedUp false quando percentChange < 0', () {
      final comp = MonthComparison(
        currentMonth: makeReport(800, 8),
        previousMonth: makeReport(1000, 10),
        receivedPercentChange: -20.0,
        sessionsPercentChange: -20.0,
      );
      expect(comp.isReceivedUp, false);
      expect(comp.isSessionsUp, false);
    });

    test('isReceivedUp false quando percentChange == 0', () {
      final comp = MonthComparison(
        currentMonth: makeReport(1000, 10),
        previousMonth: makeReport(1000, 10),
        receivedPercentChange: 0.0,
        sessionsPercentChange: 0.0,
      );
      expect(comp.isReceivedUp, false);
    });
  });

  group('InsightMessage', () {
    test('tipo success', () {
      final msg = InsightMessage(
        icon: '✨',
        type: InsightType.success,
        message: 'Tudo certo!',
      );
      expect(msg.type, InsightType.success);
      expect(msg.icon, '✨');
      expect(msg.message, 'Tudo certo!');
    });

    test('tipo warning', () {
      final msg = InsightMessage(
        icon: '⚠️',
        type: InsightType.warning,
        message: 'Atenção!',
      );
      expect(msg.type, InsightType.warning);
    });

    test('tipo alert', () {
      final msg = InsightMessage(
        icon: '🔔',
        type: InsightType.alert,
        message: 'Alerta!',
      );
      expect(msg.type, InsightType.alert);
    });

    test('tipo info', () {
      final msg = InsightMessage(
        icon: '📅',
        type: InsightType.info,
        message: 'Informação',
      );
      expect(msg.type, InsightType.info);
    });

    test('todos os tipos InsightType existem', () {
      expect(InsightType.values.length, 4);
      expect(InsightType.values, containsAll([
        InsightType.success,
        InsightType.warning,
        InsightType.alert,
        InsightType.info,
      ]));
    });
  });

  group('FinanceInsights', () {
    MonthlyReport makeReport(double received, double pending, int sessions) {
      return MonthlyReport(
        year: 2026,
        month: 4,
        totalSessions: sessions,
        sessionsConfirmed: sessions,
        sessionsMissed: 0,
        sessionsRescheduled: 0,
        totalReceived: received,
        totalPending: pending,
        total: received + pending,
      );
    }

    test('cria FinanceInsights com todas as propriedades', () {
      final current = makeReport(1200.0, 300.0, 15);
      final previous = makeReport(1000.0, 200.0, 12);

      final comparison = MonthComparison(
        currentMonth: current,
        previousMonth: previous,
        receivedPercentChange: 20.0,
        sessionsPercentChange: 25.0,
      );

      final insights = FinanceInsights(
        comparison: comparison,
        expectedNext7Days: 600.0,
        pendingCount: 3,
        pendingTotal: 300.0,
        messages: [
          InsightMessage(
            icon: '📈',
            type: InsightType.success,
            message: 'Receita 20% maior!',
          ),
        ],
      );

      expect(insights.comparison, comparison);
      expect(insights.expectedNext7Days, 600.0);
      expect(insights.pendingCount, 3);
      expect(insights.pendingTotal, 300.0);
      expect(insights.messages.length, 1);
    });

    test('messages pode estar vazio', () {
      final report = makeReport(0, 0, 0);
      final comp = MonthComparison(
        currentMonth: report,
        previousMonth: report,
        receivedPercentChange: 0,
        sessionsPercentChange: 0,
      );

      final insights = FinanceInsights(
        comparison: comp,
        expectedNext7Days: 0,
        pendingCount: 0,
        pendingTotal: 0,
        messages: [],
      );

      expect(insights.messages, isEmpty);
    });
  });

  group('MonthlyRevenuePoint', () {
    test('cria com year, month e received', () {
      const point = MonthlyRevenuePoint(year: 2026, month: 4, received: 1500.0);
      expect(point.year, 2026);
      expect(point.month, 4);
      expect(point.received, 1500.0);
    });

    test('aceita received zero', () {
      const point = MonthlyRevenuePoint(year: 2026, month: 1, received: 0.0);
      expect(point.received, 0.0);
    });
  });
}
