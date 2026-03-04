import '../models/app_module.dart';
import '../config/billing_config.dart';
import 'business_service.dart';

/// Informações do cliente de billing (resultado do fetch)
class BillingCustomerInfo {
  final String plan; // starter, pro, clinic
  final List<AppModule> enabledModules;
  final String subscriptionStatus; // active, expired, cancelled

  BillingCustomerInfo({
    required this.plan,
    required this.enabledModules,
    required this.subscriptionStatus,
  });
}

/// Interface abstrata do serviço de billing.
abstract class BillingService {
  /// Inicializa o SDK de billing
  Future<void> initialize();

  /// Faz login no provider de billing
  Future<void> logIn(String userId);

  /// Busca as informações de assinatura do usuário
  Future<BillingCustomerInfo> fetchCustomerInfo();

  /// Exibe a paywall nativa (ou custom)
  Future<bool> showPaywall();

  /// Restaura compras
  Future<BillingCustomerInfo> restorePurchases();

  /// Faz logout do provider
  Future<void> logOut();

  /// Sincroniza plano + módulos no Firestore e BusinessService
  Future<void> syncWithBusiness(BillingCustomerInfo info) async {
    await BusinessService.instance.updatePlanAndModules(
      plan: info.plan,
      enabledModules: info.enabledModules,
      subscriptionStatus: info.subscriptionStatus,
    );
  }

  /// Factory que retorna a implementação correta baseado no billing mode
  static BillingService create() {
    switch (BillingConfig.mode) {
      case BillingMode.mock:
        return MockBillingService();
      case BillingMode.revenuecat:
        return RevenueCatBillingService();
    }
  }
}

// ========== MOCK IMPLEMENTATION ==========

/// Mock para desenvolvimento sem RevenueCat.
/// Simula plano starter com therapy e massage habilitados.
class MockBillingService extends BillingService {
  String _plan = 'starter';
  List<AppModule> _modules = [AppModule.therapy, AppModule.massage];
  String _status = 'active';

  @override
  Future<void> initialize() async {
    // Noop
  }

  @override
  Future<void> logIn(String userId) async {
    // Noop — mock não precisa login
  }

  @override
  Future<BillingCustomerInfo> fetchCustomerInfo() async {
    await Future.delayed(const Duration(milliseconds: 300));
    return BillingCustomerInfo(
      plan: _plan,
      enabledModules: _modules,
      subscriptionStatus: _status,
    );
  }

  @override
  Future<bool> showPaywall() async {
    // Simula upgrade para pro
    _plan = 'pro';
    _modules = [
      AppModule.therapy,
      AppModule.aesthetics,
      AppModule.podiatry,
      AppModule.massage,
    ];
    _status = 'active';

    final info = await fetchCustomerInfo();
    await syncWithBusiness(info);
    return true; // compra bem sucedida
  }

  @override
  Future<BillingCustomerInfo> restorePurchases() async {
    return fetchCustomerInfo();
  }

  @override
  Future<void> logOut() async {
    _plan = 'starter';
    _modules = [AppModule.therapy, AppModule.massage];
    _status = 'active';
  }

  /// Para testes: permite mudar o plano manualmente
  void setMockPlan(String plan, List<AppModule> modules) {
    _plan = plan;
    _modules = modules;
  }
}

// ========== REVENUECAT IMPLEMENTATION (STUB) ==========

/// Implementação com RevenueCat (a ser integrada com SDK real).
///
/// Requer adicionar `purchases_flutter` ao pubspec.yaml:
/// ```yaml
/// dependencies:
///   purchases_flutter: ^6.0.0
/// ```
class RevenueCatBillingService extends BillingService {
  @override
  Future<void> initialize() async {
    // TODO: Descomentar quando purchases_flutter estiver no pubspec
    //
    // final config = PurchasesConfiguration(
    //   Platform.isIOS
    //       ? BillingConfig.revenueCatApiKeyIos
    //       : BillingConfig.revenueCatApiKeyAndroid,
    // );
    // await Purchases.configure(config);
  }

  @override
  Future<void> logIn(String userId) async {
    // TODO: Implementar
    // final result = await Purchases.logIn(userId);
  }

  @override
  Future<BillingCustomerInfo> fetchCustomerInfo() async {
    // TODO: Implementar
    // final info = await Purchases.getCustomerInfo();
    // return _mapCustomerInfo(info);

    // Fallback
    return BillingCustomerInfo(
      plan: 'starter',
      enabledModules: [AppModule.therapy],
      subscriptionStatus: 'active',
    );
  }

  @override
  Future<bool> showPaywall() async {
    // TODO: Implementar paywall nativa do RevenueCat
    // ou usar PaywallScreen customizada
    return false;
  }

  @override
  Future<BillingCustomerInfo> restorePurchases() async {
    // TODO: Implementar
    // final info = await Purchases.restorePurchases();
    // return _mapCustomerInfo(info);
    return fetchCustomerInfo();
  }

  @override
  Future<void> logOut() async {
    // TODO: Implementar
    // await Purchases.logOut();
  }

  // Helper para mapear entitlements do RC para nosso modelo
  // BillingCustomerInfo _mapCustomerInfo(CustomerInfo info) {
  //   String plan = 'starter';
  //   final modules = <AppModule>[];
  //
  //   if (info.entitlements.active.containsKey(BillingConfig.entitlementClinic)) {
  //     plan = 'clinic';
  //   } else if (info.entitlements.active.containsKey(BillingConfig.entitlementPro)) {
  //     plan = 'pro';
  //   }
  //
  //   if (info.entitlements.active.containsKey(BillingConfig.entitlementTherapy)) {
  //     modules.add(AppModule.therapy);
  //   }
  //   // ... etc
  //
  //   return BillingCustomerInfo(
  //     plan: plan,
  //     enabledModules: modules,
  //     subscriptionStatus: 'active',
  //   );
  // }
}
