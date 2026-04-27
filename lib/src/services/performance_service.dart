import 'package:shared_preferences/shared_preferences.dart';

import '../models/session.dart';
import 'session_service.dart';

/// Métricas de desempenho mensal.
class PerformanceMetrics {
  final int year;
  final int month;

  /// Total de sessões realizadas no mês (status != cancelado/faltou).
  final int completedSessions;

  /// Meta mensal de sessões (configurada pelo usuário).
  final int goalSessions;

  /// Receita recebida no mês.
  final double receivedRevenue;

  /// Média de sessões por semana no mês.
  final double weeklyAverage;

  /// Dia da semana com mais sessões (0 = domingo, 1 = segunda …).
  final int? bestDayOfWeek;

  /// Mapa: dia da semana → contagem de sessões.
  final Map<int, int> sessionsByWeekday;

  /// Percentual de progresso em relação à meta (0.0 – 1.0).
  double get goalProgress =>
      goalSessions > 0 ? (completedSessions / goalSessions).clamp(0.0, 1.0) : 0.0;

  bool get goalReached => goalSessions > 0 && completedSessions >= goalSessions;

  const PerformanceMetrics({
    required this.year,
    required this.month,
    required this.completedSessions,
    required this.goalSessions,
    required this.receivedRevenue,
    required this.weeklyAverage,
    required this.sessionsByWeekday,
    this.bestDayOfWeek,
  });
}

/// Serviço de métricas de desempenho do negócio.
class PerformanceService {
  PerformanceService._();
  static final instance = PerformanceService._();

  static const _prefKeyGoal = 'monthly_goal_sessions';

  // ─── Meta mensal ─────────────────────────────────────────────────────────

  /// Carrega a meta mensal de sessões gravada nas preferências.
  Future<int> getMonthlyGoal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_prefKeyGoal) ?? 20;
  }

  /// Salva a meta mensal de sessões nas preferências.
  Future<void> setMonthlyGoal(int goal) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_prefKeyGoal, goal);
  }

  // ─── Métricas mensais ────────────────────────────────────────────────────

  /// Calcula métricas de desempenho para o mês/ano fornecidos.
  Future<PerformanceMetrics> getMonthlyMetrics({
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final results = await Future.wait([
      SessionService.instance.getSessionsByPeriod(start: start, end: end),
      getMonthlyGoal(),
    ]);

    final sessions = results[0] as List<Session>;
    final goal = results[1] as int;

    // Sessões válidas (excluir canceladas, faltou, deletadas)
    final completed = sessions
        .where((s) =>
            s.deletedAt == null &&
            s.status != 'cancelado' &&
            s.status != 'faltou')
        .toList();

    // Receita recebida
    final received = completed
        .where((s) => s.paymentStatus == 'pago')
        .fold(0.0, (sum, s) => sum + s.value);

    // Sessões por dia da semana
    final byWeekday = <int, int>{};
    for (final s in completed) {
      final wd = s.dateTime.weekday % 7; // 0 = domingo
      byWeekday[wd] = (byWeekday[wd] ?? 0) + 1;
    }

    // Melhor dia da semana
    int? bestDay;
    if (byWeekday.isNotEmpty) {
      bestDay = byWeekday.entries
          .reduce((a, b) => a.value >= b.value ? a : b)
          .key;
    }

    // Média semanal — número de semanas no mês ≈ dias/7
    final daysInMonth = end.day;
    final weeklyAvg = daysInMonth > 0
        ? completed.length / (daysInMonth / 7.0)
        : 0.0;

    return PerformanceMetrics(
      year: year,
      month: month,
      completedSessions: completed.length,
      goalSessions: goal,
      receivedRevenue: received,
      weeklyAverage: double.parse(weeklyAvg.toStringAsFixed(1)),
      sessionsByWeekday: byWeekday,
      bestDayOfWeek: bestDay,
    );
  }
}
