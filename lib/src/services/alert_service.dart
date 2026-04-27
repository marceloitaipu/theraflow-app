import '../models/alert_item.dart';
import '../models/client.dart';
import '../models/package.dart';
import '../models/payment.dart';
import '../models/session.dart';

/// Serviço centralizado de alertas acionáveis.
///
/// Recebe os dados já carregados pelo HomeService e computa uma lista
/// priorizada de alertas sem fazer chamadas extras ao banco.
class AlertService {
  AlertService._();
  static final instance = AlertService._();

  /// Limiar em dias para considerar cliente "sem retorno".
  static const int noReturnDays = 30;

  /// Limiar de sessões restantes para alertar pacote acabando.
  static const int packageLowThreshold = 2;

  /// Dias de antecedência para alerta de sessão amanhã.
  static const int sessionTomorrowDays = 1;

  /// Calcula e retorna alertas ordenados por prioridade (high → low).
  List<AlertItem> computeAlerts({
    required List<Session> allSessions,
    required List<Client> clients,
    required List<Payment> payments,
    required List<Package> packages,
  }) {
    final alerts = <AlertItem>[];
    final now = DateTime.now();
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    // ── Pagamentos pendentes (alta prioridade) ────────────────────────────
    final overduePayments = payments.where((p) => p.status == 'pendente').toList();
    if (overduePayments.isNotEmpty) {
      final total = overduePayments.fold(0.0, (s, p) => s + p.value);
      final fmt = _formatCurrency(total);
      alerts.add(AlertItem(
        type: AlertType.paymentOverdue,
        priority: AlertPriority.high,
        message:
            '${overduePayments.length} pagamento(s) pendente(s) — $fmt',
        route: '/finance',
      ));
    }

    // ── Pacotes acabando (alta prioridade) ───────────────────────────────
    final lowPackages = packages
        .where((p) => p.isActive && p.remainingSessions <= packageLowThreshold)
        .toList();
    for (final pkg in lowPackages) {
      final clientName = clients
          .where((c) => c.id == pkg.clientId)
          .map((c) => c.name)
          .firstOrNull;
      final sessions = pkg.remainingSessions;
      alerts.add(AlertItem(
        type: AlertType.packageEnding,
        priority: AlertPriority.high,
        message: clientName != null
            ? '$clientName — pacote com $sessions sessão(ões) restante(s)'
            : 'Pacote com $sessions sessão(ões) restante(s)',
        clientId: pkg.clientId,
        clientName: clientName,
        route: '/clients/${pkg.clientId}',
      ));
    }

    // ── Clientes sem retorno há mais de X dias (média prioridade) ─────────
    final activeSessions = allSessions.where((s) => s.deletedAt == null).toList();
    for (final client in clients.where((c) => c.isActive)) {
      final cs = activeSessions.where((s) => s.clientId == client.id).toList();
      if (cs.isEmpty) continue;
      cs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      final days = now.difference(cs.first.dateTime).inDays;
      if (days > noReturnDays) {
        alerts.add(AlertItem(
          type: AlertType.clientAtRisk,
          priority: AlertPriority.medium,
          message: '${client.name} — sem retorno há $days dias',
          clientId: client.id,
          clientName: client.name,
          route: '/clients/${client.id}',
        ));
      }
    }

    // ── Clientes ativos sem próxima sessão (média prioridade) ─────────────
    final futureSessions = activeSessions
        .where((s) =>
            s.dateTime.isAfter(now) &&
            s.status != 'cancelado' &&
            s.status != 'faltou')
        .toList();
    final clientsWithFuture = futureSessions.map((s) => s.clientId).toSet();
    for (final client in clients.where((c) => c.isActive)) {
      if (!clientsWithFuture.contains(client.id)) {
        // Só alerta se já tiver alguma sessão anterior (não é cliente novo sem histórico)
        final hasPast = activeSessions.any((s) =>
            s.clientId == client.id && s.dateTime.isBefore(now));
        if (hasPast) {
          alerts.add(AlertItem(
            type: AlertType.clientNoNextSession,
            priority: AlertPriority.medium,
            message: '${client.name} — sem próxima sessão agendada',
            clientId: client.id,
            clientName: client.name,
            route: '/clients/${client.id}',
          ));
        }
      }
    }

    // ── Sessões de amanhã (baixa prioridade) ─────────────────────────────
    final tomorrowSessions = activeSessions
        .where((s) =>
            s.dateTime.year == tomorrow.year &&
            s.dateTime.month == tomorrow.month &&
            s.dateTime.day == tomorrow.day &&
            s.status != 'cancelado' &&
            s.status != 'faltou')
        .toList();
    if (tomorrowSessions.isNotEmpty) {
      alerts.add(AlertItem(
        type: AlertType.sessionTomorrow,
        priority: AlertPriority.low,
        message: '${tomorrowSessions.length} sessão(ões) agendada(s) para amanhã',
        route: '/agenda',
      ));
    }

    // ── Ordenar: high → medium → low ─────────────────────────────────────
    alerts.sort((a, b) => a.priority.index.compareTo(b.priority.index));
    return alerts;
  }

  String _formatCurrency(double value) {
    final int cents = (value * 100).round();
    final int reais = cents ~/ 100;
    final int centavos = cents % 100;
    return 'R\$ $reais,${centavos.toString().padLeft(2, '0')}';
  }
}
