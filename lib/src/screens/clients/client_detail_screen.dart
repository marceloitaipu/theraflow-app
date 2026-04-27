import 'package:flutter/material.dart';

import 'package:go_router/go_router.dart';

import 'package:intl/intl.dart';

import 'package:url_launcher/url_launcher.dart';



import '../../config/app_config.dart';

import '../../services/app_services.dart';

import '../../services/client_insights_service.dart';

import '../../utils/message_templates.dart';

import '../../widgets/section_title.dart';



class ClientDetailScreen extends StatefulWidget {

  final String clientId;

  const ClientDetailScreen({super.key, required this.clientId});



  @override

  State<ClientDetailScreen> createState() => _ClientDetailScreenState();

}



class _ClientDetailScreenState extends State<ClientDetailScreen>

    with SingleTickerProviderStateMixin {

  late TabController _tabController;



  @override

  void initState() {

    super.initState();

    _tabController = TabController(length: 5, vsync: this);

  }



  @override

  void dispose() {

    _tabController.dispose();

    super.dispose();

  }



  void _showEditDialog(Client client) {

    final nameController = TextEditingController(text: client.name);

    final phoneController = TextEditingController(text: client.phone);

    final notesController = TextEditingController(text: client.notes);

    final goalController = TextEditingController(text: client.goal ?? '');

    final nextActionController = TextEditingController(text: client.nextAction ?? '');

    String selectedFrequency = client.idealFrequency ?? '';

    String selectedClientStatus = client.clientStatus;



    showDialog(

      context: context,

      builder: (ctx) => StatefulBuilder(

        builder: (ctx, setLocalState) => AlertDialog(

          title: const Text('Editar Cliente'),

          content: SingleChildScrollView(

            child: Column(

              mainAxisSize: MainAxisSize.min,

              crossAxisAlignment: CrossAxisAlignment.start,

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

                  controller: goalController,

                  decoration: const InputDecoration(

                    labelText: 'Objetivo',

                    hintText: 'ex: tratar lombalgia',

                  ),

                ),

                TextField(

                  controller: notesController,

                  decoration: const InputDecoration(labelText: 'Observações'),

                  maxLines: 2,

                ),

                const SizedBox(height: 8),

                TextField(

                  controller: nextActionController,

                  decoration: const InputDecoration(

                    labelText: 'Próxima ação',

                    hintText: 'ex: ligar para confirmar retorno',

                  ),

                ),

                const SizedBox(height: 12),

                DropdownButtonFormField<String>(

                  initialValue: selectedFrequency.isEmpty ? null : selectedFrequency,

                  decoration: const InputDecoration(labelText: 'Frequência ideal'),

                  items: const [

                    DropdownMenuItem(value: 'semanal', child: Text('Semanal')),

                    DropdownMenuItem(value: 'quinzenal', child: Text('Quinzenal')),

                    DropdownMenuItem(value: 'mensal', child: Text('Mensal')),

                  ],

                  onChanged: (v) => setLocalState(() => selectedFrequency = v ?? ''),

                ),

                const SizedBox(height: 8),

                DropdownButtonFormField<String>(

                  initialValue: selectedClientStatus,

                  decoration: const InputDecoration(labelText: 'Status CRM'),

                  items: const [

                    DropdownMenuItem(value: 'novo', child: Text('Novo')),

                    DropdownMenuItem(value: 'ativo', child: Text('Ativo')),

                    DropdownMenuItem(value: 'pausado', child: Text('Pausado')),

                    DropdownMenuItem(value: 'em risco', child: Text('Em risco')),

                    DropdownMenuItem(value: 'inativo', child: Text('Inativo')),

                  ],

                  onChanged: (v) => setLocalState(() => selectedClientStatus = v ?? 'ativo'),

                ),

              ],

            ),

          ),

          actions: [

            TextButton(

              onPressed: () => Navigator.pop(ctx),

              child: const Text('Cancelar'),

            ),

            FilledButton(

              onPressed: () async {

                try {

                  await ClientService.instance.updateClient(

                    client.id,

                    name: nameController.text.trim(),

                    phone: phoneController.text.trim(),

                    notes: notesController.text.trim(),

                    goal: goalController.text.trim().isEmpty ? null : goalController.text.trim(),

                    idealFrequency: selectedFrequency.isEmpty ? null : selectedFrequency,

                    clientStatus: selectedClientStatus,

                    nextAction: nextActionController.text.trim().isEmpty

                        ? null

                        : nextActionController.text.trim(),

                  );

                  if (ctx.mounted) {

                    Navigator.pop(ctx);

                    ScaffoldMessenger.of(ctx).showSnackBar(

                      const SnackBar(content: Text('Cliente atualizado!')),

                    );

                    setState(() {});

                  }

                } catch (e) {

                  if (ctx.mounted) {

                    ScaffoldMessenger.of(ctx).showSnackBar(

                      SnackBar(content: Text('Erro: $e')),

                    );

                  }

                }

              },

              child: const Text('Salvar'),

            ),

          ],

        ),

      ),

    );

  }



  void _showDeleteDialog(Client client) {

    showDialog(

      context: context,

      builder: (ctx) => AlertDialog(

        title: const Text('Excluir Cliente'),

        content: Text('Deseja realmente excluir ${client.name}?'),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(ctx),

            child: const Text('Cancelar'),

          ),

          FilledButton(

            onPressed: () async {

              try {

                await ClientService.instance.deleteClient(client.id);

                if (ctx.mounted) {

                  Navigator.pop(ctx);

                  ctx.go('/clients');

                }

              } catch (e) {

                if (ctx.mounted) {

                  ScaffoldMessenger.of(ctx).showSnackBar(

                    SnackBar(content: Text('Erro: $e')),

                  );

                }

              }

            },

            style: FilledButton.styleFrom(backgroundColor: Colors.red),

            child: const Text('Excluir'),

          ),

        ],

      ),

    );

  }



  Future<void> _openWhatsApp(String phone, {String? clientName}) async {

    if (!isValidBrazilianPhone(phone)) {

      if (mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text('Telefone inválido ou sem número cadastrado.'),

          ),

        );

      }

      return;

    }

    if (!mounted) return;

    await showModalBottomSheet(

      context: context,

      isScrollControlled: true,

      shape: const RoundedRectangleBorder(

        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),

      ),

      builder: (ctx) => _WhatsAppTemplateSheet(

        phone: phone,

        clientName: clientName ?? '',

      ),

    );

  }



  @override

  Widget build(BuildContext context) {

    return FutureBuilder<Client?>(

      future: ClientService.instance.getClientById(widget.clientId),

      builder: (context, snapshot) {

        if (snapshot.connectionState == ConnectionState.waiting) {

          return const Scaffold(body: Center(child: CircularProgressIndicator()));

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

              if (client.phone.isNotEmpty)

                IconButton(

                  icon: const Icon(Icons.chat_outlined),

                  tooltip: 'WhatsApp',

                  onPressed: () => _openWhatsApp(client.phone, clientName: client.name),

                ),

              IconButton(icon: const Icon(Icons.edit), onPressed: () => _showEditDialog(client)),

              IconButton(

                  icon: const Icon(Icons.delete_outline),

                  onPressed: () => _showDeleteDialog(client)),

            ],

            bottom: TabBar(

              controller: _tabController,

              isScrollable: true,

              tabAlignment: TabAlignment.start,

              tabs: const [

                Tab(text: 'Resumo'),

                Tab(text: 'Sessões'),

                Tab(text: 'Financeiro'),

                Tab(text: 'Pacotes'),

                Tab(text: 'Observações'),

              ],

            ),

          ),

          floatingActionButton: FloatingActionButton.extended(

            onPressed: () => context.push('/session/new?clientId=${client.id}'),

            icon: const Icon(Icons.add),

            label: const Text('Nova sessão'),

          ),

          body: TabBarView(

            controller: _tabController,

            children: [

              _ResumoTab(client: client, onEdit: () => _showEditDialog(client)),

              _SessoesTab(clientId: client.id),

              _FinanceiroTab(clientId: client.id),

              _PacotesTab(clientId: client.id),

              _ObservacoesTab(client: client, onEdit: () => _showEditDialog(client)),

            ],

          ),

        );

      },

    );

  }

}



