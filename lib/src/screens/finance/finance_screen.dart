import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/app_services.dart';
import '../../widgets/revenue_sparkline.dart';
import '../../widgets/section_title.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen>
    with SingleTickerProviderStateMixin {
  DateTime _selectedMonth = DateTime.now();
  String? _statusFilter; // null = todos, 'pago', 'pendente'
  String? _clientFilter; // null = todos, clientId
  String? _clientFilterName;
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  void _previousMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
    });
  }

  void _nextMonth() {
    setState(() {
      _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
    });
  }

  Color _getInsightColor(InsightType type) {
    switch (type) {
      case InsightType.success:
        return Colors.green[700]!;
      case InsightType.warning:
        return Colors.orange[700]!;
      case InsightType.alert:
        return Colors.red[700]!;
      case InsightType.info:
        return Colors.blue[700]!;
    }
  }

  Future<void> _pickClientFilter() async {
    final clients = await ClientService.instance.getClients();
    if (!mounted) return;
    final picked = await showDialog<Client?>(
      context: context,
      builder: (ctx) => SimpleDialog(
        title: const Text('Filtrar por cliente'),
        children: [
          SimpleDialogOption(
            onPressed: () => Navigator.pop(ctx, null),
            child: const Text('Todos os clientes'),
          ),
          ...clients.map((c) => SimpleDialogOption(
                onPressed: () => Navigator.pop(ctx, c),
                child: Text(c.name),
              )),
        ],
      ),
    );
    setState(() {
      _clientFilter = picked?.id;
      _clientFilterName = picked?.name;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(text: 'Mês'),
            Tab(text: 'Ranking'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _MonthTab(
            selectedMonth: _selectedMonth,
            statusFilter: _statusFilter,
            clientFilter: _clientFilter,
            clientFilterName: _clientFilterName,
            onPreviousMonth: _previousMonth,
            onNextMonth: _nextMonth,
            onStatusFilter: (v) => setState(() => _statusFilter = v),
            onPickClient: _pickClientFilter,
            getInsightColor: _getInsightColor,
          ),
          _RankingTab(
            selectedMonth: _selectedMonth,
            onPreviousMonth: _previousMonth,
            onNextMonth: _nextMonth,
          ),
        ],
      ),
    );
  }
}

// ─── Aba Mês ────────────────────────────────────────────────────────────────
class _MonthTab extends StatelessWidget {
  final DateTime selectedMonth;
  final String? statusFilter;
  final String? clientFilter;
  final String? clientFilterName;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;
  final ValueChanged<String?> onStatusFilter;
  final VoidCallback onPickClient;
  final Color Function(InsightType) getInsightColor;

