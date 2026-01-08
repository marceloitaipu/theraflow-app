import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/client_service.dart';
import '../../services/session_service.dart';
import '../../models/client.dart';
import '../../models/session.dart';
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