// ─── Aba Resumo ──────────────────────────────────────────────────────────────

class _ResumoTab extends StatelessWidget {

  final Client client;

  final VoidCallback onEdit;



  const _ResumoTab({required this.client, required this.onEdit});



  @override

  Widget build(BuildContext context) {

    return FutureBuilder<ClientInsight>(

      future: ClientInsightsService.instance.getInsight(client.id),

      builder: (context, snap) {

        final insight = snap.data;

        final isLoading = snap.connectionState == ConnectionState.waiting;



        return ListView(

          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

          children: [

            // Cabeçalho com avatar + status

            _ClientHeader(client: client, insight: insight),

            const SizedBox(height: 16),



            // Próxima ação em destaque (se existir)

            if (client.nextAction != null && client.nextAction!.isNotEmpty) ...[

              _NextActionBanner(action: client.nextAction!),

              const SizedBox(height: 12),

            ],



            // Métricas

            if (isLoading)

              const Center(child: CircularProgressIndicator())

            else if (insight != null)

              _MetricsGrid(insight: insight)

            else

              const SizedBox.shrink(),



            if (client.goal != null && client.goal!.isNotEmpty) ...[

              const SizedBox(height: 16),

              _InfoCard(

                icon: Icons.flag_outlined,

                title: 'Objetivo',

                value: client.goal!,

              ),

            ],

            if (client.idealFrequency != null && client.idealFrequency!.isNotEmpty) ...[

              const SizedBox(height: 8),

              _InfoCard(

                icon: Icons.repeat,

                title: 'Frequência ideal',

                value: _freqLabel(client.idealFrequency!),

              ),

            ],

            if (client.phone.isNotEmpty) ...[

              const SizedBox(height: 8),

              _InfoCard(icon: Icons.phone_outlined, title: 'Telefone', value: client.phone),

            ],



            // Tags

            if (client.tags.isNotEmpty) ...[

              const SizedBox(height: 16),

              const SectionTitle('Tags'),

              Wrap(

                spacing: 8,

                runSpacing: 4,

                children: client.tags.map((tag) => _TagChip(tag: tag)).toList(),

              ),

            ],



            if (insight != null && insight.nextSession != null) ...[

              const SizedBox(height: 16),

              _NextSessionBanner(session: insight.nextSession!),

            ],



            const SizedBox(height: 16),

            OutlinedButton.icon(

              onPressed: onEdit,

              icon: const Icon(Icons.edit_outlined, size: 16),

              label: const Text('Editar perfil'),

            ),

          ],

        );

      },

    );

  }



