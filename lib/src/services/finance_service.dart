import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';
import '../models/session.dart';
import '../models/payment.dart';
import '../database/database_helper.dart';
import 'auth_service.dart';
import 'incremental_sync_service.dart';
import 'session_service.dart';

class FinanceService {
  FinanceService._();
  static final instance = FinanceService._();

  final DatabaseHelper _db = DatabaseHelper.instance;
  final AuthService _auth = AuthService.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final IncrementalSyncService _sync = IncrementalSyncService.instance;
  final SessionService _sessionService = SessionService.instance;
  final Uuid _uuid = const Uuid();

  CollectionReference<Map<String, dynamic>> _paymentsCollection(String userId) {
    return _firestore.collection('users').doc(userId).collection('payments');
  }

  // Buscar todos os pagamentos do banco local
  Future<List<Payment>> getPayments() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return [];
    if (kIsWeb) {
      final snapshot = await _paymentsCollection(userId).get();
      final payments = snapshot.docs
          .map((doc) => Payment.fromMap(doc.id, doc.data()))
          .where((payment) => payment.status != 'deleted')
          .toList();
      payments.sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return payments;
    }
    if (_db.isUnavailable) return [];

    try {
      final maps = await _db.getAllPayments(userId);
      return maps.map((map) => Payment.fromMap(map['id'] as String, map)).toList();
    } catch (e) {
      return [];
    }
  }

  // Criar pagamento para uma sessão
  Future<String> createPayment({
    required String sessionId,
    required double value,
    required String method,
    String status = 'pago',
  }) async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Gerar ID único
    final id = _uuid.v4();

    final now = DateTime.now();
    final paymentData = {
      'id': id,
      'userId': userId,
      'sessionId': sessionId,
      'status': status,
      'method': method,
      'value': value,
      'paidAt': status == 'pago' ? now.toIso8601String() : null,
      'createdAt': now.toIso8601String(),
      'updatedAt': now.toIso8601String(),
      'deletedAt': null,
      'synced': 0,
      'lastModified': now.toIso8601String(),
      'deleted': 0,
    };

    if (kIsWeb) {
      await _paymentsCollection(userId).doc(id).set(paymentData);
      if (status == 'pago') {
        await _sessionService.markAsPaid(sessionId);
      }
      return id;
    }

    // Salvar localmente
    await _db.insertPayment(paymentData);

    // Atualizar status de pagamento da sessão
    if (status == 'pago') {
      await _sessionService.markAsPaid(sessionId);
    }

    // Se offline, adicionar à fila de sincronização
    if (!_sync.isOnline) {
      await _db.addToSyncQueue(
        operation: 'create',
        tableName: 'payments',
        recordId: id,
        data: jsonEncode(paymentData),
      );
    } else {
      // Se online, sincronizar imediatamente
      _sync.syncAll();
    }

    return id;
  }

  // Buscar pagamento por sessão
  Future<Payment?> getPaymentBySession(String sessionId) async {
    final payments = await getPayments();
    try {
      return payments.firstWhere((p) => p.sessionId == sessionId);
    } catch (e) {
      return null;
    }
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
    final sessions = await _sessionService.getSessions();
    return sessions
        .where((s) => s.paymentStatus == 'pendente')
        .toList()
      ..sort((a, b) => b.dateTime.compareTo(a.dateTime));
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

    double total = 0.0;
    for (final s in sessions) {
      if (s.paymentStatus == 'pago') {
        total += s.value;
      }
    }
    return total;
  }

  // ========== INSIGHTS FINANCEIROS ==========

  /// Receita esperada nos próximos 7 dias (sessões agendadas)
  Future<double> getExpectedNext7Days() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 7));

    final sessions = await _sessionService.getSessionsByPeriod(
      start: start,
      end: end,
    );

    double total = 0.0;
    for (final s in sessions) {
      if (s.status == 'confirmado' || s.status == 'agendado') {
        total += s.value;
      }
    }
    return total;
  }

  /// Comparação mês atual vs mês anterior
  Future<MonthComparison> getMonthOverMonthComparison() async {
    final now = DateTime.now();

    // Mês atual
    final currentReport = await getMonthlyReport(
      year: now.year,
      month: now.month,
    );

    // Mês anterior
    final prevMonth = DateTime(now.year, now.month - 1, 1);
    final previousReport = await getMonthlyReport(
      year: prevMonth.year,
      month: prevMonth.month,
    );

    final receivedDiff = previousReport.totalReceived > 0
        ? ((currentReport.totalReceived - previousReport.totalReceived) /
                previousReport.totalReceived *
                100)
        : 0.0;

    final sessionsDiff = previousReport.totalSessions > 0
        ? ((currentReport.totalSessions - previousReport.totalSessions) /
                previousReport.totalSessions *
                100)
        : 0.0;

    return MonthComparison(
      currentMonth: currentReport,
      previousMonth: previousReport,
      receivedPercentChange: receivedDiff,
      sessionsPercentChange: sessionsDiff,
    );
  }

  /// Insights financeiros para exibição
  Future<FinanceInsights> getFinanceInsights() async {
    final comparison = await getMonthOverMonthComparison();
    final expectedNext7Days = await getExpectedNext7Days();
    final pendingSessions = await getPendingSessions();

    final currentMonth = comparison.currentMonth;

    // Gerar mensagens inteligentes
    final List<InsightMessage> messages = [];

    // Mensagem sobre pendentes
    if (currentMonth.totalPending > 0) {
      final pendingCount = pendingSessions.length;
      messages.add(InsightMessage(
        icon: '⚠️',
        type: InsightType.warning,
        message: 'Você tem R\$ ${currentMonth.totalPending.toStringAsFixed(0)} '
            'pendentes em $pendingCount sessões.',
      ));
    }

    // Mensagem sobre próximos 7 dias
    if (expectedNext7Days > 0) {
      messages.add(InsightMessage(
        icon: '📅',
        type: InsightType.info,
        message: 'Receita esperada nos próximos 7 dias: '
            'R\$ ${expectedNext7Days.toStringAsFixed(0)}',
      ));
    }

    // Mensagem de comparação mensal
    if (comparison.receivedPercentChange.abs() > 5) {
      final isUp = comparison.receivedPercentChange > 0;
      messages.add(InsightMessage(
        icon: isUp ? '📈' : '📉',
        type: isUp ? InsightType.success : InsightType.warning,
        message: isUp
            ? 'Receita ${comparison.receivedPercentChange.toStringAsFixed(0)}% '
                'maior que o mês anterior!'
            : 'Receita ${comparison.receivedPercentChange.abs().toStringAsFixed(0)}% '
                'menor que o mês anterior.',
      ));
    }

    // Taxa de faltas
    final totalScheduled = currentMonth.sessionsConfirmed +
        currentMonth.sessionsMissed +
        currentMonth.sessionsRescheduled;
    if (totalScheduled > 0) {
      final noShowRate = currentMonth.sessionsMissed / totalScheduled * 100;
      if (noShowRate > 10) {
        messages.add(InsightMessage(
          icon: '🔔',
          type: InsightType.alert,
          message:
              'Taxa de faltas de ${noShowRate.toStringAsFixed(0)}% este mês. '
              'Considere enviar lembretes!',
        ));
      }
    }

    // Mensagem positiva se tudo ok
    if (messages.isEmpty) {
      messages.add(InsightMessage(
        icon: '✨',
        type: InsightType.success,
        message: 'Suas finanças estão em dia!',
      ));
    }

    return FinanceInsights(
      comparison: comparison,
      expectedNext7Days: expectedNext7Days,
      pendingCount: pendingSessions.length,
      pendingTotal: currentMonth.totalPending,
      messages: messages,
    );
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
      'Janeiro',
      'Fevereiro',
      'Março',
      'Abril',
      'Maio',
      'Junho',
      'Julho',
      'Agosto',
      'Setembro',
      'Outubro',
      'Novembro',
      'Dezembro'
    ];
    return months[month - 1];
  }
}

// Comparação entre meses
class MonthComparison {
  final MonthlyReport currentMonth;
  final MonthlyReport previousMonth;
  final double receivedPercentChange;
  final double sessionsPercentChange;

  MonthComparison({
    required this.currentMonth,
    required this.previousMonth,
    required this.receivedPercentChange,
    required this.sessionsPercentChange,
  });

  bool get isReceivedUp => receivedPercentChange > 0;
  bool get isSessionsUp => sessionsPercentChange > 0;
}

// Tipos de insight
enum InsightType { success, warning, info, alert }

// Mensagem de insight
class InsightMessage {
  final String icon;
  final InsightType type;
  final String message;

  InsightMessage({
    required this.icon,
    required this.type,
    required this.message,
  });
}

// Insights financeiros
class FinanceInsights {
  final MonthComparison comparison;
  final double expectedNext7Days;
  final int pendingCount;
  final double pendingTotal;
  final List<InsightMessage> messages;

  FinanceInsights({
    required this.comparison,
    required this.expectedNext7Days,
    required this.pendingCount,
    required this.pendingTotal,
    required this.messages,
  });
}
