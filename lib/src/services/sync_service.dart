import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import '../database/database_helper.dart';
import 'auth_service.dart';

enum SyncStatus { idle, syncing, error }

class SyncService {
  SyncService._();
  static final instance = SyncService._();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService.instance;
  final Connectivity _connectivity = Connectivity();

  StreamController<SyncStatus> _statusController = StreamController.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  Timer? _syncTimer;
  StreamSubscription? _connectivitySubscription;
  bool _isOnline = true;

  // Inicializar sincronização
  Future<void> initialize() async {
    // Verificar conectividade inicial
    final connectivityResult = await _connectivity.checkConnectivity();
    _isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
        connectivityResult.contains(ConnectivityResult.wifi);

    // Monitorar mudanças de conectividade
    _connectivitySubscription = _connectivity.onConnectivityChanged.listen((results) {
      final wasOnline = _isOnline;
      _isOnline = results.contains(ConnectivityResult.mobile) ||
          results.contains(ConnectivityResult.wifi);

      // Se voltou online, sincronizar imediatamente
      if (!wasOnline && _isOnline) {
        syncAll();
      }
    });

    // Sincronizar periodicamente (a cada 30 segundos quando online)
    _syncTimer = Timer.periodic(Duration(seconds: 30), (_) {
      if (_isOnline && _auth.currentUser != null) {
        syncAll();
      }
    });

    // Sincronização inicial
    if (_isOnline) {
      await syncAll();
    }
  }

  // Sincronizar todos os dados
  Future<void> syncAll() async {
    if (_currentStatus == SyncStatus.syncing) return;
    if (_auth.currentUser == null) return;

    try {
      _updateStatus(SyncStatus.syncing);

      // 1. Processar fila de sincronização (operações offline)
      await _processSyncQueue();

      // 2. Sincronizar registros não sincronizados
      await _syncUnsyncedRecords();

      // 3. Baixar dados do Firestore (pull)
      await _pullFromFirestore();

      _updateStatus(SyncStatus.idle);
    } catch (e) {
      print('Erro na sincronização: $e');
      _updateStatus(SyncStatus.error);
    }
  }

  // Processar fila de operações offline
  Future<void> _processSyncQueue() async {
    final queue = await _db.getPendingSyncItems();
    
    for (final item in queue) {
      try {
        final operation = item['operation'] as String;
        final tableName = item['tableName'] as String;
        final recordId = item['recordId'] as String;
        final data = jsonDecode(item['data'] as String) as Map<String, dynamic>;

        await _executeSyncOperation(operation, tableName, recordId, data);
        
        // Remover da fila após sucesso
        await _db.removeSyncItem(item['id'] as int);
      } catch (e) {
        print('Erro ao processar item da fila: $e');
        
        // Incrementar contador de tentativas
        final retryCount = item['retryCount'] as int;
        final recordId = item['recordId'] as String;
        if (retryCount < 3) {
          await _db.incrementRetryCount(item['id'] as int);
        } else {
          // Após 3 tentativas, remover da fila (evitar loop infinito)
          await _db.removeSyncItem(item['id'] as int);
          print('Item removido da fila após 3 tentativas: $recordId');
        }
      }
    }
  }

  // Executar operação de sincronização no Firestore
  Future<void> _executeSyncOperation(
    String operation,
    String tableName,
    String recordId,
    Map<String, dynamic> data,
  ) async {
    final userId = _auth.currentUser!.uid;
    final collection = _getFirestoreCollection(tableName, userId);

    switch (operation) {
      case 'create':
      case 'update':
        await collection.doc(recordId).set(data, SetOptions(merge: true));
        break;
      case 'delete':
        await collection.doc(recordId).delete();
        break;
    }
  }

  // Sincronizar registros locais não sincronizados
  Future<void> _syncUnsyncedRecords() async {
    final tables = ['clients', 'sessions', 'payments', 'packages'];

    for (final table in tables) {
      final unsyncedRecords = await _db.getUnsyncedRecords(table);

      for (final record in unsyncedRecords) {
        try {
          final id = record['id'] as String;
          final userId = record['userId'] as String;
          final deleted = record['deleted'] == 1;

          final collection = _getFirestoreCollection(table, userId);

          if (deleted) {
            // Deletar no Firestore
            await collection.doc(id).delete();
          } else {
            // Criar/atualizar no Firestore
            final data = Map<String, dynamic>.from(record);
            data.remove('synced');
            data.remove('lastModified');
            data.remove('deleted');

            await collection.doc(id).set(data, SetOptions(merge: true));
          }

          // Marcar como sincronizado
          await _db.markAsSynced(table, id);
        } catch (e) {
          print('Erro ao sincronizar registro $table: $e');
        }
      }
    }
  }