  String _freqLabel(String f) {

    switch (f) {

      case 'semanal':

        return 'Semanal';

      case 'quinzenal':

        return 'Quinzenal';

      case 'mensal':

        return 'Mensal';

      default:

        return f;

    }

  }

}



class _ClientHeader extends StatelessWidget {

  final Client client;

  final ClientInsight? insight;



  const _ClientHeader({required this.client, this.insight});



  @override

  Widget build(BuildContext context) {

    final name = client.name;

    final statusLabel = insight?.inferredStatus ?? client.clientStatus;

    final statusColor = _statusColor(statusLabel);



    return Row(

      children: [

        CircleAvatar(

          radius: 30,

          backgroundColor: Theme.of(context).colorScheme.primaryContainer,

          child: Text(

            name.isNotEmpty ? name[0].toUpperCase() : '?',

            style: TextStyle(

              fontSize: 24,

              fontWeight: FontWeight.bold,

              color: Theme.of(context).colorScheme.primary,

            ),

          ),

        ),

        const SizedBox(width: 16),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(

                name,

                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),

              ),

              const SizedBox(height: 4),

              Container(

                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),

                decoration: BoxDecoration(

                  color: statusColor.withValues(alpha: 0.15),

                  borderRadius: BorderRadius.circular(8),

                  border: Border.all(color: statusColor.withValues(alpha: 0.4)),

                ),

                child: Text(

                  statusLabel,

                  style: TextStyle(

                    fontSize: 12,

                    color: statusColor,

                    fontWeight: FontWeight.w600,

                  ),

                ),

              ),

            ],

          ),

        ),

      ],

    );

  }



  Color _statusColor(String s) {

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



class _MetricsGrid extends StatelessWidget {

  final ClientInsight insight;



  const _MetricsGrid({required this.insight});



  @override

  Widget build(BuildContext context) {

    final currFmt = NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$');

    final dateFmt = DateFormat('dd/MM/yy');



    return Column(

      children: [

        Row(

          children: [

            _MetricCard(label: 'Total sessões', value: '${insight.totalSessions}',

                icon: Icons.event_available, color: Colors.blue),

            const SizedBox(width: 8),

            _MetricCard(

                label: 'Total recebido',

                value: currFmt.format(insight.totalPaid),

                icon: Icons.attach_money,

                color: Colors.green),

          ],

        ),

        const SizedBox(height: 8),

        Row(

          children: [

            _MetricCard(

                label: 'Faltas',

                value: '${insight.missedSessions}',

                icon: Icons.person_off_outlined,

                color: insight.missedSessions > 0 ? Colors.red : Colors.grey),

            const SizedBox(width: 8),

            _MetricCard(

                label: insight.daysSinceLastSession != null

                    ? 'Último atend.'

                    : 'Sem sessões',

                value: insight.lastSession != null

                    ? dateFmt.format(insight.lastSession!.dateTime)

                    : '—',

                icon: Icons.history,

                color: _riskColor(insight.daysSinceLastSession)),

          ],

        ),

        if (insight.totalPending > 0) ...[

          const SizedBox(height: 8),

          Container(

            width: double.infinity,

            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),

            decoration: BoxDecoration(

              color: Colors.orange.withValues(alpha: 0.1),

              borderRadius: BorderRadius.circular(10),

              border: Border.all(color: Colors.orange.withValues(alpha: 0.4)),

            ),

            child: Row(

              children: [

                const Icon(Icons.payment_outlined, color: Colors.orange, size: 18),

                const SizedBox(width: 8),

                Text(

                  'Pendente: ${currFmt.format(insight.totalPending)}',

                  style: const TextStyle(

                      color: Colors.orange, fontWeight: FontWeight.w600),

                ),

              ],

            ),

          ),

        ],

      ],

    );

  }



  Color _riskColor(int? days) {

    if (days == null) return Colors.grey;

    if (days > 60) return Colors.red;

    if (days > 30) return Colors.orange;

    return Colors.teal;

  }

}



