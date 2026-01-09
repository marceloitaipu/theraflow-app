import 'dart:async';
import '../models/user.dart' as models;
import 'mock_data_service.dart';

/// AuthService que usa dados mock (sem Firebase)
/// Para testes e desenvolvimento local
class MockAuthService {
  MockAuthService._();
  static final instance = MockAuthService._();

  final MockDataService _mock = MockDataService.instance;
  
  final _authStateController = StreamController<MockUser?>.broadcast();

  // Stream do usuário atual
  Stream<MockUser?> get authStateChanges => _authStateController.stream;

  // Usuário atual
  MockUser? get currentUser => _mock.currentUser;

  // Buscar dados do usuário
  Future<models.User?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    return models.User(
      id: user.uid,
      name: user.name,
      email: user.email,
      plan: user.plan,
      createdAt: user.createdAt,
      onboardingCompleted: user.onboardingCompleted,
    );
  }

  // Cadastro
  Future<MockUser> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    final user = await _mock.signUp(email: email, password: password, name: name);
    _authStateController.add(user);
    return user;
  }

  // Login
  Future<MockUser> signIn({
    required String email,
    required String password,
  }) async {
    final user = await _mock.signIn(email: email, password: password);
    _authStateController.add(user);
    
    // Carregar dados demo se for o primeiro login
    _mock.loadDemoData();
    
    return user;
  }

  // Logout
  Future<void> signOut() async {
    await _mock.signOut();
    _authStateController.add(null);
  }

  // Recuperação de senha (mock)
  Future<void> resetPassword({required String email}) async {
    await Future.delayed(const Duration(milliseconds: 500));
    // Simula envio de email
  }

  // Atualizar dados
  Future<void> updateUserData(Map<String, dynamic> data) async {
    await _mock.updateUserData(data);
  }

  void dispose() {
    _authStateController.close();
  }
}
