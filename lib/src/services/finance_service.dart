import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';
import '../models/payment.dart';
import 'auth_service.dart';
import 'session_service.dart';

class FinanceService {
  FinanceService._();
  static final instance = FinanceService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService.instance;
  final SessionService _sessionService = SessionService.instance;

  // Referência da coleção de pagamentos do usuário atual
  CollectionReference<Map<String, dynamic>>? _paymentsCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('payments');
  }

  // Criar pagamento para uma sessão
  Future<String> createPayment({
    required String sessionId,
    required double value,
    required String method,
    String status = 'pago',
  }) async {
    final collection = _paymentsCollection();
    if (collection == null) throw Exception('Usuário não autenticado.');

    final payment = Payment(
      id: '',
      sessionId: sessionId,
      status: status,
      method: method,
      value: value,
      paidAt: status == 'pago' ? DateTime.now() : null,
      createdAt: DateTime.now(),
    );

    final docRef = await collection.add(payment.toMap());

    // Atualizar status de pagamento da sessão
    if (status == 'pago') {
      await _sessionService.markAsPaid(sessionId);
    }

    return docRef.id;
  }

  // Buscar pagamento por sessão
  Future<Payment?> getPaymentBySession(String sessionId) async {
    final collection = _paymentsCollection();
    if (collection == null) return null;

    final snapshot = await collection
        .where('sessionId', isEqualTo: sessionId)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    final doc = snapshot.docs.first;
    return Payment.fromMap(doc.id, doc.data());
  }

  // Relatório financeiro mensal
  Future<MonthlyReport> getMonthlyReport({
    required int year,
    required int month,
  }) async {
    final start = DateTime(year, month, 1);
    final end = DateTime(year, month + 1, 0, 23, 59, 59);

    final sessions = await _sessionService.getSessionsByPeriod(
      start: start,
      end: end,
    );

    double totalReceived = 0;
    double totalPending = 0;
    int sessionsConfirmed = 0;
    int sessionsMissed = 0;
    int sessionsRescheduled = 0;

    for (final session in sessions) {
      if (session.paymentStatus == 'pago') {
        totalReceived += session.value;
      } else {
        totalPending += session.value;
      }

      switch (session.status) {
        case 'confirmado':
          sessionsConfirmed++;
          break;
        case 'faltou':
          sessionsMissed++;
          break;
        case 'remarcado':
          sessionsRescheduled++;
          break;
      }
    }

    return MonthlyReport(
      year: year,
      month: month,
      totalSessions: sessions.length,
      sessionsConfirmed: sessionsConfirmed,
      sessionsMissed: sessionsMissed,
      sessionsRescheduled: sessionsRescheduled,
      totalReceived: totalReceived,
      totalPending: totalPending,
      total: totalReceived + totalPending,
    );
  }

  // Sessões pendentes de pagamento
  Future<List<Session>> getPendingSessions() async {
    final collection = _sessionService._sessionsCollection();
    if (collection == null) return [];

    final snapshot = await collection
        .where('paymentStatus', isEqualTo: 'pendente')
        .orderBy('dateTime', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Session.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Total recebido no período
  Future<double> getTotalReceivedInPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    final sessions = await _sessionService.getSessionsByPeriod(
      start: start,
      end: end,
    );

    return sessions
        .where((s) => s.paymentStatus == 'pago')
        .fold(0.0, (sum, s) => sum + s.value);
  }
}

// Classe para relatório mensal
class MonthlyReport {
  final int year;
  final int month;
  final int totalSessions;
  final int sessionsConfirmed;
  final int sessionsMissed;
  final int sessionsRescheduled;
  final double totalReceived;
  final double totalPending;
  final double total;

  MonthlyReport({
    required this.year,
    required this.month,
    required this.totalSessions,
    required this.sessionsConfirmed,
    required this.sessionsMissed,
    required this.sessionsRescheduled,
    required this.totalReceived,
    required this.totalPending,
    required this.total,
  });

  String get monthName {
    const months = [
      'Janeiro', 'Fevereiro', 'Março', 'Abril', 'Maio', 'Junho',
      'Julho', 'Agosto', 'Setembro', 'Outubro', 'Novembro', 'Dezembro'
    ];
    return months[month - 1];
  }
}
