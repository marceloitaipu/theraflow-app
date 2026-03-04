import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/models/business.dart';
import 'package:theraflow/src/models/app_module.dart';

void main() {
  group('Business Model', () {
    group('clientLimit', () {
      test('plano starter tem limite de 10 clientes', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'starter',
          enabledModules: [AppModule.therapy],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.clientLimit, 10);
      });

      test('plano pro tem limite de 100 clientes', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'pro',
          enabledModules: [AppModule.therapy, AppModule.massage],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.clientLimit, 100);
      });

      test('plano clinic tem limite ilimitado', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'clinic',
          enabledModules: AppModule.values,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.clientLimit, 999999);
      });

      test('plano desconhecido retorna limite starter', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'unknown',
          enabledModules: [],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.clientLimit, 10);
      });
    });

    group('isModuleEnabled', () {
      test('retorna true para módulo habilitado', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'starter',
          enabledModules: [AppModule.therapy],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.isModuleEnabled(AppModule.therapy), true);
      });

      test('retorna false para módulo desabilitado', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'starter',
          enabledModules: [AppModule.therapy],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.isModuleEnabled(AppModule.aesthetics), false);
      });
    });

    group('canUsePackages', () {
      test('retorna false para plano starter', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'starter',
          enabledModules: [AppModule.therapy],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.canUsePackages, false);
      });

      test('retorna true para plano pro', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'pro',
          enabledModules: [AppModule.therapy],
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.canUsePackages, true);
      });

      test('retorna true para plano clinic', () {
        final biz = Business(
          id: '1',
          name: 'Clínica Teste',
          ownerUid: 'uid1',
          plan: 'clinic',
          enabledModules: AppModule.values,
          createdAt: DateTime.now(),
          updatedAt: DateTime.now(),
        );
        expect(biz.canUsePackages, true);
      });
    });

    group('planDisplayName', () {
      test('retorna nome correto para cada plano', () {
        Business makeBiz(String plan) => Business(
              id: '1',
              name: 'Test',
              ownerUid: 'uid1',
              plan: plan,
              enabledModules: [],
              createdAt: DateTime.now(),
              updatedAt: DateTime.now(),
            );

        expect(makeBiz('starter').planDisplayName, 'Starter');
        expect(makeBiz('pro').planDisplayName, 'Pro');
        expect(makeBiz('clinic').planDisplayName, 'Clínica');
        expect(makeBiz('unknown').planDisplayName, 'Starter');
      });
    });

    group('toMap / fromMap', () {
      test('serializa e deserializa corretamente', () {
        final now = DateTime.now();
        final original = Business(
          id: 'biz1',
          name: 'Clínica Maria',
          ownerUid: 'uid123',
          plan: 'pro',
          enabledModules: [AppModule.therapy, AppModule.massage],
          subscriptionStatus: 'active',
          rcUserId: 'rc_123',
          createdAt: now,
          updatedAt: now,
        );

        final map = original.toMap();
        final restored = Business.fromMap('biz1', map);

        expect(restored.id, original.id);
        expect(restored.name, original.name);
        expect(restored.ownerUid, original.ownerUid);
        expect(restored.plan, original.plan);
        expect(restored.enabledModules.length, 2);
        expect(restored.enabledModules.contains(AppModule.therapy), true);
        expect(restored.enabledModules.contains(AppModule.massage), true);
        expect(restored.subscriptionStatus, 'active');
        expect(restored.rcUserId, 'rc_123');
      });

      test('usa valores padrão quando campos ausentes', () {
        final restored = Business.fromMap('1', {});

        expect(restored.name, '');
        expect(restored.ownerUid, '');
        expect(restored.plan, 'starter');
        expect(restored.enabledModules, isEmpty);
      });
    });
  });
}
