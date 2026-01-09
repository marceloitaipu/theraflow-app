import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/app_services.dart';

class AgendaScreen extends StatefulWidget {
  const AgendaScreen({super.key});

  @override
  State<AgendaScreen> createState() => _AgendaScreenState();
}

class _AgendaScreenState extends State<AgendaScreen> {
  DateTime _selectedMonth = DateTime.now();
  DateTime _selectedDay = DateTime.now();

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

  void _selectDay(DateTime day) {
    setState(() {
      _selectedDay = day;
    });
  }

  @override
  Widget build(BuildContext context) {
    final monthFormat = DateFormat('MMMM yyyy', 'pt_BR');

    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/session/new'),
        child: const Icon(Icons.add),
      ),
      body: Column(
        children: [
          // Seletor de mês
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
          // Calendário simples
          FutureBuilder<List<Session>>(
            future: SessionService.instance.getSessionsByPeriod(
              start: DateTime(_selectedMonth.year, _selectedMonth.month, 1),
              end: DateTime(_selectedMonth.year, _selectedMonth.month + 1, 0, 23, 59, 59),
            ),
            builder: (context, monthSnapshot) {
              final sessionsInMonth = monthSnapshot.data ?? [];
              
              return _CalendarGrid(
                month: _selectedMonth,
                selectedDay: _selectedDay,
                sessions: sessionsInMonth,
                onDaySelected: _selectDay,
              );
            },
          ),
          const Divider(),
          // Sessões do dia selecionado
          Expanded(
            child: FutureBuilder<List<Session>>(
              future: _getSessionsForDay(_selectedDay),
              builder: (context, daySnapshot) {
                if (daySnapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                final sessions = daySnapshot.data ?? [];

                if (sessions.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.event_busy, size: 64, color: Colors.grey[400]),
                        const SizedBox(height: 16),
                        Text(
                          'Nenhuma sessão para este dia',
                          style: TextStyle(color: Colors.grey[600]),
                        ),
                      ],
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: sessions.length,
                  itemBuilder: (context, index) {
                    return _SessionTile(session: sessions[index]);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<List<Session>> _getSessionsForDay(DateTime day) async {
    final start = DateTime(day.year, day.month, day.day);
    final end = DateTime(day.year, day.month, day.day, 23, 59, 59);
    return SessionService.instance.getSessionsByPeriod(start: start, end: end);
  }
}

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

    return Container(
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Cabeçalho com dias da semana
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: ['D', 'S', 'T', 'Q', 'Q', 'S', 'S']
                .map((day) => SizedBox(
                      width: 40,
                      child: Center(
                        child: Text(
                          day,
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                          ),
                        ),
                      ),
                    ))
                .toList(),
          ),
          const SizedBox(height: 8),
          // Grade de dias
          ...List.generate((daysInMonth + firstWeekday) ~/ 7 + 1, (weekIndex) {
            return Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (dayIndex) {
                final dayNumber = weekIndex * 7 + dayIndex - firstWeekday + 1;
                
                if (dayNumber < 1 || dayNumber > daysInMonth) {
                  return const SizedBox(width: 40, height: 40);
                }

                final day = DateTime(month.year, month.month, dayNumber);
                final isSelected = selectedDay.year == day.year &&
                    selectedDay.month == day.month &&
                    selectedDay.day == day.day;
                final isToday = DateTime.now().year == day.year &&
                    DateTime.now().month == day.month &&
                    DateTime.now().day == day.day;
                final hasSessions = sessions.any((s) =>
                    s.dateTime.year == day.year &&
                    s.dateTime.month == day.month &&
                    s.dateTime.day == day.day);

                return InkWell(
                  onTap: () => onDaySelected(day),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.blue : null,
                      border: isToday
                          ? Border.all(color: Colors.blue, width: 2)
                          : null,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Text(
                          '$dayNumber',
                          style: TextStyle(
                            color: isSelected ? Colors.white : Colors.black,
                            fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
                          ),
                        ),
                        if (hasSessions)
                          Positioned(
                            bottom: 4,
                            child: Container(
                              width: 6,
                              height: 6,
                              decoration: BoxDecoration(
                                color: isSelected ? Colors.white : Colors.blue,
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

class _SessionTile extends StatelessWidget {
  final Session session;

  const _SessionTile({required this.session});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    final currencyFormat = NumberFormat.currency(locale: 'pt_BR', symbol: 'R\$');

    return FutureBuilder(
      future: ClientService.instance.getClientById(session.clientId),
      builder: (context, clientSnapshot) {
        final clientName = clientSnapshot.data?.name ?? 'Cliente';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: session.status == 'confirmado'
                ? Colors.green
                : Colors.orange,
            child: Text(
              timeFormat.format(session.dateTime).split(':')[0],
              style: const TextStyle(color: Colors.white, fontSize: 12),
            ),
          ),
          title: Text('${timeFormat.format(session.dateTime)} — $clientName'),
          subtitle: Text('${session.therapyType} • ${currencyFormat.format(session.value)}'),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                session.status,
                style: TextStyle(
                  fontSize: 11,
                  color: session.status == 'confirmado'
                      ? Colors.green
                      : Colors.orange,
                ),
              ),
              Icon(
                session.paymentStatus == 'pago'
                    ? Icons.check_circle
                    : Icons.pending,
                size: 16,
                color: session.paymentStatus == 'pago'
                    ? Colors.green
                    : Colors.orange,
              ),
            ],
          ),
          onTap: () => context.go('/session/${session.id}'),
        );
      },
    );
  }
}
