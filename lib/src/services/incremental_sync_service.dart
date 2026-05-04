import 'dart:async';
import 'dart:convert';
import 'dart:developer' as developer;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:sqflite/sqflite.dart';
import '../database/database_helper.dart';
import 'auth_service.dart';
import 'data_change_bus.dart';

/// Sistema de logging profissional. Usa `dart:developer` em produção para
/// evitar o lint `avoid_print`.
class AppLogger {
  static void info(String message, [String? context]) =>
      _log('INFO', message, context);

  static void error(String message,
      [Object? error, StackTrace? stack, String? context]) {
    _log('ERROR', message, context, error: error, stackTrace: stack);
  }

  static void warning(String message, [String? context]) =>
      _log('WARNING', message, context);

  static void debug(String message, [String? context]) =>
      _log('DEBUG', message, context);

  static void _log(
    String level,
    String message,
    String? context, {
    Object? error,
    StackTrace? stackTrace,
  }) {
    final contextStr = context != null ? '[$context] ' : '';
    developer.log(
      '$contextStr$message',
      name: 'theraflow.sync',
      level: _levelValue(level),
      error: error,
      stackTrace: stackTrace,
    );
  }

  static int _levelValue(String level) {
    switch (level) {
      case 'ERROR':
        return 1000;
      case 'WARNING':
        return 900;
      case 'INFO':
        return 800;
      default:
        return 500;
    }
  }
}

enum SyncStatus { idle, syncing, error }

/// Serviço de sincronização incremental profissional
/// 
/// Implementa:
/// - Pull incremental com updatedAt
/// - Push com confirmação server-side
/// - Soft delete (deletedAt)
/// - Resolução de conflitos (last-write-wins)
/// - Trigger por conectividade e fila pendente
class IncrementalSyncService {
  IncrementalSyncService._();
  static final instance = IncrementalSyncService._();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService.instance;
  final Connectivity _connectivity = Connectivity();

  final StreamController<SyncStatus> _statusController =
      StreamController.broadcast();
  Stream<SyncStatus> get statusStream => _statusController.stream;
  SyncStatus _currentStatus = SyncStatus.idle;
  SyncStatus get currentStatus => _currentStatus;

  StreamSubscription? _connectivitySubscription;
  bool _isOnline = true;
  bool get isOnline => _isOnline;

  /// Inicializar sincronização
  Future<void> initialize() async {
    AppLogger.info('Inicializando serviço de sincronização', 'IncrementalSyncService');

    // Verificar conectividade inicial. `connectivity_plus` pode lançar em
    // plataformas sem suporte (ex.: testes unitários, desktop sem D-Bus).
    try {
      final connectivityResult = await _connectivity.checkConnectivity();
      _isOnline = connectivityResult.contains(ConnectivityResult.mobile) ||
          connectivityResult.contains(ConnectivityResult.wifi);
    } catch (e, st) {
      AppLogger.warning(
        'Falha ao consultar conectividade inicial; assumindo ONLINE. $e',
        'IncrementalSyncService',
      );
      AppLogger.error('connectivity checkConnectivity', e, st);
      _isOnline = true;
    }

    AppLogger.info('Status de conectividade: ${_isOnline ? "ONLINE" : "OFFLINE"}', 'IncrementalSyncService');

    // Monitorar mudanças de conectividade com proteção contra erros do stream.
    try {
      _connectivitySubscription =
          _connectivity.onConnectivityChanged.listen((results) {
        final wasOnline = _isOnline;
        _isOnline = results.contains(ConnectivityResult.mobile) ||
            results.contains(ConnectivityResult.wifi);

        AppLogger.info(
          'Mudança de conectividade: ${_isOnline ? "ONLINE" : "OFFLINE"}',
          'IncrementalSyncService',
        );

        if (!wasOnline && _isOnline) {
          AppLogger.info(
            'Reconectado - iniciando sincronização automática',
            'IncrementalSyncService',
          );
          syncAll();
        }
      }, onError: (Object e, StackTrace st) {
        AppLogger.error('connectivity stream error', e, st);
      });
    } catch (e, st) {
      AppLogger.error('Falha ao registrar listener de conectividade', e, st);
    }

    // Sincronização inicial se online
    if (_isOnline) {
      await syncAll();
    }
  }

  /// Sincronizar todos os dados (push + pull)
  Future<void> syncAll() async {
    if (_currentStatus == SyncStatus.syncing) {
      AppLogger.warning('Sincronização já em andamento - ignorando requisição', 'IncrementalSyncService');
      return;
    }
    
    if (_auth.currentUser == null) {
      AppLogger.warning('Usuário não autenticado - sincronização cancelada', 'IncrementalSyncService');
      return;
    }

    if (!_isOnline) {
      AppLogger.info('Offline - sincronização adiada', 'IncrementalSyncService');
      return;
    }

    try {
      _updateStatus(SyncStatus.syncing);
      AppLogger.info('Iniciando sincronização completa', 'IncrementalSyncService');

      // 1. Push: Enviar mudanças locais para o servidor
      await _pushLocalChanges();

      // 2. Pull: Baixar mudanças do servidor
      await _pullServerChanges();

      _updateStatus(SyncStatus.idle);
      AppLogger.info('Sincronização completa bem-sucedida', 'IncrementalSyncService');
    } catch (e, stack) {
      AppLogger.error('Erro na sincronização completa', e, stack, 'IncrementalSyncService');
      _updateStatus(SyncStatus.error);
    }
  }

