import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../services/app_services.dart';
import '../../services/client_status_classifier.dart';

class ClientsScreen extends StatefulWidget {
  const ClientsScreen({super.key});

  @override
  State<ClientsScreen> createState() => _ClientsScreenState();
}

class _ClientsScreenState extends State<ClientsScreen> {
  final _searchController = TextEditingController();
  String _searchQuery = '';
  String? _statusFilter; // null = todos

  static const _statusOptions = [
    (value: null, label: 'Todos'),
    (value: 'ativo', label: 'Ativo'),
    (value: 'novo', label: 'Novo'),
    (value: 'em risco', label: 'Em risco'),
    (value: 'pausado', label: 'Pausado'),
    (value: 'inativo', label: 'Inativo'),
    (value: '_no_return', label: 'Sem retorno'),
    (value: '_no_next_session', label: 'Sem próxima sessão'),
    (value: '_inadimplente', label: 'Inadimplente'),
    (value: '_pacote_acabando', label: 'Pacote acabando'),
  ];

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
          preferredSize: const Size.fromHeight(100),
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 8, 4),
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
              SizedBox(
                height: 38,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.fromLTRB(8, 0, 8, 4),
                  children: _statusOptions.map((opt) {
                    final selected = _statusFilter == opt.value;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6),
                      child: FilterChip(
                        label: Text(opt.label),
                        selected: selected,
                        onSelected: (_) => setState(
                          () => _statusFilter = selected ? null : opt.value,
                        ),
                        visualDensity: VisualDensity.compact,
                      ),
                    );
                  }).toList(),
                ),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _showNewClientDialog,
        child: const Icon(Icons.person_add),
      ),
      body: FutureBuilder<(List<Client>, List<Session>, List<Package>)>(
        future: Future.wait([
          ClientService.instance.getClients(),
          SessionService.instance.getSessions(),
          PackageService.instance.getPackages(),
        ]).then((r) => (
              r[0] as List<Client>,
              r[1] as List<Session>,
              r[2] as List<Package>,
            )),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Erro: ${snapshot.error}'));
          }

          final clients = snapshot.data?.$1 ?? [];
          final allSessions = snapshot.data?.$2 ?? [];
          final allPackages = snapshot.data?.$3 ?? [];
          final now = DateTime.now();

          // Classifica todos os clientes de uma vez
          final statusMap = <String, ClientStatusResult>{};
          for (final r in ClientStatusClassifier.instance.classifyAll(
            clients: clients,
            allSessions: allSessions,
            allPackages: allPackages,
          )) {
            statusMap[r.client.id] = r;
          }

          // Aplica filtro de texto
          var filtered = _searchQuery.isEmpty
              ? clients
              : clients
                  .where((c) =>
                      c.name
                          .toLowerCase()
                          .contains(_searchQuery.toLowerCase()) ||
                      c.phone.contains(_searchQuery))
                  .toList();

          // Aplica filtro de status CRM ou filtros especiais
          if (_statusFilter == '_no_return') {
            filtered = filtered.where((c) {
              final cs = allSessions
                  .where((s) => s.clientId == c.id && s.deletedAt == null)
                  .toList();
              if (cs.isEmpty) return false;
              cs.sort((a, b) => b.dateTime.compareTo(a.dateTime));
              return now.difference(cs.first.dateTime).inDays > 30;
            }).toList();
          } else if (_statusFilter == '_no_next_session') {
            final futureSessions = allSessions
                .where((s) =>
                    s.deletedAt == null &&
                    s.dateTime.isAfter(now) &&
                    s.status != 'cancelado' &&
                    s.status != 'faltou')
                .map((s) => s.clientId)
                .toSet();
            filtered = filtered
                .where((c) =>
                    c.isActive &&
                    !futureSessions.contains(c.id) &&
                    allSessions.any(
                        (s) => s.clientId == c.id && s.dateTime.isBefore(now)))
                .toList();
          } else if (_statusFilter == '_inadimplente') {
            filtered = filtered
                .where((c) =>
                    statusMap[c.id]?.status ==
                    AutoClientStatus.inadimplente)
                .toList();
          } else if (_statusFilter == '_pacote_acabando') {
            filtered = filtered
                .where((c) =>
                    statusMap[c.id]?.status ==
                    AutoClientStatus.pacoteAcabando)
                .toList();
          } else if (_statusFilter != null) {
            filtered = filtered
                .where((c) => c.clientStatus == _statusFilter)
                .toList();
          }

          if (filtered.isEmpty) {
            if (_searchQuery.isNotEmpty || _statusFilter != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.search_off, size: 64, color: Colors.grey),
                    const SizedBox(height: 16),
                    Text(
                      'Nenhum cliente encontrado',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Tente outros filtros ou termos',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                    ),
                  ],
                ),
              );
            }

            return Center(
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.people_outline, size: 80, color: Colors.grey),
                    const SizedBox(height: 24),
                    Text(
                      'Nenhum cliente cadastrado ainda',
                      style: Theme.of(context).textTheme.titleLarge,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Adicione seu primeiro cliente para começar a usar o TheraFlow',
                      style: Theme.of(context)
                          .textTheme
                          .bodyMedium
                          ?.copyWith(color: Colors.grey),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 32),
                    ElevatedButton.icon(
                      onPressed: _showNewClientDialog,
                      icon: const Icon(Icons.person_add),
                      label: const Text('Adicionar Cliente'),
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 24, vertical: 16),
                      ),
                    ),
                  ],
                ),
              ),
            );
          }

          // Ordena: status mais urgentes primeiro quando não há filtro ativo
          if (_statusFilter == null && _searchQuery.isEmpty) {
            filtered.sort((a, b) {
              final sa = statusMap[a.id]?.status.priority ?? 99;
              final sb = statusMap[b.id]?.status.priority ?? 99;
              if (sa != sb) return sa.compareTo(sb);
              return a.name.compareTo(b.name);
            });
          }

          return ListView.builder(
            itemCount: filtered.length,
            itemBuilder: (context, index) {
              final client = filtered[index];
              final autoStatus = statusMap[client.id];
              return ListTile(
                leading: CircleAvatar(
                  child: Text(
                    client.name.isNotEmpty
                        ? client.name[0].toUpperCase()
                        : '?',
                  ),
                ),
                title: Text(client.name),
                subtitle: Text(client.phone),
                trailing: autoStatus != null
                    ? _AutoStatusBadge(status: autoStatus.status)
                    : _ClientStatusBadge(status: client.clientStatus),
                onTap: () => context.go('/clients/${client.id}'),
              );
            },
          );
        },
      ),
    );
  }
}

