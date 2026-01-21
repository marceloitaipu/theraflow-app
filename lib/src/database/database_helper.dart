import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('theraflow.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 2,
      onCreate: _createDB,
      onUpgrade: _upgradeDB,
    );
  }

  Future<void> _upgradeDB(Database db, int oldVersion, int newVersion) async {
    if (oldVersion < 2) {
      // Adicionar campos updatedAt e deletedAt
      await db.execute('ALTER TABLE clients ADD COLUMN updatedAt TEXT');
      await db.execute('ALTER TABLE clients ADD COLUMN deletedAt TEXT');
      await db.execute('ALTER TABLE sessions ADD COLUMN updatedAt TEXT');
      await db.execute('ALTER TABLE sessions ADD COLUMN deletedAt TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN updatedAt TEXT');
      await db.execute('ALTER TABLE payments ADD COLUMN deletedAt TEXT');
      await db.execute('ALTER TABLE packages ADD COLUMN updatedAt TEXT');
      await db.execute('ALTER TABLE packages ADD COLUMN deletedAt TEXT');

      // Criar tabela de metadata para sincronização
      await db.execute('''
        CREATE TABLE sync_metadata (
          id INTEGER PRIMARY KEY AUTOINCREMENT,
          key TEXT UNIQUE NOT NULL,
          value TEXT NOT NULL,
          updatedAt TEXT NOT NULL
        )
      ''');
      
      // Criar índices para os novos campos
      await db.execute('CREATE INDEX idx_clients_updatedAt ON clients(updatedAt)');
      await db.execute('CREATE INDEX idx_sessions_updatedAt ON sessions(updatedAt)');
      await db.execute('CREATE INDEX idx_payments_updatedAt ON payments(updatedAt)');
      await db.execute('CREATE INDEX idx_packages_updatedAt ON packages(updatedAt)');
    }
  }

  Future<void> _createDB(Database db, int version) async {
    const idType = 'TEXT PRIMARY KEY';
    const textType = 'TEXT NOT NULL';
    const textNullable = 'TEXT';
    const intType = 'INTEGER NOT NULL';
    const realType = 'REAL NOT NULL';
    const boolType = 'INTEGER NOT NULL DEFAULT 0';

    // Tabela de Clientes
    await db.execute('''
      CREATE TABLE clients (
        id $idType,
        userId $textType,
        name $textType,
        phone $textType,
        notes TEXT DEFAULT '',
        createdAt $textType,
        updatedAt $textType,
        deletedAt $textNullable,
        status TEXT DEFAULT 'active',
        synced $boolType,
        lastModified $textType,
        deleted $boolType
      )
    ''');

    // Tabela de Sessões
    await db.execute('''
      CREATE TABLE sessions (
        id $idType,
        userId $textType,
        clientId $textType,
        dateTime $textType,
        therapyType $textType,
        sessionStatus $textType,
        value $realType,
        notes TEXT DEFAULT '',
        paymentStatus $textType,
        createdAt $textType,
        updatedAt $textType,
        deletedAt $textNullable,
        packageId $textNullable,
        synced $boolType,
        lastModified $textType,
        deleted $boolType
      )
    ''');

    // Tabela de Pagamentos
    await db.execute('''
      CREATE TABLE payments (
        id $idType,
        userId $textType,
        sessionId $textType,
        paymentStatus $textType,
        method $textType,
        value $realType,
        paidAt $textNullable,
        createdAt $textType,
        updatedAt $textType,
        deletedAt $textNullable,
        synced $boolType,
        lastModified $textType,
        deleted $boolType
      )
    ''');

    // Tabela de Pacotes
    await db.execute('''
      CREATE TABLE packages (
        id $idType,
        userId $textType,
        clientId $textType,
        name $textType,
        totalSessions $intType,
        usedSessions INTEGER DEFAULT 0,
        value $realType,
        expiresAt $textNullable,
        createdAt $textType,
        updatedAt $textType,
        deletedAt $textNullable,
        packageStatus TEXT DEFAULT 'active',
        synced $boolType,
        lastModified $textType,
        deleted $boolType
      )
    ''');

    // Tabela de Fila de Sincronização
    await db.execute('''
      CREATE TABLE sync_queue (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        operation $textType,
        tableName $textType,
        recordId $textType,
        data $textType,
        createdAt $textType,
        retryCount INTEGER DEFAULT 0
      )
    ''');

    // Tabela de Metadata para Sincronização Incremental
    await db.execute('''
      CREATE TABLE sync_metadata (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        key TEXT UNIQUE NOT NULL,
        value TEXT NOT NULL,
        updatedAt TEXT NOT NULL
      )
    ''');

    // Índices para melhorar performance
    await db.execute('CREATE INDEX idx_clients_userId ON clients(userId)');
    await db.execute('CREATE INDEX idx_clients_updatedAt ON clients(updatedAt)');
    await db.execute('CREATE INDEX idx_sessions_userId ON sessions(userId)');
    await db.execute('CREATE INDEX idx_sessions_clientId ON sessions(clientId)');
    await db.execute('CREATE INDEX idx_sessions_updatedAt ON sessions(updatedAt)');
    await db.execute('CREATE INDEX idx_payments_userId ON payments(userId)');
    await db.execute('CREATE INDEX idx_payments_updatedAt ON payments(updatedAt)');
    await db.execute('CREATE INDEX idx_packages_userId ON packages(userId)');
    await db.execute('CREATE INDEX idx_packages_updatedAt ON packages(updatedAt)');
    await db.execute('CREATE INDEX idx_sync_queue_createdAt ON sync_queue(createdAt)');
  }

  // ===== CLIENTS =====

  Future<List<Map<String, dynamic>>> getAllClients(String userId) async {
    final db = await database;
    return await db.query(
      'clients',
      where: 'userId = ? AND deleted = 0',
      whereArgs: [userId],
      orderBy: 'name ASC',
    );
  }

  Future<Map<String, dynamic>?> getClientById(String id) async {
    final db = await database;
    final results = await db.query(
      'clients',
      where: 'id = ? AND deleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertClient(Map<String, dynamic> client) async {
    final db = await database;
    return await db.insert('clients', client);
  }

  Future<int> updateClient(String id, Map<String, dynamic> client) async {
    final db = await database;
    return await db.update(
      'clients',
      client,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markClientDeleted(String id) async {
    final db = await database;
    return await db.update(
      'clients',
      {
        'deleted': 1,
        'synced': 0,
        'lastModified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== SESSIONS =====

  Future<List<Map<String, dynamic>>> getAllSessions(String userId) async {
    final db = await database;
    return await db.query(
      'sessions',
      where: 'userId = ? AND deleted = 0',
      whereArgs: [userId],
      orderBy: 'dateTime DESC',
    );
  }

  Future<Map<String, dynamic>?> getSessionById(String id) async {
    final db = await database;
    final results = await db.query(
      'sessions',
      where: 'id = ? AND deleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getSessionsByClient(
    String userId,
    String clientId,
  ) async {
    final db = await database;
    return await db.query(
      'sessions',
      where: 'userId = ? AND clientId = ? AND deleted = 0',
      whereArgs: [userId, clientId],
      orderBy: 'dateTime DESC',
    );
  }

  Future<int> insertSession(Map<String, dynamic> session) async {
    final db = await database;
    return await db.insert('sessions', session);
  }

  Future<int> updateSession(String id, Map<String, dynamic> session) async {
    final db = await database;
    return await db.update(
      'sessions',
      session,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markSessionDeleted(String id) async {
    final db = await database;
    return await db.update(
      'sessions',
      {
        'deleted': 1,
        'synced': 0,
        'lastModified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== PAYMENTS =====

  Future<List<Map<String, dynamic>>> getAllPayments(String userId) async {
    final db = await database;
    return await db.query(
      'payments',
      where: 'userId = ? AND deleted = 0',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<Map<String, dynamic>?> getPaymentById(String id) async {
    final db = await database;
    final results = await db.query(
      'payments',
      where: 'id = ? AND deleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<int> insertPayment(Map<String, dynamic> payment) async {
    final db = await database;
    return await db.insert('payments', payment);
  }

  Future<int> updatePayment(String id, Map<String, dynamic> payment) async {
    final db = await database;
    return await db.update(
      'payments',
      payment,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markPaymentDeleted(String id) async {
    final db = await database;
    return await db.update(
      'payments',
      {
        'deleted': 1,
        'synced': 0,
        'lastModified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== PACKAGES =====

  Future<List<Map<String, dynamic>>> getAllPackages(String userId) async {
    final db = await database;
    return await db.query(
      'packages',
      where: 'userId = ? AND deleted = 0',
      whereArgs: [userId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<Map<String, dynamic>?> getPackageById(String id) async {
    final db = await database;
    final results = await db.query(
      'packages',
      where: 'id = ? AND deleted = 0',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  Future<List<Map<String, dynamic>>> getPackagesByClient(
    String userId,
    String clientId,
  ) async {
    final db = await database;
    return await db.query(
      'packages',
      where: 'userId = ? AND clientId = ? AND deleted = 0',
      whereArgs: [userId, clientId],
      orderBy: 'createdAt DESC',
    );
  }

  Future<int> insertPackage(Map<String, dynamic> package) async {
    final db = await database;
    return await db.insert('packages', package);
  }

  Future<int> updatePackage(String id, Map<String, dynamic> package) async {
    final db = await database;
    return await db.update(
      'packages',
      package,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> markPackageDeleted(String id) async {
    final db = await database;
    return await db.update(
      'packages',
      {
        'deleted': 1,
        'synced': 0,
        'lastModified': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== SYNC QUEUE =====

  Future<int> addToSyncQueue({
    required String operation,
    required String tableName,
    required String recordId,
    required String data,
  }) async {
    final db = await database;
    return await db.insert('sync_queue', {
      'operation': operation,
      'tableName': tableName,
      'recordId': recordId,
      'data': data,
      'createdAt': DateTime.now().toIso8601String(),
      'retryCount': 0,
    });
  }

  Future<List<Map<String, dynamic>>> getPendingSyncItems() async {
    final db = await database;
    return await db.query(
      'sync_queue',
      orderBy: 'createdAt ASC',
    );
  }

  Future<int> removeSyncItem(int id) async {
    final db = await database;
    return await db.delete(
      'sync_queue',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<int> incrementRetryCount(int id) async {
    final db = await database;
    return await db.rawUpdate(
      'UPDATE sync_queue SET retryCount = retryCount + 1 WHERE id = ?',
      [id],
    );
  }

  // ===== REGISTROS NÃO SINCRONIZADOS =====

  Future<List<Map<String, dynamic>>> getUnsyncedRecords(String tableName) async {
    final db = await database;
    return await db.query(
      tableName,
      where: 'synced = 0',
    );
  }

  Future<int> markAsSynced(String tableName, String id) async {
    final db = await database;
    return await db.update(
      tableName,
      {'synced': 1},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  // ===== SYNC METADATA =====

  /// Salva ou atualiza o timestamp da última sincronização para uma entidade
  Future<void> setLastSyncTimestamp(String entity, DateTime timestamp) async {
    final db = await database;
    final key = 'lastSync_$entity';
    await db.insert(
      'sync_metadata',
      {
        'key': key,
        'value': timestamp.toIso8601String(),
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtém o timestamp da última sincronização para uma entidade
  Future<DateTime?> getLastSyncTimestamp(String entity) async {
    final db = await database;
    final key = 'lastSync_$entity';
    final results = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    final value = results.first['value'] as String;
    return DateTime.parse(value);
  }

  /// Salva metadado genérico
  Future<void> setSyncMetadata(String key, String value) async {
    final db = await database;
    await db.insert(
      'sync_metadata',
      {
        'key': key,
        'value': value,
        'updatedAt': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  /// Obtém metadado genérico
  Future<String?> getSyncMetadata(String key) async {
    final db = await database;
    final results = await db.query(
      'sync_metadata',
      where: 'key = ?',
      whereArgs: [key],
      limit: 1,
    );
    
    if (results.isEmpty) return null;
    return results.first['value'] as String;
  }

  // ===== LIMPAR DADOS =====

  Future<void> clearAllData() async {
    final db = await database;
    await db.delete('clients');
    await db.delete('sessions');
    await db.delete('payments');
    await db.delete('packages');
    await db.delete('sync_queue');
    await db.delete('sync_metadata');
  }

  Future<void> close() async {
    final db = await database;
    await db.close();
  }
}
