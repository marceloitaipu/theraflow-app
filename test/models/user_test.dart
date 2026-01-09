import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/user.dart';

void main() {
  group('User Model', () {
    group('clientLimit', () {
      test('plano free tem limite de 5 clientes', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        expect(user.clientLimit, 5);
      });

      test('plano professional tem limite de 50 clientes', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime.now(),
        );

        expect(user.clientLimit, 50);
      });

      test('plano premium tem limite ilimitado', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'premium',
          createdAt: DateTime.now(),
        );

        expect(user.clientLimit, 999999);
      });

      test('plano desconhecido retorna limite free', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'unknown',
          createdAt: DateTime.now(),
        );

        expect(user.clientLimit, 5);
      });
    });

    group('canCreateClient', () {
      test('retorna true quando está abaixo do limite', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        expect(user.canCreateClient(3), true);
      });

      test('retorna false quando atingiu o limite', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        expect(user.canCreateClient(5), false);
      });

      test('retorna false quando está acima do limite', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        expect(user.canCreateClient(10), false);
      });
    });

    group('canUsePackages', () {
      test('retorna false para plano free', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        expect(user.canUsePackages(), false);
      });

      test('retorna true para plano professional', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime.now(),
        );

        expect(user.canUsePackages(), true);
      });

      test('retorna true para plano premium', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'premium',
          createdAt: DateTime.now(),
        );

        expect(user.canUsePackages(), true);
      });
    });

    group('canExportReports', () {
      test('retorna false para plano free', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        expect(user.canExportReports(), false);
      });

      test('retorna true para plano professional', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime.now(),
        );

        expect(user.canExportReports(), true);
      });

      test('retorna true para plano premium', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'premium',
          createdAt: DateTime.now(),
        );

        expect(user.canExportReports(), true);
      });
    });

    group('canUseSmartAlerts', () {
      test('retorna false para plano free', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        expect(user.canUseSmartAlerts(), false);
      });

      test('retorna true para plano professional', () {
        final user = User(
          id: '1',
          name: 'Test User',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime.now(),
        );

        expect(user.canUseSmartAlerts(), true);
      });
    });

    group('isFree / isPro / isPremium', () {
      test('isFree retorna true apenas para plano free', () {
        final freeUser = User(
          id: '1',
          name: 'Test',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        final proUser = User(
          id: '2',
          name: 'Test',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime.now(),
        );

        expect(freeUser.isFree, true);
        expect(proUser.isFree, false);
      });

      test('isPro retorna true para professional e premium', () {
        final freeUser = User(
          id: '1',
          name: 'Test',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        final proUser = User(
          id: '2',
          name: 'Test',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime.now(),
        );

        final premiumUser = User(
          id: '3',
          name: 'Test',
          email: 'test@test.com',
          plan: 'premium',
          createdAt: DateTime.now(),
        );

        expect(freeUser.isPro, false);
        expect(proUser.isPro, true);
        expect(premiumUser.isPro, true);
      });

      test('isPremium retorna true apenas para premium', () {
        final proUser = User(
          id: '2',
          name: 'Test',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime.now(),
        );

        final premiumUser = User(
          id: '3',
          name: 'Test',
          email: 'test@test.com',
          plan: 'premium',
          createdAt: DateTime.now(),
        );

        expect(proUser.isPremium, false);
        expect(premiumUser.isPremium, true);
      });
    });

    group('planDisplayName', () {
      test('retorna nome correto para cada plano', () {
        final freeUser = User(
          id: '1',
          name: 'Test',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime.now(),
        );

        final proUser = User(
          id: '2',
          name: 'Test',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime.now(),
        );

        final premiumUser = User(
          id: '3',
          name: 'Test',
          email: 'test@test.com',
          plan: 'premium',
          createdAt: DateTime.now(),
        );

        expect(freeUser.planDisplayName, 'Gratuito');
        expect(proUser.planDisplayName, 'Profissional');
        expect(premiumUser.planDisplayName, 'Premium');
      });

      test('retorna Gratuito para plano desconhecido', () {
        final user = User(
          id: '1',
          name: 'Test',
          email: 'test@test.com',
          plan: 'unknown',
          createdAt: DateTime.now(),
        );

        expect(user.planDisplayName, 'Gratuito');
      });
    });

    group('toMap / fromMap', () {
      test('serializa e deserializa corretamente', () {
        final now = DateTime.now();
        
        final original = User(
          id: '1',
          name: 'Maria Silva',
          email: 'maria@email.com',
          plan: 'professional',
          createdAt: now,
          onboardingCompleted: true,
        );

        final map = original.toMap();
        final restored = User.fromMap('1', map);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.email, original.email);
        expect(restored.plan, original.plan);
        expect(restored.onboardingCompleted, original.onboardingCompleted);
      });

      test('usa valores padrão quando campos estão ausentes', () {
        final restored = User.fromMap('1', {});

        expect(restored.name, '');
        expect(restored.email, '');
        expect(restored.plan, 'free');
        expect(restored.onboardingCompleted, false);
      });
    });
  });
}
