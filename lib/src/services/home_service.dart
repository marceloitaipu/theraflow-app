import '../models/home_summary.dart';
import '../models/session.dart';
import '../models/client.dart';
import '../models/payment.dart';
import '../models/package.dart';
import 'alert_service.dart';
import 'session_service.dart';
import 'client_service.dart';
import 'finance_service.dart';
import 'package_service.dart';

/// Serviço que agrega os dados necessários para a tela Home.
///
/// Centraliza as consultas para evitar múltiplos FutureBuilders na UI
/// e mantém a lógica de negócio fora dos widgets.
class HomeService {
  HomeService._();
  static final instance = HomeService._();

  /// Carrega o resumo completo do dia atual.
  Future<HomeSummary> getSummary() async {
    final now = DateTime.now();

    // Busca paralela para minimizar latência
    final results = await Future.wait([
      SessionService.instance.getTodaySessions(),           // 0
      FinanceService.instance.getPayments(),                // 1
      ClientService.instance.getClients(),                  // 2
      PackageService.instance.getPackages(),                // 3
      FinanceService.instance.getMonthlyReport(             // 4
        year: now.year,
        month: now.month,
      ),
      SessionService.instance.getSessions(),               // 5
    ]);

    final todaySessions = results[0] as List<Session>;
    final allPayments = results[1] as List<Payment>;
    final clients = results[2] as List<Client>;
    final allPackages = results[3] as List<Package>;
    final monthReport = results[4] as MonthlyReport;
    final allSessions = results[5] as List<Session>;

    // Próxima sessão ainda não realizada hoje
    final upcoming = todaySessions
        .where((s) => s.dateTime.isAfter(now) && s.status != 'faltou')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final nextSession = upcoming.isNotEmpty ? upcoming.first : null;

    // Resolução do cliente da próxima sessão
    Client? nextSessionClient;
    if (nextSession != null) {
      try {
        nextSessionClient = clients.firstWhere((c) => c.id == nextSession.clientId);
      } catch (_) {
        nextSessionClient = null;
      }
    }

    // Pagamentos pendentes (status 'pendente')
    final pendingPayments = allPayments.where((p) => p.status == 'pendente').toList();

    // Clientes ativos sem sessão há mais de 30 dias
    final activeClients = clients.where((c) => c.isActive).toList();
    final clientsAtRisk = <Client>[];
    for (final client in activeClients) {
      final clientSessions = allSessions
          .where((s) => s.clientId == client.id && s.deletedAt == null)
          .toList();
      if (clientSessions.isEmpty) continue;
      clientSessions.sort((a, b) => b.dateTime.compareTo(a.dateTime));
      final lastSession = clientSessions.first;
      if (now.difference(lastSession.dateTime).inDays > 30) {
        clientsAtRisk.add(client);
      }
    }

    // Pacotes ativos acabando (≤2 sessões restantes)
    final lowPackages = allPackages.where((p) => p.isActive && p.remainingSessions <= 2).toList();

    // Recebimentos do dia: sessões de hoje com paymentStatus == 'pago'
    final receivedToday = todaySessions
        .where((s) => s.paymentStatus == 'pago')
        .fold(0.0, (sum, s) => sum + s.value);

    // Mapa id → nome para lookup rápido nos tiles da home
    final clientNamesById = Map<String, String>.fromEntries(
      clients.map((c) => MapEntry(c.id, c.name)),
    );

    // Clientes ativos sem próxima sessão
    final futureSessions = allSessions
        .where((s) =>
            s.deletedAt == null &&
            s.dateTime.isAfter(now) &&
            s.status != 'cancelado' &&
            s.status != 'faltou')
        .toList();
    final clientsWithFuture = futureSessions.map((s) => s.clientId).toSet();
    final clientsWithoutNextSession = activeClients
        .where((c) =>
            !clientsWithFuture.contains(c.id) &&
            allSessions.any(
                (s) => s.clientId == c.id && s.dateTime.isBefore(now)))
        .toList();

    // Alertas acionáveis centralizados
    final alerts = AlertService.instance.computeAlerts(
      allSessions: allSessions,
      clients: activeClients,
      payments: allPayments,
      packages: allPackages,
    );

    return HomeSummary(
      todaySessions: todaySessions,
      nextSession: nextSession,
      nextSessionClient: nextSessionClient,
      pendingPayments: pendingPayments,
      clientsAtRisk: clientsAtRisk,
      lowPackages: lowPackages,
      receivedThisMonth: monthReport.totalReceived,
      pendingThisMonth: monthReport.totalPending,
      receivedToday: receivedToday,
      clientNamesById: clientNamesById,
      alerts: alerts,
      clientsWithoutNextSession: clientsWithoutNextSession,
    );
  }
}
