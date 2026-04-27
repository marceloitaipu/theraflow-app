import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/user.dart';

void main() {
  group('User Model extended', () {
    User makeUser({String plan = 'free', bool onboardingCompleted = false}) {
      return User(
        id: 'u1',
        name: 'Test User',
        email: 'test@test.com',
        plan: plan,
        createdAt: DateTime(2026, 1, 1),
        onboardingCompleted: onboardingCompleted,
      );
    }

    group('planDisplayName', () {
      test('free → Gratuito', () {
        expect(makeUser(plan: 'free').planDisplayName, 'Gratuito');
      });

      test('professional → Profissional', () {
        expect(makeUser(plan: 'professional').planDisplayName, 'Profissional');
      });

      test('premium → Premium', () {
        expect(makeUser(plan: 'premium').planDisplayName, 'Premium');
      });

      test('desconhecido → Gratuito', () {
        expect(makeUser(plan: 'xyz').planDisplayName, 'Gratuito');
      });
    });

    group('isFree / isPro / isPremium', () {
      test('isFree true apenas para free', () {
        expect(makeUser(plan: 'free').isFree, true);
        expect(makeUser(plan: 'professional').isFree, false);
        expect(makeUser(plan: 'premium').isFree, false);
      });

      test('isPro true para professional e premium', () {
        expect(makeUser(plan: 'professional').isPro, true);
        expect(makeUser(plan: 'premium').isPro, true);
        expect(makeUser(plan: 'free').isPro, false);
      });

      test('isPremium true apenas para premium', () {
        expect(makeUser(plan: 'premium').isPremium, true);
        expect(makeUser(plan: 'professional').isPremium, false);
        expect(makeUser(plan: 'free').isPremium, false);
      });
    });

    group('clientLimit por plano', () {
      test('free: 5', () => expect(makeUser(plan: 'free').clientLimit, 5));
      test('professional: 50',
          () => expect(makeUser(plan: 'professional').clientLimit, 50));
      test('premium: 999999',
          () => expect(makeUser(plan: 'premium').clientLimit, 999999));
      test('desconhecido: 5 (padrão free)',
          () => expect(makeUser(plan: 'unknown').clientLimit, 5));
    });

    group('canCreateClient', () {
      test('true quando abaixo do limite', () {
        expect(makeUser(plan: 'free').canCreateClient(4), true);
      });

      test('false quando no limite', () {
        expect(makeUser(plan: 'free').canCreateClient(5), false);
      });

      test('false quando acima do limite', () {
        expect(makeUser(plan: 'free').canCreateClient(10), false);
      });

      test('professional pode ter até 50', () {
        expect(makeUser(plan: 'professional').canCreateClient(49), true);
        expect(makeUser(plan: 'professional').canCreateClient(50), false);
      });
    });

    group('canUsePackages / canExportReports / canUseSmartAlerts', () {
      test('free não pode usar pacotes', () {
        expect(makeUser(plan: 'free').canUsePackages(), false);
      });

      test('professional pode usar pacotes', () {
        expect(makeUser(plan: 'professional').canUsePackages(), true);
      });

      test('premium pode usar pacotes', () {
        expect(makeUser(plan: 'premium').canUsePackages(), true);
      });

      test('free não pode exportar', () {
        expect(makeUser(plan: 'free').canExportReports(), false);
      });

      test('professional pode exportar', () {
        expect(makeUser(plan: 'professional').canExportReports(), true);
      });

      test('premium pode exportar', () {
        expect(makeUser(plan: 'premium').canExportReports(), true);
      });

      test('free não pode usar alertas inteligentes', () {
        expect(makeUser(plan: 'free').canUseSmartAlerts(), false);
      });

      test('professional pode usar alertas inteligentes', () {
        expect(makeUser(plan: 'professional').canUseSmartAlerts(), true);
      });

      test('premium pode usar alertas inteligentes', () {
        expect(makeUser(plan: 'premium').canUseSmartAlerts(), true);
      });
    });

    group('toMap / fromMap', () {
      test('toMap serializa campos obrigatórios', () {
        final user = makeUser(plan: 'professional', onboardingCompleted: true);
        final map = user.toMap();

        expect(map['name'], 'Test User');
        expect(map['email'], 'test@test.com');
        expect(map['plan'], 'professional');
        expect(map['onboardingCompleted'], true);
      });

      test('toMap inclui campos opcionais quando preenchidos', () {
        final user = User(
          id: 'u1',
          name: 'Test',
          email: 'test@test.com',
          plan: 'free',
          createdAt: DateTime(2026),
          module: 'therapy',
          businessName: 'Clínica X',
          phone: '11999990000',
          city: 'São Paulo',
          defaultDurationMinutes: 60,
          defaultPrice: 150.0,
        );

        final map = user.toMap();
        expect(map['module'], 'therapy');
        expect(map['businessName'], 'Clínica X');
        expect(map['phone'], '11999990000');
        expect(map['city'], 'São Paulo');
        expect(map['defaultDurationMinutes'], 60);
        expect(map['defaultPrice'], 150.0);
      });

      test('fromMap reconstrói user corretamente', () {
        final map = {
          'name': 'João',
          'email': 'joao@test.com',
          'plan': 'premium',
          'createdAt': DateTime(2026, 1, 1).toIso8601String(),
          'onboardingCompleted': true,
        };

        final user = User.fromMap('uid123', map);

        expect(user.id, 'uid123');
        expect(user.name, 'João');
        expect(user.plan, 'premium');
        expect(user.onboardingCompleted, true);
      });

      test('fromMap usa defaults quando campos ausentes', () {
        final map = {
          'createdAt': DateTime(2026).toIso8601String(),
        };

        final user = User.fromMap('uid', map);

        expect(user.name, '');
        expect(user.email, '');
        expect(user.plan, 'free');
        expect(user.onboardingCompleted, false);
        expect(user.module, isNull);
        expect(user.defaultPrice, isNull);
      });

      test('fromMap parseia defaultPrice como int corretamente', () {
        final map = {
          'createdAt': DateTime(2026).toIso8601String(),
          'defaultPrice': 200,
        };

        final user = User.fromMap('uid', map);
        expect(user.defaultPrice, 200.0);
        expect(user.defaultPrice, isA<double>());
      });
    });

    group('copyWith', () {
      test('atualiza plan e onboardingCompleted', () {
        final original = makeUser(plan: 'free', onboardingCompleted: false);
        final updated = original.copyWith(
          plan: 'professional',
          onboardingCompleted: true,
        );

        expect(updated.plan, 'professional');
        expect(updated.onboardingCompleted, true);
        expect(updated.id, original.id);
        expect(updated.email, original.email);
      });

      test('preserva campos não fornecidos', () {
        final original = User(
          id: 'u1',
          name: 'Test',
          email: 'test@test.com',
          plan: 'professional',
          createdAt: DateTime(2026),
          module: 'therapy',
          businessName: 'Minha Clínica',
          city: 'SP',
          defaultPrice: 200.0,
        );

        final copy = original.copyWith(name: 'Test Atualizado');

        expect(copy.module, 'therapy');
        expect(copy.businessName, 'Minha Clínica');
        expect(copy.city, 'SP');
        expect(copy.defaultPrice, 200.0);
      });
    });
  });
}
