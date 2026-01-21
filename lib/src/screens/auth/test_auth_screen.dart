import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tela de teste simplificada para debug de autenticação
class TestAuthScreen extends StatefulWidget {
  const TestAuthScreen({super.key});

  @override
  State<TestAuthScreen> createState() => _TestAuthScreenState();
}

class _TestAuthScreenState extends State<TestAuthScreen> {
  final _emailController = TextEditingController(text: 'teste@teste.com');
  final _passController = TextEditingController(text: '123456');
  String _status = 'Aguardando...';
  bool _loading = false;

  Future<void> _testSignUp() async {
    setState(() {
      _loading = true;
      _status = 'Tentando criar conta...';
    });

    try {
      final auth = FirebaseAuth.instance;
      final firestore = FirebaseFirestore.instance;

      // Tentar criar usuário
      final credential = await auth.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      setState(() => _status = 'Usuário criado! UID: ${credential.user?.uid}');

      // Criar documento no Firestore
      await firestore.collection('users').doc(credential.user!.uid).set({
        'name': 'Teste',
        'email': _emailController.text,
        'plan': 'free',
        'createdAt': DateTime.now().toIso8601String(),
        'onboardingCompleted': false,
      });

      setState(() => _status = 'SUCESSO! Conta criada e dados salvos no Firestore!');
    } on FirebaseAuthException catch (e) {
      setState(() => _status = 'ERRO AUTH: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() => _status = 'ERRO: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _testSignIn() async {
    setState(() {
      _loading = true;
      _status = 'Tentando fazer login...';
    });

    try {
      final auth = FirebaseAuth.instance;

      final credential = await auth.signInWithEmailAndPassword(
        email: _emailController.text,
        password: _passController.text,
      );

      setState(() => _status = 'LOGIN OK! UID: ${credential.user?.uid}');
    } on FirebaseAuthException catch (e) {
      setState(() => _status = 'ERRO LOGIN: ${e.code} - ${e.message}');
    } catch (e) {
      setState(() => _status = 'ERRO: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  Future<void> _checkFirebaseConnection() async {
    setState(() {
      _loading = true;
      _status = 'Verificando conexão...';
    });

    try {
      final auth = FirebaseAuth.instance;
      final currentUser = auth.currentUser;
      
      setState(() => _status = 'Firebase conectado! User atual: ${currentUser?.email ?? "nenhum"}');
    } catch (e) {
      setState(() => _status = 'ERRO conexão: $e');
    } finally {
      setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Teste de Autenticação')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _emailController,
              decoration: const InputDecoration(labelText: 'Email'),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _passController,
              decoration: const InputDecoration(labelText: 'Senha'),
              obscureText: true,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loading ? null : _checkFirebaseConnection,
              child: const Text('1. Verificar Conexão Firebase'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _testSignUp,
              child: const Text('2. Criar Conta (SignUp)'),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: _loading ? null : _testSignIn,
              child: const Text('3. Fazer Login (SignIn)'),
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 12),
            Text(
              'Status:',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.grey[100],
                ),
                child: SingleChildScrollView(
                  child: Text(
                    _status,
                    style: const TextStyle(
                      fontFamily: 'monospace',
                      fontSize: 12,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