  /// Push: Enviar mudanças locais para o servidor
  Future<void> _pushLocalChanges() async {
    final userId = _auth.currentUser!.uid;
    final tables = ['clients', 'sessions', 'payments', 'packages'];

    AppLogger.info('Push: Enviando mudanças locais', 'IncrementalSyncService');

    for (final table in tables) {
      try {
        final unsyncedRecords = await _db.getUnsyncedRecords(table);
        
        if (unsyncedRecords.isEmpty) {
          AppLogger.debug('Push: Nenhum registro não sincronizado em $table', 'IncrementalSyncService');
          continue;
        }

        AppLogger.info('Push: Enviando ${unsyncedRecords.length} registros de $table', 'IncrementalSyncService');

        for (final record in unsyncedRecords) {
          try {
            await _pushRecord(table, record, userId);
            await _db.markAsSynced(table, record['id'] as String);
          } catch (e, stack) {
            AppLogger.error('Push: Erro ao enviar registro ${record['id']} de $table', e, stack, 'IncrementalSyncService');
          }
        }
      } catch (e, stack) {
        AppLogger.error('Push: Erro ao processar tabela $table', e, stack, 'IncrementalSyncService');
      }
    }
  }

  /// Push individual de um registro
  Future<void> _pushRecord(String table, Map<String, dynamic> record, String userId) async {
    final id = record['id'] as String;
    final collection = _getFirestoreCollection(table, userId);
    final deletedAt = record['deletedAt'] as String?;

    // Preparar dados para Firestore
    final data = Map<String, dynamic>.from(record);
    data.remove('synced');
    data.remove('lastModified');
    data.remove('deleted');

    // Soft delete: se deletedAt está presente, marcar no Firestore
    if (deletedAt != null) {
      data['deletedAt'] = deletedAt;
      AppLogger.debug('Push: Soft delete de $id em $table', 'IncrementalSyncService');
    }

    // Adicionar/atualizar timestamp server-side
    data['updatedAt'] = FieldValue.serverTimestamp();

    await collection.doc(id).set(data, SetOptions(merge: true));
    AppLogger.debug('Push: Registro $id de $table enviado com sucesso', 'IncrementalSyncService');
  }

  /// Pull: Baixar mudanças do servidor (incremental)
  Future<void> _pullServerChanges() async {
    final userId = _auth.currentUser!.uid;
    final tables = ['clients', 'sessions', 'payments', 'packages'];

    AppLogger.info('Pull: Baixando mudanças do servidor', 'IncrementalSyncService');

    for (final table in tables) {
      try {
        final lastSync = await _db.getLastSyncTimestamp(table);
        
        if (lastSync == null) {
          AppLogger.info('Pull: Primeira sincronização de $table', 'IncrementalSyncService');
        } else {
          AppLogger.info('Pull: Sincronização incremental de $table desde $lastSync', 'IncrementalSyncService');
        }

        await _pullCollection(table, userId, lastSync);

        // Atualizar timestamp da última sincronização
        await _db.setLastSyncTimestamp(table, DateTime.now());
      } catch (e, stack) {
        AppLogger.error('Pull: Erro ao baixar $table', e, stack, 'IncrementalSyncService');
      }
    }

    // Notifica streams reativas (UI) após pull completo.
    DataChangeBus.instance.notifyAll(tables);
  }

  /// Pull individual de uma coleção
  Future<void> _pullCollection(String table, String userId, DateTime? lastSync) async {
    final collection = _getFirestoreCollection(table, userId);
    
    Query<Map<String, dynamic>> query = collection.orderBy('updatedAt');
    
    // Pull incremental: apenas documentos modificados desde a última sincronização
    if (lastSync != null) {
      query = query.where('updatedAt', isGreaterThan: Timestamp.fromDate(lastSync));
    }

    final snapshot = await query.get();
    
    if (snapshot.docs.isEmpty) {
      AppLogger.debug('Pull: Nenhum registro novo em $table', 'IncrementalSyncService');
      return;
    }

    AppLogger.info('Pull: Recebidos ${snapshot.docs.length} registros de $table', 'IncrementalSyncService');

    for (final doc in snapshot.docs) {
      try {
        await _mergeRecord(table, doc.id, doc.data());
      } catch (e, stack) {
        AppLogger.error('Pull: Erro ao mesclar registro ${doc.id} de $table', e, stack, 'IncrementalSyncService');
      }
    }
  }