class _MetricCard extends StatelessWidget {

  final String label;

  final String value;

  final IconData icon;

  final Color color;



  const _MetricCard({

    required this.label,

    required this.value,

    required this.icon,

    required this.color,

  });



  @override

  Widget build(BuildContext context) {

    return Expanded(

      child: Container(

        padding: const EdgeInsets.all(12),

        decoration: BoxDecoration(

          color: color.withValues(alpha: 0.08),

          borderRadius: BorderRadius.circular(10),

          border: Border.all(color: color.withValues(alpha: 0.25)),

        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Icon(icon, size: 18, color: color),

            const SizedBox(height: 6),

            Text(value,

                style: TextStyle(

                    fontSize: 18, fontWeight: FontWeight.bold, color: color)),

            Text(label,

                style: TextStyle(
                    fontSize: 11,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),

                maxLines: 1,

                overflow: TextOverflow.ellipsis),

          ],

        ),

      ),

    );

  }

}



class _InfoCard extends StatelessWidget {

  final IconData icon;

  final String title;

  final String value;



  const _InfoCard({required this.icon, required this.title, required this.value});



  @override

  Widget build(BuildContext context) {

    return Row(

      crossAxisAlignment: CrossAxisAlignment.start,

      children: [

        Icon(icon, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),

        const SizedBox(width: 10),

        Expanded(

          child: Column(

            crossAxisAlignment: CrossAxisAlignment.start,

            children: [

              Text(title, style: TextStyle(fontSize: 11, color: Theme.of(context).colorScheme.onSurfaceVariant)),

              Text(value, style: const TextStyle(fontSize: 14)),

            ],

          ),

        ),

      ],

    );

  }

}



class _TagChip extends StatelessWidget {

  final String tag;

  const _TagChip({required this.tag});



  @override

  Widget build(BuildContext context) {

    final color = _tagColor(tag);

    return Chip(

      label: Text(tag, style: TextStyle(fontSize: 12, color: color)),

      backgroundColor: color.withValues(alpha: 0.12),

      side: BorderSide(color: color.withValues(alpha: 0.3)),

      materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,

      padding: EdgeInsets.zero,

    );

  }



  Color _tagColor(String t) {

    switch (t.toLowerCase()) {

      case 'vip':

        return Colors.amber[800]!;

      case 'inadimplente':

        return Colors.red;

      case 'pacote':

        return Colors.blue;

      case 'novo':

        return Colors.purple;

      default:

        return Colors.teal;

    }

  }

}



class _NextSessionBanner extends StatelessWidget {

  final Session session;

  const _NextSessionBanner({required this.session});



  @override

