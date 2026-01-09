import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/services/finance_service.dart';

void main() {
  group('FinanceService Classes', () {
    group('MonthlyReport', () {
      test('monthName retorna nome correto do mês em português', () {
        final janReport = MonthlyReport(
          year: 2026,
          month: 1,
          totalSessions: 10,
          sessionsConfirmed: 8,
          sessionsMissed: 1,
          sessionsRescheduled: 1,
          totalReceived: 1000.0,
          totalPending: 200.0,
          total: 1200.0,
        );

        final decReport = MonthlyReport(
          year: 2026,
          month: 12,
          totalSessions: 10,
          sessionsConfirmed: 8,
          sessionsMissed: 1,
          sessionsRescheduled: 1,
          totalReceived: 1000.0,
          totalPending: 200.0,
          total: 1200.0,
        );

        expect(janReport.monthName, 'Janeiro');
        expect(decReport.monthName, 'Dezembro');
      });

      test('total é soma de received e pending', () {
        final report = MonthlyReport(
          year: 2026,
          month: 1,
          totalSessions: 10,
          sessionsConfirmed: 8,
          sessionsMissed: 1,
          sessionsRescheduled: 1,
          totalReceived: 800.0,
          totalPending: 400.0,
          total: 1200.0,
        );

        expect(report.total, report.totalReceived + report.totalPending);
      });
    });

    group('MonthComparison', () {
      test('isReceivedUp retorna true quando percentual é positivo', () {
        final current = MonthlyReport(
          year: 2026,
          month: 2,
          totalSessions: 15,
          sessionsConfirmed: 12,
          sessionsMissed: 2,
          sessionsRescheduled: 1,
          totalReceived: 1500.0,
          totalPending: 300.0,
          total: 1800.0,
        );

        final previous = MonthlyReport(
          year: 2026,
          month: 1,
          totalSessions: 10,
          sessionsConfirmed: 8,
          sessionsMissed: 1,
          sessionsRescheduled: 1,
          totalReceived: 1000.0,
          totalPending: 200.0,
          total: 1200.0,
        );

        final comparison = MonthComparison(
          currentMonth: current,
          previousMonth: previous,
          receivedPercentChange: 50.0,
          sessionsPercentChange: 50.0,
        );

        expect(comparison.isReceivedUp, true);
        expect(comparison.isSessionsUp, true);
      });

      test('isReceivedUp retorna false quando percentual é negativo', () {
        final current = MonthlyReport(
          year: 2026,
          month: 2,
          totalSessions: 8,
          sessionsConfirmed: 6,
          sessionsMissed: 1,
          sessionsRescheduled: 1,
          totalReceived: 800.0,
          totalPending: 100.0,
          total: 900.0,
        );

        final previous = MonthlyReport(
          year: 2026,
          month: 1,
          totalSessions: 10,
          sessionsConfirmed: 8,
          sessionsMissed: 1,
          sessionsRescheduled: 1,
          totalReceived: 1000.0,
          totalPending: 200.0,
          total: 1200.0,
        );

        final comparison = MonthComparison(
          currentMonth: current,
          previousMonth: previous,
          receivedPercentChange: -20.0,
          sessionsPercentChange: -20.0,
        );

        expect(comparison.isReceivedUp, false);
        expect(comparison.isSessionsUp, false);
      });
    });

    group('InsightMessage', () {
      test('cria mensagem com tipo success', () {
        final message = InsightMessage(
          icon: '✨',
          type: InsightType.success,
          message: 'Suas finanças estão em dia!',
        );

        expect(message.type, InsightType.success);
        expect(message.icon, '✨');
        expect(message.message, isNotEmpty);
      });

      test('cria mensagem com tipo warning', () {
        final message = InsightMessage(
          icon: '⚠️',
          type: InsightType.warning,
          message: 'Você tem R\$ 500 pendentes.',
        );

        expect(message.type, InsightType.warning);
      });

      test('cria mensagem com tipo alert', () {
        final message = InsightMessage(
          icon: '🔔',
          type: InsightType.alert,
          message: 'Taxa de faltas alta!',
        );

        expect(message.type, InsightType.alert);
      });

      test('cria mensagem com tipo info', () {
        final message = InsightMessage(
          icon: '📅',
          type: InsightType.info,
          message: 'Receita esperada: R\$ 1000',
        );

        expect(message.type, InsightType.info);
      });
    });

    group('FinanceInsights', () {
      test('cria insights com todas as propriedades', () {
        final current = MonthlyReport(
          year: 2026,
          month: 1,
          totalSessions: 10,
          sessionsConfirmed: 8,
          sessionsMissed: 1,
          sessionsRescheduled: 1,
          totalReceived: 1000.0,
          totalPending: 200.0,
          total: 1200.0,
        );

        final previous = MonthlyReport(
          year: 2025,
          month: 12,
          totalSessions: 8,
          sessionsConfirmed: 6,
          sessionsMissed: 1,
          sessionsRescheduled: 1,
          totalReceived: 800.0,
          totalPending: 100.0,
          total: 900.0,
        );

        final comparison = MonthComparison(
          currentMonth: current,
          previousMonth: previous,
          receivedPercentChange: 25.0,
          sessionsPercentChange: 25.0,
        );

        final insights = FinanceInsights(
          comparison: comparison,
          expectedNext7Days: 500.0,
          pendingCount: 2,
          pendingTotal: 200.0,
          messages: [
            InsightMessage(
              icon: '📈',
              type: InsightType.success,
              message: 'Receita 25% maior!',
            ),
          ],
        );

        expect(insights.expectedNext7Days, 500.0);
        expect(insights.pendingCount, 2);
        expect(insights.pendingTotal, 200.0);
        expect(insights.messages.length, 1);
        expect(insights.comparison.isReceivedUp, true);
      });
    });

    group('InsightType enum', () {
      test('contém todos os tipos esperados', () {
        expect(InsightType.values, contains(InsightType.success));
        expect(InsightType.values, contains(InsightType.warning));
        expect(InsightType.values, contains(InsightType.info));
        expect(InsightType.values, contains(InsightType.alert));
        expect(InsightType.values.length, 4);
      });
    });
  });
}
