import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../models/alert_item.dart';
import '../../models/home_summary.dart';
import '../../services/app_services.dart';
import '../../services/home_service.dart';
import '../../services/performance_service.dart';
import '../../widgets/home_dashboard.dart';
import '../../widgets/section_title.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<HomeSummary>? _summaryFuture;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() {
      _summaryFuture = HomeService.instance.getSummary();
    });
  }

  @override
  Widget build(BuildContext context) {
    final dateFormat = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final today = dateFormat.format(DateTime.now());

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Hoje', style: TextStyle(fontWeight: FontWeight.bold)),
            Text(today, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.normal)),
          ],
        ),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _load),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/session/new'),
        icon: const Icon(Icons.add),
        label: const Text('Nova sessão'),
      ),
      body: RefreshIndicator(
        onRefresh: () async => _load(),
        child: FutureBuilder<HomeSummary>(
          future: _summaryFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }

            if (snapshot.hasError) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.error_outline, size: 48, color: Colors.red[300]),
                    const SizedBox(height: 12),
                    Text('Erro ao carregar dados',
                        style: TextStyle(
                            color: Theme.of(context)
                                .colorScheme
                                .onSurfaceVariant)),
                    const SizedBox(height: 8),
                    TextButton.icon(
                      onPressed: _load,
                      icon: const Icon(Icons.refresh),
                      label: const Text('Tentar novamente'),
                    ),
                  ],
                ),
              );
            }

            final summary = snapshot.data;
            if (summary == null) {
              return ListView(children: [const HomeDashboard(), _buildQuickActions(context)]);
            }

            return ListView(
              children: [
                const HomeDashboard(),
                // Card de recebido hoje (destaque operacional)
                if (summary.receivedToday > 0)
                  _ReceivedTodayCard(value: summary.receivedToday),
                _buildQuickActions(context),
                if (summary.hasAlerts) _AlertsSection(summary: summary),
                if (summary.nextSession != null) ...[
                  const SectionTitle('Próxima sessão'),
                  _NextSessionCard(
                    session: summary.nextSession!,
                    client: summary.nextSessionClient,
                  ),
                ],
                if (summary.todaySessions.isNotEmpty) ...[
                  const SectionTitle('Sessões de hoje'),
                  ...summary.todaySessions.map(
                    (s) => _SessionTile(
                      session: s,
                      clientName: summary.clientNamesById[s.clientId],
                    ),
                  ),
                ] else
                  _EmptyToday(onSchedule: () => context.go('/agenda')),
                const SectionTitle('Desempenho do mês'),
                _PerformanceSection(
                  year: DateTime.now().year,
                  month: DateTime.now().month,
                ),
                const SizedBox(height: 80),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildQuickActions(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Row(
        children: [
          _QuickAction(
            icon: Icons.person_add_outlined,
            label: 'Cliente',
            onTap: () => context.push('/clients/new'),
          ),
          const SizedBox(width: 8),
          _QuickAction(
            icon: Icons.add_circle_outline,
            label: 'Sessão',
            onTap: () => context.push('/session/new'),
          ),
          const SizedBox(width: 8),
          _QuickAction(
            icon: Icons.calendar_today_outlined,
            label: 'Agenda',
            onTap: () => context.go('/agenda'),
          ),
          const SizedBox(width: 8),
          _QuickAction(
            icon: Icons.attach_money,
            label: 'Pagamento',
            onTap: () => context.go('/finance'),
          ),
        ],
      ),
    );
  }
}

// ─── Ação rápida ────────────────────────────────────────────────────────────
class _QuickAction extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  const _QuickAction({required this.icon, required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final color = Theme.of(context).colorScheme.primary;
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            border: Border.all(color: color.withValues(alpha: 0.3)),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 22, color: color),
              const SizedBox(height: 4),
              Text(
                label,
                style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w500),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Seção de alertas ───────────────────────────────────────────────────────
class _AlertsSection extends StatelessWidget {
  final HomeSummary summary;

  const _AlertsSection({required this.summary});

  @override
  Widget build(BuildContext context) {
    final alerts = summary.alerts;
    if (alerts.isEmpty) return const SizedBox.shrink();

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: Column(
        children: alerts.map((alert) {
          final color = _alertColor(alert.priority);
          final icon = _alertIcon(alert.type);
          return _AlertBanner(
            icon: icon,
            color: color,
            message: alert.message,
            onTap: () => context.go(alert.route),
          );
        }).toList(),
      ),
    );
  }

  Color _alertColor(AlertPriority priority) {
    switch (priority) {
      case AlertPriority.high:
        return Colors.red;
      case AlertPriority.medium:
        return Colors.orange;
      case AlertPriority.low:
        return Colors.blueGrey;
    }
  }

  IconData _alertIcon(AlertType type) {
    switch (type) {
      case AlertType.paymentOverdue:
        return Icons.payment_outlined;
      case AlertType.packageEnding:
        return Icons.inventory_2_outlined;
      case AlertType.clientAtRisk:
        return Icons.person_off_outlined;
      case AlertType.clientNoNextSession:
        return Icons.event_busy_outlined;
      case AlertType.sessionTomorrow:
        return Icons.event_available_outlined;
      case AlertType.manyAbsences:
        return Icons.warning_amber_outlined;
    }
  }
}