  Widget build(BuildContext context) {

    final fmt = DateFormat("d 'de' MMMM 'às' HH:mm", 'pt_BR');

    return Container(

      padding: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: Colors.blue.withValues(alpha: 0.08),

        borderRadius: BorderRadius.circular(10),

        border: Border.all(color: Colors.blue.withValues(alpha: 0.3)),

      ),

      child: Row(

        children: [

          const Icon(Icons.event_outlined, color: Colors.blue, size: 20),

          const SizedBox(width: 10),

          Expanded(

            child: Column(

              crossAxisAlignment: CrossAxisAlignment.start,

              children: [

                const Text('Próxima sessão',

                    style: TextStyle(fontSize: 11, color: Colors.blue)),

                Text(fmt.format(session.dateTime),

                    style: const TextStyle(fontWeight: FontWeight.w600)),

              ],

            ),

          ),

          TextButton(

            onPressed: () => context.go('/session/${session.id}'),

            child: const Text('Ver'),

          ),

        ],

      ),

    );

  }

}



// ─── Aba Sessões ─────────────────────────────────────────────────────────────

class _SessoesTab extends StatelessWidget {

  final String clientId;

  const _SessoesTab({required this.clientId});



  @override

  Widget build(BuildContext context) {

    return StreamBuilder<List<Session>>(

      stream: SessionService.instance.getClientSessionsStream(clientId),

      builder: (context, snap) {

        final sessions = snap.data ?? [];



        if (snap.connectionState == ConnectionState.waiting && sessions.isEmpty) {

          return const Center(child: CircularProgressIndicator());

        }



        if (sessions.isEmpty) {

          return Center(

            child: Column(

              mainAxisAlignment: MainAxisAlignment.center,

              children: [

                Icon(Icons.event_note, size: 56, color: Colors.grey[300]),

                const SizedBox(height: 12),

                Text('Nenhuma sessão registrada',

                    style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),

              ],

            ),

          );

        }



        return ListView.builder(

          padding: const EdgeInsets.only(bottom: 80),

          itemCount: sessions.length,

          itemBuilder: (ctx, i) => _SessionTile(session: sessions[i]),

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

    final dateFmt = DateFormat('dd/MM/yyyy HH:mm');

    final currFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');



    return ListTile(

      leading: Icon(

        _statusIcon(session.status),

        color: _statusColor(session.status),

      ),

      title: Text('${dateFmt.format(session.dateTime)} — ${session.therapyType}'),

      subtitle: Text('${currFmt.format(session.value)} • ${session.paymentStatus}'),

      trailing: session.paymentStatus == 'pago'

          ? const Icon(Icons.attach_money, color: Colors.green)

          : const Icon(Icons.pending_outlined, color: Colors.orange),

      onTap: () => context.go('/session/${session.id}'),

    );

  }



  IconData _statusIcon(String s) {

    switch (s) {

      case 'confirmado':

        return Icons.check_circle_outline;

      case 'realizada':

        return Icons.done_all;

      case 'faltou':

        return Icons.cancel_outlined;

      case 'remarcado':

        return Icons.swap_horiz;

      default:

        return Icons.event;

    }

  }



  Color _statusColor(String s) {

    switch (s) {

      case 'confirmado':

        return Colors.green;

      case 'realizada':

        return Colors.teal;

      case 'faltou':

        return Colors.red;

      case 'remarcado':

        return Colors.orange;

      default:

        return Colors.blue;

    }

  }

}



// ─── Aba Financeiro ──────────────────────────────────────────────────────────

class _FinanceiroTab extends StatelessWidget {

  final String clientId;

  const _FinanceiroTab({required this.clientId});



  @override

  Widget build(BuildContext context) {

    return FutureBuilder<ClientInsight>(

      future: ClientInsightsService.instance.getInsight(clientId),

      builder: (context, snap) {

        final insight = snap.data;



        return ListView(

          padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),

          children: [

            if (insight != null) ...[

              _FinanceSummary(insight: insight),

              const SizedBox(height: 16),

            ],

            _PackagesSection(clientId: clientId),

          ],

        );

      },

    );

  }

}



class _FinanceSummary extends StatelessWidget {

  final ClientInsight insight;

  const _FinanceSummary({required this.insight});



  @override

  Widget build(BuildContext context) {

    final currFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');



    return Card(

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            const Text('Resumo financeiro',

                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),

            const Divider(),

            _FinRow(label: 'Total recebido', value: currFmt.format(insight.totalPaid),

                color: Colors.green),

            _FinRow(label: 'Total pendente', value: currFmt.format(insight.totalPending),

                color: insight.totalPending > 0 ? Colors.orange : Colors.grey),

            _FinRow(

              label: 'Total geral',

              value: currFmt.format(insight.totalPaid + insight.totalPending),

              color: Theme.of(context).colorScheme.onSurface,

              bold: true,

            ),

          ],

        ),

      ),

    );

  }

}



