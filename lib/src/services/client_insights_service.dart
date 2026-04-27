import '../models/session.dart';
import '../models/package.dart';
import 'session_service.dart';
import 'package_service.dart';

/// Métricas calculadas de um cliente.
class ClientInsight {
  final String clientId;
  final int totalSessions;
  final int missedSessions;
  final int rescheduledSessions;
  final double totalPaid;
  final double totalPending;
  final Session? lastSession;
  final Session? nextSession;
  final Package? activePackage;

  const ClientInsight({
    required this.clientId,
    required this.totalSessions,
    required this.missedSessions,
    required this.rescheduledSessions,
    required this.totalPaid,
    required this.totalPending,
    this.lastSession,
    this.nextSession,
    this.activePackage,
  });

  /// Dias desde a última sessão realizada. Null se nunca atendeu.
  int? get daysSinceLastSession {
    if (lastSession == null) return null;
    return DateTime.now().difference(lastSession!.dateTime).inDays;
  }

  /// Status inferido com base nas métricas.
  String get inferredStatus {
    if (totalSessions == 0) return 'novo';
    final days = daysSinceLastSession;
    if (days == null) return 'novo';
    if (days > 60) return 'inativo';
    if (days > 30) return 'em risco';
    return 'ativo';
  }

}

/// Serviço que calcula métricas agregadas por cliente.
class ClientInsightsService {
  ClientInsightsService._();
  static final instance = ClientInsightsService._();

  Future<ClientInsight> getInsight(String clientId) async {
    final now = DateTime.now();

    final results = await Future.wait([
      SessionService.instance.getClientSessions(clientId),
      PackageService.instance.getActivePackage(clientId),
    ]);

    final sessions = results[0] as List<Session>;
    final activePackage = results[1] as Package?;

    // Filtra apenas sessões não deletadas
    final liveSessions = sessions.where((s) => s.deletedAt == null).toList();

    final missed = liveSessions.where((s) => s.status == 'faltou').length;
    final rescheduled = liveSessions.where((s) => s.status == 'remarcado').length;

    // Receita: considera apenas sessões realizadas ou confirmadas
    final paid = liveSessions
        .where((s) => s.paymentStatus == 'pago')
        .fold(0.0, (sum, s) => sum + s.value);
    final pending = liveSessions
        .where((s) => s.paymentStatus == 'pendente')
        .fold(0.0, (sum, s) => sum + s.value);

    // Última sessão (passada, não deletada, não faltou)
    final pastSessions = liveSessions
        .where((s) => s.dateTime.isBefore(now) && s.status != 'faltou')
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final lastSession = pastSessions.isNotEmpty ? pastSessions.first : null;

    // Próxima sessão (futura)
    final futureSessions = liveSessions
        .where((s) => s.dateTime.isAfter(now))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final nextSession = futureSessions.isNotEmpty ? futureSessions.first : null;

    return ClientInsight(
      clientId: clientId,
      totalSessions: liveSessions.length,
      missedSessions: missed,
      rescheduledSessions: rescheduled,
      totalPaid: paid,
      totalPending: pending,
      lastSession: lastSession,
      nextSession: nextSession,
      activePackage: activePackage,
    );
  }
}
