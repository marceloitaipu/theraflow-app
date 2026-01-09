/// Serviço de dados mock para testes sem Firebase
/// Armazena todos os dados em memória
class MockDataService {
  MockDataService._();
  static final instance = MockDataService._();

  // Usuários cadastrados (email -> dados)
  final Map<String, MockUser> _users = {};
  
  // Dados por usuário
  final Map<String, List<Map<String, dynamic>>> _clients = {};
  final Map<String, List<Map<String, dynamic>>> _sessions = {};
  final Map<String, Map<String, List<Map<String, dynamic>>>> _packages = {};

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
