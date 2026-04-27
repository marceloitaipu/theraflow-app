import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/package.dart';

void main() {
  group('Package Model extended', () {
    Package makePackage({
      int totalSessions = 10,
      int remainingSessions = 10,
      double price = 1000.0,
      String status = 'active',
      DateTime? expirationDate,
    }) {
      return Package(
        id: 'pkg1',
        clientId: 'c1',
        totalSessions: totalSessions,
        remainingSessions: remainingSessions,
        price: price,
        createdAt: DateTime(2026, 1, 1),
        status: status,
        expirationDate: expirationDate,
      );
    }

    group('isActive', () {
      test('true para pacote ativo com sessões restantes', () {
        expect(makePackage(remainingSessions: 5).isActive, true);
      });

      test('false quando status não é active', () {
        expect(makePackage(status: 'expired').isActive, false);
        expect(makePackage(status: 'completed').isActive, false);
      });

      test('false quando não há sessões restantes', () {
        expect(makePackage(remainingSessions: 0).isActive, false);
      });

      test('false quando expirado', () {
        expect(makePackage(
          expirationDate: DateTime.now().subtract(const Duration(days: 1)),
        ).isActive, false);
      });

      test('true com expiração futura', () {
        expect(makePackage(
          expirationDate: DateTime.now().add(const Duration(days: 30)),
        ).isActive, true);
      });
    });

    group('fromMap com Timestamp', () {
      test('aceita Timestamp em createdAt', () {
        final ts = Timestamp.fromDate(DateTime(2026, 1, 1));
        final map = {
          'clientId': 'c1',
          'totalSessions': 10,
          'remainingSessions': 8,
          'price': 1000.0,
          'createdAt': ts,
          'status': 'active',
        };

        final pkg = Package.fromMap('pkg1', map);
        expect(pkg.createdAt, ts.toDate());
      });

      test('aceita totalSessions como int', () {
        final map = {
          'clientId': 'c1',
          'totalSessions': 10,
          'remainingSessions': 5,
          'price': 1000.0,
          'createdAt': DateTime.now().toIso8601String(),
          'status': 'active',
        };

        final pkg = Package.fromMap('pkg1', map);
        expect(pkg.totalSessions, 10);
        expect(pkg.remainingSessions, 5);
      });

      test('usa defaults quando campos ausentes', () {
        final map = {
          'clientId': 'c1',
          'createdAt': DateTime.now().toIso8601String(),
        };

        final pkg = Package.fromMap('pkg1', map);
        expect(pkg.totalSessions, 0);
        expect(pkg.remainingSessions, 0);
        expect(pkg.price, 0.0);
        expect(pkg.status, 'active');
        expect(pkg.expirationDate, isNull);
      });
    });

    group('pricePerSession edge cases', () {
      test('totalSessions 0 retorna 0 sem dividir por zero', () {
        expect(makePackage(totalSessions: 0, price: 999).pricePerSession, 0.0);
      });

      test('1 sessão retorna preço total', () {
        expect(makePackage(totalSessions: 1, price: 300).pricePerSession, 300.0);
      });
    });

    group('usedSessions e usagePercentage', () {
      test('0 sessões usadas', () {
        final pkg = makePackage(totalSessions: 10, remainingSessions: 10);
        expect(pkg.usedSessions, 0);
        expect(pkg.usagePercentage, 0.0);
      });

      test('todas usadas', () {
        final pkg = makePackage(totalSessions: 10, remainingSessions: 0);
        expect(pkg.usedSessions, 10);
        expect(pkg.usagePercentage, 100.0);
      });

      test('metade usada', () {
        final pkg = makePackage(totalSessions: 8, remainingSessions: 4);
        expect(pkg.usedSessions, 4);
        expect(pkg.usagePercentage, 50.0);
      });
    });

    group('copyWith', () {
      test('atualiza remainingSessions e status', () {
        final original = makePackage(remainingSessions: 5, status: 'active');
        final updated = original.copyWith(remainingSessions: 0, status: 'completed');

        expect(updated.remainingSessions, 0);
        expect(updated.status, 'completed');
        expect(updated.id, original.id);
        expect(updated.clientId, original.clientId);
      });

      test('atualiza expirationDate', () {
        final newDate = DateTime(2027, 12, 31);
        final updated = makePackage().copyWith(expirationDate: newDate);
        expect(updated.expirationDate, newDate);
      });

      test('preserva campos não fornecidos', () {
        final original = makePackage(price: 500.0, totalSessions: 5);
        final copy = original.copyWith();
        expect(copy.price, 500.0);
        expect(copy.totalSessions, 5);
      });
    });
  });
}
