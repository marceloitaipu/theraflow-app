/// Wrapper unificado de serviços
/// Usa mock services para demonstração sem Firebase
/// 
/// Este arquivo fornece acesso unificado a todos os serviços

import '../models/client.dart';
import '../models/session.dart';
import '../models/package.dart';
import '../models/user.dart' as models;
import 'mock_data_service.dart';
import 'mock_auth_service.dart';

export '../models/client.dart';
export '../models/session.dart';
export '../models/package.dart';
export '../models/user.dart';

// ========== AUTH SERVICE ==========

class AppAuthService {
  AppAuthService._();
  static final instance = AppAuthService._();

  final MockAuthService _mock = MockAuthService.instance;

  Stream<dynamic> get authStateChanges => _mock.authStateChanges;
  dynamic get currentUser => _mock.currentUser;

  Future<models.User?> getCurrentUserData() => _mock.getCurrentUserData();

  Future<dynamic> signUp({
    required String email,
    required String password,
    required String name,
  }) => _mock.signUp(email: email, password: password, name: name);

  Future<dynamic> signIn({
    required String email,
    required String password,
  }) => _mock.signIn(email: email, password: password);

  Future<void> signOut() => _mock.signOut();
  Future<void> resetPassword({required String email}) => _mock.resetPassword(email: email);
  Future<void> updateUserData(Map<String, dynamic> data) => _mock.updateUserData(data);
}

// ========== CLIENT SERVICE ==========

class AppClientService {
  AppClientService._();
  static final instance = AppClientService._();

  final MockDataService _mock = MockDataService.instance;

  Stream<List<Client>> getClientsStream() {
    return Stream.value(_mock.getClients().map((m) => Client.fromMap(m['id'], m)).toList());
  }

  Future<List<Client>> getClients() async {
    return _mock.getClients().map((m) => Client.fromMap(m['id'], m)).toList();
  }

  Future<Client?> getClientById(String id) async {
    final data = _mock.getClientById(id);
    if (data == null) return null;
    return Client.fromMap(data['id'], data);
  }

  Future<String> createClient({
    required String name,
    required String phone,
    String? notes,
  }) async {
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
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (notes != null) updates['notes'] = notes;
    _mock.updateClient(id, updates);
  }

  Future<void> deleteClient(String id) async {
    _mock.deleteClient(id);
  }

  Future<int> getClientCount() async {
    return _mock.getClients().length;
  }
}

// ========== SESSION SERVICE ==========

class AppSessionService {
  AppSessionService._();
  static final instance = AppSessionService._();

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
    return _mock.getTodaySessions().map((m) => Session.fromMap(m['id'], m)).toList();
  }

  Future<List<Session>> getSessionsByPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    return _mock.getSessionsByPeriod(start, end)
        .map((m) => Session.fromMap(m['id'], m)).toList();
  }

  Future<Session?> getSessionById(String id) async {
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

// ========== PACKAGE SERVICE ==========

class AppPackageService {
  AppPackageService._();
  static final instance = AppPackageService._();

  final MockDataService _mock = MockDataService.instance;

  Future<List<Package>> listPackages(String clientId) async {
    return _mock.getPackages(clientId).map((m) => Package.fromMap(m['id'], m)).toList();
  }

  Stream<List<Package>> getPackagesStream(String clientId) {
    return Stream.value(
      _mock.getPackages(clientId).map((m) => Package.fromMap(m['id'], m)).toList()
    );
  }

  Future<Package?> getActivePackage(String clientId) async {
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

// ========== FINANCE SERVICE ==========

class MonthlyReport {
  final int year;
  final int month;
  final int totalSessions;
  final int sessionsConfirmed;
  final int sessionsMissed;
  final int sessionsRescheduled;
  final double totalReceived;
  final double totalPending;
  final double total;

  MonthlyReport({
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

enum InsightType { success, warning, info, alert }

class InsightMessage {
  final String icon;
  final InsightType type;
  final String message;

  InsightMessage({
    required this.icon,
    required this.type,
    required this.message,
  });
}

class MonthComparison {
  final MonthlyReport currentMonth;
  final MonthlyReport previousMonth;
  final double receivedPercentChange;
  final double sessionsPercentChange;

  MonthComparison({
    required this.currentMonth,
    required this.previousMonth,
    required this.receivedPercentChange,
    required this.sessionsPercentChange,
  });

  bool get isReceivedUp => receivedPercentChange > 0;
  bool get isSessionsUp => sessionsPercentChange > 0;
}

class FinanceInsights {
  final MonthComparison comparison;
  final double expectedNext7Days;
  final int pendingCount;
  final double pendingTotal;
  final List<InsightMessage> messages;

  FinanceInsights({
    required this.comparison,
    required this.expectedNext7Days,
    required this.pendingCount,
    required this.pendingTotal,
    required this.messages,
  });
}

class AppFinanceService {
  AppFinanceService._();
  static final instance = AppFinanceService._();

  final MockDataService _mock = MockDataService.instance;

  Future<MonthlyReport> getMonthlyReport({
    required int year,
    required int month,
  }) async {
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
    
    return MonthlyReport(
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
    return _mock.getPendingSessions().map((m) => Session.fromMap(m['id'], m)).toList();
  }

  Future<FinanceInsights> getFinanceInsights() async {
    final now = DateTime.now();
    final currentReport = await getMonthlyReport(year: now.year, month: now.month);
    
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final previousReport = await getMonthlyReport(year: prevMonth.year, month: prevMonth.month);
    
    final receivedDiff = previousReport.totalReceived > 0
        ? ((currentReport.totalReceived - previousReport.totalReceived) / 
           previousReport.totalReceived * 100)
        : 0.0;
    
    final sessionsDiff = previousReport.totalSessions > 0
        ? ((currentReport.totalSessions - previousReport.totalSessions) / 
           previousReport.totalSessions * 100)
        : 0.0;
    
    final comparison = MonthComparison(
      currentMonth: currentReport,
      previousMonth: previousReport,
      receivedPercentChange: receivedDiff,
      sessionsPercentChange: sessionsDiff,
    );
    
    final pendingSessions = await getPendingSessions();
    final messages = <InsightMessage>[];
    
    if (currentReport.totalPending > 0) {
      messages.add(InsightMessage(
        icon: '⚠️',
        type: InsightType.warning,
        message: 'Você tem R\$ ${currentReport.totalPending.toStringAsFixed(0)} pendentes em ${pendingSessions.length} sessões.',
      ));
    }
    
    if (comparison.isReceivedUp && receivedDiff > 5) {
      messages.add(InsightMessage(
        icon: '📈',
        type: InsightType.success,
        message: 'Receita ${receivedDiff.toStringAsFixed(0)}% maior que o mês anterior!',
      ));
    }
    
    if (messages.isEmpty) {
      messages.add(InsightMessage(
        icon: '✨',
        type: InsightType.success,
        message: 'Suas finanças estão em dia!',
      ));
    }
    
    return FinanceInsights(
      comparison: comparison,
      expectedNext7Days: 0,
      pendingCount: pendingSessions.length,
      pendingTotal: currentReport.totalPending,
      messages: messages,
    );
  }
}

// Aliases para compatibilidade
typedef ClientService = AppClientService;
typedef SessionService = AppSessionService;
typedef PackageService = AppPackageService;
typedef FinanceService = AppFinanceService;
typedef AuthService = AppAuthService;
