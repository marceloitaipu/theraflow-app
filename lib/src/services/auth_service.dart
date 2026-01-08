import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart' as models;

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Stream do usuário atual
  Stream<firebase_auth.User?> get authStateChanges => _auth.authStateChanges();

  // Usuário atual
  firebase_auth.User? get currentUser => _auth.currentUser;

  // Buscar dados do usuário no Firestore
  Future<models.User?> getCurrentUserData() async {
    final user = currentUser;
    if (user == null) return null;

    try {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (!doc.exists) return null;
      return models.User.fromMap(doc.id, doc.data()!);
    } catch (e) {
      return null;
    }
  }

  // Cadastro com e-mail e senha
  Future<firebase_auth.User> signUp({
    required String email,
    required String password,
    required String name,
  }) async {
    if (email.isEmpty || password.length < 6) {
      throw Exception('Senha deve ter ao menos 6 caracteres.');
    }
    if (name.isEmpty) {
      throw Exception('Informe seu nome.');
    }

    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // Criar documento do usuário no Firestore
      final user = models.User(
        id: credential.user!.uid,
        name: name,
        email: email,
        plan: 'free',
        createdAt: DateTime.now(),
        onboardingCompleted: false,
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      return credential.user!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Login com e-mail e senha
  Future<firebase_auth.User> signIn({
    required String email,
    required String password,
  }) async {
    if (email.isEmpty || password.isEmpty) {
      throw Exception('Informe e-mail e senha.');
    }

    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
  }

  // Recuperação de senha
  Future<void> resetPassword({required String email}) async {
    if (email.isEmpty) {
      throw Exception('Informe o e-mail.');
    }

    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    }
  }

  // Atualizar dados do usuário
  Future<void> updateUserData(Map<String, dynamic> data) async {
    final user = currentUser;
    if (user == null) throw Exception('Usuário não autenticado.');

    await _firestore.collection('users').doc(user.uid).update(data);
  }

  // Tratamento de erros do Firebase Auth
  String _handleAuthException(firebase_auth.FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'Usuário não encontrado.';
      case 'wrong-password':
        return 'Senha incorreta.';
      case 'email-already-in-use':
        return 'E-mail já cadastrado.';
      case 'invalid-email':
        return 'E-mail inválido.';
      case 'weak-password':
        return 'Senha muito fraca.';
      case 'too-many-requests':
        return 'Muitas tentativas. Tente novamente mais tarde.';
      default:
        return 'Erro ao autenticar: ${e.message}';
    }
  }
}
