import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/services/performance_service.dart';

// ─── helpers ─────────────────────────────────────────────────────────────────

PerformanceMetrics _metrics({
  int year = 2026,
  int month = 4,
  int completedSessions = 10,
  int goalSessions = 20,
  double receivedRevenue = 1000.0,
  double weeklyAverage = 2.5,
  Map<int, int>? sessionsByWeekday,
  int? bestDayOfWeek,
}) {
  return PerformanceMetrics(
    year: year,
    month: month,
    completedSessions: completedSessions,
    goalSessions: goalSessions,
    receivedRevenue: receivedRevenue,
    weeklyAverage: weeklyAverage,
    sessionsByWeekday: sessionsByWeekday ?? {1: 3, 3: 4, 5: 3},
    bestDayOfWeek: bestDayOfWeek,
  );
}

void main() {
  group('PerformanceMetrics', () {
    // ── goalProgress ───────────────────────────────────────────────────────
    group('goalProgress', () {
      test('retorna 0.0 quando goalSessions é 0', () {
        final m = _metrics(goalSessions: 0, completedSessions: 5);
        expect(m.goalProgress, 0.0);
      });

      test('retorna razão correta (parcial)', () {
        final m = _metrics(completedSessions: 10, goalSessions: 20);
        expect(m.goalProgress, 0.5);
      });

      test('retorna 1.0 quando completedSessions == goalSessions', () {
        final m = _metrics(completedSessions: 20, goalSessions: 20);
        expect(m.goalProgress, 1.0);
      });

      test('clamp: não ultrapassa 1.0 quando completedSessions > goalSessions',
          () {
        final m = _metrics(completedSessions: 30, goalSessions: 20);
        expect(m.goalProgress, 1.0);
      });

      test('retorna 0.0 quando completedSessions é 0', () {
        final m = _metrics(completedSessions: 0, goalSessions: 20);
        expect(m.goalProgress, 0.0);
      });

      test('progresso com frações', () {
        final m = _metrics(completedSessions: 1, goalSessions: 4);
        expect(m.goalProgress, 0.25);
      });
    });

    // ── goalReached ────────────────────────────────────────────────────────
    group('goalReached', () {
      test('false quando goalSessions é 0', () {
        final m = _metrics(goalSessions: 0, completedSessions: 100);
        expect(m.goalReached, false);
      });

      test('false quando completedSessions < goalSessions', () {
        final m = _metrics(completedSessions: 15, goalSessions: 20);
        expect(m.goalReached, false);
      });

      test('true quando completedSessions == goalSessions', () {
        final m = _metrics(completedSessions: 20, goalSessions: 20);
        expect(m.goalReached, true);
      });

      test('true quando completedSessions > goalSessions', () {
        final m = _metrics(completedSessions: 25, goalSessions: 20);
        expect(m.goalReached, true);
      });

      test('false quando completedSessions é 0', () {
        final m = _metrics(completedSessions: 0, goalSessions: 20);
        expect(m.goalReached, false);
      });
    });

    // ── campos básicos ─────────────────────────────────────────────────────
    group('campos', () {
      test('armazena year e month corretamente', () {
        final m = _metrics(year: 2025, month: 12);
        expect(m.year, 2025);
        expect(m.month, 12);
      });

      test('armazena receivedRevenue corretamente', () {
        final m = _metrics(receivedRevenue: 3500.50);
        expect(m.receivedRevenue, 3500.50);
      });

      test('armazena weeklyAverage corretamente', () {
        final m = _metrics(weeklyAverage: 4.2);
        expect(m.weeklyAverage, 4.2);
      });

      test('bestDayOfWeek pode ser null', () {
        final m = _metrics(bestDayOfWeek: null);
        expect(m.bestDayOfWeek, isNull);
      });

      test('bestDayOfWeek armazena valor quando fornecido', () {
        final m = _metrics(bestDayOfWeek: 3); // quarta-feira
        expect(m.bestDayOfWeek, 3);
      });

      test('sessionsByWeekday armazena mapa completo', () {
        const map = {1: 4, 2: 2, 3: 6};
        final m = _metrics(sessionsByWeekday: map);
        expect(m.sessionsByWeekday, map);
      });
    });

    // ── cenários de negócio ────────────────────────────────────────────────
    group('cenários reais', () {
      test('mês zerado — nenhuma sessão realizada', () {
        final m = _metrics(
          completedSessions: 0,
          goalSessions: 20,
          receivedRevenue: 0,
          weeklyAverage: 0,
          sessionsByWeekday: {},
          bestDayOfWeek: null,
        );

        expect(m.goalProgress, 0.0);
        expect(m.goalReached, false);
        expect(m.sessionsByWeekday, isEmpty);
        expect(m.bestDayOfWeek, isNull);
      });

      test('meta superada em 150%', () {
        final m = _metrics(completedSessions: 30, goalSessions: 20);
        expect(m.goalProgress, 1.0); // clampado
        expect(m.goalReached, true);
      });

      test('meta exatamente alcançada', () {
        final m = _metrics(completedSessions: 20, goalSessions: 20);
        expect(m.goalProgress, 1.0);
        expect(m.goalReached, true);
      });

      test('meta configurada para 1 sessão', () {
        final m = _metrics(completedSessions: 1, goalSessions: 1);
        expect(m.goalProgress, 1.0);
        expect(m.goalReached, true);
      });

      test('alta meta (100) com poucas sessões (5)', () {
        final m = _metrics(completedSessions: 5, goalSessions: 100);
        expect(m.goalProgress, 0.05);
        expect(m.goalReached, false);
      });
    });
  });
}
