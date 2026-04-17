import 'dart:async';
import 'dart:convert';
import 'package:uuid/uuid.dart';
import '../models/client.dart';
import '../database/database_helper.dart';
import 'auth_service.dart';
import 'data_change_bus.dart';
import 'incremental_sync_service.dart';

class ClientService {
  ClientService._();
  static final instance = ClientService._();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final AuthService _auth = AuthService.instance;
  final IncrementalSyncService _sync = IncrementalSyncService.instance;
  final Uuid _uuid = const Uuid();

  // Stream reativa de todos os clientes. Reemite apenas quando dados mudam.
  Stream<List<Client>> getClientsStream() async* {
    yield await getClients();
    await for (final _ in DataChangeBus.instance.streamFor('clients')) {
      yield await getClients();
    }
  }

  // Buscar todos os clientes do banco local
  Future<List<Client>> getClients() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];

    final maps = await _db.getAllClients(userId);
    return maps.map((map) => Client.fromMap(map['id'] as String, map)).toList();
  }

  // Buscar cliente por ID
  Future<Client?> getClientById(String id) async {
    final map = await _db.getClientById(id);
    if (map == null) return null;
    return Client.fromMap(map['id'] as String, map);
  }

  // Criar cliente
  Future<String> createClient({
    required String name,
    required String phone,
    String? notes,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Verificar limite do plano
    await _checkClientLimit();

    // Gerar ID único
    final id = _uuid.v4();

    final now = DateTime.now();
    final clientData = {
      'id': id,
      'userId': userId,
      'name': name,
      'phone': phone,
      'notes': notes ?? '',
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'deletedAt': null,
      'status': 'active',
      'synced': _sync.isOnline ? 1 : 0,
      'deleted': 0,
    };

    // Salvar localmente
    await _db.insertClient(clientData);
    DataChangeBus.instance.notify('clients');

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      await _db.addToSyncQueue(
        operation: 'create',
        tableName: 'clients',
        recordId: id,
        data: jsonEncode(clientData),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }

    return id;
  }

  // Atualizar cliente
  Future<void> updateClient(
    String id, {
    String? name,
    String? phone,
    String? notes,
    String? status,
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Buscar cliente existente
    final existing = await _db.getClientById(id);
    if (existing == null) throw Exception('Cliente não encontrado.');

    final now = DateTime.now();
    final updates = <String, dynamic>{
      'updatedAt': now.toIso8601String(),
      'synced': 0,
    };

    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (notes != null) updates['notes'] = notes;
    if (status != null) updates['status'] = status;

    // Atualizar localmente
    await _db.updateClient(id, updates);
    DataChangeBus.instance.notify('clients');

    // Sincronizar se online
    if (_sync.isOnline) {
      _sync.syncAll();
    }
  }

  // Arquivar cliente (soft delete - mantém histórico financeiro)
  Future<void> archiveClient(String id) async {
    await updateClient(id, status: 'inactive');
  }

  // Reativar cliente arquivado
  Future<void> reactivateClient(String id) async {
    await updateClient(id, status: 'active');
  }

  // Deletar cliente permanentemente
  Future<void> deleteClient(String id) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Marcar como deletado (soft delete)
    await _db.markClientDeleted(id);
    DataChangeBus.instance.notify('clients');

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      await _db.addToSyncQueue(
        operation: 'delete',
        tableName: 'clients',
        recordId: id,
        data: jsonEncode({'id': id}),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }
  }

  // Buscar clientes por nome ou telefone
  Future<List<Client>> searchClients(String query) async {
    final clients = await getClients();
    if (query.isEmpty) return clients;

    final lowerQuery = query.toLowerCase();
    return clients
        .where((client) =>
            client.name.toLowerCase().contains(lowerQuery) ||
            client.phone.contains(query))
        .toList();
  }

  // Contar clientes do usuário
  Future<int> getClientCount() async {
    final clients = await getClients();
    return clients.where((c) => c.isActive).length;
  }

  // Verificar limite de clientes do plano
  Future<void> _checkClientLimit() async {
    final userData = await _auth.getCurrentUserData();
    if (userData == null) throw Exception('Dados do usuário não encontrados.');

    final currentCount = await getClientCount();
    if (currentCount >= userData.clientLimit) {
      throw Exception(
          'Limite de ${userData.clientLimit} clientes atingido. Faça upgrade do seu plano.');
    }
  }
}
