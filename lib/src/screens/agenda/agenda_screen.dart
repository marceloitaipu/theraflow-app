import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/app_services.dart';

enum _ViewMode { month, week }

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();
  _ViewMode _viewMode = _ViewMode.month;

  // Semana atual: início na segunda-feira
  DateTime get _weekStart {
    final d = _selectedDay;
    return d.subtract(Duration(days: (d.weekday - 1) % 7));
  }

  void _previousPeriod() {
    setState(() {
      if (_viewMode == _ViewMode.month) {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month - 1);
      } else {
        _selectedDay = _selectedDay.subtract(const Duration(days: 7));
      }
    });
  }

  void _nextPeriod() {
    setState(() {
      if (_viewMode == _ViewMode.month) {
        _selectedMonth = DateTime(_selectedMonth.year, _selectedMonth.month + 1);
      } else {
        _selectedDay = _selectedDay.add(const Duration(days: 7));
      }
    });
  }

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
  }

  void _toggleView() {
    setState(() {
      _viewMode = _viewMode == _ViewMode.month ? _ViewMode.week : _ViewMode.month;
      // Sincroniza mês com dia selecionado ao alternar
      _selectedMonth = DateTime(_selectedDay.year, _selectedDay.month);
    });
  }

  String _periodLabel() {
    if (_viewMode == _ViewMode.month) {
      return DateFormat('MMMM yyyy', 'pt_BR').format(_selectedMonth);
    } else {
      final start = _weekStart;
      final end = start.add(const Duration(days: 6));
      final dayFmt = DateFormat('d MMM', 'pt_BR');
      return '${dayFmt.format(start)} – ${dayFmt.format(end)}';
    }
  }

  Future<List<Session>> _getSessionsForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    return SessionService.instance.getSessionsByPeriod(start: start, end: end);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            tooltip: _viewMode == _ViewMode.month ? 'Visão semanal' : 'Visão mensal',
            icon: Icon(
              _viewMode == _ViewMode.month ? Icons.view_week : Icons.calendar_month,
            ),
            onPressed: _toggleView,
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/session/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Barra de navegação de período
          _PeriodNavigator(
            label: _periodLabel(),
            onPrevious: _previousPeriod,
            onNext: _nextPeriod,
          ),
          // Calendário (mensal ou semanal)
          if (_viewMode == _ViewMode.month)
            FutureBuilder<List<Session>>(
              future: SessionService.instance.getSessionsByPeriod(
                start: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
                end: DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59),
              ),
              builder: (context, monthSnapshot) {
                return _CalendarGrid(
                  month: _selectedMonth,
                  selectedDay: _selectedDay,
                  sessions: monthSnapshot.data ?? [],
                  onDaySelected: _selectDay,
                );
              },
            )
          else
            FutureBuilder<List<Session>>(
              future: SessionService.instance.getSessionsByPeriod(
                start: _weekStart,
                end: _weekStart.add(const Duration(days: 6, hours: 23, minutes: 59, seconds: 59)),
              ),
              builder: (context, weekSnapshot) {
                return _WeekStrip(
                  weekStart: _weekStart,
                  selectedDay: _selectedDay,
                  sessions: weekSnapshot.data ?? [],
                  onDaySelected: _selectDay,
                );
              },
            ),
          const Divider(height: 1),
          // Cabeçalho do dia selecionado
          _DayHeader(day: _selectedDay),
          // Sessões do dia selecionado
          Expanded(
            child: FutureBuilder<List<Session>>(
              future: _getSessionsForDay(_selectedDay),
              builder: (context, daySnapshot) {
                if (daySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sessions = daySnapshot.data ?? [];
                final conflicts = _detectConflicts(sessions);

                if (sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 56, color: Colors.grey[300]),
                        const SizedBox(height: 12),
                        Text(
                          'Nenhuma sessão neste dia',
                          style: TextStyle(color: Theme.of(context).colorScheme.onSurfaceVariant),
                        ),
                        const SizedBox(height: 8),
                        TextButton.icon(
                          onPressed: () =>
                              context.go('/session/new?date=${_selectedDay.toIso8601String()}'),
                          icon: const Icon(Icons.add, size: 16),
                          label: const Text('Agendar'),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    final session = sessions[index];
                    final hasConflict = conflicts.contains(session.id);
                    return _SessionTile(
                      session: session,
                      hasConflict: hasConflict,
                      onAction: (action) => _handleAction(context, session, action),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  /// Retorna IDs de sessões que se sobrepõem com outra (mesma hora ±duração mínima 30min).
  Set<String> _detectConflicts(List<Session> sessions) {
    const minGap = Duration(minutes: 30);
    final conflicts = <String>{};
    for (var i = 0; i < sessions.length; i++) {
      for (var j = i + 1; j < sessions.length; j++) {
        final a = sessions[i].dateTime;
        final b = sessions[j].dateTime;
        if (a.difference(b).abs() < minGap) {
          conflicts.add(sessions[i].id);
          conflicts.add(sessions[j].id);
        }
      }
    }
    return conflicts;
  }

  Future<void> _handleAction(BuildContext context, Session session, _SessionAction action) async {
    switch (action) {
      case _SessionAction.editar:
        context.go('/session/${session.id}');
      case _SessionAction.iniciar:
        context.go('/session/${session.id}/start');
      case _SessionAction.confirmar:
        await SessionService.instance.updateSession(session.id, status: 'confirmado');
        setState(() {});
      case _SessionAction.remarcar:
        context.go('/session/${session.id}');
      case _SessionAction.cancelar:
        final confirmed = await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Cancelar sessão?'),
            content: const Text('Isto marcará a sessão como "faltou".'),
            actions: [
              TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Voltar')),
              FilledButton(
                onPressed: () => Navigator.pop(ctx, true),
                style: FilledButton.styleFrom(backgroundColor: Colors.red),
                child: const Text('Confirmar'),
              ),
            ],
          ),
        );
        if (confirmed == true) {
          await SessionService.instance.updateSession(session.id, status: 'faltou');
          setState(() {});
        }
    }
  }
}

// ─── Enum de ações da sessão ─────────────────────────────────────────────────
enum _SessionAction { editar, iniciar, confirmar, remarcar, cancelar }

// ─── Barra de período ────────────────────────────────────────────────────────
class _PeriodNavigator extends StatelessWidget {
  final String label;
  final VoidCallback onPrevious;
  final VoidCallback onNext;

  const _PeriodNavigator({required this.label, required this.onPrevious, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).colorScheme.primaryContainer.withValues(alpha: 0.25),
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(icon: const Icon(Icons.chevron_left), onPressed: onPrevious),
          Text(
            label,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          IconButton(icon: const Icon(Icons.chevron_right), onPressed: onNext),
        ],
      ),
    );
  }
}

// ─── Cabeçalho do dia ───────────────────────────────────────────────────────
class _DayHeader extends StatelessWidget {
  final DateTime day;
  const _DayHeader({required this.day});

  @override
  Widget build(BuildContext context) {
    final fmt = DateFormat("EEEE, d 'de' MMMM", 'pt_BR');
    final isToday = _isSameDay(day, DateTime.now());
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        children: [
          Text(
            fmt.format(day),
            style: TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 14,
              color: isToday
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          if (isToday) ...[
            const SizedBox(width: 6),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.primary,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text('Hoje', style: TextStyle(color: Colors.white, fontSize: 11)),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Tira semanal ────────────────────────────────────────────────────────────
class _WeekStrip extends StatelessWidget {
  final DateTime weekStart;
  final DateTime selectedDay;
  final List<Session> sessions;
  final Function(DateTime) onDaySelected;

  const _WeekStrip({
    required this.weekStart,
    required this.selectedDay,
    required this.sessions,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    const labels = ['Seg', 'Ter', 'Qua', 'Qui', 'Sex', 'Sáb', 'Dom'];
    final today = DateTime.now();
    final primary = Theme.of(context).colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: List.generate(7, (i) {
          final day = weekStart.add(Duration(days: i));
          final isSelected = _isSameDay(day, selectedDay);
          final isToday = _isSameDay(day, today);
          final hasSessions = sessions.any((s) => _isSameDay(s.dateTime, day));

          return Expanded(
            child: GestureDetector(
              onTap: () => onDaySelected(day),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    labels[i],
                    style: TextStyle(
                      fontSize: 11,
                      color: isToday
                          ? primary
                          : Theme.of(context).colorScheme.onSurfaceVariant,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: isSelected ? primary : null,
                      border: isToday && !isSelected ? Border.all(color: primary, width: 1.5) : null,
                      borderRadius: BorderRadius.circular(18),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '${day.day}',
                          style: TextStyle(
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                            color: isSelected
                                ? Colors.white
                                : Theme.of(context).colorScheme.onSurface,
                          ),
                        ),
                        if (hasSessions)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white70 : primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        }),
      ),
    );
  }
}

// ─── Grade mensal ────────────────────────────────────────────────────────────
class _CalendarGrid extends StatelessWidget {
  final DateTime month;
  final DateTime selectedDay;
  final List<Session> sessions;
  final Function(DateTime) onDaySelected;

  const _CalendarGrid({
    required this.month,
    required this.selectedDay,
    required this.sessions,
    required this.onDaySelected,
  });

  @override
  Widget build(BuildContext context) {
    final firstDayOfMonth = DateTime(month.year, month.month, 1);
    final lastDayOfMonth = DateTime(month.year, month.month + 1, 0);
    final daysInMonth = lastDayOfMonth.day;
    final firstWeekday = firstDayOfMonth.weekday % 7; // 0 = domingo
    final primary = Theme.of(context).colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                .map((d) => SizedBox(
                      width: 36,
                      child: Center(
                        child: Text(d,
                            style: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 12,
                                color: Theme.of(context).colorScheme.onSurfaceVariant)),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 4),
          ...List.generate((daysInMonth + firstWeekday + 6) ~/ 7, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 36, height: 36);
                }
                final day = DateTime(month.year, month.month, dayNumber);
                final isSelected = _isSameDay(day, selectedDay);
                final isToday = _isSameDay(day, DateTime.now());
                final hasSessions = sessions.any((s) => _isSameDay(s.dateTime, day));

                return InkWell(
                  onTap: () => onDaySelected(day),
                  borderRadius: BorderRadius.circular(18),
                  child: SizedBox(
                    width: 36,
                    height: 36,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: isSelected ? primary : null,
                            border: isToday && !isSelected
                                ? Border.all(color: primary, width: 1.5)
                                : null,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          alignment: Alignment.center,
                          child: Text(
                            '$dayNumber',
                            style: TextStyle(
                              fontSize: 13,
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              fontWeight:
                                  isToday ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                        if (hasSessions)
                          Positioned(
                            bottom: 3,
                            child: Container(
                              width: 5,
                              height: 5,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white70 : primary,
                                shape: BoxShape.circle,
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                );
              }),
            );
          }),
        ],
      ),
    );
  }
}

// ─── Tile de sessão com ações ────────────────────────────────────────────────
class _SessionTile extends StatelessWidget {
  final Session session;
  final bool hasConflict;
  final Function(_SessionAction) onAction;

  const _SessionTile({
    required this.session,
    required this.hasConflict,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return FutureBuilder<Client?>(
      future: ClientService.instance.getClientById(session.clientId),
      builder: (context, snap) {
        final clientName = snap.data?.name ?? 'Cliente';

        return InkWell(
          onTap: () => _showActionSheet(context, clientName),
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            decoration: BoxDecoration(
              border: Border.all(
                color: hasConflict
                    ? Colors.red.withValues(alpha: 0.6)
                    : _statusColor(session.status).withValues(alpha: 0.3),
                width: hasConflict ? 1.5 : 1,
              ),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  // Hora + indicador de status
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Text(
                        timeFormat.format(session.dateTime),
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                          color: _statusColor(session.status),
                        ),
                      ),
                      const SizedBox(height: 2),
                      Container(
                        width: 8,
                        height: 8,
                        decoration: BoxDecoration(
                          color: _statusColor(session.status),
                          shape: BoxShape.circle,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(width: 12),
                  // Infos
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                clientName,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w600, fontSize: 14),
                              ),
                            ),
                            if (hasConflict)
                              const Icon(Icons.warning_amber_rounded,
                                  color: Colors.red, size: 16),
                          ],
                        ),
                        Text(
                          '${session.therapyType} • ${currencyFormat.format(session.value)}',
                          style: TextStyle(
                              color: Theme.of(context).colorScheme.onSurfaceVariant,
                              fontSize: 12),
                        ),
                        _StatusRow(session: session),
                      ],
                    ),
                  ),
                  const Icon(Icons.more_vert, color: Colors.grey, size: 18),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _showActionSheet(BuildContext context, String clientName) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (ctx) {
        final timeFormat = DateFormat('HH:mm');
        return SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Row(
                  children: [
                    const Icon(Icons.event, size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        '$clientName — ${timeFormat.format(session.dateTime)}',
                        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.close),
                      onPressed: () => Navigator.pop(ctx),
                    ),
                  ],
                ),
              ),
              const Divider(height: 1),
              _ActionItem(
                icon: Icons.play_arrow,
                color: Colors.green,
                label: 'Iniciar atendimento',
                onTap: () {
                  Navigator.pop(ctx);
                  onAction(_SessionAction.iniciar);
                },
              ),
              if (session.status != 'confirmado')
                _ActionItem(
                  icon: Icons.check,
                  color: Colors.blue,
                  label: 'Confirmar presença',
                  onTap: () {
                    Navigator.pop(ctx);
                    onAction(_SessionAction.confirmar);
                  },
                ),
              _ActionItem(
                icon: Icons.edit_outlined,
                color: Colors.orange,
                label: 'Editar / Remarcar',
                onTap: () {
                  Navigator.pop(ctx);
                  onAction(_SessionAction.remarcar);
                },
              ),
              _ActionItem(
                icon: Icons.cancel_outlined,
                color: Colors.red,
                label: 'Marcar como faltou',
                onTap: () {
                  Navigator.pop(ctx);
                  onAction(_SessionAction.cancelar);
                },
              ),
              const SizedBox(height: 8),
            ],
          ),
        );
      },
    );
  }

  Color _statusColor(String status) {
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

// ─── Row de status + pagamento ──────────────────────────────────────────────
class _StatusRow extends StatelessWidget {
  final Session session;
  const _StatusRow({required this.session});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _badge(session.status, _statusColor(session.status)),
        const SizedBox(width: 4),
        _badge(
          session.paymentStatus == 'pago' ? 'pago' : 'pendente',
          session.paymentStatus == 'pago' ? Colors.green : Colors.orange,
        ),
      ],
    );
  }

  Widget _badge(String label, Color color) {
    return Container(
      margin: const EdgeInsets.only(top: 4),
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: TextStyle(fontSize: 10, color: color, fontWeight: FontWeight.w600),
      ),
    );
  }

  Color _statusColor(String s) {
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

// ─── Item de ação no bottom sheet ───────────────────────────────────────────
class _ActionItem extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String label;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.color,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: color),
      title: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}

// ─── Utilitário ─────────────────────────────────────────────────────────────
bool _isSameDay(DateTime a, DateTime b) =>
    a.year == b.year && a.month == b.month && a.day == b.day;
