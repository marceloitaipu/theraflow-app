import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/services/business_service.dart';
import 'package:theraflow/src/models/app_module.dart';

void main() {
  group('BusinessService', () {
    late BusinessService service;

    setUp(() {
      service = BusinessService.instance;
      service.clear();
    });

    test('começa sem business', () {
      expect(service.currentBusiness, isNull);
      expect(service.currentBusinessId, isNull);
    });

    test('createBusiness cria um business', () async {
      await service.createBusiness(
        ownerUid: 'uid1',
        name: 'Clínica Teste',
        plan: 'starter',
        enabledModules: [AppModule.therapy],
      );

      expect(service.currentBusiness, isNotNull);
      expect(service.currentBusiness!.name, 'Clínica Teste');
      expect(service.currentBusiness!.ownerUid, 'uid1');
      expect(service.currentBusiness!.plan, 'starter');
      expect(service.currentBusiness!.enabledModules, contains(AppModule.therapy));
    });

    test('resolveBusinessForUser resolve business existente', () async {
      await service.createBusiness(
        ownerUid: 'uid1',
        name: 'Clínica Teste',
        plan: 'pro',
        enabledModules: [AppModule.therapy, AppModule.massage],
      );

      service.clear();
      expect(service.currentBusiness, isNull);

      await service.resolveBusinessForUser('uid1');
      expect(service.currentBusiness, isNotNull);
      expect(service.currentBusiness!.ownerUid, 'uid1');
    });

    test('isModuleEnabled verifica módulo corretamente', () async {
      await service.createBusiness(
        ownerUid: 'uid1',
        name: 'Clínica Teste',
        plan: 'starter',
        enabledModules: [AppModule.therapy],
      );

      expect(service.isModuleEnabled(AppModule.therapy), true);
      expect(service.isModuleEnabled(AppModule.aesthetics), false);
    });

    test('updatePlanAndModules atualiza plano e módulos', () async {
      await service.createBusiness(
        ownerUid: 'uid1',
        name: 'Clínica Teste',
        plan: 'starter',
        enabledModules: [AppModule.therapy],
      );

      await service.updatePlanAndModules(
        plan: 'pro',
        enabledModules: [AppModule.therapy, AppModule.aesthetics],
        subscriptionStatus: 'active',
      );

      expect(service.currentBusiness!.plan, 'pro');
      expect(service.currentBusiness!.enabledModules.length, 2);
      expect(service.currentBusiness!.enabledModules, contains(AppModule.aesthetics));
    });

    test('clear limpa o estado', () async {
      await service.createBusiness(
        ownerUid: 'uid1',
        name: 'Clínica Teste',
        plan: 'starter',
        enabledModules: [AppModule.therapy],
      );

      expect(service.currentBusiness, isNotNull);

      service.clear();
      expect(service.currentBusiness, isNull);
      expect(service.currentBusinessId, isNull);
    });
  });
}
