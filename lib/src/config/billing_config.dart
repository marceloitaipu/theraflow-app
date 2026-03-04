/// Configuração do modo de billing.
///
/// Em desenvolvimento, usa mock.
/// Em produção, usa RevenueCat.
enum BillingMode {
  mock,
  revenuecat,
}

class BillingConfig {
  BillingConfig._();

  /// Altere para BillingMode.revenuecat em produção
  static BillingMode mode = BillingMode.mock;

  /// RevenueCat API Key (iOS)
  static const String revenueCatApiKeyIos = 'YOUR_IOS_API_KEY';

  /// RevenueCat API Key (Android)
  static const String revenueCatApiKeyAndroid = 'YOUR_ANDROID_API_KEY';

  /// Entitlements IDs no RevenueCat
  static const String entitlementStarter = 'plan_starter';
  static const String entitlementPro = 'plan_pro';
  static const String entitlementClinic = 'plan_clinic';
  static const String entitlementTherapy = 'module_therapy';
  static const String entitlementAesthetics = 'module_aesthetics';
  static const String entitlementPodiatry = 'module_podiatry';
  static const String entitlementMassage = 'module_massage';
}
