import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/payment.dart';

void main() {
  group('Payment Model', () {
    group('construtor e propriedades', () {
      test('cria payment com valores corretos', () {
        final now = DateTime(2026, 3, 15, 10, 30);
        final payment = Payment(
          id: 'p1',
          sessionId: 's1',
          status: 'pago',
          method: 'pix',
          value: 200.0,
          paidAt: now,
          createdAt: now,
        );

        expect(payment.id, 'p1');
        expect(payment.sessionId, 's1');
        expect(payment.status, 'pago');
        expect(payment.method, 'pix');
        expect(payment.value, 200.0);
        expect(payment.paidAt, now);
      });

      test('paidAt pode ser nulo para pagamento pendente', () {
        final payment = Payment(
          id: 'p2',
          sessionId: 's2',
          status: 'pendente',
          method: 'dinheiro',
          value: 150.0,
          paidAt: null,
          createdAt: DateTime.now(),
        );

        expect(payment.paidAt, isNull);
        expect(payment.status, 'pendente');
      });
    });

    group('toMap / fromMap', () {
      test('toMap serializa todos os campos', () {
        final now = DateTime(2026, 4, 1);
        final payment = Payment(
          id: 'p1',
          sessionId: 's1',
          status: 'pago',
          method: 'cartao',
          value: 300.0,
          paidAt: now,
          createdAt: now,
        );

        final map = payment.toMap();

        expect(map['sessionId'], 's1');
        expect(map['status'], 'pago');
        expect(map['method'], 'cartao');
        expect(map['value'], 300.0);
        expect(map['paidAt'], now.toIso8601String());
        expect(map['createdAt'], now.toIso8601String());
      });

      test('toMap serializa paidAt nulo', () {
        final payment = Payment(
          id: 'p1',
          sessionId: 's1',
          status: 'pendente',
          method: 'pix',
          value: 100.0,
          createdAt: DateTime.now(),
        );

        final map = payment.toMap();
        expect(map['paidAt'], isNull);
      });

      test('fromMap recria payment corretamente', () {
        final now = DateTime(2026, 1, 20);
        final map = {
          'sessionId': 'sess123',
          'status': 'pago',
          'method': 'pix',
          'value': 250.0,
          'paidAt': now.toIso8601String(),
          'createdAt': now.toIso8601String(),
        };

        final payment = Payment.fromMap('pay1', map);

        expect(payment.id, 'pay1');
        expect(payment.sessionId, 'sess123');
        expect(payment.method, 'pix');
        expect(payment.value, 250.0);
      });

      test('fromMap aceita Timestamp do Firestore', () {
        final ts = Timestamp.fromDate(DateTime(2026, 2, 10));
        final map = {
          'sessionId': 's1',
          'status': 'pago',
          'method': 'dinheiro',
          'value': 100.0,
          'paidAt': ts,
          'createdAt': ts,
        };

        final payment = Payment.fromMap('p1', map);
        expect(payment.paidAt, ts.toDate());
        expect(payment.createdAt, ts.toDate());
      });

      test('fromMap aceita value como int', () {
        final map = {
          'sessionId': 's1',
          'status': 'pago',
          'method': 'dinheiro',
          'value': 200,
          'createdAt': DateTime.now().toIso8601String(),
        };

        final payment = Payment.fromMap('p1', map);
        expect(payment.value, 200.0);
        expect(payment.value, isA<double>());
      });

      test('fromMap usa defaults quando campos ausentes', () {
        final map = {
          'createdAt': DateTime.now().toIso8601String(),
        };

        final payment = Payment.fromMap('p1', map);
        expect(payment.status, 'pendente');
        expect(payment.method, 'dinheiro');
        expect(payment.value, 0.0);
        expect(payment.paidAt, isNull);
      });
    });

    group('copyWith', () {
      test('atualiza status e paidAt', () {
        final original = Payment(
          id: 'p1',
          sessionId: 's1',
          status: 'pendente',
          method: 'pix',
          value: 150.0,
          createdAt: DateTime(2026, 1, 1),
        );

        final paid = DateTime(2026, 4, 20);
        final updated = original.copyWith(status: 'pago', paidAt: paid);

        expect(updated.status, 'pago');
        expect(updated.paidAt, paid);
        expect(updated.id, original.id);
        expect(updated.sessionId, original.sessionId);
        expect(updated.value, original.value);
      });

      test('atualiza method e value', () {
        final original = Payment(
          id: 'p1',
          sessionId: 's1',
          status: 'pendente',
          method: 'dinheiro',
          value: 100.0,
          createdAt: DateTime(2026, 1, 1),
        );

        final updated = original.copyWith(method: 'cartao', value: 200.0);

        expect(updated.method, 'cartao');
        expect(updated.value, 200.0);
        expect(updated.status, 'pendente');
      });

      test('preserva campos não fornecidos', () {
        final paidAt = DateTime(2026, 3, 15);
        final original = Payment(
          id: 'p1',
          sessionId: 's1',
          status: 'pago',
          method: 'pix',
          value: 150.0,
          paidAt: paidAt,
          createdAt: DateTime(2026, 1, 1),
        );

        final updated = original.copyWith(value: 180.0);
        expect(updated.paidAt, paidAt);
        expect(updated.method, 'pix');
      });
    });
  });
}
