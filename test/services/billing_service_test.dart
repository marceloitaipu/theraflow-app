import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/services/billing_service.dart';
import 'package:theraflow/src/config/billing_config.dart';
import 'package:theraflow/src/models/app_module.dart';

void main() {
  group('BillingService', () {
    group('MockBillingService', () {
      late MockBillingService service;

      setUp(() {
        service = MockBillingService();
      });

      test('initialize completa sem erro', () async {
        await expectLater(service.initialize(), completes);
      });

      test('fetchCustomerInfo retorna starter por padrão', () async {
        await service.initialize();
        final info = await service.fetchCustomerInfo();
        expect(info.plan, 'starter');
        expect(info.subscriptionStatus, 'active');
        expect(info.enabledModules, contains(AppModule.therapy));
      });

      test('showPaywall simula upgrade para pro', () async {
        await service.initialize();
        final result = await service.showPaywall();
        expect(result, true);

        final info = await service.fetchCustomerInfo();
        expect(info.plan, 'pro');
      });

      test('restorePurchases retorna info atual', () async {
        await service.initialize();
        final info = await service.restorePurchases();
        expect(info.plan, 'starter');
      });

      test('logOut reseta para starter', () async {
        await service.initialize();
        await service.showPaywall(); // upgrade
        await service.logOut(); // reset

        final info = await service.fetchCustomerInfo();
        expect(info.plan, 'starter');
      });

      test('setMockPlan permite mudar plano manualmente', () async {
        service.setMockPlan('clinic', AppModule.values);
        final info = await service.fetchCustomerInfo();
        expect(info.plan, 'clinic');
        expect(info.enabledModules.length, 4);
      });
    });

    group('BillingConfig', () {
      test('modo padrão é mock', () {
        expect(BillingConfig.mode, BillingMode.mock);
      });

      test('entitlements estão definidos', () {
        expect(BillingConfig.entitlementStarter, 'plan_starter');
        expect(BillingConfig.entitlementPro, 'plan_pro');
        expect(BillingConfig.entitlementClinic, 'plan_clinic');
      });

      test('module entitlements estão definidos', () {
        expect(BillingConfig.entitlementTherapy, 'module_therapy');
        expect(BillingConfig.entitlementAesthetics, 'module_aesthetics');
        expect(BillingConfig.entitlementPodiatry, 'module_podiatry');
        expect(BillingConfig.entitlementMassage, 'module_massage');
      });
    });

    group('BillingService.create factory', () {
      test('cria MockBillingService quando modo é mock', () {
        final service = BillingService.create();
        expect(service, isA<MockBillingService>());
      });
    });
  });
}
