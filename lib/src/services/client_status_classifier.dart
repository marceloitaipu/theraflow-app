import '../models/client.dart';
import '../models/package.dart';
import '../models/session.dart';

/// Status automático calculado com base em regras de negócio.
enum AutoClientStatus {
  /// Cadastrado há menos de 14 dias sem sessões.
  novo,

  /// Tem sessão futura ou sessão nos últimos 30 dias.
  ativo,

  /// Possui pagamento pendente vencido.
  inadimplente,

  /// Tem pacote ativo com poucas sessões restantes.
  pacoteAcabando,

  /// Sem sessão nos últimos 30 dias e sem próxima sessão.
  emRisco,

  /// Sem sessão há mais de 90 dias.
  inativo,
}

/// Extensão com label em português e cor sugerida.
extension AutoClientStatusX on AutoClientStatus {
  String get label {
    switch (this) {
      case AutoClientStatus.novo:
        return 'novo';
      case AutoClientStatus.ativo:
        return 'ativo';
      case AutoClientStatus.inadimplente:
        return 'inadimplente';
      case AutoClientStatus.pacoteAcabando:
        return 'pacote acabando';
      case AutoClientStatus.emRisco:
        return 'em risco';
      case AutoClientStatus.inativo:
        return 'inativo';
    }
  }

  /// Índice de prioridade para ordenação (menor = mais urgente).
  int get priority {
    switch (this) {
      case AutoClientStatus.inadimplente:
        return 0;
      case AutoClientStatus.emRisco:
        return 1;
      case AutoClientStatus.pacoteAcabando:
        return 2;
      case AutoClientStatus.inativo:
        return 3;
      case AutoClientStatus.novo:
        return 4;
      case AutoClientStatus.ativo:
        return 5;
    }
  }
}

/// Resultado da classificação para um cliente.
class ClientStatusResult {
  final Client client;
  final AutoClientStatus status;
  final DateTime? lastSessionDate;
  final DateTime? nextSessionDate;
  final bool hasOverduePayment;
  final bool hasLowPackage;

  const ClientStatusResult({
    required this.client,
    required this.status,
    this.lastSessionDate,
    this.nextSessionDate,
    this.hasOverduePayment = false,
    this.hasLowPackage = false,
  });
}

/// Classificador isolado de status automático de clientes.
///
/// Centraliza as regras de negócio para status inteligente,
/// sem depender diretamente de serviços ou banco de dados.
class ClientStatusClassifier {
  ClientStatusClassifier._();
  static final instance = ClientStatusClassifier._();

  /// Dias sem retorno para considerar "em risco".
  static const int riskDays = 30;

  /// Dias sem retorno para considerar "inativo".
  static const int inactiveDays = 90;

  /// Dias após o cadastro para considerar "novo".
  static const int newClientDays = 14;

  /// Sessões restantes para alertar "pacote acabando".
  static const int lowPackageThreshold = 2;

  /// Classifica um único cliente.
  ClientStatusResult classify({
    required Client client,
    required List<Session> allSessions,
    required List<Package> allPackages,
    List<dynamic> allPayments = const [], // mantido para compatibilidade de assinatura
  }) {
    final now = DateTime.now();

    // Sessões do cliente (não deletadas)
    final clientSessions = allSessions
        .where((s) => s.clientId == client.id && s.deletedAt == null)
        .toList();

    // Última sessão realizada
    final pastSessions = clientSessions
        .where((s) =>
            s.dateTime.isBefore(now) &&
            s.status != 'cancelado' &&
            s.status != 'faltou')
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
    final lastSession = pastSessions.isNotEmpty ? pastSessions.first : null;

    // Próxima sessão futura (não cancelada)
    final futureSessions = clientSessions
        .where((s) =>
            s.dateTime.isAfter(now) &&
            s.status != 'cancelado' &&
            s.status != 'faltou')
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
    final nextSession = futureSessions.isNotEmpty ? futureSessions.first : null;

    // Pagamentos pendentes: sessões do cliente com paymentStatus == 'pendente'
    final hasOverdue = clientSessions.any((s) =>
        s.paymentStatus == 'pendente' &&
        s.status != 'cancelado' &&
        s.status != 'faltou');

    // Pacotes ativos com poucas sessões
    final clientPackages = allPackages
        .where((p) => p.clientId == client.id && p.isActive)
        .toList();
    final hasLowPackage = clientPackages
        .any((p) => p.remainingSessions <= lowPackageThreshold);

    // ─── Regras de classificação (ordem de prioridade) ──────────────────

    // 1. Inadimplente — tem pagamento pendente
    if (hasOverdue) {
      return ClientStatusResult(
        client: client,
        status: AutoClientStatus.inadimplente,
        lastSessionDate: lastSession?.dateTime,
        nextSessionDate: nextSession?.dateTime,
        hasOverduePayment: true,
        hasLowPackage: hasLowPackage,
      );
    }

    // 2. Inativo — sem sessão há mais de 90 dias e sem próxima sessão
    if (lastSession != null &&
        nextSession == null &&
        now.difference(lastSession.dateTime).inDays > inactiveDays) {
      return ClientStatusResult(
        client: client,
        status: AutoClientStatus.inativo,
        lastSessionDate: lastSession.dateTime,
        hasLowPackage: hasLowPackage,
      );
    }

    // 3. Em risco — sem retorno há mais de 30 dias e sem próxima sessão
    if (lastSession != null &&
        nextSession == null &&
        now.difference(lastSession.dateTime).inDays > riskDays) {
      return ClientStatusResult(
        client: client,
        status: AutoClientStatus.emRisco,
        lastSessionDate: lastSession.dateTime,
        hasLowPackage: hasLowPackage,
      );
    }

    // 4. Pacote acabando
    if (hasLowPackage) {
      return ClientStatusResult(
        client: client,
        status: AutoClientStatus.pacoteAcabando,
        lastSessionDate: lastSession?.dateTime,
        nextSessionDate: nextSession?.dateTime,
        hasLowPackage: true,
      );
    }

    // 5. Novo — cadastrado há menos de X dias e sem sessão
    if (clientSessions.isEmpty &&
        now.difference(client.createdAt).inDays <= newClientDays) {
      return ClientStatusResult(
        client: client,
        status: AutoClientStatus.novo,
      );
    }

    // 6. Ativo — tem sessão futura ou sessão recente
    return ClientStatusResult(
      client: client,
      status: AutoClientStatus.ativo,
      lastSessionDate: lastSession?.dateTime,
      nextSessionDate: nextSession?.dateTime,
    );
  }

  /// Classifica uma lista de clientes em paralelo.
  List<ClientStatusResult> classifyAll({
    required List<Client> clients,
    required List<Session> allSessions,
    required List<Package> allPackages,
    List<dynamic> allPayments = const [],
  }) {
    return clients.map((c) => classify(
          client: c,
          allSessions: allSessions,
          allPackages: allPackages,
        )).toList();
  }
}
