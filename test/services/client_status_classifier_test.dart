import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/client.dart';
import 'package:theraflow/src/models/package.dart';
import 'package:theraflow/src/models/session.dart';
import 'package:theraflow/src/services/client_status_classifier.dart';

// ─── helpers ────────────────────────────────────────────────────────────────

Client _client({
  String id = 'c1',
  DateTime? createdAt,
}) {
  final now = DateTime.now();
  return Client(
    id: id,
    userId: 'u1',
    name: 'Test $id',
    phone: '',
    notes: '',
    createdAt: createdAt ?? now,
    updatedAt: now,
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

final _classifier = ClientStatusClassifier.instance;

// ─── testes ──────────────────────────────────────────────────────────────────

void main() {
  group('AutoClientStatus', () {
    group('labels pt-BR', () {
      test('novo', () => expect(AutoClientStatus.novo.label, 'novo'));
      test('ativo', () => expect(AutoClientStatus.ativo.label, 'ativo'));
      test('inadimplente',
          () => expect(AutoClientStatus.inadimplente.label, 'inadimplente'));
      test('pacoteAcabando',
          () => expect(AutoClientStatus.pacoteAcabando.label, 'pacote acabando'));
      test('emRisco',
          () => expect(AutoClientStatus.emRisco.label, 'em risco'));
      test('inativo',
          () => expect(AutoClientStatus.inativo.label, 'inativo'));
    });

    group('priority — menor = mais urgente', () {
      test('inadimplente é mais urgente (0)', () {
        expect(AutoClientStatus.inadimplente.priority, 0);
      });
      test('emRisco vem depois (1)', () {
        expect(AutoClientStatus.emRisco.priority, 1);
      });
      test('pacoteAcabando vem depois (2)', () {
        expect(AutoClientStatus.pacoteAcabando.priority, 2);
      });
      test('inativo vem depois (3)', () {
        expect(AutoClientStatus.inativo.priority, 3);
      });
      test('novo (4)', () {
        expect(AutoClientStatus.novo.priority, 4);
      });
      test('ativo é menos urgente (5)', () {
        expect(AutoClientStatus.ativo.priority, 5);
      });

      test('inadimplente é mais urgente que todos', () {
        for (final s in AutoClientStatus.values) {
          if (s != AutoClientStatus.inadimplente) {
            expect(AutoClientStatus.inadimplente.priority < s.priority, true,
                reason: 'inadimplente deve ter prioridade menor que ${s.name}');
          }
        }
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('ClientStatusClassifier.classify', () {
    final now = DateTime.now();

    // ── 1. inadimplente ────────────────────────────────────────────────────
    group('inadimplente', () {
      test('sessão não-cancelada com paymentStatus pendente → inadimplente', () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 5)),
            status: 'realizada',
            paymentStatus: 'pendente',
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, AutoClientStatus.inadimplente);
        expect(result.hasOverduePayment, true);
      });

      test('sessão cancelada com paymentStatus pendente → NÃO inadimplente', () {
        final client = _client(createdAt: now.subtract(const Duration(days: 5)));
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 5)),
            status: 'cancelado',
            paymentStatus: 'pendente',
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, isNot(AutoClientStatus.inadimplente));
      });

      test('sessão "faltou" com paymentStatus pendente → NÃO inadimplente', () {
        final client = _client(createdAt: now.subtract(const Duration(days: 5)));
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 5)),
            status: 'faltou',
            paymentStatus: 'pendente',
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, isNot(AutoClientStatus.inadimplente));
      });

      test('sessão deletada com paymentStatus pendente → NÃO inadimplente', () {
        final client = _client(createdAt: now.subtract(const Duration(days: 5)));
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 5)),
            status: 'realizada',
            paymentStatus: 'pendente',
            deletedAt: now,
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, isNot(AutoClientStatus.inadimplente));
      });

      test('inadimplente tem prioridade sobre emRisco', () {
        final client = _client();
        final sessions = [
          // em risco (última sessão > 30 dias, sem próxima)
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 45)),
            paymentStatus: 'pendente', // inadimplente também
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, AutoClientStatus.inadimplente);
      });
    });

    // ── 2. inativo ─────────────────────────────────────────────────────────
    group('inativo', () {
      test('última sessão > 90 dias e sem próxima → inativo', () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 91)),
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, AutoClientStatus.inativo);
      });

      test('última sessão == 90 dias → emRisco (não ultrapassou threshold)', () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 90)),
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        // 90 dias não ultrapassa inactiveDays (> 90), cai em emRisco
        expect(result.status, AutoClientStatus.emRisco);
      });

      test('última sessão > 90 dias MAS tem próxima sessão → NÃO inativo', () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 91)),
          ),
          _session(
            clientId: 'c1',
            dateTime: now.add(const Duration(days: 7)),
            status: 'agendado',
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, isNot(AutoClientStatus.inativo));
      });
    });

    // ── 3. emRisco ─────────────────────────────────────────────────────────
    group('emRisco', () {
      test('última sessão > 30 dias e sem próxima → emRisco', () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 45)),
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, AutoClientStatus.emRisco);
        expect(result.lastSessionDate, isNotNull);
      });

      test('última sessão == 30 dias → NÃO emRisco (não ultrapassa threshold)',
          () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 30)),
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, isNot(AutoClientStatus.emRisco));
      });

      test('tem próxima sessão agendada → NÃO emRisco', () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 40)),
          ),
          _session(
            clientId: 'c1',
            dateTime: now.add(const Duration(days: 3)),
            status: 'agendado',
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, isNot(AutoClientStatus.emRisco));
      });
    });

    // ── 4. pacoteAcabando ─────────────────────────────────────────────────
    group('pacoteAcabando', () {
      test('pacote ativo com 2 sessões restantes → pacoteAcabando', () {
        final client = _client();
        final packages = [
          _package(clientId: 'c1', remainingSessions: 2),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: [],
          allPackages: packages,
        );

        expect(result.status, AutoClientStatus.pacoteAcabando);
        expect(result.hasLowPackage, true);
      });

      test('pacote ativo com 1 sessão restante → pacoteAcabando', () {
        final client = _client();
        final packages = [
          _package(clientId: 'c1', remainingSessions: 1),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: [],
          allPackages: packages,
        );

        expect(result.status, AutoClientStatus.pacoteAcabando);
      });

      test('pacote ativo com 3 sessões restantes → NÃO pacoteAcabando', () {
        final client = _client();
        final packages = [
          _package(clientId: 'c1', remainingSessions: 3),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: [],
          allPackages: packages,
        );

        expect(result.status, isNot(AutoClientStatus.pacoteAcabando));
      });

      test('pacote inativo com 1 sessão → NÃO pacoteAcabando', () {
        final client = _client();
        final packages = [
          _package(
            clientId: 'c1',
            remainingSessions: 1,
            status: 'expired', // inativo
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: [],
          allPackages: packages,
        );

        expect(result.status, isNot(AutoClientStatus.pacoteAcabando));
      });

      test('pacote expirado com 1 sessão → NÃO pacoteAcabando', () {
        final client = _client();
        final packages = [
          _package(
            clientId: 'c1',
            remainingSessions: 1,
            expirationDate: now.subtract(const Duration(days: 1)),
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: [],
          allPackages: packages,
        );

        expect(result.status, isNot(AutoClientStatus.pacoteAcabando));
      });
    });

    // ── 5. novo ───────────────────────────────────────────────────────────
    group('novo', () {
      test('sem sessões e cadastrado há ≤ 14 dias → novo', () {
        final client = _client(createdAt: now.subtract(const Duration(days: 7)));

        final result = _classifier.classify(
          client: client,
          allSessions: [],
          allPackages: [],
        );

        expect(result.status, AutoClientStatus.novo);
      });

      test('sem sessões e cadastrado há 14 dias → novo', () {
        final client =
            _client(createdAt: now.subtract(const Duration(days: 14)));

        final result = _classifier.classify(
          client: client,
          allSessions: [],
          allPackages: [],
        );

        expect(result.status, AutoClientStatus.novo);
      });

      test('sem sessões e cadastrado há 15 dias → ativo (passou do limiar)', () {
        final client =
            _client(createdAt: now.subtract(const Duration(days: 15)));

        final result = _classifier.classify(
          client: client,
          allSessions: [],
          allPackages: [],
        );

        expect(result.status, isNot(AutoClientStatus.novo));
      });
    });

    // ── 6. ativo ──────────────────────────────────────────────────────────
    group('ativo', () {
      test('sessão recente (< 30 dias) e sem próxima → ativo', () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.subtract(const Duration(days: 10)),
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, AutoClientStatus.ativo);
      });

      test('tem próxima sessão agendada → ativo', () {
        final client = _client();
        final sessions = [
          _session(
            clientId: 'c1',
            dateTime: now.add(const Duration(days: 7)),
            status: 'agendado',
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.status, AutoClientStatus.ativo);
        expect(result.nextSessionDate, isNotNull);
      });

      test('resultado carrega lastSessionDate e nextSessionDate', () {
        final client = _client();
        final past = now.subtract(const Duration(days: 10));
        final future = now.add(const Duration(days: 7));
        final sessions = [
          _session(clientId: 'c1', dateTime: past),
          _session(clientId: 'c1', dateTime: future, status: 'agendado'),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        expect(result.lastSessionDate, past);
        expect(result.nextSessionDate, future);
      });
    });

    // ── sessões de outros clientes não interferem ─────────────────────────
    group('isolamento por clientId', () {
      test('sessão de outro cliente não afeta classificação', () {
        final client = _client(id: 'c1',
            createdAt: now.subtract(const Duration(days: 5)));
        final sessions = [
          // sessão de outro cliente com pendência
          _session(
            clientId: 'OUTRO',
            dateTime: now.subtract(const Duration(days: 3)),
            paymentStatus: 'pendente',
          ),
        ];

        final result = _classifier.classify(
          client: client,
          allSessions: sessions,
          allPackages: [],
        );

        // Não deve ser inadimplente — a sessão pendente não é desse cliente
        expect(result.status, isNot(AutoClientStatus.inadimplente));
      });
    });
  });

  // ─────────────────────────────────────────────────────────────────────────
  group('ClientStatusClassifier.classifyAll', () {
    final now = DateTime.now();

    test('lista vazia retorna lista vazia', () {
      final results = _classifier.classifyAll(
        clients: [],
        allSessions: [],
        allPackages: [],
      );
      expect(results, isEmpty);
    });

    test('classifica todos os clientes da lista', () {
      final c1 = _client(id: 'c1', createdAt: now.subtract(const Duration(days: 3)));
      final c2 = _client(id: 'c2');
      final sessions = [
        _session(
          clientId: 'c2',
          dateTime: now.subtract(const Duration(days: 5)),
          paymentStatus: 'pendente',
        ),
      ];

      final results = _classifier.classifyAll(
        clients: [c1, c2],
        allSessions: sessions,
        allPackages: [],
      );

      expect(results.length, 2);

      final r1 = results.firstWhere((r) => r.client.id == 'c1');
      final r2 = results.firstWhere((r) => r.client.id == 'c2');

      expect(r1.status, AutoClientStatus.novo);
      expect(r2.status, AutoClientStatus.inadimplente);
    });

    test('cada resultado carrega o cliente correto', () {
      final clients = [
        _client(id: 'A'),
        _client(id: 'B'),
        _client(id: 'C'),
      ];

      final results = _classifier.classifyAll(
        clients: clients,
        allSessions: [],
        allPackages: [],
      );

      expect(results.map((r) => r.client.id).toSet(), {'A', 'B', 'C'});
    });

    test('parâmetro allPayments opcional não causa erro', () {
      final client = _client();

      expect(
        () => _classifier.classifyAll(
          clients: [client],
          allSessions: [],
          allPackages: [],
          allPayments: [],
        ),
        returnsNormally,
      );
    });
  });
}
