/// Wrapper unificado de serviços — Arquitetura Multi-Tenant
///
/// Todos os serviços recebem businessId do BusinessService.
/// Usa mock services para demonstração sem Firebase.

import '../models/client.dart';
import '../models/session.dart';
import '../models/appointment.dart';
import '../models/package.dart';
import '../models/service_item.dart';
import '../models/user.dart' as models;
import 'mock_data_service.dart';
import 'mock_auth_service.dart';
import 'business_service.dart';

export '../models/client.dart';
export '../models/session.dart';
export '../models/appointment.dart';
export '../models/package.dart';
export '../models/service_item.dart';
export '../models/user.dart';
export '../models/business.dart';
export '../models/app_module.dart';
export '../models/appointment_metadata.dart';
export '../models/transaction.dart';

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

  Future<void> signOut() async {
    BusinessService.instance.clear();
    await _mock.signOut();
  }
  Future<void> resetPassword({required String email}) => _mock.resetPassword(email: email);
  Future<void> updateUserData(Map<String, dynamic> data) => _mock.updateUserData(data);
}

// ========== HELPER: resolve businessId ==========

String _bizId() {
  final id = BusinessService.instance.currentBusinessId;
  if (id == null) throw Exception('Business não resolvido. Faça login primeiro.');
  return id;
}

// ========== CLIENT SERVICE (business-scoped) ==========

class AppClientService {
  AppClientService._();
  static final instance = AppClientService._();

  final MockDataService _mock = MockDataService.instance;

  Stream<List<Client>> getClientsStream() {
    return Stream.value(
      _mock.getBizClients(_bizId()).map((m) => Client.fromMap(m['id'], m)).toList(),
    );
  }

  Future<List<Client>> getClients() async {
    return _mock.getBizClients(_bizId()).map((m) => Client.fromMap(m['id'], m)).toList();
  }

  Future<Client?> getClientById(String id) async {
    final data = _mock.getBizClientById(_bizId(), id);
    if (data == null) return null;
    return Client.fromMap(data['id'], data);
  }

