import 'alert_item.dart';
import 'client.dart';
import 'session.dart';
import 'payment.dart';
import 'package.dart';

/// DTO com todos os dados agregados para a Home.
class HomeSummary {
  final List<Session> todaySessions;
  final Session? nextSession;
  final Client? nextSessionClient;
  final List<Payment> pendingPayments;
  final List<Client> clientsAtRisk; // sem retorno há mais de 30 dias
  final List<Package> lowPackages; // ativos com ≤2 sessões restantes
  final double receivedThisMonth;
  final double pendingThisMonth;

  /// Valor total recebido hoje (sessões de hoje com paymentStatus == 'pago').
  final double receivedToday;

  /// Mapa id → nome de cliente para lookup rápido sem chamadas extras.
  final Map<String, String> clientNamesById;

  /// Alertas acionáveis calculados pelo AlertService.
  final List<AlertItem> alerts;

  /// Clientes ativos sem próxima sessão agendada.
  final List<Client> clientsWithoutNextSession;

  /// Sessões agendadas para amanhã (para envio de lembretes WhatsApp).
  final List<Session> tomorrowSessions;

  const HomeSummary({
    required this.todaySessions,
    this.nextSession,
    this.nextSessionClient,
    required this.pendingPayments,
    required this.clientsAtRisk,
    required this.lowPackages,
    required this.receivedThisMonth,
    required this.pendingThisMonth,
    this.receivedToday = 0.0,
    this.clientNamesById = const {},
    this.alerts = const [],
    this.clientsWithoutNextSession = const [],
    this.tomorrowSessions = const [],
  });

  int get todayCount => todaySessions.length;
  int get pendingCount => pendingPayments.length;
  double get pendingTotal => pendingPayments.fold(0.0, (sum, p) => sum + p.value);
  bool get hasAlerts => alerts.isNotEmpty;
}