class _FinRow extends StatelessWidget {

  final String label;

  final String value;

  final Color color;

  final bool bold;



  const _FinRow({

    required this.label,

    required this.value,

    required this.color,

    this.bold = false,

  });



  @override

  Widget build(BuildContext context) {

    return Padding(

      padding: const EdgeInsets.symmetric(vertical: 4),

      child: Row(

        mainAxisAlignment: MainAxisAlignment.spaceBetween,

        children: [

          Text(label, style: TextStyle(fontWeight: bold ? FontWeight.bold : FontWeight.normal)),

          Text(value,

              style: TextStyle(

                  color: color, fontWeight: bold ? FontWeight.bold : FontWeight.w500)),

        ],

      ),

    );

  }

}



// ─── Seção de pacotes (mantida do original) ──────────────────────────────────

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

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Row(

                  children: [

                    const Icon(Icons.inventory_2_outlined, size: 20),

                    const SizedBox(width: 8),

                    const Text('Pacotes',

                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),

                    if (!canUsePackages) ...[

                      const SizedBox(width: 6),

                      Container(

                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),

                        decoration: BoxDecoration(

                            color: Colors.amber,

                            borderRadius: BorderRadius.circular(4)),

                        child: const Text('PRO',

                            style:

                                TextStyle(fontSize: 10, fontWeight: FontWeight.bold)),

                      ),

                    ],

                  ],

                ),

                TextButton.icon(

                  onPressed: canUsePackages

                      ? () => context.push('/clients/$clientId/package/new')

                      : () => context.push('/paywall'),

                  icon: Icon(canUsePackages ? Icons.add : Icons.lock, size: 16),

                  label: Text(canUsePackages ? 'Novo pacote' : 'Desbloquear'),

                ),

              ],

            ),

            if (canUsePackages)

              FutureBuilder<List<Package>>(

                future: PackageService.instance.listPackages(clientId),

                builder: (context, snapshot) {

                  if (snapshot.connectionState == ConnectionState.waiting) {

                    return const Center(child: CircularProgressIndicator());

                  }

                  final packages = snapshot.data ?? [];

                  if (packages.isEmpty) {

                    return Padding(

                      padding: const EdgeInsets.symmetric(vertical: 16),

                      child: Center(

                        child: Text('Nenhum pacote',

                            style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant)),

                      ),

                    );

                  }

                  return Column(

                    children:

                        packages.map((pkg) => _PackageTile(package: pkg)).toList(),

                  );

                },

              )

            else

              Container(

                margin: const EdgeInsets.only(top: 8),

                padding: const EdgeInsets.all(16),

                decoration: BoxDecoration(

                  color: Colors.grey[100],

                  borderRadius: BorderRadius.circular(12),

                  border: Border.all(color: Colors.grey[300]!),

                ),

                child: Column(

                  children: [

                    Icon(Icons.lock, color: Colors.grey[400], size: 28),

                    const SizedBox(height: 8),

                    Text('Pacotes são recursos PRO',

                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),

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

      if (AppConfig.isWebTestMode) return true;

      final user = await AuthService.instance.getCurrentUserData();

      return user?.canUsePackages() ?? false;

    } catch (_) {

      return false;

    }

  }

}



class _PackageTile extends StatelessWidget {

  final Package package;

  const _PackageTile({required this.package});



  @override

  Widget build(BuildContext context) {

    final currFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    final dateFmt = DateFormat('dd/MM/yyyy');

    final isLow = package.isLow;

    final isExpired = package.isExpired;

    final needsRenewal = isLow || isExpired || package.remainingSessions == 0;



    return Card(

      margin: const EdgeInsets.only(top: 8),

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

                    const SizedBox(width: 6),

                    const Text('sessões restantes'),

                  ],

                ),

                Container(

                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),

                  decoration: BoxDecoration(

                    color: _statusColor(package.status),

                    borderRadius: BorderRadius.circular(12),

                  ),