  // Baixar dados do Firestore
  Future<void> _pullFromFirestore() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return;

    try {
      // Sincronizar clientes
      await _pullCollection('clients', userId);
      
      // Sincronizar sessões
      await _pullCollection('sessions', userId);
      
      // Sincronizar pagamentos
      await _pullCollection('payments', userId);
      
      // Sincronizar pacotes
      await _pullCollection('packages', userId);
    } catch (e) {
      print('Erro ao baixar dados do Firestore: $e');
    }
  }

  // Baixar uma coleção do Firestore
  Future<void> _pullCollection(String tableName, String userId) async {
    final collection = _getFirestoreCollection(tableName, userId);
    final snapshot = await collection.get();

    for (final doc in snapshot.docs) {
      try {
        final data = doc.data();
        final id = doc.id;

        // Verificar se já existe localmente
        final existingRecord = await _getLocalRecord(tableName, id);

        if (existingRecord == null) {
          // Inserir novo registro
          final localData = Map<String, dynamic>.from(data);
          localData['id'] = id;
          localData['synced'] = 1;
          localData['lastModified'] = DateTime.now().toIso8601String();
          localData['deleted'] = 0;

          await _insertLocalRecord(tableName, localData);
        } else {
          // Verificar timestamp e atualizar se necessário
          final localModified = DateTime.parse(existingRecord['lastModified'] as String);
          final remoteModified = data['createdAt'] != null
              ? DateTime.parse(data['createdAt'] as String)
              : DateTime.now();

          // Firestore vence conflitos (última gravação)
          if (remoteModified.isAfter(localModified) || existingRecord['synced'] == 1) {
            final localData = Map<String, dynamic>.from(data);
            localData['synced'] = 1;
            localData['lastModified'] = DateTime.now().toIso8601String();
            localData['deleted'] = 0;

            await _updateLocalRecord(tableName, id, localData);
          }
        }
      } catch (e) {
        print('Erro ao processar documento do Firestore: $e');
      }
    }
  }

  // Helpers para operações locais
  Future<Map<String, dynamic>?> _getLocalRecord(String tableName, String id) async {
    switch (tableName) {
      case 'clients':
        return await _db.getClientById(id);
      case 'sessions':
        return await _db.getSessionById(id);
      case 'payments':
        return await _db.getPaymentById(id);
      case 'packages':
        return await _db.getPackageById(id);
      default:
        return null;
    }
  }

  Future<void> _insertLocalRecord(String tableName, Map<String, dynamic> data) async {
    switch (tableName) {
      case 'clients':
        await _db.insertClient(data);
        break;
      case 'sessions':
        await _db.insertSession(data);
        break;
      case 'payments':
        await _db.insertPayment(data);
        break;
      case 'packages':
        await _db.insertPackage(data);
        break;
    }
  }

  Future<void> _updateLocalRecord(
    String tableName,
    String id,
    Map<String, dynamic> data,
  ) async {
    switch (tableName) {
      case 'clients':
        await _db.updateClient(id, data);
        break;
      case 'sessions':
        await _db.updateSession(id, data);
        break;
      case 'payments':
        await _db.updatePayment(id, data);
        break;
      case 'packages':
        await _db.updatePackage(id, data);
        break;
    }
  }

  // Obter referência da coleção do Firestore
  CollectionReference<Map<String, dynamic>> _getFirestoreCollection(
    String tableName,
    String userId,
  ) {
    return _firestore.collection('users').doc(userId).collection(tableName);
  }

  // Atualizar status
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  // Verificar se está online
  bool get isOnline => _isOnline;

  // Limpar dados ao fazer logout
  Future<void> clearData() async {
    await _db.clearAllData();
  }

  // Dispose
  void dispose() {
    _syncTimer?.cancel();
    _connectivitySubscription?.cancel();
    _statusController.close();
  }
}
