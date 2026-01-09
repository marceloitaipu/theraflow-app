import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/package.dart';

void main() {
  group('Package Model', () {
    group('pricePerSession', () {
      test('calcula corretamente o preço por sessão', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 10,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.pricePerSession, 100.0);
      });

      test('retorna 0 quando totalSessions é 0', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 0,
          remainingSessions: 0,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.pricePerSession, 0.0);
      });
    });

    group('usagePercentage', () {
      test('retorna 0 quando pacote está cheio (0% usado)', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 10,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        // usagePercentage = (usedSessions / totalSessions) * 100
        // usedSessions = 10 - 10 = 0
        expect(package.usagePercentage, 0.0);
      });

      test('retorna 50 quando metade das sessões foram usadas', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 5,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.usagePercentage, 50.0);
      });

      test('retorna 100 quando todas as sessões foram usadas', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 0,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.usagePercentage, 100.0);
      });

      test('retorna 0.0 quando totalSessions é 0', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 0,
          remainingSessions: 0,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.usagePercentage, 0.0);
      });
    });

    group('isLow', () {
      test('retorna true quando restam 2 sessões', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 2,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.isLow, true);
      });

      test('retorna true quando resta 1 sessão', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 1,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.isLow, true);
      });

      test('retorna false quando restam mais de 2 sessões', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 5,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.isLow, false);
      });

      test('retorna false quando não restam sessões', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 0,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.isLow, false);
      });
    });

    group('isActive', () {
      test('retorna true quando status é active e tem sessões restantes', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 5,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.isActive, true);
      });

      test('retorna false quando status é completed', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 0,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'completed',
        );

        expect(package.isActive, false);
      });

      test('retorna false quando não tem sessões restantes', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 0,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.isActive, false);
      });
    });

    group('isExpired', () {
      test('retorna false quando não tem data de expiração', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 5,
          price: 1000.0,
          createdAt: DateTime.now(),
          expirationDate: null,
          status: 'active',
        );

        expect(package.isExpired, false);
      });

      test('retorna true quando data de expiração já passou', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 5,
          price: 1000.0,
          createdAt: DateTime.now(),
          expirationDate: DateTime.now().subtract(const Duration(days: 1)),
          status: 'active',
        );

        expect(package.isExpired, true);
      });

      test('retorna false quando data de expiração é futura', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 5,
          price: 1000.0,
          createdAt: DateTime.now(),
          expirationDate: DateTime.now().add(const Duration(days: 30)),
          status: 'active',
        );

        expect(package.isExpired, false);
      });
    });

    group('usedSessions', () {
      test('calcula corretamente sessões usadas', () {
        final package = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 7,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        expect(package.usedSessions, 3);
      });
    });

    group('toMap / fromMap', () {
      test('serializa e deserializa corretamente', () {
        final now = DateTime.now();
        final expiration = now.add(const Duration(days: 30));
        
        final original = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 8,
          price: 1200.0,
          createdAt: now,
          expirationDate: expiration,
          status: 'active',
        );

        final map = original.toMap();
        final restored = Package.fromMap('1', map);

        expect(restored.id, original.id);
        expect(restored.clientId, original.clientId);
        expect(restored.totalSessions, original.totalSessions);
        expect(restored.remainingSessions, original.remainingSessions);
        expect(restored.price, original.price);
        expect(restored.status, original.status);
      });

      test('lida com expirationDate nulo', () {
        final now = DateTime.now();
        
        final original = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 8,
          price: 1200.0,
          createdAt: now,
          expirationDate: null,
          status: 'active',
        );

        final map = original.toMap();
        final restored = Package.fromMap('1', map);

        expect(restored.expirationDate, isNull);
      });
    });

    group('copyWith', () {
      test('cria cópia com valores alterados', () {
        final original = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 10,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        final updated = original.copyWith(
          remainingSessions: 9,
          status: 'active',
        );

        expect(updated.remainingSessions, 9);
        expect(updated.totalSessions, 10); // Manteve valor original
        expect(updated.id, '1'); // Manteve valor original
      });

      test('mantém valores originais quando não especificados', () {
        final original = Package(
          id: '1',
          clientId: 'client1',
          totalSessions: 10,
          remainingSessions: 10,
          price: 1000.0,
          createdAt: DateTime.now(),
          status: 'active',
        );

        final copy = original.copyWith();

        expect(copy.id, original.id);
        expect(copy.clientId, original.clientId);
        expect(copy.totalSessions, original.totalSessions);
        expect(copy.remainingSessions, original.remainingSessions);
        expect(copy.price, original.price);
        expect(copy.status, original.status);
      });
    });
  });
}