                  child: Text(

                    _statusLabel(package.status),

                    style: const TextStyle(

                        color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),

                  ),

                ),

              ],

            ),

            const SizedBox(height: 8),

            LinearProgressIndicator(

              value: package.usagePercentage / 100,

              backgroundColor: Colors.grey[200],

              color: isLow ? Colors.orange : Colors.green,

            ),

            const SizedBox(height: 8),

            Row(

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Text(currFmt.format(package.price)),

                if (package.expirationDate != null)

                  Text(

                    'Expira: ${dateFmt.format(package.expirationDate!)}',

                    style: TextStyle(

                        color: isExpired ? Colors.red : Theme.of(context).colorScheme.onSurfaceVariant,

                        fontSize: 12),

                  ),

              ],

            ),

            if (needsRenewal) ...[

              const SizedBox(height: 10),

              SizedBox(

                width: double.infinity,

                child: OutlinedButton.icon(

                  onPressed: () => _quickRenew(context),

                  icon: const Icon(Icons.refresh, size: 16),

                  label: const Text('Renovar pacote'),

                  style: OutlinedButton.styleFrom(

                    foregroundColor: Colors.deepPurple,

                    side: const BorderSide(color: Colors.deepPurple),

                    visualDensity: VisualDensity.compact,

                    padding: const EdgeInsets.symmetric(vertical: 8),

                  ),

                ),

              ),

            ],

          ],

        ),

      ),

    );

  }



  Future<void> _quickRenew(BuildContext context) async {

    final totalCtrl = TextEditingController(text: package.totalSessions.toString());

    final priceCtrl = TextEditingController(text: package.price.toStringAsFixed(2));



    final confirmed = await showDialog<bool>(

      context: context,

      builder: (ctx) => AlertDialog(

        title: const Text('Renovar pacote'),

        content: Column(

          mainAxisSize: MainAxisSize.min,

          children: [

            TextField(

              controller: totalCtrl,

              keyboardType: TextInputType.number,

              decoration: const InputDecoration(

                labelText: 'Total de sessões',

                border: OutlineInputBorder(),

              ),

            ),

            const SizedBox(height: 12),

            TextField(

              controller: priceCtrl,

              keyboardType: const TextInputType.numberWithOptions(decimal: true),

              decoration: const InputDecoration(

                labelText: 'Valor do pacote (R\$)',

                border: OutlineInputBorder(),

              ),

            ),

          ],

        ),

        actions: [

          TextButton(

            onPressed: () => Navigator.pop(ctx, false),

            child: const Text('Cancelar'),

          ),

          ElevatedButton(

            onPressed: () => Navigator.pop(ctx, true),

            child: const Text('Renovar'),

          ),

        ],

      ),

    );



    if (confirmed != true || !context.mounted) return;

    try {

      final total = int.tryParse(totalCtrl.text.trim()) ?? package.totalSessions;

      final price = double.tryParse(priceCtrl.text.trim().replaceAll(',', '.')) ?? package.price;

      await PackageService.instance.createPackage(

        clientId: package.clientId,

        totalSessions: total,

        price: price,

      );

      if (context.mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          const SnackBar(

            content: Text('Pacote renovado com sucesso!'),

            backgroundColor: Colors.green,

          ),

        );

      }

    } catch (e) {

      if (context.mounted) {

        ScaffoldMessenger.of(context).showSnackBar(

          SnackBar(content: Text('Erro ao renovar: $e')),

        );

      }

    }

  }



  Color _statusColor(String s) {

    switch (s) {

      case 'active':

        return Colors.green;

      case 'completed':

        return Colors.blue;

      case 'expired':

        return Colors.red;

      case 'cancelled':

        return Colors.grey;

      default:

        return Colors.grey;

    }

  }



  String _statusLabel(String s) {

    switch (s) {

      case 'active':

        return 'ativo';

      case 'completed':

        return 'concluído';

      case 'expired':

        return 'vencido';

      case 'cancelled':

        return 'cancelado';

      default:

        return s;

    }

  }

}

