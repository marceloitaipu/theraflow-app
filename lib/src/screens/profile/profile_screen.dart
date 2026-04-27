import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../../services/app_services.dart';
import '../../services/export_service.dart';
import '../../widgets/section_title.dart';
import '../../providers/theme_provider.dart';

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
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, _) {
                  return SwitchListTile(
                    value: themeProvider.isDarkMode,
                    onChanged: (_) {
                      themeProvider.toggleTheme();
                    },
                    title: const Text('Tema escuro'),
                    subtitle: Text(
                      themeProvider.isDarkMode ? 'Ativado' : 'Desativado',
                    ),
                    secondary: Icon(
                      themeProvider.isDarkMode 
                        ? Icons.dark_mode 
                        : Icons.light_mode,
                    ),
                  );
                },
              ),
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
              const SectionTitle('Exportar dados'),
              _ExportSection(),
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

// ─── Seção de exportação ─────────────────────────────────────────────────────
class _ExportSection extends StatefulWidget {
  @override
  State<_ExportSection> createState() => _ExportSectionState();
}

class _ExportSectionState extends State<_ExportSection> {
  bool _loading = false;

  Future<void> _run(Future<void> Function() action) async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await action();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Erro ao exportar: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final now = DateTime.now();

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Column(
        children: [
          if (_loading)
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 12),
              child: Center(child: CircularProgressIndicator()),
            ),
          _ExportTile(
            icon: Icons.people_outline,
            label: 'Exportar clientes',
            subtitle: 'Lista completa de clientes em CSV',
            onTap: _loading ? null : () => _run(ExportService.instance.exportClients),
          ),
          _ExportTile(
            icon: Icons.event_note_outlined,
            label: 'Exportar sessões do mês',
            subtitle: 'Sessões do mês atual',
            onTap: _loading
                ? null
                : () => _run(() => ExportService.instance.exportSessions(
                      start: DateTime(now.year, now.month, 1),
                      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
                    )),
          ),
          _ExportTile(
            icon: Icons.attach_money_outlined,
            label: 'Exportar financeiro do mês',
            subtitle: 'Receitas e pagamentos do mês atual',
            onTap: _loading
                ? null
                : () => _run(() => ExportService.instance.exportFinance(
                      start: DateTime(now.year, now.month, 1),
                      end: DateTime(now.year, now.month + 1, 0, 23, 59, 59),
                    )),
          ),
          _ExportTile(
            icon: Icons.summarize_outlined,
            label: 'Resumo mensal',
            subtitle: 'Totais e indicadores do mês atual',
            onTap: _loading
                ? null
                : () => _run(() => ExportService.instance.exportMonthlySummary(
                      year: now.year,
                      month: now.month,
                    )),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}

class _ExportTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String subtitle;
  final VoidCallback? onTap;

  const _ExportTile({
    required this.icon,
    required this.label,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
        title: Text(label),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 12)),
        trailing: const Icon(Icons.file_download_outlined),
        onTap: onTap,
        enabled: onTap != null,
      ),
    );
  }
}