class _AlertBanner extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String message;
  final VoidCallback onTap;

  const _AlertBanner({
    required this.icon,
    required this.color,
    required this.message,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            border: Border.all(color: color.withValues(alpha: 0.4)),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Row(
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  message,
                  style: TextStyle(fontSize: 13, color: color, fontWeight: FontWeight.w500),
                ),
              ),
              Icon(Icons.chevron_right, size: 18, color: color),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Card próxima sessão ────────────────────────────────────────────────────
class _NextSessionCard extends StatelessWidget {
  final Session session;
  final Client? client;

  const _NextSessionCard({required this.session, this.client});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final clientName = client?.name ?? 'Cliente';

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.4),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: Theme.of(context).colorScheme.primary,
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
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        '${timeFormat.format(session.dateTime)} • ${session.therapyType}',
                        style: TextStyle(
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                            fontSize: 13),
                      ),
                    ],
                  ),
                ),
                _StatusChip(status: session.status),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () => context.push('/session/${session.id}'),
                    icon: const Icon(Icons.edit, size: 16),
                    label: const Text('Editar'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: FilledButton.icon(
                    onPressed: () => context.push('/session/${session.id}/start'),
                    icon: const Icon(Icons.play_arrow, size: 16),
                    label: const Text('Iniciar'),
                    style: FilledButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Tile de sessão ─────────────────────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  final Session session;
  final String? clientName;

  const _SessionTile({required this.session, this.clientName});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final name = clientName ?? 'Cliente';
    final statusColor = _sessionStatusColor(session.status);

    return ListTile(
      leading: CircleAvatar(
        backgroundColor: statusColor.withValues(alpha: 0.15),
        child: Text(
          name.isNotEmpty ? name[0].toUpperCase() : '?',
          style: TextStyle(color: statusColor, fontWeight: FontWeight.bold),
        ),
      ),
      title: Text('${timeFormat.format(session.dateTime)} — $name'),
      subtitle: Text('${session.therapyType} • ${session.status}'),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (session.paymentStatus == 'pago')
            const Icon(Icons.check_circle, color: Colors.green, size: 18)
          else
            const Icon(Icons.radio_button_unchecked, color: Colors.orange, size: 18),
          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(Icons.play_circle_outline, color: Colors.green, size: 22),
            tooltip: 'Iniciar',
            onPressed: () => context.push('/session/${session.id}/start'),
          ),
        ],
      ),
      onTap: () => context.push('/session/${session.id}'),
    );
  }

  Color _sessionStatusColor(String status) {
    switch (status) {
      case 'realizada':
        return Colors.teal;
      case 'confirmado':
        return Colors.blue;
      case 'faltou':
      case 'cancelado':
        return Colors.red;
      case 'remarcado':
        return Colors.orange;
      default:
        return Colors.grey;
    }
  }
}

// ─── Card recebido hoje ──────────────────────────────────────────────────────
class _ReceivedTodayCard extends StatelessWidget {
  final double value;
  const _ReceivedTodayCard({required this.value});

  @override
  Widget build(BuildContext context) {
    final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
      child: InkWell(
        onTap: () => context.go('/finance'),
        borderRadius: BorderRadius.circular(10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: Colors.green.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: Colors.green.withValues(alpha: 0.35)),
          ),
          child: Row(
            children: [
              const Icon(Icons.check_circle_outline, color: Colors.green, size: 20),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Recebido hoje: ${fmt.format(value)}',
                  style: const TextStyle(
                    color: Colors.green,
                    fontWeight: FontWeight.w600,
                    fontSize: 14,
                  ),
                ),
              ),
              const Icon(Icons.chevron_right, size: 18, color: Colors.green),
            ],
          ),
        ),
      ),
    );
  }
}

// ─── Estado vazio ───────────────────────────────────────────────────────────
class _EmptyToday extends StatelessWidget {
  final VoidCallback onSchedule;

