import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/app_services.dart';
import '../../widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refresh() async {
    setState(() {});
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refresh,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/session/new'),
        child: const Icon(Icons.add),
      ),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Session>>(
          future: SessionService.instance.getTodaySessions(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(child: Text('Erro: ${snapshot.error}'));
            }

            final sessions = snapshot.data ?? [];

            if (sessions.isEmpty) {
              return ListView(
                children: [
                  const _FinanceSummaryCard(),
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.all(48),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.event_available, size: 64, color: Colors.grey[400]),
                          const SizedBox(height: 16),
                          Text(
                            'Nenhuma sessão agendada para hoje',
                            style: TextStyle(color: Colors.grey[600]),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              );
            }

            // Separar próxima sessão das demais
            final now = DateTime.now();
            final upcomingSessions = sessions.where((s) => s.dateTime.isAfter(now)).toList();
            final nextSession = upcomingSessions.isNotEmpty ? upcomingSessions.first : null;

            return ListView(
              children: [
                const _FinanceSummaryCard(),
                if (nextSession != null) ...[
                  const SectionTitle('Próxima sessão'),
                  _NextSessionCard(session: nextSession),
                ],
                const SectionTitle('Todas as sessões do dia'),
                ...sessions.map((session) => _SessionTile(session: session)),
              ],
            );
          },
        ),
      ),
    );
  }
}

// Card de resumo financeiro
class _FinanceSummaryCard extends StatelessWidget {
  const _FinanceSummaryCard();

  @override
  Widget build(BuildContext context) {
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    final now = DateTime.now();

    return FutureBuilder<MonthlyReport>(
      future: FinanceService.instance.getMonthlyReport(
        year: now.year,
        month: now.month,
      ),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox.shrink();
        }

        final report = snapshot.data!;

        return Card(
          margin: const EdgeInsets.all(12),
          child: InkWell(
            onTap: () => context.go('/finance'),
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Este mês',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          currencyFormat.format(report.totalReceived),
                          style: const TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.green,
                          ),
                        ),
                        Text(
                          'recebidos',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    width: 1,
                    height: 50,
                    color: Colors.grey[300],
                  ),
                  Expanded(
                    child: Column(
                      children: [
                        Text(
                          currencyFormat.format(report.totalPending),
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: report.totalPending > 0 ? Colors.orange : Colors.grey,
                          ),
                        ),
                        Text(
                          'pendentes',
                          style: TextStyle(
                            color: Colors.grey[600],
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(Icons.chevron_right, color: Colors.grey[400]),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

// Card de próxima sessão com botão Iniciar
class _NextSessionCard extends StatelessWidget {
  final Session session;

  const _NextSessionCard({required this.session});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return FutureBuilder<Client?>(
      future: ClientService.instance.getClientById(session.clientId),
      builder: (context, clientSnapshot) {
        final clientName = clientSnapshot.data?.name ?? 'Cliente';

        return Card(
          margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          color: Colors.blue[50],
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    CircleAvatar(
                      backgroundColor: Colors.blue,
                      child: Text(
                        clientName.isNotEmpty ? clientName[0].toUpperCase() : '?',
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            clientName,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                            ),
                          ),
                          Text(
                            '${timeFormat.format(session.dateTime)} • ${session.therapyType}',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: _getStatusColor(session.status),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        session.status,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => context.go('/session/${session.id}'),
                        icon: const Icon(Icons.edit, size: 18),
                        label: const Text('Editar'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: FilledButton.icon(
                        onPressed: () => context.go('/session/${session.id}/start'),
                        icon: const Icon(Icons.play_arrow, size: 18),
                        label: const Text('Iniciar'),
                        style: FilledButton.styleFrom(
                          backgroundColor: Colors.green,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'confirmado':
        return Colors.green;
      case 'agendado':
        return Colors.blue;
      case 'realizada':
        return Colors.teal;
      case 'faltou':
        return Colors.red;
      case 'remarcado':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// Tile simples para lista de sessões
class _SessionTile extends StatelessWidget {
  final Session session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');

    return FutureBuilder<Client?>(
      future: ClientService.instance.getClientById(session.clientId),
      builder: (context, clientSnapshot) {
        final clientName = clientSnapshot.data?.name ?? 'Cliente';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: Colors.grey,
            child: Text(
              clientName.isNotEmpty ? clientName[0].toUpperCase() : '?',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          title: Text('${timeFormat.format(session.dateTime)} — $clientName'),
          subtitle: Text(
            '${session.therapyType} • ${session.status} • ${session.paymentStatus}',
          ),
          trailing: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (session.paymentStatus == 'pago')
                const Icon(Icons.check_circle, color: Colors.green, size: 20)
              else
                const Icon(Icons.pending, color: Colors.orange, size: 20),
              const SizedBox(width: 8),
              IconButton(
                icon: const Icon(Icons.play_circle_outline, color: Colors.green),
                tooltip: 'Iniciar sessão',
                onPressed: () => context.go('/session/${session.id}/start'),
              ),
            ],
          ),
          onTap: () => context.go('/session/${session.id}'),
        );
      },
    );
  }
}
