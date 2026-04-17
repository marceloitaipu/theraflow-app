import '../config/billing_config.dart';

/// Informações do cliente de billing (resultado do fetch)
class BillingCustomerInfo {
  final String plan; // free, professional, premium
  final String subscriptionStatus; // active, expired, cancelled

  BillingCustomerInfo({
    required this.plan,
    required this.subscriptionStatus,
  });
}

/// Interface abstrata do serviço de billing.
///
/// Mantida intencionalmente simples enquanto a integração real com
/// Google Play / App Store / RevenueCat não está validada ponta-a-ponta
/// (incluindo a Cloud Function `validateSubscription` do backend).
abstract class BillingService {
  Future<void> initialize();
  Future<void> logIn(String userId);
  Future<BillingCustomerInfo> fetchCustomerInfo();
  Future<bool> showPaywall();
  Future<BillingCustomerInfo> restorePurchases();
  Future<void> logOut();

  static BillingService create() {
    switch (BillingConfig.mode) {
      case BillingMode.disabled:
        return DisabledBillingService();
      case BillingMode.mock:
        return MockBillingService();
      case BillingMode.revenuecat:
        return RevenueCatBillingService();
    }
  }
}

/// Billing desativado: todos os usuários ficam no plano `free`.
/// Default de produção enquanto não há integração real.
class DisabledBillingService extends BillingService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> logIn(String userId) async {}

  @override
  Future<BillingCustomerInfo> fetchCustomerInfo() async {
    return BillingCustomerInfo(plan: 'free', subscriptionStatus: 'active');
  }

  @override
  Future<bool> showPaywall() async => false;

  @override
  Future<BillingCustomerInfo> restorePurchases() async => fetchCustomerInfo();

  @override
  Future<void> logOut() async {}
}

/// Mock para desenvolvimento. Simula upgrade em memória, sem persistência.
class MockBillingService extends BillingService {
  String _plan = 'free';
  String _status = 'active';

  @override
  Future<void> initialize() async {}

  @override
  Future<void> logIn(String userId) async {}

  @override
  Future<BillingCustomerInfo> fetchCustomerInfo() async {
    await Future.delayed(const Duration(milliseconds: 200));
    return BillingCustomerInfo(plan: _plan, subscriptionStatus: _status);
  }

  @override
  Future<bool> showPaywall() async {
    _plan = 'professional';
    _status = 'active';
    return true;
  }

  @override
  Future<BillingCustomerInfo> restorePurchases() async => fetchCustomerInfo();

  @override
  Future<void> logOut() async {
    _plan = 'free';
    _status = 'active';
  }
}

/// Stub para RevenueCat. Não integrado — ver pubspec e IN_APP_PURCHASE_SETUP.md.
class RevenueCatBillingService extends BillingService {
  @override
  Future<void> initialize() async {}

  @override
  Future<void> logIn(String userId) async {}

  @override
  Future<BillingCustomerInfo> fetchCustomerInfo() async {
    return BillingCustomerInfo(plan: 'free', subscriptionStatus: 'active');
  }

  @override
  Future<bool> showPaywall() async => false;

  @override
  Future<BillingCustomerInfo> restorePurchases() async => fetchCustomerInfo();

  @override
  Future<void> logOut() async {}
}
