import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/package.dart';
import '../database/database_helper.dart';
import 'auth_service.dart';
import 'data_change_bus.dart';
import 'incremental_sync_service.dart';

class PackageService {
  PackageService._();
  static final instance = PackageService._();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final AuthService _auth = AuthService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IncrementalSyncService _sync = IncrementalSyncService.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _packagesCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('packages');
  }

  // Buscar todos os pacotes do banco local
  Future<List<Package>> getPackages() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    if (kIsWeb) {
      final snapshot = await _packagesCollection(userId).get();
      final packages = snapshot.docs
          .map((doc) => Package.fromMap(doc.id, doc.data()))
          .where((package) => package.status != 'deleted')
          .toList();
      packages.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return packages;
    }

    final maps = await _db.getAllPackages(userId);
    return maps
        .map((map) => Package.fromMap(map['id'] as String, map))
        .toList();
  }

  // Listar todos os pacotes de um cliente (compatibilidade)
  Future<List<Package>> listPackages(String clientId) async {
    return getClientPackages(clientId);
  }

  // Stream reativa de pacotes de um cliente. Reemite apenas em mudanças.
  Stream<List<Package>> getPackagesStream(String clientId) async* {
    yield await getClientPackages(clientId);
    await for (final _ in DataChangeBus.instance.streamFor('packages')) {
      yield await getClientPackages(clientId);
    }
  }

  // Buscar pacotes de um cliente
  Future<List<Package>> getClientPackages(String clientId) async {
    final packages = await getPackages();
    return packages.where((p) => p.clientId == clientId).toList();
  }

  // Buscar pacote ativo de um cliente
  Future<Package?> getActivePackage(String clientId) async {
    final packages = await getClientPackages(clientId);
    try {
      return packages.firstWhere((p) => p.isActive);
    } catch (e) {
      return null;
    }
  }

  // Buscar pacote por ID (compatibilidade com código antigo)
  Future<Package?> getPackageById(String clientId, String packageId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    if (kIsWeb) {
      final doc = await _packagesCollection(userId).doc(packageId).get();
      if (!doc.exists) return null;
      final pkg = Package.fromMap(doc.id, doc.data()!);
      return pkg.status == 'deleted' ? null : pkg;
    }

    final map = await _db.getPackageById(packageId);
    if (map == null) return null;
    return Package.fromMap(map['id'] as String, map);
  }

  // Criar pacote
  Future<String> createPackage({
    required String clientId,
    required int totalSessions,
    required double price,
    DateTime? expirationDate,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Permite múltiplos pacotes ativos simultâneos por cliente.

    // Gerar ID único
    final id = _uuid.v4();

    final now = DateTime.now();
    final packageData = {
      'id': id,
      'userId': userId,
      'clientId': clientId,
      'totalSessions': totalSessions,
      'remainingSessions': totalSessions,
      'price': price,
      'createdAt': now.toIso8601String(),
      'expirationDate': expirationDate?.toIso8601String(),
      'status': 'active',
      'updatedAt': now.toIso8601String(),
      'deletedAt': null,
      'synced': 0,
      'lastModified': now.toIso8601String(),
      'deleted': 0,
    };

    if (kIsWeb) {
      await _packagesCollection(userId).doc(id).set(packageData);
      DataChangeBus.instance.notify('packages');
      return id;
    }

    // Salvar localmente
    await _db.insertPackage(packageData);
    DataChangeBus.instance.notify('packages');

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      await _db.addToSyncQueue(
        operation: 'create',
        tableName: 'packages',
        recordId: id,
        data: jsonEncode(packageData),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }

    return id;
  }

  // Decrementar pacote (compatibilidade com código antigo)
  Future<Package?> decrementPackage(String packageId) async {
    return await useSession(packageId);
  }

  // Decrementar pacote por clientId e packageId (compatibilidade)
  Future<Package?> decrementPackageByClient(String clientId, String packageId) async {
    return await useSession(packageId);
  }

  // Usar uma sessão do pacote
  Future<Package?> useSession(String packageId) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Buscar pacote existente
    final existing = kIsWeb
        ? (await _packagesCollection(userId).doc(packageId).get()).data()
        : await _db.getPackageById(packageId);
    if (existing == null) return null;

    final pkg = Package.fromMap(packageId, existing);

    if (pkg.remainingSessions <= 0) {
      throw Exception('Pacote sem sessões restantes.');
    }

    if (pkg.isExpired) {
      throw Exception('Pacote expirado.');
    }

    final newRemaining = pkg.remainingSessions - 1;
    final newStatus = newRemaining == 0 ? 'completed' : pkg.status;

    final updates = <String, dynamic>{
      'remainingSessions': newRemaining,
      'status': newStatus,
      'updatedAt': DateTime.now().toIso8601String(),
      'synced': 0,
    };

    if (kIsWeb) {
      await _packagesCollection(userId).doc(packageId).update(updates);
      DataChangeBus.instance.notify('packages');
      return pkg.copyWith(
        remainingSessions: newRemaining,
        status: newStatus,
      );
    }

    // Atualizar localmente
    await _db.updatePackage(packageId, updates);
    DataChangeBus.instance.notify('packages');

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      final fullData = Map<String, dynamic>.from(existing);
      fullData.addAll(updates);

      await _db.addToSyncQueue(
        operation: 'update',
        tableName: 'packages',
        recordId: packageId,
        data: jsonEncode(fullData),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }

    return pkg.copyWith(
      remainingSessions: newRemaining,
      status: newStatus,
    );
  }

  // Atualizar pacote
  Future<void> updatePackage(
    String id, {
    int? totalSessions,
    int? remainingSessions,
    double? price,
    DateTime? expirationDate,
    String? status,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    Map<String, dynamic>? existing;

    if (kIsWeb) {
      final doc = await _packagesCollection(userId).doc(id).get();
      if (!doc.exists) throw Exception('Pacote não encontrado.');
    } else {
      existing = await _db.getPackageById(id);
      if (existing == null) throw Exception('Pacote não encontrado.');
    }

    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
      'synced': 0,
    };

    if (totalSessions != null) updates['totalSessions'] = totalSessions;
    if (remainingSessions != null) {
      updates['remainingSessions'] = remainingSessions;
    }
    if (price != null) updates['price'] = price;
    if (expirationDate != null) {
      updates['expirationDate'] = expirationDate.toIso8601String();
    }
    if (status != null) updates['status'] = status;

    if (kIsWeb) {
      await _packagesCollection(userId).doc(id).update(updates);
      DataChangeBus.instance.notify('packages');
      return;
    }

    // Atualizar localmente
    await _db.updatePackage(id, updates);
    DataChangeBus.instance.notify('packages');

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      final fullData = Map<String, dynamic>.from(existing!);
      fullData.addAll(updates);

      await _db.addToSyncQueue(
        operation: 'update',
        tableName: 'packages',
        recordId: id,
        data: jsonEncode(fullData),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }
  }

  // Marcar pacote como expirado
  Future<void> expirePackage(String id) async {
    await updatePackage(id, status: 'expired');
  }

  // Marcar pacote como completo (todas as sessões usadas)
  Future<void> completePackage(String id) async {
    await updatePackage(id, status: 'completed', remainingSessions: 0);
  }

  // Verificar se cliente tem pacote ativo
  Future<bool> hasActivePackage(String clientId) async {
    final package = await getActivePackage(clientId);
    return package != null;
  }

  // Deletar pacote (compatibilidade com código antigo)
  Future<void> deletePackage(String clientId, String packageId) async {
    await deletePackageById(packageId);
  }

  // Deletar pacote permanentemente
  Future<void> deletePackageById(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    if (kIsWeb) {
      await _packagesCollection(userId).doc(id).update({
        'status': 'deleted',
        'deletedAt': DateTime.now().toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      });
      DataChangeBus.instance.notify('packages');
      return;
    }

    // Marcar como deletado (soft delete)
    await _db.markPackageDeleted(id);

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      await _db.addToSyncQueue(
        operation: 'delete',
        tableName: 'packages',
        recordId: id,
        data: jsonEncode({'id': id}),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }
  }

  // Buscar pacotes que estão acabando (2 ou menos sessões)
  Future<List<Package>> getLowPackages() async {
    final packages = await getPackages();
    return packages.where((p) => p.isLow && p.isActive).toList();
  }

  // Buscar pacotes expirados
  Future<List<Package>> getExpiredPackages() async {
    final packages = await getPackages();
    return packages.where((p) => p.isExpired).toList();
  }

  // Verificar e atualizar status de pacotes expirados
  Future<void> checkAndUpdateExpiredPackages() async {
    final packages = await getPackages();
    for (final pkg in packages) {
      if (pkg.status == 'active' && pkg.isExpired) {
        await expirePackage(pkg.id);
      }
    }
  }
}
