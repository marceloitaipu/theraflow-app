import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import '../config/app_config.dart';
import '../models/user.dart' as models;

class AuthService {
  AuthService._();
  static final instance = AuthService._();

  final firebase_auth.FirebaseAuth _auth = firebase_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Inicializa configurações de auth (chamar no main antes de usar).
  Future<void> initialize() async {
    if (kIsWeb) {
      // Desabilita reCAPTCHA Enterprise que causa 400 no signup web
      await _auth.setSettings(appVerificationDisabledForTesting: kDebugMode);
    }
  }

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
      firebase_auth.UserCredential credential;

      if (kIsWeb) {
        // Na web, usa REST API para evitar bloqueio do reCAPTCHA Enterprise
        credential = await _signUpViaRestApi(email, password);
      } else {
        credential = await _auth.createUserWithEmailAndPassword(
          email: email,
          password: password,
        );
      }

      // Criar documento do usuário no Firestore
      final user = models.User(
        id: credential.user!.uid,
        name: name,
        email: email,
        plan: 'professional',
        createdAt: DateTime.now(),
        onboardingCompleted: false,
      );

      await _firestore.collection('users').doc(user.id).set(user.toMap());

      return credential.user!;
    } on firebase_auth.FirebaseAuthException catch (e) {
      throw Exception(_handleAuthException(e));
    } catch (e) {
      // Tratamento para erros no Flutter Web
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('email-already-in-use')) {
        throw Exception('E-mail já cadastrado.');
      } else if (errorString.contains('invalid-email')) {
        throw Exception('E-mail inválido.');
      } else if (errorString.contains('weak-password')) {
        throw Exception('Senha muito fraca.');
      }
      rethrow;
    }
  }

  /// Cria conta via REST API do Firebase Auth (sem reCAPTCHA Enterprise).
  Future<firebase_auth.UserCredential> _signUpViaRestApi(
      String email, String password) async {
    final apiKey = Firebase.app().options.apiKey;
    final url = Uri.parse(
        'https://identitytoolkit.googleapis.com/v1/accounts:signUp?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'returnSecureToken': true,
      }),
    );

    if (response.statusCode != 200) {
      final body = jsonDecode(response.body);
      final errorMsg =
          body['error']?['message'] ?? 'Erro desconhecido ao criar conta';
      if (errorMsg == 'EMAIL_EXISTS') {
        throw Exception('E-mail já cadastrado.');
      } else if (errorMsg == 'WEAK_PASSWORD') {
        throw Exception('Senha muito fraca.');
      } else if (errorMsg == 'INVALID_EMAIL') {
        throw Exception('E-mail inválido.');
      }
      throw Exception(errorMsg);
    }

    // Faz login com as credenciais para obter o UserCredential do SDK
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Login com GitHub
  Future<firebase_auth.User> signInWithGitHub() async {
    try {
      if (!kIsWeb) {
        throw Exception('Login com GitHub está disponível apenas na web nesta fase de testes.');
      }

      final githubProvider = firebase_auth.GithubAuthProvider();
      final credential = await _auth.signInWithPopup(githubProvider);
      final user = credential.user;
      if (user == null) throw Exception('Falha ao autenticar com GitHub');

      // Verificar se é primeiro login e criar documento do usuário
      final userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (!userDoc.exists) {
        final newUser = models.User(
          id: user.uid,
          name: user.displayName ?? 'Usuário GitHub',
          email: user.email ?? '',
          plan: 'free',
          createdAt: DateTime.now(),
          onboardingCompleted: false,
        );
        await _firestore.collection('users').doc(user.uid).set(newUser.toMap());
      }

      return user;
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (e.code == 'popup-closed-by-user') {
        throw Exception('Login com GitHub cancelado.');
      }
      if (e.code == 'popup-blocked') {
        throw Exception('O navegador bloqueou o popup do GitHub. Libere popups e tente novamente.');
      }
      if (e.code == 'operation-not-supported-in-this-environment') {
        throw Exception('Login com GitHub indisponível neste ambiente. Use email e senha para continuar.');
      }
      throw Exception(_handleAuthException(e));
    } catch (e) {
      if (AppConfig.isWebTestMode) {
        throw Exception('Erro no login GitHub para teste web: $e');
      }
      throw Exception('Erro ao fazer login com GitHub: $e');
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
      throw Exception(_handleAuthException(e));
    } catch (e) {
      // Tratamento para erros no Flutter Web
      final errorString = e.toString().toLowerCase();
      if (errorString.contains('user-not-found')) {
        throw Exception('Usuário não encontrado.');
      } else if (errorString.contains('wrong-password') || errorString.contains('invalid-credential')) {
        throw Exception('Senha incorreta.');
      } else if (errorString.contains('invalid-email')) {
        throw Exception('E-mail inválido.');
      } else if (errorString.contains('too-many-requests')) {
        throw Exception('Muitas tentativas. Tente novamente mais tarde.');
      }
      throw Exception('Erro ao fazer login. Verifique suas credenciais.');
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
      case 'popup-blocked':
        return 'O navegador bloqueou o popup de autenticação.';
      case 'popup-closed-by-user':
        return 'Autenticação cancelada.';
      case 'invalid-credential':
      case 'INVALID_LOGIN_CREDENTIALS':
        return 'E-mail ou senha incorretos.';
      default:
        return 'Erro ao autenticar: ${e.message}';
    }
  }
}
