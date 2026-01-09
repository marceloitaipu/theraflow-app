import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/app_services.dart';
import '../../services/mock_data_service.dart';
import '../../widgets/primary_button.dart';

/// Tela de login usando dados mock (sem Firebase)
class MockLoginScreen extends StatefulWidget {
  const MockLoginScreen({super.key});

  @override
  State<MockLoginScreen> createState() => _MockLoginScreenState();
}

class _MockLoginScreenState extends State<MockLoginScreen> {
  final _email = TextEditingController(text: 'demo@theraflow.com');
  final _pass = TextEditingController(text: '123456');
  final _name = TextEditingController(text: 'Terapeuta Demo');
  bool _loading = false;
  bool _isSignup = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await AppAuthService.instance.signIn(
        email: _email.text.trim(),
        password: _pass.text,
      );
      
      final userData = await AppAuthService.instance.getCurrentUserData();
      if (!mounted) return;
      
      if (userData?.onboardingCompleted == false) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_parseError(e)), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    setState(() => _loading = true);
    try {
      await AppAuthService.instance.signUp(
        email: _email.text.trim(),
        password: _pass.text,
        name: _name.text.trim(),
      );
      
      // Carregar dados de demonstração
      MockDataService.instance.loadDemoData();
      
      if (mounted) context.go('/onboarding');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(_parseError(e)), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _quickDemo() async {
    setState(() => _loading = true);
    try {
      // Login rápido com conta demo
      try {
        await AppAuthService.instance.signIn(
          email: 'demo@theraflow.com',
          password: '123456',
        );
      } catch (_) {
        // Criar conta demo se não existir
        await AppAuthService.instance.signUp(
          email: 'demo@theraflow.com',
          password: '123456',
          name: 'Terapeuta Demo',
        );
        MockDataService.instance.loadDemoData();
        
        // Marcar onboarding como completo
        await AppAuthService.instance.updateUserData({
          'onboardingCompleted': true,
        });
      }
      
      if (mounted) context.go('/home');
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro: $e'), backgroundColor: Colors.red),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _parseError(dynamic e) {
    final errorString = e.toString();
    if (errorString.contains('E-mail já cadastrado')) {
      return 'E-mail já cadastrado. Tente fazer login.';
    } else if (errorString.contains('Usuário não encontrado')) {
      return 'Usuário não encontrado. Crie uma conta.';
    }
    return e.toString().replaceAll('Exception: ', '');
  }

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('TheraFlow'),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Banner de modo demo
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                children: [
                  Icon(Icons.science, color: Colors.amber[700]),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Modo Demonstração',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.amber[800],
                          ),
                        ),
                        Text(
                          'Dados salvos apenas em memória',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.amber[700],
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 24),
            
            // Botão de acesso rápido
            OutlinedButton.icon(
              onPressed: _loading ? null : _quickDemo,
              icon: const Icon(Icons.rocket_launch),
              label: const Text('Entrar com conta demo'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(color: Theme.of(context).primaryColor),
              ),
            ),
            
            const SizedBox(height: 24),
            
            Row(
              children: [
                Expanded(child: Divider(color: Colors.grey[300])),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Text('ou', style: TextStyle(color: Colors.grey[500])),
                ),
                Expanded(child: Divider(color: Colors.grey[300])),
              ],
            ),
            
            const SizedBox(height: 24),
            
            // Formulário
            if (_isSignup) ...[
              TextField(
                controller: _name,
                decoration: const InputDecoration(
                  labelText: 'Nome',
                  prefixIcon: Icon(Icons.person),
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 16),
            ],
            
            TextField(
              controller: _email,
              decoration: const InputDecoration(
                labelText: 'E-mail',
                prefixIcon: Icon(Icons.email),
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            
            const SizedBox(height: 16),
            
            TextField(
              controller: _pass,
              decoration: const InputDecoration(
                labelText: 'Senha',
                prefixIcon: Icon(Icons.lock),
                border: OutlineInputBorder(),
              ),
              obscureText: true,
            ),
            
            const SizedBox(height: 24),
            
            PrimaryButton(
              onPressed: _loading ? null : (_isSignup ? _signup : _login),
              label: _loading 
                  ? (_isSignup ? 'Criando conta...' : 'Entrando...') 
                  : (_isSignup ? 'Criar conta' : 'Entrar'),
            ),
            
            const SizedBox(height: 12),
            
            TextButton(
              onPressed: _loading ? null : () {
                setState(() => _isSignup = !_isSignup);
              },
              child: Text(_isSignup ? 'Já tenho conta' : 'Criar nova conta'),
            ),
            
            const SizedBox(height: 48),
            
            Text(
              'Organize seus atendimentos, clientes e pagamentos',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