  const _MonthTab({
    required this.selectedMonth,
    required this.statusFilter,
    required this.clientFilter,
    required this.clientFilterName,
    required this.onPreviousMonth,
    required this.onNextMonth,
    required this.onStatusFilter,
    required this.onPickClient,
    required this.getInsightColor,
  });

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy', 'pt_BR');
    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end = DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);

    return Column(
      children: [
        // Insights Card
        FutureBuilder<FinanceInsights>(
          future: FinanceService.instance.getFinanceInsights(),
          builder: (context, snapshot) {
            if (!snapshot.hasData) return const SizedBox.shrink();
            final insights = snapshot.data!;
            if (insights.messages.isEmpty) return const SizedBox.shrink();
            return Container(
              margin: const EdgeInsets.all(12),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Theme.of(context).colorScheme.primary.withValues(alpha: 0.2)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.insights, color: Theme.of(context).colorScheme.primary, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Insights',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: Theme.of(context).colorScheme.primary,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ...insights.messages.map((msg) => Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(msg.icon, style: const TextStyle(fontSize: 16)),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            msg.message,
                            style: TextStyle(
                              fontSize: 13,
                              color: getInsightColor(msg.type),
                            ),
                          ),
                        ),
                      ],
                    ),
                  )),
                ],
              ),
            );
          },
        ),
        // Sparkline
        FutureBuilder<List<MonthlyRevenuePoint>>(
          future: FinanceService.instance.getRevenueLastMonths(6),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const SizedBox.shrink();
            }
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 12),
              padding: const EdgeInsets.symmetric(vertical: 8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      'Receita — últimos 6 meses',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: 4),
                  RevenueSparkline(points: snapshot.data!),
                ],
              ),
            );
          },
        ),
        // Navegação mensal + filtros
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          padding: const EdgeInsets.symmetric(vertical: 6, horizontal: 4),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  IconButton(
                    icon: const Icon(Icons.chevron_left),
                    onPressed: onPreviousMonth,
                  ),
                  Text(
                    monthFormat.format(selectedMonth),
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.chevron_right),
                    onPressed: onNextMonth,
                  ),
                ],
              ),
              // Filtros
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(8, 0, 8, 6),
                child: Row(
                  children: [
                    _FilterChip(
                      label: 'Todos',
                      selected: statusFilter == null,
                      onTap: () => onStatusFilter(null),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Pago',
                      selected: statusFilter == 'pago',
                      onTap: () => onStatusFilter('pago'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: 'Pendente',
                      selected: statusFilter == 'pendente',
                      onTap: () => onStatusFilter('pendente'),
                    ),
                    const SizedBox(width: 6),
                    _FilterChip(
                      label: clientFilterName != null
                          ? '👤 $clientFilterName'
                          : '👤 Cliente',
                      selected: clientFilter != null,
                      onTap: onPickClient,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Conteúdo mensal
        Expanded(
          child: FutureBuilder<(MonthlyReport, double)>(
            future: Future.wait([
              FinanceService.instance.getMonthlyReport(
                year: selectedMonth.year,
                month: selectedMonth.month,
              ),
              FinanceService.instance.getAverageTicket(start: start, end: end),
            ]).then((r) => (r[0] as MonthlyReport, r[1] as double)),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              if (snapshot.hasError) {
                return Center(child: Text('Erro: ${snapshot.error}'));
              }
              final report = snapshot.data!.$1;
              final avgTicket = snapshot.data!.$2;
              final currencyFormat = NumberFormat.currency(
                locale: 'pt_BR',
                symbol: 'R\$',
              );

              return ListView(
                children: [
                  const SectionTitle('Resumo do Mês'),
                  // Cards de resumo em grade
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Recebido',
                            value: currencyFormat.format(report.totalReceived),
                            color: Colors.green,
                            icon: Icons.check_circle_outline,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Pendente',
                            value: currencyFormat.format(report.totalPending),
                            color: Colors.orange,
                            icon: Icons.pending_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        Expanded(
                          child: _SummaryCard(
                            label: 'Ticket médio',
                            value: avgTicket > 0
                                ? currencyFormat.format(avgTicket)
                                : '—',
                            color: Colors.blue,
                            icon: Icons.analytics_outlined,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: _SummaryCard(
                            label: 'Sessões',
                            value: '${report.totalSessions}',
                            color: Colors.purple,
                            icon: Icons.event_outlined,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Card(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        children: [
                          _SummaryRow(
                            label: 'Confirmadas',
                            value: '${report.sessionsConfirmed}',
                            icon: Icons.check_circle,
                            color: Colors.green,
                          ),
                          _SummaryRow(
                            label: 'Faltas',
                            value: '${report.sessionsMissed}',
                            icon: Icons.cancel,
                            color: Colors.red,
                          ),
                          _SummaryRow(
                            label: 'Remarcadas',
                            value: '${report.sessionsRescheduled}',
                            icon: Icons.update,
                            color: Colors.blue,
                          ),
                          const Divider(),
                          _SummaryRow(
                            label: 'Total',
                            value: currencyFormat.format(report.total),
                            icon: Icons.attach_money,
                            color: Colors.blue,
                            isBold: true,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SectionTitle('Pagamentos Pendentes'),
                  FutureBuilder<List<Session>>(
                    future: FinanceService.instance.getPendingSessions(),
                    builder: (context, pendingSnapshot) {
                      if (pendingSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return const Center(
                          child: Padding(
                            padding: EdgeInsets.all(16.0),
                            child: CircularProgressIndicator(),
                          ),
                        );
                      }

                      var pending = pendingSnapshot.data ?? [];

                      // Aplica filtros de cliente
                      if (clientFilter != null) {
                        pending = pending
                            .where((s) => s.clientId == clientFilter)
                            .toList();
                      }

                      if (pending.isEmpty) {
                        return const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: Center(
                            child: Text(
                              'Nenhum pagamento pendente',
                              style: TextStyle(color: Colors.grey),
                            ),
                          ),
                        );
                      }

                      return Column(
                        children: pending
                            .map((session) =>
                                _PendingSessionTile(session: session))
                            .toList(),
                      );
                    },
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── Aba Ranking ─────────────────────────────────────────────────────────────
class _RankingTab extends StatelessWidget {
  final DateTime selectedMonth;
  final VoidCallback onPreviousMonth;
  final VoidCallback onNextMonth;

  const _RankingTab({
    required this.selectedMonth,
    required this.onPreviousMonth,
    required this.onNextMonth,
  });

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy', 'pt_BR');
    final start = DateTime(selectedMonth.year, selectedMonth.month, 1);
    final end =
        DateTime(selectedMonth.year, selectedMonth.month + 1, 0, 23, 59, 59);
    final currFmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return Column(
      children: [
        Container(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: onPreviousMonth),
              Text(
                monthFormat.format(selectedMonth),
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Theme.of(context).colorScheme.onSurface),
              ),
              IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: onNextMonth),
            ],
          ),
        ),
        Expanded(
          child: FutureBuilder<List<ClientRevenueRankItem>>(
            future: FinanceService.instance
                .getClientRanking(start: start, end: end),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final items = snapshot.data ?? [];
              if (items.isEmpty) {
                return const Center(
                  child: Text(
                    'Sem dados de receita para este período',
                    style: TextStyle(color: Colors.grey),
                  ),
                );
              }
              final maxReceived =
                  items.map((i) => i.received).fold(0.0, (a, b) => a > b ? a : b);

              return ListView.separated(
                padding: const EdgeInsets.symmetric(vertical: 8),
                itemCount: items.length,
                separatorBuilder: (_, _) =>
                    const Divider(height: 1, indent: 72),
                itemBuilder: (_, index) {
                  final item = items[index];
                  final ratio = maxReceived > 0 ? item.received / maxReceived : 0.0;
                  return ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          index == 0 ? Colors.amber : Colors.grey[300],
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          color: index == 0
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ),
                    title: Text(item.clientName,
                        style: const TextStyle(fontWeight: FontWeight.w600)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(height: 4),
                        LinearProgressIndicator(
                          value: ratio,
                          backgroundColor: Colors.grey[200],
                          color: Colors.deepPurple,
                          minHeight: 4,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          '${item.sessionCount} sessão(ões)',
                          style: const TextStyle(fontSize: 12),
                        ),
                      ],
                    ),
                    trailing: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          currFmt.format(item.received),
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        if (item.pending > 0)
                          Text(
                            '+ ${currFmt.format(item.pending)} pend.',
                            style: const TextStyle(
                                fontSize: 11, color: Colors.orange),
                          ),
                      ],
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

// ─── _FilterChip ────────────────────────────────────────────────────────────
class _FilterChip extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _FilterChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;
    return FilterChip(
      label: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          color: selected ? cs.onPrimary : cs.onSurface,
        ),
      ),
      selected: selected,
      onSelected: (_) => onTap(),
      visualDensity: VisualDensity.compact,
      backgroundColor: cs.surfaceContainerHigh,
      selectedColor: cs.primary,
      checkmarkColor: cs.onPrimary,
    );
  }
}

// ─── _SummaryCard ────────────────────────────────────────────────────────────
class _SummaryCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;

  const _SummaryCard({
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.25)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color? color;
  final bool isBold;

  const _SummaryRow({
    required this.label,
    required this.value,
    required this.icon,
    this.color,
    this.isBold = false,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(icon, color: color ?? Colors.grey),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              label,
              style: TextStyle(
                fontSize: isBold ? 16 : 14,
                fontWeight: isBold ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: isBold ? 18 : 16,
              fontWeight: isBold ? FontWeight.bold : FontWeight.w500,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _PendingSessionTile extends StatelessWidget {
  final Session session;

  const _PendingSessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat('dd/MM/yyyy HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return FutureBuilder(
      future: ClientService.instance.getClientById(session.clientId),
      builder: (context, clientSnapshot) {
        final client = clientSnapshot.data;
        final clientName = client?.displayName ?? 'Cliente removido';
        final isInactive = client?.isInactive ?? false;

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isInactive ? Colors.grey : Colors.orange,
            child: const Icon(Icons.pending, color: Colors.white, size: 20),
          ),
          title: Row(
            children: [
              Expanded(child: Text(clientName)),
              if (isInactive)
                Container(
                  margin: const EdgeInsets.only(left: 8),
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade200,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: const Text(
                    'INATIVO',
                    style: TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                      color: Colors.grey,
                    ),
                  ),
                ),
            ],
          ),
          subtitle: Text(
            '${dateFormat.format(session.dateTime)} • ${session.therapyType}',
          ),
          trailing: Text(
            currencyFormat.format(session.value),
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.orange,
            ),
          ),
          onTap: () async {
            final confirm = await showDialog<bool>(
              context: context,
              builder: (context) => AlertDialog(
                title: const Text('Marcar como Pago'),
                content: Text('Confirmar pagamento de ${currencyFormat.format(session.value)}?'),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(context, false),
                    child: const Text('Cancelar'),
                  ),
                  TextButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: const Text('Confirmar'),
                  ),
                ],
              ),
            );

            if (confirm == true && context.mounted) {
              try {
                await SessionService.instance.markAsPaid(session.id);
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pagamento confirmado!')),
                );
              } catch (e) {
                if (!context.mounted) return;
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: Text('Erro: $e')),
                );
              }
            }
          },
        );
      },
    );
  }
}
