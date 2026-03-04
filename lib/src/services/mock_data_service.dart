/// Serviço de dados mock para testes sem Firebase
/// Armazena todos os dados em memória
///
/// Suporta arquitetura multi-tenant com business entity.
/// Dados agora são organizados por businessId.
class MockDataService {
  MockDataService._();
  static final instance = MockDataService._();

  // Usuários cadastrados (email -> dados)
  final Map<String, MockUser> _users = {};
  
  // Dados por usuário (legacy)
  final Map<String, List<Map<String, dynamic>>> _clients = {};
  final Map<String, List<Map<String, dynamic>>> _sessions = {};
  final Map<String, Map<String, List<Map<String, dynamic>>>> _packages = {};

  // ========== MULTI-TENANT DATA ==========
  // Businesses
  final Map<String, Map<String, dynamic>> _businesses = {};
  
  // Dados por businessId
  final Map<String, List<Map<String, dynamic>>> _bizClients = {};
  final Map<String, List<Map<String, dynamic>>> _bizAppointments = {};
  final Map<String, List<Map<String, dynamic>>> _bizServices = {};
  final Map<String, List<Map<String, dynamic>>> _bizTransactions = {};
  final Map<String, Map<String, List<Map<String, dynamic>>>> _bizPackages = {};

  // Usuário logado atual
  MockUser? _currentUser;
  MockUser? get currentUser => _currentUser;

  // ========== AUTH ==========

  Future<MockUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (email.isEmpty) throw Exception('E-mail é obrigatório.');
    if (password.length < 6) throw Exception('Senha deve ter ao menos 6 caracteres.');
    if (name.isEmpty) throw Exception('Nome é obrigatório.');
    
    if (_users.containsKey(email)) {
      throw Exception('E-mail já cadastrado.');
    }

    final user = MockUser(
      uid: 'user_${DateTime.now().millisecondsSinceEpoch}',
      email: email,
      name: name,
      plan: 'free',
      createdAt: DateTime.now(),
      onboardingCompleted: false,
    );

    _users[email] = user;
    _currentUser = user;
    _clients[user.uid] = [];
    _sessions[user.uid] = [];
    _packages[user.uid] = {};

