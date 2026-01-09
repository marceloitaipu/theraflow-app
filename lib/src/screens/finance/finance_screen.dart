import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../services/finance_service.dart';
import '../../services/session_service.dart';
import '../../services/client_service.dart';
import '../../models/session.dart';
import '../../widgets/section_title.dart';

class FinanceScreen extends StatefulWidget {
  const FinanceScreen({super.key});

  @override
  State<FinanceScreen> createState() => _FinanceScreenState();
}

class _FinanceScreenState extends State<FinanceScreen> {
  DateTime _selectedMonth = DateTime.now();

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

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Financeiro'),
      ),
      body: Column(
        children: [
          // Insights Card
          FutureBuilder<FinanceInsights>(
            future: FinanceService.instance.getFinanceInsights(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return const SizedBox.shrink();
              }

              final insights = snapshot.data!;
              if (insights.messages.isEmpty) {
                return const SizedBox.shrink();
              }

              return Container(
                margin: const EdgeInsets.all(12),
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.insights, color: Colors.blue[700], size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Insights',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.blue[700],
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
                                color: _getInsightColor(msg.type),
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
          Container(
            color: Colors.blue[50],
            padding: const EdgeInsets.symmetric(vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                IconButton(
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _previousMonth,
                ),
                Text(
                  monthFormat.format(_selectedMonth),
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.chevron_right),
                  onPressed: _nextMonth,
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<MonthlyReport>(
              future: FinanceService.instance.getMonthlyReport(
                year: _selectedMonth.year,
                month: _selectedMonth.month,
              ),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erro: ${snapshot.error}'));
                }

                final report = snapshot.data;
                if (report == null) {
                  return const Center(child: Text('Sem dados'));
                }

                final currencyFormat = NumberFormat.currency(
                  locale: 'pt_BR',
                  symbol: 'R\$',
                );

                return ListView(
                  children: [
                    const SectionTitle('Resumo do Mês'),
                    Card(
                      margin: const EdgeInsets.all(12),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          children: [
                            _SummaryRow(
                              label: 'Total de Sessões',
                              value: '${report.totalSessions}',
                              icon: Icons.event,
                            ),
                            const Divider(),
                            _SummaryRow(
                              label: 'Recebido',
                              value: currencyFormat.format(report.totalReceived),
                              icon: Icons.check_circle,
                              color: Colors.green,
                            ),
                            _SummaryRow(
                              label: 'Pendente',
                              value: currencyFormat.format(report.totalPending),
                              icon: Icons.pending,
                              color: Colors.orange,
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
                    const SectionTitle('Detalhes'),
                    ListTile(
                      leading: const Icon(Icons.check_circle, color: Colors.green),
                      title: const Text('Sessões Confirmadas'),
                      trailing: Text('${report.sessionsConfirmed}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.cancel, color: Colors.red),
                      title: const Text('Faltas'),
                      trailing: Text('${report.sessionsMissed}'),
                    ),
                    ListTile(
                      leading: const Icon(Icons.update, color: Colors.blue),
                      title: const Text('Remarcadas'),
                      trailing: Text('${report.sessionsRescheduled}'),
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

                        final pending = pendingSnapshot.data ?? [];

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
                              .map((session) => _PendingSessionTile(session: session))
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
        final clientName = clientSnapshot.data?.name ?? 'Cliente';

        return ListTile(
          leading: const CircleAvatar(
            backgroundColor: Colors.orange,
            child: Icon(Icons.pending, color: Colors.white, size: 20),
          ),
          title: Text(clientName),
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
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Pagamento confirmado!')),
                );
              } catch (e) {
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
