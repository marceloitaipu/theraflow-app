import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/app_services.dart';
import '../../widgets/section_title.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: FutureBuilder<User?>(
        future: AuthService.instance.getCurrentUserData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            return const Center(child: Text('Erro ao carregar dados'));
          }

          return ListView(
            children: [
              const SectionTitle('Dados'),
              ListTile(
                title: const Text('Nome'),
                subtitle: Text(user.name),
              ),
              ListTile(
                title: const Text('E-mail'),
                subtitle: Text(user.email),
              ),
              ListTile(
                title: const Text('Plano'),
                subtitle: Text(_getPlanName(user.plan)),
                trailing: user.plan == 'free'
                    ? TextButton(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Upgrade de plano em breve!'),
                            ),
                          );
                        },
                        child: const Text('Upgrade'),
                      )
                    : null,
              ),
              FutureBuilder<int>(
                future: ClientService.instance.getClientCount(),
                builder: (context, clientSnapshot) {
                  final count = clientSnapshot.data ?? 0;
                  return ListTile(
                    title: const Text('Clientes'),
                    subtitle: Text('$count de ${user.clientLimit}'),
                  );
                },
              ),
              const SectionTitle('Configurações'),
              SwitchListTile(
                value: true,
                onChanged: (_) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Notificações em breve!'),
                    ),
                  );
                },
                title: const Text('Lembretes de sessões'),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(12),
                child: OutlinedButton.icon(
                  onPressed: () async {
                    await AuthService.instance.signOut();
                    if (context.mounted) context.go('/login');
                  },
                  icon: const Icon(Icons.logout),
                  label: const Text('Sair'),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _getPlanName(String plan) {
    switch (plan) {
      case 'free':
        return 'Free (até 5 clientes)';
      case 'professional':
        return 'Profissional (até 50 clientes)';
      case 'premium':
        return 'Premium (ilimitado)';
      default:
        return plan;
    }
  }
}