    return user;
  }

  Future<MockUser> signIn({
    required String email,
    required String password,
  }) async {
    await Future.delayed(const Duration(milliseconds: 500));
    
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Informe e-mail e senha.');
    }

    final user = _users[email];
    if (user == null) {
      throw Exception('Usuário não encontrado.');
    }

    _currentUser = user;
    return user;
  }

  Future<void> signOut() async {
    await Future.delayed(const Duration(milliseconds: 200));
    _currentUser = null;
  }

  Future<void> updateUserData(Map<String, dynamic> data) async {
    if (_currentUser == null) return;
    
    _currentUser = _currentUser!.copyWith(
      name: data['name'] as String? ?? _currentUser!.name,
      plan: data['plan'] as String? ?? _currentUser!.plan,
      onboardingCompleted: data['onboardingCompleted'] as bool? ?? _currentUser!.onboardingCompleted,
    );
    _users[_currentUser!.email] = _currentUser!;
  }

  // ========== CLIENTES ==========

  List<Map<String, dynamic>> getClients() {
    if (_currentUser == null) return [];
    return _clients[_currentUser!.uid] ?? [];
  }

  Map<String, dynamic>? getClientById(String id) {
    return getClients().where((c) => c['id'] == id).firstOrNull;
  }

  String addClient(Map<String, dynamic> data) {
    if (_currentUser == null) throw Exception('Não autenticado');
    
    final id = 'client_${DateTime.now().millisecondsSinceEpoch}';
    final client = {...data, 'id': id};
    _clients[_currentUser!.uid]!.add(client);
    _packages[_currentUser!.uid]![id] = [];
    return id;
  }

  void updateClient(String id, Map<String, dynamic> data) {
    if (_currentUser == null) return;
    final clients = _clients[_currentUser!.uid]!;
    final index = clients.indexWhere((c) => c['id'] == id);
    if (index >= 0) {
      clients[index] = {...clients[index], ...data};
    }
  }

  void deleteClient(String id) {
    if (_currentUser == null) return;
    _clients[_currentUser!.uid]!.removeWhere((c) => c['id'] == id);
  }

  /// Arquiva cliente (soft delete) - mantém histórico financeiro
  void archiveClient(String id) {
    updateClient(id, {'status': 'inactive'});
  }

  /// Reativa cliente arquivado
  void reactivateClient(String id) {
    updateClient(id, {'status': 'active'});
  }

  /// Retorna apenas clientes ativos
  List<Map<String, dynamic>> getActiveClients() {
    return getClients().where((c) => 
      (c['status'] ?? 'active') == 'active'
    ).toList();
  }

  // ========== SESSÕES ==========

  List<Map<String, dynamic>> getSessions() {
    if (_currentUser == null) return [];
    return _sessions[_currentUser!.uid] ?? [];
  }

  List<Map<String, dynamic>> getSessionsByClient(String clientId) {
    return getSessions().where((s) => s['clientId'] == clientId).toList();
  }

  List<Map<String, dynamic>> getTodaySessions() {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);
    
    return getSessions().where((s) {
      final dt = DateTime.parse(s['dateTime'] as String);
      return dt.isAfter(startOfDay) && dt.isBefore(endOfDay);
    }).toList()
      ..sort((a, b) => (a['dateTime'] as String).compareTo(b['dateTime'] as String));
  }

  Map<String, dynamic>? getSessionById(String id) {
    return getSessions().where((s) => s['id'] == id).firstOrNull;
  }

  String addSession(Map<String, dynamic> data) {
    if (_currentUser == null) throw Exception('Não autenticado');
    
    final id = 'session_${DateTime.now().millisecondsSinceEpoch}';
    final session = {...data, 'id': id, 'userId': _currentUser!.uid};
    _sessions[_currentUser!.uid]!.add(session);
    return id;
  }

  void updateSession(String id, Map<String, dynamic> data) {
    if (_currentUser == null) return;
    final sessions = _sessions[_currentUser!.uid]!;
    final index = sessions.indexWhere((s) => s['id'] == id);
    if (index >= 0) {
      sessions[index] = {...sessions[index], ...data};
    }
  }

  void deleteSession(String id) {
    if (_currentUser == null) return;
    _sessions[_currentUser!.uid]!.removeWhere((s) => s['id'] == id);
  }

  // ========== PACOTES ==========

  List<Map<String, dynamic>> getPackages(String clientId) {
    if (_currentUser == null) return [];
    return _packages[_currentUser!.uid]?[clientId] ?? [];
  }

  Map<String, dynamic>? getActivePackage(String clientId) {
    final packages = getPackages(clientId);
    return packages.where((p) => 
      p['status'] == 'active' && (p['remainingSessions'] as int) > 0
    ).firstOrNull;
  }

  String addPackage(String clientId, Map<String, dynamic> data) {
    if (_currentUser == null) throw Exception('Não autenticado');
    
    final id = 'pkg_${DateTime.now().millisecondsSinceEpoch}';
    final pkg = {...data, 'id': id, 'clientId': clientId};
    
    _packages[_currentUser!.uid] ??= {};
    _packages[_currentUser!.uid]![clientId] ??= [];
    _packages[_currentUser!.uid]![clientId]!.add(pkg);
    
    return id;
  }

  void decrementPackage(String clientId, String packageId) {
    if (_currentUser == null) return;
    final packages = _packages[_currentUser!.uid]?[clientId];
    if (packages == null) return;
    
    final index = packages.indexWhere((p) => p['id'] == packageId);
    if (index >= 0) {
      final remaining = (packages[index]['remainingSessions'] as int) - 1;
      packages[index]['remainingSessions'] = remaining;
      if (remaining == 0) {
        packages[index]['status'] = 'completed';
      }
    }
  }

  // ========== FINANCEIRO ==========

  List<Map<String, dynamic>> getSessionsByPeriod(DateTime start, DateTime end) {
    return getSessions().where((s) {
      final dt = DateTime.parse(s['dateTime'] as String);
      return dt.isAfter(start) && dt.isBefore(end);
    }).toList();
  }

  List<Map<String, dynamic>> getPendingSessions() {
    return getSessions().where((s) => s['paymentStatus'] == 'pendente').toList();
  }

  // Dados de exemplo para demonstração
  void loadDemoData() {
    if (_currentUser == null) return;
    
    final userId = _currentUser!.uid;
    
    // Clientes de exemplo
    _clients[userId] = [
      {
        'id': 'client_1',
        'name': 'Maria Silva',
        'phone': '(11) 99999-1111',
        'notes': 'Dor lombar crônica',
        'createdAt': DateTime.now().subtract(const Duration(days: 30)).toIso8601String(),
      },
      {
        'id': 'client_2',
        'name': 'João Santos',
        'phone': '(11) 99999-2222',
        'notes': 'Relaxamento e estresse',
        'createdAt': DateTime.now().subtract(const Duration(days: 20)).toIso8601String(),
      },
      {
        'id': 'client_3',
        'name': 'Ana Oliveira',
        'phone': '(11) 99999-3333',
        'notes': 'Pós-operatório joelho',
        'createdAt': DateTime.now().subtract(const Duration(days: 10)).toIso8601String(),
      },
    ];

    // Sessões de exemplo (incluindo hoje)
    final now = DateTime.now();
    _sessions[userId] = [
      {
        'id': 'session_1',
        'userId': userId,
        'clientId': 'client_1',
        'dateTime': DateTime(now.year, now.month, now.day, 9, 0).toIso8601String(),
        'therapyType': 'Massoterapia',
        'status': 'confirmado',
        'value': 150.0,
        'paymentStatus': 'pendente',
        'notes': '',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 'session_2',
        'userId': userId,
        'clientId': 'client_2',
        'dateTime': DateTime(now.year, now.month, now.day, 11, 0).toIso8601String(),
        'therapyType': 'Relaxante',
        'status': 'confirmado',
        'value': 180.0,
        'paymentStatus': 'pago',
        'notes': '',
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 'session_3',
        'userId': userId,
        'clientId': 'client_3',
        'dateTime': DateTime(now.year, now.month, now.day, 14, 30).toIso8601String(),
        'therapyType': 'Fisioterapia',
        'status': 'confirmado',
        'value': 200.0,
        'paymentStatus': 'pendente',
        'notes': '',
        'createdAt': now.toIso8601String(),
      },
      // Sessões do mês passado
      {
        'id': 'session_old_1',
        'userId': userId,
        'clientId': 'client_1',
        'dateTime': now.subtract(const Duration(days: 7)).toIso8601String(),
        'therapyType': 'Massoterapia',
        'status': 'realizada',
        'value': 150.0,
        'paymentStatus': 'pago',
        'notes': 'Paciente relatou melhora',
        'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 'session_old_2',
        'userId': userId,
        'clientId': 'client_2',
        'dateTime': now.subtract(const Duration(days: 5)).toIso8601String(),
        'therapyType': 'Relaxante',
        'status': 'realizada',
        'value': 180.0,
        'paymentStatus': 'pago',
        'notes': '',
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
    ];

    // Pacotes de exemplo
    _packages[userId] = {
      'client_1': [
        {
          'id': 'pkg_1',
          'clientId': 'client_1',
          'totalSessions': 10,
          'remainingSessions': 7,
          'price': 1200.0,
          'status': 'active',
          'createdAt': now.subtract(const Duration(days: 15)).toIso8601String(),
          'expirationDate': now.add(const Duration(days: 165)).toIso8601String(),
        },
      ],
    };

    // ===== Carregar dados demo multi-tenant =====
    _loadDemoBusinessData(userId);
  }

  /// Carrega dados demo na estrutura multi-tenant (business-scoped)
  void _loadDemoBusinessData(String userId) {
    final now = DateTime.now();
    final bizId = 'biz_demo_$userId';

    // Business
    _businesses[bizId] = {
      'id': bizId,
      'name': 'Meu Consultório',
      'ownerUid': userId,
      'plan': 'starter',
      'enabledModules': ['therapy', 'massage'],
      'subscriptionStatus': 'trial',
      'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
      'updatedAt': now.toIso8601String(),
    };

    // Clients (business-scoped)
    _bizClients[bizId] = [
      {
        'id': 'client_1',
        'name': 'Maria Silva',
        'phone': '(11) 99999-1111',
        'email': 'maria@email.com',
        'birthDate': null,
        'notes': 'Dor lombar crônica',
        'tags': ['frequente'],
        'createdAt': now.subtract(const Duration(days: 30)).toIso8601String(),
        'status': 'active',
      },
      {
        'id': 'client_2',
        'name': 'João Santos',
        'phone': '(11) 99999-2222',
        'email': 'joao@email.com',
        'birthDate': null,
        'notes': 'Relaxamento e estresse',
        'tags': [],
        'createdAt': now.subtract(const Duration(days: 20)).toIso8601String(),
        'status': 'active',
      },
      {
        'id': 'client_3',
        'name': 'Ana Oliveira',
        'phone': '(11) 99999-3333',
        'email': 'ana@email.com',
        'birthDate': null,
        'notes': 'Pós-operatório joelho',
        'tags': [],
        'createdAt': now.subtract(const Duration(days: 10)).toIso8601String(),
        'status': 'active',
      },
    ];

    // Services
    _bizServices[bizId] = [
      {
        'id': 'svc_1',
        'name': 'Sessão de Terapia',
        'module': 'therapy',
        'durationMin': 50,
        'price': 150.0,
        'active': true,
      },
      {
        'id': 'svc_2',
        'name': 'Massagem Relaxante',
        'module': 'massage',
        'durationMin': 60,
        'price': 180.0,
        'active': true,
      },
      {
        'id': 'svc_3',
        'name': 'Massagem Desportiva',
        'module': 'massage',
        'durationMin': 50,
        'price': 200.0,
        'active': true,
      },
    ];

    // Appointments (business-scoped, com module + metadata)
    _bizAppointments[bizId] = [
      {
        'id': 'apt_1',
        'clientId': 'client_1',
        'staffUid': userId,
        'serviceId': 'svc_1',
        'module': 'therapy',
        'startAt': DateTime(now.year, now.month, now.day, 9, 0).toIso8601String(),
        'endAt': DateTime(now.year, now.month, now.day, 9, 50).toIso8601String(),
        'status': 'confirmado',
        'price': 150.0,
        'paymentStatus': 'pendente',
        'metadata': {
          'sessionNotes': '',
          'goals': 'Reduzir dor lombar',
          'homework': '',
        },
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 'apt_2',
        'clientId': 'client_2',
        'staffUid': userId,
        'serviceId': 'svc_2',
        'module': 'massage',
        'startAt': DateTime(now.year, now.month, now.day, 11, 0).toIso8601String(),
        'endAt': DateTime(now.year, now.month, now.day, 12, 0).toIso8601String(),
        'status': 'confirmado',
        'price': 180.0,
        'paymentStatus': 'pago',
        'metadata': {
          'technique': 'Relaxante',
          'areas': ['costas', 'ombros'],
          'pressure': 'moderada',
        },
        'createdAt': now.toIso8601String(),
      },
      {
        'id': 'apt_3',
        'clientId': 'client_3',
        'staffUid': userId,
        'serviceId': 'svc_3',
        'module': 'massage',
        'startAt': DateTime(now.year, now.month, now.day, 14, 30).toIso8601String(),
        'endAt': DateTime(now.year, now.month, now.day, 15, 20).toIso8601String(),
        'status': 'confirmado',
        'price': 200.0,
        'paymentStatus': 'pendente',
        'metadata': {
          'technique': 'Desportiva',
          'areas': ['pernas'],
          'pressure': 'forte',
        },
        'createdAt': now.toIso8601String(),
      },
      // Passadas
      {
        'id': 'apt_old_1',
        'clientId': 'client_1',
        'staffUid': userId,
        'serviceId': 'svc_1',
        'module': 'therapy',
        'startAt': now.subtract(const Duration(days: 7)).toIso8601String(),
        'endAt': now.subtract(const Duration(days: 7)).add(const Duration(minutes: 50)).toIso8601String(),
        'status': 'realizada',
        'price': 150.0,
        'paymentStatus': 'pago',
        'metadata': {
          'sessionNotes': 'Paciente relatou melhora significativa',
          'goals': 'Reduzir dor lombar',
          'homework': 'Exercícios de alongamento diários',
        },
        'createdAt': now.subtract(const Duration(days: 7)).toIso8601String(),
      },
      {
        'id': 'apt_old_2',
        'clientId': 'client_2',
        'staffUid': userId,
        'serviceId': 'svc_2',
        'module': 'massage',
        'startAt': now.subtract(const Duration(days: 5)).toIso8601String(),
        'endAt': now.subtract(const Duration(days: 5)).add(const Duration(minutes: 60)).toIso8601String(),
        'status': 'realizada',
        'price': 180.0,
        'paymentStatus': 'pago',
        'metadata': {
          'technique': 'Relaxante',
          'areas': ['costas'],
          'pressure': 'leve',
          'painBefore': 6,
          'painAfter': 2,
        },
        'createdAt': now.subtract(const Duration(days: 5)).toIso8601String(),
      },
    ];

    // Packages (business-scoped)
    _bizPackages[bizId] = {
      'client_1': [
        {
          'id': 'pkg_1',
          'clientId': 'client_1',
          'totalSessions': 10,
          'remainingSessions': 7,
          'price': 1200.0,
          'status': 'active',
          'createdAt': now.subtract(const Duration(days: 15)).toIso8601String(),
          'expirationDate': now.add(const Duration(days: 165)).toIso8601String(),
        },
      ],
    };

    // Transactions
    _bizTransactions[bizId] = [];
  }

  // ========== BUSINESS METHODS ==========

  void saveBusiness(Map<String, dynamic> data) {
    final id = data['id'] as String;
    _businesses[id] = data;
    // Inicializa coleções se necessário
    _bizClients[id] ??= [];
    _bizAppointments[id] ??= [];
    _bizServices[id] ??= [];
    _bizTransactions[id] ??= [];
    _bizPackages[id] ??= {};
  }

  Map<String, dynamic>? getBusinessByOwner(String uid) {
    for (final biz in _businesses.values) {
      if (biz['ownerUid'] == uid) return biz;
    }
    return null;
  }

  Map<String, dynamic>? getBusinessById(String bizId) {
    return _businesses[bizId];
  }

  // ========== BUSINESS-SCOPED CLIENT METHODS ==========

  List<Map<String, dynamic>> getBizClients(String bizId) {
    return _bizClients[bizId] ?? [];
  }

  List<Map<String, dynamic>> getActiveBizClients(String bizId) {
    return getBizClients(bizId)
        .where((c) => (c['status'] ?? 'active') == 'active')
        .toList();
  }

  Map<String, dynamic>? getBizClientById(String bizId, String clientId) {
    return getBizClients(bizId).where((c) => c['id'] == clientId).firstOrNull;
  }

  String addBizClient(String bizId, Map<String, dynamic> data) {
    final id = 'client_${DateTime.now().millisecondsSinceEpoch}';
    final client = {...data, 'id': id, 'status': data['status'] ?? 'active'};
    _bizClients[bizId] ??= [];
    _bizClients[bizId]!.add(client);
    _bizPackages[bizId] ??= {};
    _bizPackages[bizId]![id] = [];
    return id;
  }

  void updateBizClient(String bizId, String clientId, Map<String, dynamic> data) {
    final clients = _bizClients[bizId];
    if (clients == null) return;
    final index = clients.indexWhere((c) => c['id'] == clientId);
    if (index >= 0) {
      clients[index] = {...clients[index], ...data};
    }
  }

  void deleteBizClient(String bizId, String clientId) {
    _bizClients[bizId]?.removeWhere((c) => c['id'] == clientId);
  }

  void archiveBizClient(String bizId, String clientId) {
    updateBizClient(bizId, clientId, {'status': 'inactive'});
  }

  void reactivateBizClient(String bizId, String clientId) {
    updateBizClient(bizId, clientId, {'status': 'active'});
  }

  // ========== BUSINESS-SCOPED APPOINTMENT METHODS ==========

  List<Map<String, dynamic>> getBizAppointments(String bizId) {
    return _bizAppointments[bizId] ?? [];
  }

  List<Map<String, dynamic>> getBizAppointmentsByClient(String bizId, String clientId) {
    return getBizAppointments(bizId).where((a) => a['clientId'] == clientId).toList();
  }

  List<Map<String, dynamic>> getBizTodayAppointments(String bizId) {
    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    return getBizAppointments(bizId).where((a) {
      final dt = DateTime.parse((a['startAt'] ?? a['dateTime']) as String);
      return dt.isAfter(startOfDay) && dt.isBefore(endOfDay);
    }).toList()
      ..sort((a, b) =>
          ((a['startAt'] ?? a['dateTime']) as String)
              .compareTo((b['startAt'] ?? b['dateTime']) as String));
  }

  List<Map<String, dynamic>> getBizAppointmentsByPeriod(
      String bizId, DateTime start, DateTime end) {
    return getBizAppointments(bizId).where((a) {
      final dt = DateTime.parse((a['startAt'] ?? a['dateTime']) as String);
      return dt.isAfter(start) && dt.isBefore(end);
    }).toList();
  }

  Map<String, dynamic>? getBizAppointmentById(String bizId, String appointmentId) {
    return getBizAppointments(bizId)
        .where((a) => a['id'] == appointmentId)
        .firstOrNull;
  }

  String addBizAppointment(String bizId, Map<String, dynamic> data) {
    final id = 'apt_${DateTime.now().millisecondsSinceEpoch}';
    final appointment = {...data, 'id': id};
    _bizAppointments[bizId] ??= [];
    _bizAppointments[bizId]!.add(appointment);
    return id;
  }

  void updateBizAppointment(
      String bizId, String appointmentId, Map<String, dynamic> data) {
    final appointments = _bizAppointments[bizId];
    if (appointments == null) return;
    final index = appointments.indexWhere((a) => a['id'] == appointmentId);
    if (index >= 0) {
      appointments[index] = {...appointments[index], ...data};
    }
  }

  void deleteBizAppointment(String bizId, String appointmentId) {
    _bizAppointments[bizId]?.removeWhere((a) => a['id'] == appointmentId);
  }

  List<Map<String, dynamic>> getBizPendingAppointments(String bizId) {
    return getBizAppointments(bizId)
        .where((a) => a['paymentStatus'] == 'pendente')
        .toList();
  }

  // ========== BUSINESS-SCOPED SERVICE METHODS ==========

  List<Map<String, dynamic>> getBizServices(String bizId) {
    return _bizServices[bizId] ?? [];
  }

  String addBizService(String bizId, Map<String, dynamic> data) {
    final id = 'svc_${DateTime.now().millisecondsSinceEpoch}';
    final svc = {...data, 'id': id};
    _bizServices[bizId] ??= [];
    _bizServices[bizId]!.add(svc);
    return id;
  }

  void updateBizService(String bizId, String serviceId, Map<String, dynamic> data) {
    final services = _bizServices[bizId];
    if (services == null) return;
    final index = services.indexWhere((s) => s['id'] == serviceId);
    if (index >= 0) {
      services[index] = {...services[index], ...data};
    }
  }

  // ========== BUSINESS-SCOPED PACKAGE METHODS ==========

  List<Map<String, dynamic>> getBizPackages(String bizId, String clientId) {
    return _bizPackages[bizId]?[clientId] ?? [];
  }

  Map<String, dynamic>? getActiveBizPackage(String bizId, String clientId) {
    return getBizPackages(bizId, clientId).where((p) =>
        p['status'] == 'active' && (p['remainingSessions'] as int) > 0).firstOrNull;
  }

  String addBizPackage(String bizId, String clientId, Map<String, dynamic> data) {
    final id = 'pkg_${DateTime.now().millisecondsSinceEpoch}';
    final pkg = {...data, 'id': id, 'clientId': clientId};
    _bizPackages[bizId] ??= {};
    _bizPackages[bizId]![clientId] ??= [];
    _bizPackages[bizId]![clientId]!.add(pkg);
    return id;
  }

  void decrementBizPackage(String bizId, String clientId, String packageId) {
    final packages = _bizPackages[bizId]?[clientId];
    if (packages == null) return;
    final index = packages.indexWhere((p) => p['id'] == packageId);
    if (index >= 0) {
      final remaining = (packages[index]['remainingSessions'] as int) - 1;
      packages[index]['remainingSessions'] = remaining;
      if (remaining == 0) {
        packages[index]['status'] = 'completed';
      }
    }
  }

  // ========== BUSINESS-SCOPED TRANSACTION METHODS ==========

  List<Map<String, dynamic>> getBizTransactions(String bizId) {
    return _bizTransactions[bizId] ?? [];
  }

  String addBizTransaction(String bizId, Map<String, dynamic> data) {
    final id = 'tx_${DateTime.now().millisecondsSinceEpoch}';
    final tx = {...data, 'id': id};
    _bizTransactions[bizId] ??= [];
    _bizTransactions[bizId]!.add(tx);
    return id;
  }
}

class MockUser {
  final String uid;
  final String email;
  final String name;
  final String plan;
  final DateTime createdAt;
  final bool onboardingCompleted;

  MockUser({
    required this.uid,
    required this.email,
    required this.name,
    required this.plan,
    required this.createdAt,
    required this.onboardingCompleted,
  });

  MockUser copyWith({
    String? name,
    String? plan,
    bool? onboardingCompleted,
  }) {
    return MockUser(
      uid: uid,
      email: email,
      name: name ?? this.name,
      plan: plan ?? this.plan,
      createdAt: createdAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
