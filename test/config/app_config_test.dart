import 'package:flutter_test/flutter_test.dart';
import 'package:theraflow/src/config/app_config.dart';
import 'package:theraflow/src/config/billing_config.dart';

void main() {
  group('AppConfig', () {
    test('useMockServices é false em produção', () {
      expect(AppConfig.useMockServices, false);
    });

    test('appName está definido', () {
      expect(AppConfig.appName, isNotEmpty);
      expect(AppConfig.appName, 'TheraFlow');
    });

    test('planLimits contém todos os planos', () {
      expect(AppConfig.planLimits.containsKey('free'), true);
      expect(AppConfig.planLimits.containsKey('professional'), true);
      expect(AppConfig.planLimits.containsKey('premium'), true);
    });

    test('planLimits.free == 5', () {
      expect(AppConfig.planLimits['free'], 5);
    });

    test('planLimits.professional == 50', () {
      expect(AppConfig.planLimits['professional'], 50);
    });

    test('planLimits.premium == 999999', () {
      expect(AppConfig.planLimits['premium'], 999999);
    });

    test('defaultSessionDuration == 60', () {
      expect(AppConfig.defaultSessionDuration, 60);
    });

    test('defaultSessionPrice > 0', () {
      expect(AppConfig.defaultSessionPrice, greaterThan(0));
    });

    test('landingPageUrl é URL válida', () {
      expect(AppConfig.landingPageUrl, startsWith('https://'));
    });

    test('supportEmail contém @', () {
      expect(AppConfig.supportEmail, contains('@'));
    });
  });

  group('BillingConfig', () {
    test('modo padrão é disabled', () {
      expect(BillingConfig.mode, BillingMode.disabled);
    });

    test('BillingMode contém todos os valores esperados', () {
      expect(BillingMode.values, containsAll([
        BillingMode.disabled,
        BillingMode.mock,
        BillingMode.revenuecat,
        BillingMode.inAppPurchase,
      ]));
    });

    test('entitlements estão definidos', () {
      expect(BillingConfig.entitlementStarter, isNotEmpty);
      expect(BillingConfig.entitlementPro, isNotEmpty);
      expect(BillingConfig.entitlementClinic, isNotEmpty);
      expect(BillingConfig.entitlementTherapy, isNotEmpty);
      expect(BillingConfig.entitlementAesthetics, isNotEmpty);
      expect(BillingConfig.entitlementPodiatry, isNotEmpty);
      expect(BillingConfig.entitlementMassage, isNotEmpty);
    });
  });
}
