import '../models/client.dart';
import '../models/session.dart';
import '../models/package.dart';
import '../models/user.dart' as models;
import 'mock_data_service.dart';
import 'mock_auth_service.dart';

/// Serviço de clientes usando mock
class MockClientService {
  MockClientService._();
  static final instance = MockClientService._();

  final MockDataService _mock = MockDataService.instance;

  Stream<List<Client>> getClientsStream() {
    // Simula um stream com os dados atuais
    return Stream.value(getClientsSync());
  }

  List<Client> getClientsSync() {
    return _mock.getClients().map((m) => Client.fromMap(m['id'], m)).toList();
  }

  Future<List<Client>> getClients() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return getClientsSync();
  }

  Future<Client?> getClientById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final data = _mock.getClientById(id);
    if (data == null) return null;
    return Client.fromMap(data['id'], data);
  }

  Future<String> createClient({
    required String name,
    required String phone,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mock.addClient({
      'name': name,
      'phone': phone,
      'notes': notes ?? '',
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateClient(String id, {
    String? name,
    String? phone,
    String? notes,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (notes != null) updates['notes'] = notes;
    _mock.updateClient(id, updates);
  }

  Future<void> deleteClient(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mock.deleteClient(id);
  }

  Future<int> getClientCount() async {
    return _mock.getClients().length;
  }
}

/// Serviço de sessões usando mock
class MockSessionService {
  MockSessionService._();
  static final instance = MockSessionService._();

  final MockDataService _mock = MockDataService.instance;

  Stream<List<Session>> getSessionsStream() {
    return Stream.value(_mock.getSessions().map((m) => Session.fromMap(m['id'], m)).toList());
  }

  Stream<List<Session>> getClientSessionsStream(String clientId) {
    return Stream.value(
      _mock.getSessionsByClient(clientId).map((m) => Session.fromMap(m['id'], m)).toList()
    );
  }

  Future<List<Session>> getTodaySessions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mock.getTodaySessions().map((m) => Session.fromMap(m['id'], m)).toList();
  }

  Future<List<Session>> getSessionsByPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mock.getSessionsByPeriod(start, end)
        .map((m) => Session.fromMap(m['id'], m)).toList();
  }

  Future<Session?> getSessionById(String id) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final data = _mock.getSessionById(id);
    if (data == null) return null;
    return Session.fromMap(data['id'], data);
  }

  Future<String> createSession({
    required String clientId,
    required DateTime dateTime,
    required String therapyType,
    required double value,
    String? notes,
    String status = 'confirmado',
    String paymentStatus = 'pendente',
    String? packageId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mock.addSession({
      'clientId': clientId,
      'dateTime': dateTime.toIso8601String(),
      'therapyType': therapyType,
      'value': value,
      'notes': notes ?? '',
      'status': status,
      'paymentStatus': paymentStatus,
      'packageId': packageId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateSession(String id, {
    DateTime? dateTime,
    String? therapyType,
    String? status,
    double? value,
    String? notes,
    String? paymentStatus,
    String? packageId,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    final updates = <String, dynamic>{};
    if (dateTime != null) updates['dateTime'] = dateTime.toIso8601String();
    if (therapyType != null) updates['therapyType'] = therapyType;
    if (status != null) updates['status'] = status;
    if (value != null) updates['value'] = value;
    if (notes != null) updates['notes'] = notes;
    if (paymentStatus != null) updates['paymentStatus'] = paymentStatus;
    if (packageId != null) updates['packageId'] = packageId;
    _mock.updateSession(id, updates);
  }

  Future<void> deleteSession(String id) async {
    await Future.delayed(const Duration(milliseconds: 100));
    _mock.deleteSession(id);
  }

  Future<void> markAsPaid(String id) async {
    await updateSession(id, paymentStatus: 'pago');
  }

  Future<void> markAsNoShow(String id) async {
    await updateSession(id, status: 'faltou');
  }

  Future<Session?> getLastSessionByClient(String clientId, {String? excludeSessionId}) async {
    final sessions = _mock.getSessionsByClient(clientId)
      ..sort((a, b) => (b['dateTime'] as String).compareTo(a['dateTime'] as String));
    
    for (final s in sessions) {
      if (excludeSessionId == null || s['id'] != excludeSessionId) {
        return Session.fromMap(s['id'], s);
      }
    }
    return null;
  }
}

/// Serviço de pacotes usando mock
class MockPackageService {
  MockPackageService._();
  static final instance = MockPackageService._();

  final MockDataService _mock = MockDataService.instance;

  Future<List<Package>> listPackages(String clientId) async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mock.getPackages(clientId).map((m) => Package.fromMap(m['id'], m)).toList();
  }

  Stream<List<Package>> getPackagesStream(String clientId) {
    return Stream.value(
      _mock.getPackages(clientId).map((m) => Package.fromMap(m['id'], m)).toList()
    );
  }

  Future<Package?> getActivePackage(String clientId) async {
    await Future.delayed(const Duration(milliseconds: 50));
    final data = _mock.getActivePackage(clientId);
    if (data == null) return null;
    return Package.fromMap(data['id'], data);
  }

  Future<String> createPackage({
    required String clientId,
    required int totalSessions,
    required double price,
    DateTime? expirationDate,
  }) async {
    await Future.delayed(const Duration(milliseconds: 200));
    return _mock.addPackage(clientId, {
      'totalSessions': totalSessions,
      'remainingSessions': totalSessions,
      'price': price,
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
    });
  }

  Future<Package?> decrementPackage(String packageId) async {
    // Encontrar o pacote
    final clients = _mock.getClients();
    for (final client in clients) {
      final packages = _mock.getPackages(client['id']);
      final pkg = packages.where((p) => p['id'] == packageId).firstOrNull;
      if (pkg != null) {
        _mock.decrementPackage(client['id'], packageId);
        final updated = _mock.getPackages(client['id']).where((p) => p['id'] == packageId).firstOrNull;
        if (updated != null) {
          return Package.fromMap(updated['id'], updated);
        }
      }
    }
    return null;
  }

  Future<bool> hasActivePackage(String clientId) async {
    return _mock.getActivePackage(clientId) != null;
  }
}

/// Serviço financeiro usando mock
class MockFinanceService {
  MockFinanceService._();
  static final instance = MockFinanceService._();

  final MockDataService _mock = MockDataService.instance;

  Future<MockMonthlyReport> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    await Future.delayed(const Duration(milliseconds: 100));
    
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);
    
    final sessions = _mock.getSessionsByPeriod(start, end);
    
    double totalReceived = 0;
    double totalPending = 0;
    int confirmed = 0;
    int missed = 0;
    int rescheduled = 0;
    
    for (final s in sessions) {
      final value = (s['value'] as num).toDouble();
      if (s['paymentStatus'] == 'pago') {
        totalReceived += value;
      } else {
        totalPending += value;
      }
      
      switch (s['status']) {
        case 'realizada':
        case 'confirmado':
          confirmed++;
          break;
        case 'faltou':
          missed++;
          break;
        case 'remarcado':
          rescheduled++;
          break;
      }
    }
    
    return MockMonthlyReport(
      year: year,
      month: month,
      totalSessions: sessions.length,
      sessionsConfirmed: confirmed,
      sessionsMissed: missed,
      sessionsRescheduled: rescheduled,
      totalReceived: totalReceived,
      totalPending: totalPending,
      total: totalReceived + totalPending,
    );
  }

  Future<List<Session>> getPendingSessions() async {
    await Future.delayed(const Duration(milliseconds: 100));
    return _mock.getPendingSessions().map((m) => Session.fromMap(m['id'], m)).toList();
  }

  Future<MockFinanceInsights> getFinanceInsights() async {
    final now = DateTime.now();
    final currentReport = await getMonthlyReport(year: now.year, month: now.month);
    
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final previousReport = await getMonthlyReport(year: prevMonth.year, month: prevMonth.month);
    
    final messages = <MockInsightMessage>[];
    
    if (currentReport.totalPending > 0) {
      messages.add(MockInsightMessage(
        icon: '⚠️',
        type: MockInsightType.warning,
        message: 'Você tem R\$ ${currentReport.totalPending.toStringAsFixed(0)} pendentes.',
      ));
    }
    
    if (currentReport.totalReceived > previousReport.totalReceived) {
      messages.add(MockInsightMessage(
        icon: '📈',
        type: MockInsightType.success,
        message: 'Receita maior que o mês anterior!',
      ));
    }
    
    if (messages.isEmpty) {
      messages.add(MockInsightMessage(
        icon: '✨',
        type: MockInsightType.success,
        message: 'Suas finanças estão em dia!',
      ));
    }
    
    return MockFinanceInsights(
      currentMonth: currentReport,
      previousMonth: previousReport,
      messages: messages,
    );
  }
}

// Classes auxiliares
class MockMonthlyReport {
  final int year;
  final int month;
  final int totalSessions;
  final int sessionsConfirmed;
  final int sessionsMissed;
  final int sessionsRescheduled;
  final double totalReceived;
  final double totalPending;
  final double total;

  MockMonthlyReport({
    required this.year,
    required this.month,
    required this.totalSessions,
    required this.sessionsConfirmed,
    required this.sessionsMissed,
    required this.sessionsRescheduled,
    required this.totalReceived,
    required this.totalPending,
    required this.total,
  });

  String get monthName {
    const months = ['Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
                    'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'];
    return months[month - 1];
  }
}

enum MockInsightType { success, warning, info, alert }

class MockInsightMessage {
  final String icon;
  final MockInsightType type;
  final String message;

  MockInsightMessage({
    required this.icon,
    required this.type,
    required this.message,
  });
}

class MockFinanceInsights {
  final MockMonthlyReport currentMonth;
  final MockMonthlyReport previousMonth;
  final List<MockInsightMessage> messages;

  MockFinanceInsights({
    required this.currentMonth,
    required this.previousMonth,
    required this.messages,
  });
}
