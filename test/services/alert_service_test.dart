import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/alert_item.dart';
import 'package:theraflow/src/models/client.dart';
import 'package:theraflow/src/models/package.dart';
import 'package:theraflow/src/models/payment.dart';
import 'package:theraflow/src/models/session.dart';
import 'package:theraflow/src/services/alert_service.dart';

// ─── helpers ────────────────────────────────────────────────────────────────

Client _client({
  String id = 'c1',
  String status = 'active',
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return Client(
    id: id,
    userId: 'u1',
    name: 'Cliente $id',
    phone: '',
    notes: '',
    createdAt: createdAt ?? now,
    updatedAt: now,
    status: status,
  );
}

Session _session({
  required String clientId,
  required DateTime dateTime,
  String status = 'realizada',
  String paymentStatus = 'pago',
  DateTime? deletedAt,
}) {
  final now = DateTime.now();
  return Session(
    id: '${clientId}_${dateTime.millisecondsSinceEpoch}',
    userId: 'u1',
    clientId: clientId,
    dateTime: dateTime,
    therapyType: 'fisioterapia',
    status: status,
    value: 100.0,
    notes: '',
    paymentStatus: paymentStatus,
    createdAt: now,
    updatedAt: now,
    deletedAt: deletedAt,
  );
}

Package _package({
  required String clientId,
  int remainingSessions = 5,
  String status = 'active',
  DateTime? expirationDate,
}) {
  return Package(
    id: '${clientId}_pkg',
    clientId: clientId,
    totalSessions: 10,
    remainingSessions: remainingSessions,
    price: 500.0,
    createdAt: DateTime.now(),
    status: status,
    expirationDate: expirationDate,
  );
}

Payment _payment({
  required String sessionId,
  String status = 'pendente',
  double value = 100.0,
}) {
  final now = DateTime.now();
  return Payment(
    id: 'pay_$sessionId',
    sessionId: sessionId,
    status: status,
    method: 'pix',
    value: value,
    createdAt: now,
  );
}

final _svc = AlertService.instance;

// ─── testes ─────────────────────────────────────────────────────────────────

void main() {
  final now = DateTime.now();

  group('AlertService.computeAlerts', () {
    // ── lista vazia ──────────────────────────────────────────────────────────
    test('sem dados retorna lista vazia', () {
      final alerts = _svc.computeAlerts(
        allSessions: [],
        clients: [],
        payments: [],
        packages: [],
      );
      expect(alerts, isEmpty);
    });

    // ── paymentOverdue ───────────────────────────────────────────────────────
    group('paymentOverdue', () {
      test('pagamento pendente gera alerta high', () {
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [],
          payments: [_payment(sessionId: 's1', status: 'pendente', value: 200)],
          packages: [],
        );

        expect(alerts.length, 1);
        expect(alerts.first.type, AlertType.paymentOverdue);
        expect(alerts.first.priority, AlertPriority.high);
        expect(alerts.first.message, contains('200'));
      });

      test('pagamento pago NÃO gera alerta', () {
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [],
          payments: [_payment(sessionId: 's1', status: 'pago')],
          packages: [],
        );
        expect(alerts.where((a) => a.type == AlertType.paymentOverdue), isEmpty);
      });

      test('múltiplos pagamentos pendentes: contagem e total corretos', () {
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [],
          payments: [
            _payment(sessionId: 's1', status: 'pendente', value: 100),
            _payment(sessionId: 's2', status: 'pendente', value: 150),
          ],
          packages: [],
        );

        final overdue =
            alerts.where((a) => a.type == AlertType.paymentOverdue).toList();
        expect(overdue.length, 1);
        expect(overdue.first.message, contains('2'));
        expect(overdue.first.message, contains('250'));
      });

      test('rota aponta para /finance', () {
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [],
          payments: [_payment(sessionId: 's1', status: 'pendente')],
          packages: [],
        );
        expect(
          alerts.firstWhere((a) => a.type == AlertType.paymentOverdue).route,
          '/finance',
        );
      });
    });

    // ── packageEnding ────────────────────────────────────────────────────────
    group('packageEnding', () {
      test('pacote ativo com ≤2 sessões gera alerta high', () {
        final client = _client(id: 'c1');
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [client],
          payments: [],
          packages: [_package(clientId: 'c1', remainingSessions: 2)],
        );
        final pkg = alerts.where((a) => a.type == AlertType.packageEnding).toList();
        expect(pkg.length, 1);
        expect(pkg.first.priority, AlertPriority.high);
        expect(pkg.first.clientId, 'c1');
        expect(pkg.first.clientName, 'Cliente c1');
      });

      test('pacote com 1 sessão restante gera alerta', () {
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [_client(id: 'c1')],
          payments: [],
          packages: [_package(clientId: 'c1', remainingSessions: 1)],
        );
        expect(
          alerts.where((a) => a.type == AlertType.packageEnding),
          isNotEmpty,
        );
      });

      test('pacote com 3 sessões NÃO gera alerta', () {
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [_client(id: 'c1')],
          payments: [],
          packages: [_package(clientId: 'c1', remainingSessions: 3)],
        );
        expect(
          alerts.where((a) => a.type == AlertType.packageEnding),
          isEmpty,
        );
      });

      test('pacote expirado NÃO gera alerta mesmo com poucas sessões', () {
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [_client(id: 'c1')],
          payments: [],
          packages: [
            _package(
              clientId: 'c1',
              remainingSessions: 1,
              expirationDate: now.subtract(const Duration(days: 1)),
            ),
          ],
        );
        expect(
          alerts.where((a) => a.type == AlertType.packageEnding),
          isEmpty,
        );
      });

      test('cliente sem nome exibe mensagem sem nome (não null)', () {
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [],
          payments: [],
          packages: [_package(clientId: 'desconhecido', remainingSessions: 1)],
        );
        final pkg =
            alerts.firstWhere((a) => a.type == AlertType.packageEnding);
        expect(pkg.message, isNotEmpty);
        expect(pkg.message, isNot(contains('null')));
      });
    });

    // ── clientAtRisk ─────────────────────────────────────────────────────────
    group('clientAtRisk', () {
      test('última sessão > 30 dias e sem próxima gera alerta medium', () {
        final client = _client(id: 'c1');
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 45)),
          ),
        ];
        final alerts = _svc.computeAlerts(
          allSessions: sessions,
          clients: [client],
          payments: [],
          packages: [],
        );
        final risk =
            alerts.where((a) => a.type == AlertType.clientAtRisk).toList();
        expect(risk.length, 1);
        expect(risk.first.priority, AlertPriority.medium);
        expect(risk.first.clientId, 'c1');
      });

      test('última sessão ≤ 30 dias NÃO gera alerta de risco', () {
        final client = _client(id: 'c1');
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 20)),
          ),
        ];
        final alerts = _svc.computeAlerts(
          allSessions: sessions,
          clients: [client],
          payments: [],
          packages: [],
        );
        expect(
          alerts.where((a) => a.type == AlertType.clientAtRisk),
          isEmpty,
        );
      });

      test('sessão deletada não conta como retorno', () {
        final client = _client(id: 'c1');
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 5)),
            deletedAt: now,
          ),
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 45)),
          ),
        ];
        final alerts = _svc.computeAlerts(
          allSessions: sessions,
          clients: [client],
          payments: [],
          packages: [],
        );
        expect(
          alerts.where((a) => a.type == AlertType.clientAtRisk),
          isNotEmpty,
        );
      });

      test('cliente inativo NÃO gera alerta de risco', () {
        final client = _client(id: 'c1', status: 'inactive');
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 45)),
          ),
        ];
        final alerts = _svc.computeAlerts(
          allSessions: sessions,
          clients: [client],
          payments: [],
          packages: [],
        );
        expect(
          alerts.where((a) => a.type == AlertType.clientAtRisk),
          isEmpty,
        );
      });
    });

    // ── clientNoNextSession ──────────────────────────────────────────────────
    group('clientNoNextSession', () {
      test('cliente ativo com sessão passada e sem próxima gera alerta medium',
          () {
        final client = _client(id: 'c1');
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 5)),
          ),
        ];
        final alerts = _svc.computeAlerts(
          allSessions: sessions,
          clients: [client],
          payments: [],
          packages: [],
        );
        expect(
          alerts.where((a) => a.type == AlertType.clientNoNextSession),
          isNotEmpty,
        );
        expect(
          alerts
              .firstWhere((a) => a.type == AlertType.clientNoNextSession)
              .priority,
          AlertPriority.medium,
        );
      });

      test('cliente com próxima sessão agendada NÃO gera alerta', () {
        final client = _client(id: 'c1');
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 5)),
          ),
          _session(
            clientId: 'c1',
            dateTime: now.add(const Duration(days: 7)),
            status: 'agendado',
          ),
        ];
        final alerts = _svc.computeAlerts(
          allSessions: sessions,
          clients: [client],
          payments: [],
          packages: [],
        );
        expect(
          alerts.where((a) => a.type == AlertType.clientNoNextSession),
          isEmpty,
        );
      });

      test('cliente novo sem histórico NÃO gera alerta de sem-próxima', () {
        final client = _client(id: 'c1');
        final alerts = _svc.computeAlerts(
          allSessions: [],
          clients: [client],
          payments: [],
          packages: [],
        );
        expect(
          alerts.where((a) => a.type == AlertType.clientNoNextSession),
          isEmpty,
        );
      });
    });

    // ── sessionTomorrow ──────────────────────────────────────────────────────
    group('sessionTomorrow', () {
      test('sessão amanhã gera alerta low', () {
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);
        final alerts = _svc.computeAlerts(
          allSessions: [
            _session(clientId: 'c1', dateTime: tomorrow, status: 'agendado'),
          ],
          clients: [],
          payments: [],
          packages: [],
        );
        final tmw =
            alerts.where((a) => a.type == AlertType.sessionTomorrow).toList();
        expect(tmw.length, 1);
        expect(tmw.first.priority, AlertPriority.low);
        expect(tmw.first.route, '/agenda');
      });

      test('sessão cancelada amanhã NÃO gera alerta', () {
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);
        final alerts = _svc.computeAlerts(
          allSessions: [
            _session(
                clientId: 'c1', dateTime: tomorrow, status: 'cancelado'),
          ],
          clients: [],
          payments: [],
          packages: [],
        );
        expect(
          alerts.where((a) => a.type == AlertType.sessionTomorrow),
          isEmpty,
        );
      });

      test('sessão hoje NÃO gera alerta de amanhã', () {
        final alerts = _svc.computeAlerts(
          allSessions: [
            _session(clientId: 'c1', dateTime: now, status: 'agendado'),
          ],
          clients: [],
          payments: [],
          packages: [],
        );
        expect(
          alerts.where((a) => a.type == AlertType.sessionTomorrow),
          isEmpty,
        );
      });

      test('2 sessões amanhã: mensagem menciona 2', () {
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);
        final tomorrow2 = DateTime(now.year, now.month, now.day + 1, 14, 0);
        final alerts = _svc.computeAlerts(
          allSessions: [
            _session(clientId: 'c1', dateTime: tomorrow, status: 'agendado'),
            _session(clientId: 'c2', dateTime: tomorrow2, status: 'agendado'),
          ],
          clients: [],
          payments: [],
          packages: [],
        );
        final tmw =
            alerts.firstWhere((a) => a.type == AlertType.sessionTomorrow);
        expect(tmw.message, contains('2'));
      });
    });

    // ── ordenação ────────────────────────────────────────────────────────────
    group('ordenação por prioridade', () {
      test('alertas high aparecem antes de medium e low', () {
        final tomorrow = DateTime(now.year, now.month, now.day + 1, 10, 0);
        final client = _client(id: 'c1');
        final alerts = _svc.computeAlerts(
          allSessions: [
            _session(
              clientId: 'c1',
              dateTime: now.subtract(const Duration(days: 5)),
            ),
            _session(clientId: 'c1', dateTime: tomorrow, status: 'agendado'),
          ],
          clients: [client],
          payments: [_payment(sessionId: 's1', status: 'pendente')],
          packages: [_package(clientId: 'c1', remainingSessions: 1)],
        );

        expect(alerts, isNotEmpty);
        for (int i = 0; i < alerts.length - 1; i++) {
          expect(
            alerts[i].priority.index <= alerts[i + 1].priority.index,
            true,
            reason:
                'Alerta $i (${alerts[i].priority}) deve vir antes do ${i + 1} (${alerts[i + 1].priority})',
          );
        }
      });
    });
  });
}
