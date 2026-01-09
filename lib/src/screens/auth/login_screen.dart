import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/auth_service.dart';
import '../../widgets/primary_button.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  final _name = TextEditingController();
  bool _loading = false;
  bool _isSignup = false;

  Future<void> _login() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signIn(
        email: _email.text.trim(),
        password: _pass.text,
      );
      
      // Verificar flag de onboarding
      final userData = await AuthService.instance.getCurrentUserData();
      if (!mounted) return;
      
      if (userData?.onboardingCompleted == false) {
        context.go('/onboarding');
      } else {
        context.go('/home');
      }
    } catch (e) {
      if (!mounted) return;
      final errorMsg = _parseError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _signup() async {
    setState(() => _loading = true);
    try {
      await AuthService.instance.signUp(
        email: _email.text.trim(),
        password: _pass.text,
        name: _name.text.trim(),
      );
      if (mounted) context.go('/onboarding');
    } catch (e) {
      if (!mounted) return;
      final errorMsg = _parseError(e);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(errorMsg)),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  String _parseError(dynamic e) {
    final errorString = e.toString().toLowerCase();
    if (errorString.contains('user-not-found')) {
      return 'Usuário não encontrado.';
    } else if (errorString.contains('wrong-password') || errorString.contains('invalid-credential')) {
      return 'Senha incorreta.';
    } else if (errorString.contains('email-already-in-use')) {
      return 'E-mail já cadastrado. Tente fazer login.';
    } else if (errorString.contains('invalid-email')) {
      return 'E-mail inválido.';
    } else if (errorString.contains('weak-password')) {
      return 'Senha muito fraca. Use pelo menos 6 caracteres.';
    } else if (errorString.contains('too-many-requests')) {
      return 'Muitas tentativas. Aguarde um momento.';
    } else if (errorString.contains('network')) {
      return 'Erro de conexão. Verifique sua internet.';
    }
    return 'Erro ao autenticar. Tente novamente.';
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
      appBar: AppBar(title: const Text('TheraFlow')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const SizedBox(height: 12),
            if (_isSignup) ...[
              TextField(controller: _name, decoration: const InputDecoration(labelText: 'Nome')),
              const SizedBox(height: 12),
            ],
            TextField(controller: _email, decoration: const InputDecoration(labelText: 'E-mail')),
            const SizedBox(height: 12),
            TextField(controller: _pass, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
            const SizedBox(height: 16),
            PrimaryButton(
              onPressed: _loading ? null : (_isSignup ? _signup : _login),
              label: _loading 
                  ? (_isSignup ? 'Criando conta...' : 'Entrando...') 
                  : (_isSignup ? 'Criar conta' : 'Entrar'),
            ),
            const SizedBox(height: 8),
            TextButton(
              onPressed: _loading ? null : () {
                setState(() => _isSignup = !_isSignup);
              },
              child: Text(_isSignup ? 'Já tenho conta' : 'Criar conta'),
            ),
            const Spacer(),
            Text(
              'Organize seus atendimentos, clientes e pagamentos',
              style: Theme.of(context).textTheme.bodySmall,
              textAlign: TextAlign.center,
            )
          ],
        ),
      ),
    );
  }
}