// ─── Banner de próxima ação ──────────────────────────────────────────────────
class _NextActionBanner extends StatelessWidget {
  final String action;
  const _NextActionBanner({required this.action});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.deepPurple.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.deepPurple.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.bolt_outlined, color: Colors.deepPurple, size: 20),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Próxima ação',
                  style: TextStyle(fontSize: 11, color: Colors.deepPurple),
                ),
                Text(action,
                    style: const TextStyle(
                        fontWeight: FontWeight.w600, fontSize: 14)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Aba Pacotes ─────────────────────────────────────────────────────────────
class _PacotesTab extends StatelessWidget {
  final String clientId;
  const _PacotesTab({required this.clientId});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        _PackagesSection(clientId: clientId),
      ],
    );
  }
}

// ─── Aba Observações ─────────────────────────────────────────────────────────
class _ObservacoesTab extends StatelessWidget {
  final Client client;
  final VoidCallback onEdit;
  const _ObservacoesTab({required this.client, required this.onEdit});

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 100),
      children: [
        if (client.notes.isNotEmpty) ...[
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.notes, size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      const Text('Observações',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(client.notes),
                ],
              ),
            ),
          ),
        ] else ...[
          Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                children: [
                  Icon(Icons.notes_outlined, size: 56, color: Colors.grey[300]),
                  const SizedBox(height: 12),
                  Text('Nenhuma observação',
                      style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant)),
                  const SizedBox(height: 16),
                  OutlinedButton.icon(
                    onPressed: onEdit,
                    icon: const Icon(Icons.edit_outlined, size: 16),
                    label: const Text('Adicionar observação'),
                  ),
                ],
              ),
            ),
          ),
        ],
        if (client.goal != null && client.goal!.isNotEmpty) ...[
          const SizedBox(height: 16),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.flag_outlined,
                          size: 18, color: Theme.of(context).colorScheme.onSurfaceVariant),
                      const SizedBox(width: 8),
                      const Text('Objetivo terapêutico',
                          style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(client.goal!),
                ],
              ),
            ),
          ),
        ],
      ],
    );
  }
}

// ─── WhatsApp: bottom sheet com mensagens prontas ────────────────────────────
class _WhatsAppTemplateSheet extends StatefulWidget {
  final String phone;
  final String clientName;

  const _WhatsAppTemplateSheet({
    required this.phone,
    required this.clientName,
  });

  @override
  State<_WhatsAppTemplateSheet> createState() => _WhatsAppTemplateSheetState();
}

class _WhatsAppTemplateSheetState extends State<_WhatsAppTemplateSheet> {
  late final TextEditingController _msgController;
  MessageTemplate? _selected;

  @override
  void initState() {
    super.initState();
    _msgController = TextEditingController();
    _msgController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _msgController.dispose();
    super.dispose();
  }

  void _selectTemplate(MessageTemplate tpl) {
    final text = tpl.build(name: widget.clientName.isNotEmpty ? widget.clientName : 'cliente');
    setState(() {
      _selected = tpl;
      _msgController.text = text;
    });
  }

  Future<void> _send() async {
    final number = sanitizePhoneForWhatsApp(widget.phone);
    final encoded = Uri.encodeComponent(_msgController.text.trim());
    final uri = Uri.parse('https://wa.me/$number?text=$encoded');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
      if (mounted) Navigator.pop(context);
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Não foi possível abrir o WhatsApp')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
        left: 16,
        right: 16,
        top: 16,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.chat_outlined, color: Color(0xFF25D366)),
              const SizedBox(width: 8),
              const Text(
                'Mensagem WhatsApp',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const Spacer(),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
                padding: EdgeInsets.zero,
              ),
            ],
          ),
          const SizedBox(height: 8),
          SizedBox(
            height: 44,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: MessageTemplates.all.length,
              separatorBuilder: (_, _) => const SizedBox(width: 6),
              itemBuilder: (_, i) {
                final tpl = MessageTemplates.all[i];
                final isSelected = _selected?.type == tpl.type;
                return ChoiceChip(
                  label: Text('${tpl.icon} ${tpl.label}',
                      style: const TextStyle(fontSize: 12)),
                  selected: isSelected,
                  onSelected: (_) => _selectTemplate(tpl),
                  visualDensity: VisualDensity.compact,
                );
              },
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _msgController,
            maxLines: 4,
            decoration: InputDecoration(
              hintText: 'Selecione um template ou escreva a mensagem...',
              border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
              filled: true,
              fillColor: Colors.grey[50],
            ),
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _msgController.text.trim().isEmpty ? null : _send,
              icon: const Icon(Icons.send),
              label: const Text('Enviar no WhatsApp'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF25D366),
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
      ),
    );
  }
}


