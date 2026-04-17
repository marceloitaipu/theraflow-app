import 'package:flutter/material.dart';

/// Tela exibida durante a inicialização enquanto o [GoRouter.redirect] decide
/// para onde enviar o usuário (login, onboarding ou home).
class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.spa, size: 72, color: Color(0xFF6C63FF)),
            SizedBox(height: 16),
            Text(
              'TheraFlow',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF6C63FF),
              ),
            ),
            SizedBox(height: 24),
            CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }
}
