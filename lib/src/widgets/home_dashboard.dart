import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../services/app_services.dart';
import 'revenue_sparkline.dart';

/// Dashboard compacto da Home com 3 cartões de KPI + sparkline de receita.
class HomeDashboard extends StatelessWidget {
  const HomeDashboard({super.key});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<_DashboardData>(
      future: _loadData(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const SizedBox(
            height: 220,
            child: Center(child: CircularProgressIndicator()),
          );
        }
        final data = snapshot.data!;
        return Padding(
          padding: const EdgeInsets.fromLTRB(12, 12, 12, 0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _KpiCard(
                      label: 'Recebido (mês)',
                      value: _currency.format(data.received),
                      icon: Icons.attach_money,
                      color: Colors.green,
                      onTap: () => context.go('/finance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiCard(
                      label: 'Pendentes',
                      value: _currency.format(data.pending),
                      icon: Icons.pending,
                      color: data.pending > 0 ? Colors.orange : Colors.grey,
                      onTap: () => context.go('/finance'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _KpiCard(
                      label: 'Novos clientes (30d)',
                      value: '${data.newClients}',
                      icon: Icons.person_add,
                      color: Colors.blue,
                      onTap: () => context.go('/clients'),
                    ),
                  ),
                ],
              ),
              if (data.revenueSeries.isNotEmpty) ...[
                const SizedBox(height: 12),
                Card(
                  margin: EdgeInsets.zero,
                  child: InkWell(
                    onTap: () => context.go('/finance'),
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding:
                          const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 12),
                            child: Text(
                              'Tendência — últimos 6 meses',
                              style: TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurfaceVariant,
                              ),
                            ),
                          ),
                          const SizedBox(height: 4),
                          RevenueSparkline(points: data.revenueSeries),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }

  static final _currency =
      NumberFormat.compactCurrency(locale: 'pt_BR', symbol: 'R\$');

  Future<_DashboardData> _loadData() async {
    final now = DateTime.now();
    final results = await Future.wait([
      FinanceService.instance
          .getMonthlyReport(year: now.year, month: now.month),
      ClientService.instance.getNewClientsCount(days: 30),
      FinanceService.instance.getRevenueLastMonths(6),
    ]);
    final report = results[0] as MonthlyReport;
    final newClients = results[1] as int;
    final series = results[2] as List<MonthlyRevenuePoint>;
    return _DashboardData(
      received: report.totalReceived,
      pending: report.totalPending,
      newClients: newClients,
      revenueSeries: series,
    );
  }
}

class _DashboardData {
  final double received;
  final double pending;
  final int newClients;
  final List<MonthlyRevenuePoint> revenueSeries;

  _DashboardData({
    required this.received,
    required this.pending,
    required this.newClients,
    required this.revenueSeries,
  });
}

class _KpiCard extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;
  final Color color;
  final VoidCallback? onTap;

  const _KpiCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: color, size: 18),
              const SizedBox(height: 6),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: color,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Text(
                label,
                style: TextStyle(
                    fontSize: 10,
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
