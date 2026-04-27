import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:theraflow/src/models/session.dart';

void main() {
  group('Session Model extended', () {
    Session makeSession({
      String status = 'confirmado',
      String paymentStatus = 'pendente',
      String? packageId,
      double value = 150.0,
    }) {
      final now = DateTime(2026, 4, 27, 10, 0);
      return Session(
        id: 's1',
        userId: 'u1',
        clientId: 'c1',
        dateTime: now,
        therapyType: 'Massoterapia',
        status: status,
        value: value,
        notes: '',
        paymentStatus: paymentStatus,
        createdAt: now,
        updatedAt: now,
        packageId: packageId,
      );
    }

    group('construtor e propriedades', () {
      test('cria session com todos os campos', () {
        final session = makeSession(
          status: 'realizada',
          paymentStatus: 'pago',
          packageId: 'pkg1',
          value: 200.0,
        );

        expect(session.status, 'realizada');
        expect(session.paymentStatus, 'pago');
        expect(session.packageId, 'pkg1');
        expect(session.value, 200.0);
      });

      test('deletedAt é nulo por padrão', () {
        expect(makeSession().deletedAt, isNull);
      });
    });

    group('status possíveis', () {
      for (final s in ['confirmado', 'realizada', 'faltou', 'remarcado', 'agendado']) {
        test('aceita status $s', () {
          final session = makeSession(status: s);
          expect(session.status, s);
        });
      }
    });

    group('paymentStatus possíveis', () {
      test('aceita pago', () => expect(makeSession(paymentStatus: 'pago').paymentStatus, 'pago'));
      test('aceita pendente', () => expect(makeSession(paymentStatus: 'pendente').paymentStatus, 'pendente'));
    });

    group('toMap', () {
      test('inclui todos os campos', () {
        final session = makeSession(status: 'realizada', paymentStatus: 'pago', packageId: 'pkg1');
        final map = session.toMap();

        expect(map['userId'], 'u1');
        expect(map['clientId'], 'c1');
        expect(map['therapyType'], 'Massoterapia');
        expect(map['status'], 'realizada');
        expect(map['paymentStatus'], 'pago');
        expect(map['packageId'], 'pkg1');
        expect(map['value'], 150.0);
        expect(map.containsKey('createdAt'), true);
        expect(map.containsKey('updatedAt'), true);
      });

      test('packageId null quando não definido', () {
        final map = makeSession().toMap();
        expect(map['packageId'], isNull);
      });
    });

    group('fromMap', () {
      test('reconstrói session completa', () {
        final now = DateTime(2026, 3, 10, 14, 0);
        final map = {
          'userId': 'u2',
          'clientId': 'c2',
          'dateTime': now.toIso8601String(),
          'therapyType': 'Reiki',
          'status': 'faltou',
          'value': 120.0,
          'notes': 'Sem contato',
          'paymentStatus': 'pendente',
          'packageId': null,
          'createdAt': now.toIso8601String(),
          'updatedAt': now.toIso8601String(),
        };

        final session = Session.fromMap('s99', map);

        expect(session.id, 's99');
        expect(session.status, 'faltou');
        expect(session.value, 120.0);
        expect(session.therapyType, 'Reiki');
        expect(session.packageId, isNull);
      });

      test('aceita Timestamp do Firestore em dateTime', () {
        final ts = Timestamp.fromDate(DateTime(2026, 2, 15, 9, 30));
        final map = {
          'userId': 'u1',
          'clientId': 'c1',
          'dateTime': ts,
          'therapyType': 'Acupuntura',
          'status': 'confirmado',
          'value': 180.0,
          'notes': '',
          'paymentStatus': 'pendente',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final session = Session.fromMap('s1', map);
        expect(session.dateTime, ts.toDate());
      });

      test('aceita value como int', () {
        final map = {
          'userId': 'u1',
          'clientId': 'c1',
          'dateTime': DateTime.now().toIso8601String(),
          'therapyType': 'X',
          'status': 'confirmado',
          'value': 150,
          'notes': '',
          'paymentStatus': 'pendente',
          'createdAt': DateTime.now().toIso8601String(),
          'updatedAt': DateTime.now().toIso8601String(),
        };

        final session = Session.fromMap('s1', map);
        expect(session.value, 150.0);
        expect(session.value, isA<double>());
      });

      test('usa defaults quando campos ausentes', () {
        final map = {
          'createdAt': DateTime.now().toIso8601String(),
          'dateTime': DateTime.now().toIso8601String(),
        };

        final session = Session.fromMap('s1', map);
        expect(session.status, 'confirmado');
        expect(session.paymentStatus, 'pendente');
        expect(session.value, 0.0);
        expect(session.packageId, isNull);
      });
    });

    group('copyWith', () {
      test('atualiza campos informados', () {
        final original = makeSession(status: 'confirmado', paymentStatus: 'pendente');
        final updated = original.copyWith(status: 'realizada', paymentStatus: 'pago');

        expect(updated.status, 'realizada');
        expect(updated.paymentStatus, 'pago');
        expect(updated.id, original.id);
        expect(updated.clientId, original.clientId);
      });

      test('updatedAt é atualizado quando não fornecido', () {
        final past = DateTime(2025, 1, 1);
        final session = Session(
          id: 's1',
          userId: 'u1',
          clientId: 'c1',
          dateTime: past,
          therapyType: 'X',
          status: 'confirmado',
          value: 100,
          notes: '',
          paymentStatus: 'pendente',
          createdAt: past,
          updatedAt: past,
        );

        final updated = session.copyWith(status: 'realizada');
        expect(updated.updatedAt.isAfter(past), true);
      });

      test('define packageId via copyWith', () {
        final original = makeSession(packageId: null);
        final updated = original.copyWith(packageId: 'pkg123');
        expect(updated.packageId, 'pkg123');
      });

      test('preserva packageId quando não alterado', () {
        final original = makeSession(packageId: 'existing');
        final updated = original.copyWith(status: 'realizada');
        expect(updated.packageId, 'existing');
      });
    });
  });
}