  /// Colunas válidas por tabela. Campos extras vindos do Firestore são descartados
  /// antes do insert/update no SQLite, evitando DatabaseException por colunas inexistentes.
  static const _tableColumns = <String, Set<String>>{
    'clients': {
      'id', 'userId', 'name', 'phone', 'notes',
      'createdAt', 'updatedAt', 'deletedAt', 'status',
      'goal', 'idealFrequency', 'tags', 'clientStatus',
      'nextAction', 'nextActionDate',
      'synced', 'lastModified', 'deleted',
    },
    'sessions': {
      'id', 'userId', 'clientId', 'dateTime', 'therapyType',
      'status', 'value', 'notes', 'paymentStatus',
      'createdAt', 'updatedAt', 'deletedAt', 'packageId',
      'howClientArrived', 'whatWasDone', 'guidelines', 'nextSteps', 'isDraft',
      'synced', 'lastModified', 'deleted',
    },
    'payments': {
      'id', 'userId', 'sessionId', 'status', 'method', 'value',
      'paidAt', 'createdAt', 'updatedAt', 'deletedAt',
      'synced', 'lastModified', 'deleted',
    },
    'packages': {
      'id', 'userId', 'clientId', 'name',
      'totalSessions', 'remainingSessions', 'price', 'expirationDate',
      'createdAt', 'updatedAt', 'deletedAt', 'status',
      'synced', 'lastModified', 'deleted',
    },
  };

  /// Converte tipos do Firestore para tipos suportados pelo SQLite e remove
  /// campos não presentes no schema da tabela.
  Map<String, dynamic> _sanitizeForSQLite(
      String table, Map<String, dynamic> data) {
    final allowed = _tableColumns[table];
    final result = <String, dynamic>{};
    for (final entry in data.entries) {
      if (allowed != null && !allowed.contains(entry.key)) continue;
      final value = entry.value;
      if (value is Timestamp) {
        result[entry.key] = value.toDate().toIso8601String();
      } else if (value is List) {
        result[entry.key] = jsonEncode(value);
      } else if (value is Map) {
        result[entry.key] = jsonEncode(value);
      } else {
        result[entry.key] = value;
      }
    }
    return result;
  }

  /// Mesclar registro do servidor com banco local (resolução de conflitos)
  Future<void> _mergeRecord(String table, String id, Map<String, dynamic> serverData) async {
    final db = await _db.database;

    final serverUpdatedAt = (serverData['updatedAt'] as Timestamp?)?.toDate();

    // Verificar se registro existe localmente
    final localResults = await db.query(table, where: 'id = ?', whereArgs: [id], limit: 1);

    if (localResults.isEmpty) {
      // Não existe localmente - inserir
      final data = _sanitizeForSQLite(table, Map<String, dynamic>.from(serverData));
      data['id'] = id;
      data['synced'] = 1;
      data['lastModified'] = data['updatedAt'];
      data['deleted'] = data.containsKey('deletedAt') && data['deletedAt'] != null ? 1 : 0;

      await db.insert(table, data, conflictAlgorithm: ConflictAlgorithm.replace);
      AppLogger.debug('Pull: Registro $id de $table inserido', 'IncrementalSyncService');
      return;
    }

    final localData = localResults.first;
    final localUpdatedAt = DateTime.tryParse(localData['updatedAt'] as String? ?? '');

    // Estratégia: Last-Write-Wins
    if (serverUpdatedAt != null && localUpdatedAt != null) {
      if (serverUpdatedAt.isAfter(localUpdatedAt)) {
        // Servidor mais recente - atualizar local
        final data = _sanitizeForSQLite(table, Map<String, dynamic>.from(serverData));
        data['id'] = id;
        data['synced'] = 1;
        data['lastModified'] = data['updatedAt'];
        data['deleted'] = data.containsKey('deletedAt') && data['deletedAt'] != null ? 1 : 0;

        await db.update(table, data, where: 'id = ?', whereArgs: [id]);
        AppLogger.debug('Pull: Registro $id de $table atualizado (servidor mais recente)', 'IncrementalSyncService');
      } else {
        AppLogger.debug('Pull: Registro $id de $table não atualizado (local mais recente)', 'IncrementalSyncService');
      }
    } else {
      // Se não houver timestamp, aplicar servidor
      final data = _sanitizeForSQLite(table, Map<String, dynamic>.from(serverData));
      data['id'] = id;
      data['synced'] = 1;
      data['lastModified'] = data['updatedAt'];
      data['deleted'] = data.containsKey('deletedAt') && data['deletedAt'] != null ? 1 : 0;

      await db.update(table, data, where: 'id = ?', whereArgs: [id]);
      AppLogger.debug('Pull: Registro $id de $table atualizado (sem timestamp local)', 'IncrementalSyncService');
    }
  }

  /// Obter referência da coleção Firestore
  CollectionReference<Map<String, dynamic>> _getFirestoreCollection(String table, String userId) {
    return _firestore.collection('users').doc(userId).collection(table);
  }

  /// Atualizar status de sincronização
  void _updateStatus(SyncStatus status) {
    _currentStatus = status;
    if (!_statusController.isClosed) {
      _statusController.add(status);
    }
  }

  /// Finalizar serviço
  void dispose() {
    _connectivitySubscription?.cancel();
    _statusController.close();
    AppLogger.info('Serviço de sincronização finalizado', 'IncrementalSyncService');
  }
}