  const _EmptyToday({required this.onSchedule});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          Icon(Icons.event_available, size: 56, color: Colors.grey[300]),
          const SizedBox(height: 12),
          Text(
            'Nenhuma sessão hoje',
            style: TextStyle(fontSize: 16, color: Theme.of(context).colorScheme.onSurfaceVariant, fontWeight: FontWeight.w500),
          ),
          const SizedBox(height: 4),
          Text(
            'Aproveite para agendar ou verificar pendências.',
            style: TextStyle(fontSize: 13, color: Theme.of(context).colorScheme.onSurfaceVariant),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          OutlinedButton.icon(
            onPressed: onSchedule,
            icon: const Icon(Icons.calendar_today, size: 16),
            label: const Text('Ver agenda'),
          ),
        ],
      ),
    );
  }
}

// ─── Chip de status ─────────────────────────────────────────────────────────
class _StatusChip extends StatelessWidget {
  final String status;

  const _StatusChip({required this.status});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: _color(status),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        status,
        style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w500),
      ),
    );
  }

  Color _color(String s) {
    switch (s) {
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

// ─── Seção de desempenho mensal ──────────────────────────────────────────────
class _PerformanceSection extends StatelessWidget {
  final int year;
  final int month;

  const _PerformanceSection({required this.year, required this.month});

  static const _weekdays = ['Dom', 'Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb'];

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PerformanceMetrics>(
      future: PerformanceService.instance
          .getMonthlyMetrics(year: year, month: month),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final m = snapshot.data!;
        final fmt = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');
        final progress = m.goalProgress;
        final progressColor =
            progress >= 1.0 ? Colors.green : Colors.deepPurple;

        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
          child: Column(
            children: [
              // Card principal: meta + progresso
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: progressColor.withValues(alpha: 0.07),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: progressColor.withValues(alpha: 0.25)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.track_changes,
                            color: progressColor, size: 20),
                        const SizedBox(width: 8),
                        Text(
                          'Meta: ${m.goalSessions} sessões',
                          style: TextStyle(
                            fontWeight: FontWeight.w600,
                            color: progressColor,
                          ),
                        ),
                        const Spacer(),
                        Text(
                          '${m.completedSessions}/${m.goalSessions}',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: progressColor,
                            fontSize: 16,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => _editGoal(context),
                          child: Icon(Icons.edit_outlined,
                              size: 16, color: progressColor),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ClipRRect(
                      borderRadius: BorderRadius.circular(4),
                      child: LinearProgressIndicator(
                        value: progress,
                        minHeight: 8,
                        backgroundColor: progressColor.withValues(alpha: 0.15),
                        color: progressColor,
                      ),
                    ),
                    if (m.goalReached)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: Text(
                          '🎉 Meta atingida!',
                          style: TextStyle(
                              color: progressColor,
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              // Cards de métricas secundárias
              Row(
                children: [
                  Expanded(
                    child: _MiniMetricCard(
                      label: 'Receita',
                      value: fmt.format(m.receivedRevenue),
                      icon: Icons.attach_money,
                      color: Colors.green,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniMetricCard(
                      label: 'Média semanal',
                      value: '${m.weeklyAverage} sess.',
                      icon: Icons.trending_up,
                      color: Colors.blue,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _MiniMetricCard(
                      label: 'Melhor dia',
                      value: m.bestDayOfWeek != null
                          ? _weekdays[m.bestDayOfWeek!]
                          : '—',
                      icon: Icons.star_outline,
                      color: Colors.amber[700]!,
                    ),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _editGoal(BuildContext context) async {
    final current = await PerformanceService.instance.getMonthlyGoal();
    if (!context.mounted) return;
    final controller =
        TextEditingController(text: current.toString());
    final result = await showDialog<int?>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Meta mensal de sessões'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          decoration: const InputDecoration(
            labelText: 'Sessões por mês',
            suffixText: 'sessões',
          ),
          autofocus: true,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancelar'),
          ),
          FilledButton(
            onPressed: () {
              final v = int.tryParse(controller.text.trim());
              Navigator.pop(ctx, v);
            },
            child: const Text('Salvar'),
          ),
        ],
      ),
    );
    if (result != null && result > 0 && context.mounted) {
      await PerformanceService.instance.setMonthlyGoal(result);
      // Rebuild chamado implicitamente pelo FutureBuilder ao próximo frame
      (context as Element).markNeedsBuild();
    }
  }
}

class _MiniMetricCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;

  const _MiniMetricCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 13,
              color: color,
            ),
          ),
          Text(
            label,
            style: TextStyle(
                fontSize: 10,
                color: Theme.of(context).colorScheme.onSurfaceVariant),
          ),
        ],
      ),
    );
  }
}
