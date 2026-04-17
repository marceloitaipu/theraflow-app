import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../database/database_helper.dart';
import 'auth_service.dart';
import 'data_change_bus.dart';
import 'incremental_sync_service.dart';

class SessionService {
  SessionService._();
  static final instance = SessionService._();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final AuthService _auth = AuthService.instance;
  final IncrementalSyncService _sync = IncrementalSyncService.instance;
  final Uuid _uuid = const Uuid();

  // Stream reativa de todas as sessões. Reemite apenas em mudanças.
  Stream<List<Session>> getSessionsStream() async* {
    yield await getSessions();
    await for (final _ in DataChangeBus.instance.streamFor('sessions')) {
      yield await getSessions();
    }
  }

  // Buscar todas as sessões do banco local
  Future<List<Session>> getSessions() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final maps = await _db.getAllSessions(userId);
    return maps
        .map((map) => Session.fromMap(map['id'] as String, map))
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Stream reativa de sessões de um cliente.
  Stream<List<Session>> getClientSessionsStream(String clientId) async* {
    yield await getClientSessions(clientId);
    await for (final _ in DataChangeBus.instance.streamFor('sessions')) {
      yield await getClientSessions(clientId);
    }
  }

  // Buscar sessões de um cliente
  Future<List<Session>> getClientSessions(String clientId) async {
    final sessions = await getSessions();
    return sessions
        .where((s) => s.clientId == clientId)
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
  }

  // Buscar sessões do dia
  Future<List<Session>> getTodaySessions() async {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final sessions = await getSessions();
    return sessions
        .where((s) =>
            s.dateTime.isAfter(startOfDay) && s.dateTime.isBefore(endOfDay))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Buscar sessões por período
  Future<List<Session>> getSessionsByPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    final sessions = await getSessions();
    return sessions
        .where((s) => s.dateTime.isAfter(start) && s.dateTime.isBefore(end))
        .toList()
      ..sort((a, b) => a.dateTime.compareTo(b.dateTime));
  }

  // Buscar sessão por ID
  Future<Session?> getSessionById(String id) async {
    final map = await _db.getSessionById(id);
    if (map == null) return null;
    return Session.fromMap(map['id'] as String, map);
  }

  // Criar sessão
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
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Gerar ID único
    final id = _uuid.v4();

    final now = DateTime.now();
    final sessionData = {
      'id': id,
      'userId': userId,
      'clientId': clientId,
      'dateTime': dateTime.toIso8601String(),
      'therapyType': therapyType,
      'status': status,
      'value': value,
      'notes': notes ?? '',
      'paymentStatus': paymentStatus,
      'packageId': packageId,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'deletedAt': null,
      'synced': 0,
      'deleted': 0,
    };

    // Salvar localmente
    await _db.insertSession(sessionData);
    DataChangeBus.instance.notify('sessions');

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      await _db.addToSyncQueue(
        operation: 'create',
        tableName: 'sessions',
        recordId: id,
        data: jsonEncode(sessionData),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }

    return id;
  }

  // Atualizar sessão
  Future<void> updateSession(
    String id, {
    DateTime? dateTime,
    String? therapyType,
    String? status,
    double? value,
    String? notes,
    String? paymentStatus,
    String? packageId,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Buscar sessão existente
    final existing = await _db.getSessionById(id);
    if (existing == null) throw Exception('Sessão não encontrada.');

    final updates = <String, dynamic>{
      'updatedAt': DateTime.now().toIso8601String(),
      'synced': 0,
    };

    if (dateTime != null) updates['dateTime'] = dateTime.toIso8601String();
    if (therapyType != null) updates['therapyType'] = therapyType;
    if (status != null) updates['status'] = status;
    if (value != null) updates['value'] = value;
    if (notes != null) updates['notes'] = notes;
    if (paymentStatus != null) updates['paymentStatus'] = paymentStatus;
    if (packageId != null) updates['packageId'] = packageId;

    // Atualizar localmente
    await _db.updateSession(id, updates);
    DataChangeBus.instance.notify('sessions');

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      final fullData = Map<String, dynamic>.from(existing);
      fullData.addAll(updates);

      await _db.addToSyncQueue(
        operation: 'update',
        tableName: 'sessions',
        recordId: id,
        data: jsonEncode(fullData),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }
  }

  // Deletar sessão
  Future<void> deleteSession(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Marcar como deletado (soft delete)
    await _db.markSessionDeleted(id);
    DataChangeBus.instance.notify('sessions');

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      await _db.addToSyncQueue(
        operation: 'delete',
        tableName: 'sessions',
        recordId: id,
        data: jsonEncode({'id': id}),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }
  }

  // Marcar sessão como paga
  Future<void> markAsPaid(String id) async {
    await updateSession(id, paymentStatus: 'pago');
  }

  // Marcar sessão como falta
  Future<void> markAsNoShow(String id) async {
    await updateSession(id, status: 'faltou');
  }

  // Buscar última sessão de um cliente (para ver notas anteriores)
  Future<Session?> getLastSessionByClient(String clientId,
      {String? excludeSessionId}) async {
    final sessions = await getClientSessions(clientId);
    if (sessions.isEmpty) return null;

    // Se temos ID para excluir, buscar a segunda sessão
    if (excludeSessionId != null) {
      final filtered = sessions.where((s) => s.id != excludeSessionId).toList();
      return filtered.isNotEmpty ? filtered.first : null;
    }

    return sessions.first;
  }
}