  Future<String> createClient({
    required String name,
    required String phone,
    String? email,
    String? notes,
    List<String>? tags,
  }) async {
    return _mock.addBizClient(_bizId(), {
      'name': name,
      'phone': phone,
      'email': email ?? '',
      'notes': notes ?? '',
      'tags': tags ?? [],
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateClient(String id, {
    String? name,
    String? phone,
    String? email,
    String? notes,
    String? status,
    List<String>? tags,
  }) async {
    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (email != null) updates['email'] = email;
    if (notes != null) updates['notes'] = notes;
    if (status != null) updates['status'] = status;
    if (tags != null) updates['tags'] = tags;
    _mock.updateBizClient(_bizId(), id, updates);
  }

  /// Arquiva cliente (soft delete) - mantém histórico financeiro
  Future<void> archiveClient(String id) async {
    _mock.archiveBizClient(_bizId(), id);
  }

  /// Reativa cliente arquivado
  Future<void> reactivateClient(String id) async {
    _mock.reactivateBizClient(_bizId(), id);
  }

  /// Deleta cliente permanentemente (não recomendado)
  Future<void> deleteClient(String id) async {
    _mock.deleteBizClient(_bizId(), id);
  }

  /// Retorna apenas clientes ativos
  Future<List<Client>> getActiveClients() async {
    return _mock.getActiveBizClients(_bizId())
        .map((m) => Client.fromMap(m['id'], m))
        .toList();
  }

  Future<int> getClientCount() async {
    return _mock.getBizClients(_bizId()).length;
  }

  /// Conta apenas clientes ativos
  Future<int> getActiveClientCount() async {
    return _mock.getActiveBizClients(_bizId()).length;
  }
}

// ========== APPOINTMENT SERVICE (business-scoped) ==========

class AppAppointmentService {
  AppAppointmentService._();
  static final instance = AppAppointmentService._();

  final MockDataService _mock = MockDataService.instance;

  Stream<List<Appointment>> getAppointmentsStream() {
    return Stream.value(
      _mock.getBizAppointments(_bizId())
          .map((m) => Appointment.fromMap(m['id'], m))
          .toList(),
    );
  }

  Stream<List<Appointment>> getClientAppointmentsStream(String clientId) {
    return Stream.value(
      _mock.getBizAppointmentsByClient(_bizId(), clientId)
          .map((m) => Appointment.fromMap(m['id'], m))
          .toList(),
    );
  }

  Future<List<Appointment>> getTodayAppointments() async {
    return _mock.getBizTodayAppointments(_bizId())
        .map((m) => Appointment.fromMap(m['id'], m))
        .toList();
  }

  Future<List<Appointment>> getAppointmentsByPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    return _mock.getBizAppointmentsByPeriod(_bizId(), start, end)
        .map((m) => Appointment.fromMap(m['id'], m))
        .toList();
  }

  Future<Appointment?> getAppointmentById(String id) async {
    final data = _mock.getBizAppointmentById(_bizId(), id);
    if (data == null) return null;
    return Appointment.fromMap(data['id'], data);
  }

  Future<String> createAppointment({
    required String clientId,
    required String module,
    required DateTime startAt,
    required DateTime endAt,
    required double price,
    String? staffUid,
    String? serviceId,
    String status = 'confirmado',
    String paymentStatus = 'pendente',
    Map<String, dynamic>? metadata,
    String? packageId,
  }) async {
    return _mock.addBizAppointment(_bizId(), {
      'clientId': clientId,
      'staffUid': staffUid,
      'serviceId': serviceId,
      'module': module,
      'startAt': startAt.toIso8601String(),
      'endAt': endAt.toIso8601String(),
      'status': status,
      'price': price,
      'paymentStatus': paymentStatus,
      'metadata': metadata ?? {},
      'packageId': packageId,
      'createdAt': DateTime.now().toIso8601String(),
    });
  }

  Future<void> updateAppointment(String id, {
    DateTime? startAt,
    DateTime? endAt,
    String? module,
    String? status,
    double? price,
    String? paymentStatus,
    Map<String, dynamic>? metadata,
    String? packageId,
  }) async {
    final updates = <String, dynamic>{};
    if (startAt != null) updates['startAt'] = startAt.toIso8601String();
    if (endAt != null) updates['endAt'] = endAt.toIso8601String();
    if (module != null) updates['module'] = module;
    if (status != null) updates['status'] = status;
    if (price != null) updates['price'] = price;
    if (paymentStatus != null) updates['paymentStatus'] = paymentStatus;
    if (metadata != null) updates['metadata'] = metadata;
    if (packageId != null) updates['packageId'] = packageId;
    _mock.updateBizAppointment(_bizId(), id, updates);
  }

  Future<void> deleteAppointment(String id) async {
    _mock.deleteBizAppointment(_bizId(), id);
  }

  Future<void> markAsPaid(String id) async {
    await updateAppointment(id, paymentStatus: 'pago');
  }

  Future<void> markAsNoShow(String id) async {
    await updateAppointment(id, status: 'faltou');
  }

  Future<Appointment?> getLastAppointmentByClient(String clientId,
      {String? excludeId}) async {
    final appointments = _mock.getBizAppointmentsByClient(_bizId(), clientId)
      ..sort((a, b) =>
          ((b['startAt'] ?? b['dateTime']) as String)
              .compareTo((a['startAt'] ?? a['dateTime']) as String));

    for (final a in appointments) {
      if (excludeId == null || a['id'] != excludeId) {
        return Appointment.fromMap(a['id'], a);
      }
    }
    return null;
  }
}

// ========== LEGACY SESSION SERVICE (backward compatibility) ==========

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

// ========== SERVICE ITEM SERVICE (business-scoped) ==========

class AppServiceItemService {
  AppServiceItemService._();
  static final instance = AppServiceItemService._();

  final MockDataService _mock = MockDataService.instance;

  Future<List<ServiceItem>> getServices() async {
    return _mock.getBizServices(_bizId())
        .map((m) => ServiceItem.fromMap(m['id'], m))
        .toList();
  }

  Future<List<ServiceItem>> getServicesByModule(String module) async {
    return _mock.getBizServices(_bizId())
        .where((m) => m['module'] == module)
        .map((m) => ServiceItem.fromMap(m['id'], m))
        .toList();
  }

  Future<String> createService({
    required String name,
    required String module,
    required int durationMin,
    required double price,
  }) async {
    return _mock.addBizService(_bizId(), {
      'name': name,
      'module': module,
      'durationMin': durationMin,
      'price': price,
      'active': true,
    });
  }
}

// ========== PACKAGE SERVICE (business-scoped) ==========

class AppPackageService {
  AppPackageService._();
  static final instance = AppPackageService._();

  final MockDataService _mock = MockDataService.instance;

  Future<List<Package>> listPackages(String clientId) async {
    return _mock.getBizPackages(_bizId(), clientId)
        .map((m) => Package.fromMap(m['id'], m))
        .toList();
  }

  Stream<List<Package>> getPackagesStream(String clientId) {
    return Stream.value(
      _mock.getBizPackages(_bizId(), clientId)
          .map((m) => Package.fromMap(m['id'], m))
          .toList(),
    );
  }

  Future<Package?> getActivePackage(String clientId) async {
    final data = _mock.getActiveBizPackage(_bizId(), clientId);
    if (data == null) return null;
    return Package.fromMap(data['id'], data);
  }

  Future<String> createPackage({
    required String clientId,
    required int totalSessions,
    required double price,
    DateTime? expirationDate,
  }) async {
    return _mock.addBizPackage(_bizId(), clientId, {
      'totalSessions': totalSessions,
      'remainingSessions': totalSessions,
      'price': price,
      'status': 'active',
      'createdAt': DateTime.now().toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
    });
  }

  Future<Package?> decrementPackage(String packageId) async {
    final clients = _mock.getBizClients(_bizId());
    for (final client in clients) {
      final packages = _mock.getBizPackages(_bizId(), client['id']);
      final pkg = packages.where((p) => p['id'] == packageId).firstOrNull;
      if (pkg != null) {
        _mock.decrementBizPackage(_bizId(), client['id'], packageId);
        final updated = _mock.getBizPackages(_bizId(), client['id'])
            .where((p) => p['id'] == packageId)
            .firstOrNull;
        if (updated != null) {
          return Package.fromMap(updated['id'], updated);
        }
      }
    }
    return null;
  }

  Future<bool> hasActivePackage(String clientId) async {
    return _mock.getActiveBizPackage(_bizId(), clientId) != null;
  }
}

// ========== FINANCE SERVICE (business-scoped) ==========

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
    
    final appointments = _mock.getBizAppointmentsByPeriod(_bizId(), start, end);
    
    double totalReceived = 0;
    double totalPending = 0;
    int confirmed = 0;
    int missed = 0;
    int rescheduled = 0;
    
    for (final a in appointments) {
      final value = (a['price'] ?? a['value'] ?? 0) is num
          ? ((a['price'] ?? a['value']) as num).toDouble()
          : 0.0;
      if (a['paymentStatus'] == 'pago') {
        totalReceived += value;
      } else {
        totalPending += value;
      }
      
      switch (a['status']) {
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
      totalSessions: appointments.length,
      sessionsConfirmed: confirmed,
      sessionsMissed: missed,
      sessionsRescheduled: rescheduled,
      totalReceived: totalReceived,
      totalPending: totalPending,
      total: totalReceived + totalPending,
    );
  }

  Future<List<Appointment>> getPendingAppointments() async {
    return _mock.getBizPendingAppointments(_bizId())
        .map((m) => Appointment.fromMap(m['id'], m))
        .toList();
  }

  /// Alias para compatibilidade com telas existentes
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
    
    final pendingAppointments = await getPendingAppointments();
    final messages = <InsightMessage>[];
    
    if (currentReport.totalPending > 0) {
      messages.add(InsightMessage(
        icon: '⚠️',
        type: InsightType.warning,
        message: 'Você tem R\$ ${currentReport.totalPending.toStringAsFixed(0)} pendentes em ${pendingAppointments.length} agendamentos.',
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
      pendingCount: pendingAppointments.length,
      pendingTotal: currentReport.totalPending,
      messages: messages,
    );
  }
}

// ========== ALIASES (backward compatibility) ==========
typedef ClientService = AppClientService;
typedef SessionService = AppSessionService;
typedef AppointmentService = AppAppointmentService;
typedef PackageService = AppPackageService;
typedef FinanceService = AppFinanceService;
typedef AuthService = AppAuthService;
typedef ServiceItemService = AppServiceItemService;
