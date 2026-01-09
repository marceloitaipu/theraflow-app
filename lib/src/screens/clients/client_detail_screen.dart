import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/client_service.dart';
import '../../services/session_service.dart';
import '../../services/package_service.dart';
import '../../services/auth_service.dart';
import '../../models/client.dart';
import '../../models/session.dart';
import '../../models/package.dart';
import '../../widgets/section_title.dart';

class ClientDetailScreen extends StatefulWidget {
  final String clientId;
  const ClientDetailScreen({super.key, required this.clientId});

  @override
  State<ClientDetailScreen> createState() => _ClientDetailScreenState();
}

class _ClientDetailScreenState extends State<ClientDetailScreen> {
  final _notesController = TextEditingController();
  bool _isEditingNotes = false;

  void _showEditDialog(Client client) {
    final nameController = TextEditingController(text: client.name);
    final phoneController = TextEditingController(text: client.phone);
    final notesController = TextEditingController(text: client.notes);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Editar Cliente'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: nameController,
              decoration: const InputDecoration(labelText: 'Nome'),
            ),
            TextField(
              controller: phoneController,
              decoration: const InputDecoration(labelText: 'Telefone'),
            ),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Observações'),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ClientService.instance.updateClient(
                  client.id,
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  notes: notesController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente atualizado!')),
                  );
                  setState(() {});
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(Client client) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Excluir Cliente'),
        content: Text('Deseja realmente excluir ${client.name}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () async {
              try {
                await ClientService.instance.deleteClient(client.id);
                if (context.mounted) {
                  Navigator.pop(context);
                  context.go('/clients');
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Erro: $e')),
                  );
                }
              }
            },
            child: const Text('Excluir', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<Client?>(
      future: ClientService.instance.getClientById(widget.clientId),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final client = snapshot.data;
        if (client == null) {
          return Scaffold(
            appBar: AppBar(title: const Text('Cliente')),
            body: const Center(child: Text('Cliente não encontrado')),
          );
        }

        return Scaffold(
          appBar: AppBar(
            title: Text(client.name),
            actions: [
              IconButton(
                icon: const Icon(Icons.edit),
                onPressed: () => _showEditDialog(client),
              ),
              IconButton(
                icon: const Icon(Icons.delete),
                onPressed: () => _showDeleteDialog(client),
              ),
            ],
          ),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => context.push('/session/new?clientId=${client.id}'),
            icon: const Icon(Icons.add),
            label: const Text('Nova sessão'),
          ),
          body: ListView(
            children: [
              ListTile(
                leading: const Icon(Icons.phone),
                title: const Text('Telefone'),
                subtitle: Text(client.phone.isEmpty ? 'Não informado' : client.phone),
              ),
              if (client.notes.isNotEmpty)
                ListTile(
                  leading: const Icon(Icons.note),
                  title: const Text('Observações'),
                  subtitle: Text(client.notes),
                ),
              const Divider(),
              
              // ========== SEÇÃO DE PACOTES ==========
              _PackagesSection(clientId: client.id),
              const Divider(),
              
              const SectionTitle('Histórico de Sessões'),
              StreamBuilder<List<Session>>(
                stream: SessionService.instance.getClientSessionsStream(client.id),
                builder: (context, sessionsSnapshot) {
                  if (sessionsSnapshot.connectionState == ConnectionState.waiting) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: CircularProgressIndicator(),
                      ),
                    );
                  }

                  final sessions = sessionsSnapshot.data ?? [];

                  if (sessions.isEmpty) {
                    return const Padding(
                      padding: EdgeInsets.all(24.0),
                      child: Center(
                        child: Text(
                          'Nenhuma sessão registrada',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: sessions.map((session) => _SessionTile(session: session)).toList(),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return ListTile(
      leading: Icon(
        session.status == 'confirmado' ? Icons.check_circle : Icons.cancel,
        color: session.status == 'confirmado' ? Colors.green : Colors.orange,
      ),
      title: Text('${dateFormat.format(session.dateTime)} — ${session.therapyType}'),
      subtitle: Text(
        '${currencyFormat.format(session.value)} • ${session.paymentStatus}',
      ),
      trailing: session.paymentStatus == 'pago'
          ? const Icon(Icons.attach_money, color: Colors.green)
          : const Icon(Icons.pending, color: Colors.orange),
      onTap: () => context.go('/session/${session.id}'),
    );
  }
}

// Seção de pacotes do cliente
class _PackagesSection extends StatelessWidget {
  final String clientId;

  const _PackagesSection({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<bool>(
      future: _canUsePackages(),
      builder: (context, permSnapshot) {
        final canUsePackages = permSnapshot.data ?? false;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.inventory_2, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Pacotes',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (!canUsePackages) ...[
                        const SizedBox(width: 8),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.amber,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: const Text(
                            'PRO',
                            style: TextStyle(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  TextButton.icon(
                    onPressed: canUsePackages
                        ? () => context.push('/clients/$clientId/package/new')
                        : () => context.push('/paywall'),
                    icon: Icon(
                      canUsePackages ? Icons.add : Icons.lock,
                      size: 18,
                    ),
                    label: Text(canUsePackages ? 'Novo pacote' : 'Desbloquear'),
                  ),
                ],
              ),
            ),
            if (canUsePackages)
              FutureBuilder<List<Package>>(
                future: PackageService.instance.listPackages(clientId),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const Padding(
                      padding: EdgeInsets.all(16),
                      child: Center(child: CircularProgressIndicator()),
                    );
                  }

                  final packages = snapshot.data ?? [];

                  if (packages.isEmpty) {
                    return Padding(
                      padding: const EdgeInsets.all(16),
                      child: Center(
                        child: Text(
                          'Nenhum pacote ativo',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: packages.map((pkg) => _PackageTile(package: pkg)).toList(),
                  );
                },
              )
            else
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  children: [
                    Icon(Icons.lock, color: Colors.grey[400], size: 32),
                    const SizedBox(height: 8),
                    Text(
                      'Pacotes são recursos PRO',
                      style: TextStyle(
                        color: Colors.grey[600],
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Gerencie pacotes de sessões e aumente sua receita',
                      style: TextStyle(
                        color: Colors.grey[500],
                        fontSize: 12,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
          ],
        );
      },
    );
  }

  Future<bool> _canUsePackages() async {
    try {
      final user = await AuthService.instance.getCurrentUserData();
      return user?.canUsePackages() ?? false;
    } catch (e) {
      return false;
    }
  }
}

// Tile de pacote
class _PackageTile extends StatelessWidget {
  final Package package;

  const _PackageTile({required this.package});

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final dateFormat = DateFormat('dd/MM/yyyy');

    final isLow = package.isLow;
    final isExpired = package.isExpired;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(
                      '${package.remainingSessions}/${package.totalSessions}',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: isLow
                            ? Colors.orange
                            : isExpired
                                ? Colors.red
                                : Colors.green,
                      ),
                    ),
                    const SizedBox(width: 8),
                    const Text('sessões restantes'),
                  ],
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: _getStatusColor(package.status),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    _getStatusLabel(package.status),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            LinearProgressIndicator(
              value: package.usagePercentage,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(
                isLow ? Colors.orange : Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  currencyFormat.format(package.price),
                  style: const TextStyle(fontWeight: FontWeight.w500),
                ),
                if (package.expirationDate != null)
                  Text(
                    'Expira: ${dateFormat.format(package.expirationDate!)}',
                    style: TextStyle(
                      color: isExpired ? Colors.red : Colors.grey[600],
                      fontSize: 12,
                    ),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'ativo':
        return Colors.green;
      case 'concluído':
        return Colors.blue;
      case 'expirado':
        return Colors.red;
      case 'cancelado':
        return Colors.grey;
      default:
        return Colors.grey;
    }
  }

  String _getStatusLabel(String status) {
    switch (status) {
      case 'ativo':
        return 'Ativo';
      case 'concluído':
        return 'Concluído';
      case 'expirado':
        return 'Expirado';
      case 'cancelado':
        return 'Cancelado';
      default:
        return status;
    }
  }
}
