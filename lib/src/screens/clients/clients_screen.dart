import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/app_services.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';

  void _showNewClientDialog() {
    final nameController = TextEditingController();
    final phoneController = TextEditingController();
    final notesController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Novo Cliente'),
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
                await ClientService.instance.createClient(
                  name: nameController.text.trim(),
                  phone: phoneController.text.trim(),
                  notes: notesController.text.trim(),
                );
                if (context.mounted) {
                  Navigator.pop(context);
                  setState(() {});
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Cliente criado!')),
                  );
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Clientes'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(56),
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Buscar cliente...',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                filled: true,
                fillColor: Colors.white,
              ),
              onChanged: (value) => setState(() => _searchQuery = value),
            ),
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewClientDialog,
        child: const Icon(Icons.person_add),
      ),
      body: FutureBuilder<List<Client>>(
        future: ClientService.instance.getClients(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final clients = snapshot.data ?? [];
          final filteredClients = _searchQuery.isEmpty
              ? clients
              : clients.where((c) =>
                  c.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
                  c.phone.contains(_searchQuery)).toList();

          if (filteredClients.isEmpty) {
            return const Center(
              child: Text('Nenhum cliente encontrado'),
            );
          }

          return ListView.builder(
            itemCount: filteredClients.length,
            itemBuilder: (context, index) {
              final client = filteredClients[index];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(client.name[0].toUpperCase()),
                ),
                title: Text(client.name),
                subtitle: Text(client.phone),
                onTap: () => context.go('/clients/${client.id}'),
              );
            },
          );
        },
      ),
    );
  }
}
