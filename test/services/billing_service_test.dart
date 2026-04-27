import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/services/billing_service.dart';

void main() {
  group('BillingService', () {
    group('DisabledBillingService', () {
      late DisabledBillingService service;

      setUp(() {
        service = DisabledBillingService();
      });

      test('initialize não lança exceção', () async {
        await expectLater(service.initialize(), completes);
      });

      test('logIn não lança exceção', () async {
        await expectLater(service.logIn('user123'), completes);
      });

      test('fetchCustomerInfo retorna plano free', () async {
        final info = await service.fetchCustomerInfo();
        expect(info.plan, 'free');
        expect(info.subscriptionStatus, 'active');
      });

      test('showPaywall retorna false', () async {
        final result = await service.showPaywall();
        expect(result, false);
      });

      test('restorePurchases retorna plano free', () async {
        final info = await service.restorePurchases();
        expect(info.plan, 'free');
      });

      test('logOut não lança exceção', () async {
        await expectLater(service.logOut(), completes);
      });
    });

    group('MockBillingService', () {
      late MockBillingService service;

      setUp(() {
        service = MockBillingService();
      });

      test('fetchCustomerInfo inicial retorna free', () async {
        final info = await service.fetchCustomerInfo();
        expect(info.plan, 'free');
        expect(info.subscriptionStatus, 'active');
      });

      test('showPaywall simula upgrade para professional', () async {
        final result = await service.showPaywall();
        expect(result, true);

        final info = await service.fetchCustomerInfo();
        expect(info.plan, 'professional');
      });

      test('logOut reverte para free', () async {
        await service.showPaywall(); // faz upgrade
        await service.logOut();

        final info = await service.fetchCustomerInfo();
        expect(info.plan, 'free');
      });

      test('restorePurchases retorna info atual', () async {
        await service.showPaywall(); // professional
        final info = await service.restorePurchases();
        expect(info.plan, 'professional');
      });
    });

    group('BillingCustomerInfo', () {
      test('cria com plan e subscriptionStatus', () {
        final info = BillingCustomerInfo(
          plan: 'premium',
          subscriptionStatus: 'active',
        );
        expect(info.plan, 'premium');
        expect(info.subscriptionStatus, 'active');
      });
    });

    group('BillingService.create()', () {
      test('retorna DisabledBillingService por padrão', () {
        final service = BillingService.create();
        expect(service, isA<DisabledBillingService>());
      });
    });
  });
}
