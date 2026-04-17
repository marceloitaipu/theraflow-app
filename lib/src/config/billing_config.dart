/// Configuração do modo de billing.
///
/// - [disabled]: billing desativado. `showPaywall()` retorna false e não simula
///   compras. Todos os usuários ficam no plano starter. **Use em produção até
///   que a integração real com Google Play / App Store / RevenueCat esteja
///   validada ponta-a-ponta.**
/// - [mock]: apenas para desenvolvimento local. Simula upgrade automático.
///   NUNCA usar em builds de produção.
/// - [revenuecat]: implementação real via SDK `purchases_flutter`.
enum BillingMode {
  disabled,
  mock,
  revenuecat,
}

class BillingConfig {
  BillingConfig._();

  /// Modo padrão de produção: [BillingMode.disabled].
  /// Ative `mock` apenas em desenvolvimento local.
  static BillingMode mode = BillingMode.disabled;

  /// RevenueCat API Key (iOS) — configure via variável de ambiente no build.
  static const String revenueCatApiKeyIos = 'YOUR_IOS_API_KEY';

  /// RevenueCat API Key (Android) — configure via variável de ambiente no build.
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
