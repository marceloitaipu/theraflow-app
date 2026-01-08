import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../services/session_service.dart';
import '../../services/client_service.dart';
import '../../models/session.dart';
import '../../widgets/section_title.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hoje'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              // Recarregar dados
            },
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => context.go('/session/new'),
        child: const Icon(Icons.add),
      ),
      body: FutureBuilder<List<Session>>(
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
            return Center(
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
            );
          }

          // Separar próxima sessão das demais
          final now = DateTime.now();
          final upcomingSessions = sessions.where((s) => s.dateTime.isAfter(now)).toList();
          final nextSession = upcomingSessions.isNotEmpty ? upcomingSessions.first : null;

          return ListView(
            children: [
              if (nextSession != null) ...[
                const SectionTitle('Próxima sessão'),
                _SessionTile(session: nextSession, isNext: true),
              ],
              const SectionTitle('Todas as sessões do dia'),
              ...sessions.map((session) => _SessionTile(session: session)),
            ],
          );
        },
      ),
    );
  }
}

class _SessionTile extends StatelessWidget {
  final Session session;
  final bool isNext;

  const _SessionTile({required this.session, this.isNext = false});

  @override
  Widget build(BuildContext context) {
    final timeFormat = DateFormat('HH:mm');
    
    return FutureBuilder(
      future: ClientService.instance.getClientById(session.clientId),
      builder: (context, clientSnapshot) {
        final clientName = clientSnapshot.data?.name ?? 'Cliente';

        return ListTile(
          leading: CircleAvatar(
            backgroundColor: isNext ? Colors.blue : Colors.grey,
            child: const Icon(Icons.person, color: Colors.white),
          ),
          title: Text('${timeFormat.format(session.dateTime)} — $clientName'),
          subtitle: Text(
            '${session.therapyType} • ${session.status} • ${session.paymentStatus}',
          ),
          trailing: session.paymentStatus == 'pago'
              ? const Icon(Icons.check_circle, color: Colors.green)
              : const Icon(Icons.pending, color: Colors.orange),
          onTap: () => context.go('/session/${session.id}'),
        );
      },
    );
  }
}
