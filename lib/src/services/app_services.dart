/// Wrapper unificado de serviços
/// Fornece acesso unificado aos services refatorados (SQLite-first)

import '../models/client.dart';
import '../models/session.dart';
import '../models/package.dart';
import '../models/user.dart' as models;
import 'auth_service.dart';
import 'client_service_v2.dart';
import 'session_service_v2.dart';
import 'package_service.dart';
import 'finance_service_v2.dart';

export '../models/client.dart';
export '../models/session.dart';
export '../models/package.dart';
export '../models/user.dart';
export 'finance_service_v2.dart' show MonthlyReport, InsightType, InsightMessage, MonthComparison, FinanceInsights;

// ========== AUTH SERVICE ==========

class AppAuthService {
  AppAuthService._();
  static final instance = AppAuthService._();

  final AuthService _real = AuthService.instance;

  Stream<dynamic> get authStateChanges => _real.authStateChanges;
  dynamic get currentUser => _real.currentUser;

  Future<models.User?> getCurrentUserData() => _real.getCurrentUserData();

  Future<dynamic> signUp({
    required String email,
    required String password,
    required String name,
  }) => _real.signUp(email: email, password: password, name: name);

  Future<dynamic> signIn({
    required String email,
    required String password,
  }) => _real.signIn(email: email, password: password);

  Future<void> signOut() => _real.signOut();
  Future<void> resetPassword({required String email}) =>
      _real.resetPassword(email: email);
  Future<void> updateUserData(Map<String, dynamic> data) =>
      _real.updateUserData(data);
}

// ========== CLIENT SERVICE ==========

class AppClientService {
  AppClientService._();
  static final instance = AppClientService._();

  final ClientService _real = ClientService.instance;

  Stream<List<Client>> getClientsStream() => _real.getClientsStream();

  Future<List<Client>> getClients() => _real.getClients();

  Future<Client?> getClientById(String id) => _real.getClientById(id);

  Future<String> createClient({
    required String name,
    required String phone,
    String? notes,
  }) =>
      _real.createClient(name: name, phone: phone, notes: notes);

  Future<void> updateClient(
    String id, {
    String? name,
    String? phone,
    String? notes,
    String? status,
  }) =>
      _real.updateClient(id,
          name: name, phone: phone, notes: notes, status: status);

  Future<void> archiveClient(String id) => _real.archiveClient(id);

  Future<void> reactivateClient(String id) => _real.reactivateClient(id);

  Future<void> deleteClient(String id) => _real.deleteClient(id);

  Future<List<Client>> searchClients(String query) =>
      _real.searchClients(query);

  Future<int> getClientCount() => _real.getClientCount();

  // Aliases para compatibilidade
  Future<List<Client>> getActiveClients() async {
    final clients = await getClients();
    return clients.where((c) => c.isActive).toList();
  }

  Future<int> getActiveClientCount() async {
    return (await getActiveClients()).length;
  }
}

// ========== SESSION SERVICE ==========

class AppSessionService {
  AppSessionService._();
  static final instance = AppSessionService._();

  final SessionService _real = SessionService.instance;

  Stream<List<Session>> getSessionsStream() => _real.getSessionsStream();

  Stream<List<Session>> getClientSessionsStream(String clientId) =>
      _real.getClientSessionsStream(clientId);

  Future<List<Session>> getTodaySessions() => _real.getTodaySessions();

  Future<List<Session>> getSessionsByPeriod({
    required DateTime start,
    required DateTime end,
  }) =>
      _real.getSessionsByPeriod(start: start, end: end);

  Future<Session?> getSessionById(String id) => _real.getSessionById(id);

  Future<String> createSession({
    required String clientId,
    required DateTime dateTime,
    required String therapyType,
    required double value,
    String? notes,
    String status = 'confirmado',
    String paymentStatus = 'pendente',
    String? packageId,
  }) =>
      _real.createSession(
        clientId: clientId,
        dateTime: dateTime,
        therapyType: therapyType,
        value: value,
        notes: notes,
        status: status,
        paymentStatus: paymentStatus,
        packageId: packageId,
      );

  Future<void> updateSession(
    String id, {
    DateTime? dateTime,
    String? therapyType,
    String? status,
    double? value,
    String? notes,
    String? paymentStatus,
    String? packageId,
  }) =>
      _real.updateSession(
        id,
        dateTime: dateTime,
        therapyType: therapyType,
        status: status,
        value: value,
        notes: notes,
        paymentStatus: paymentStatus,
        packageId: packageId,
      );

  Future<void> deleteSession(String id) => _real.deleteSession(id);

  Future<void> markAsPaid(String id) => _real.markAsPaid(id);

  Future<void> markAsNoShow(String id) => _real.markAsNoShow(id);

  Future<Session?> getLastSessionByClient(String clientId,
          {String? excludeSessionId}) =>
      _real.getLastSessionByClient(clientId,
          excludeSessionId: excludeSessionId);
}

// ========== PACKAGE SERVICE ==========

class AppPackageService {
  AppPackageService._();
  static final instance = AppPackageService._();

  final PackageService _real = PackageService.instance;

  Future<List<Package>> listPackages(String clientId) =>
      _real.listPackages(clientId);

  Stream<List<Package>> getPackagesStream(String clientId) =>
      _real.getPackagesStream(clientId);

  Future<Package?> getActivePackage(String clientId) =>
      _real.getActivePackage(clientId);

  Future<Package?> getPackageById(String clientId, String packageId) =>
      _real.getPackageById(clientId, packageId);

  Future<String> createPackage({
    required String clientId,
    required int totalSessions,
    required double price,
    DateTime? expirationDate,
  }) =>
      _real.createPackage(
        clientId: clientId,
        totalSessions: totalSessions,
        price: price,
        expirationDate: expirationDate,
      );

  Future<Package?> decrementPackage(String packageId) =>
      _real.decrementPackage(packageId);

  Future<Package?> decrementPackageByClient(String clientId, String packageId) =>
      _real.decrementPackageByClient(clientId, packageId);

  Future<bool> hasActivePackage(String clientId) =>
      _real.hasActivePackage(clientId);

  Future<void> deletePackage(String clientId, String packageId) =>
      _real.deletePackage(clientId, packageId);
}

// ========== FINANCE SERVICE ==========

class AppFinanceService {
  AppFinanceService._();
  static final instance = AppFinanceService._();

  final FinanceService _real = FinanceService.instance;

  Future<String> createPayment({
    required String sessionId,
    required double value,
    required String method,
    String status = 'pago',
  }) =>
      _real.createPayment(
        sessionId: sessionId,
        value: value,
        method: method,
        status: status,
      );

  Future<MonthlyReport> getMonthlyReport({
    required int year,
    required int month,
  }) =>
      _real.getMonthlyReport(year: year, month: month);

  Future<List<Session>> getPendingSessions() => _real.getPendingSessions();

  Future<double> getTotalReceivedInPeriod({
    required DateTime start,
    required DateTime end,
  }) =>
      _real.getTotalReceivedInPeriod(start: start, end: end);

  Future<double> getExpectedNext7Days() => _real.getExpectedNext7Days();

  Future<MonthComparison> getMonthOverMonthComparison() =>
      _real.getMonthOverMonthComparison();

  Future<FinanceInsights> getFinanceInsights() => _real.getFinanceInsights();
}

// Aliases para compatibilidade
typedef ClientService = AppClientService;
typedef SessionService = AppSessionService;
typedef PackageService = AppPackageService;
typedef FinanceService = AppFinanceService;
typedef AuthService = AppAuthService;