// ─── Badge de status CRM ─────────────────────────────────────────────────────
class _ClientStatusBadge extends StatelessWidget {
  final String status;
  const _ClientStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _color(String s) {
    switch (s) {
      case 'ativo':
        return Colors.green[700]!;
      case 'em risco':
        return Colors.orange[700]!;
      case 'inativo':
        return Colors.red[700]!;
      case 'pausado':
        return Colors.blue[600]!;
      case 'novo':
        return Colors.purple[600]!;
      default:
        return Colors.grey[600]!;
    }
  }
}

// ─── Badge de status automático (classificado por regras) ───────────────────
class _AutoStatusBadge extends StatelessWidget {
  final AutoClientStatus status;
  const _AutoStatusBadge({required this.status});

  @override
  Widget build(BuildContext context) {
    final color = _color(status);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color.withValues(alpha: 0.35)),
      ),
      child: Text(
        status.label,
        style: TextStyle(
            fontSize: 11, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _color(AutoClientStatus s) {
    switch (s) {
      case AutoClientStatus.ativo:
        return Colors.green[700]!;
      case AutoClientStatus.emRisco:
        return Colors.orange[700]!;
      case AutoClientStatus.inativo:
        return Colors.red[700]!;
      case AutoClientStatus.inadimplente:
        return Colors.red[900]!;
      case AutoClientStatus.pacoteAcabando:
        return Colors.deepPurple[600]!;
      case AutoClientStatus.novo:
        return Colors.purple[600]!;
    }
  }
}
