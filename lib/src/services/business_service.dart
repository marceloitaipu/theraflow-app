import '../models/business.dart';
import '../models/app_module.dart';
import 'mock_data_service.dart';

/// Serviço para gerenciar a entidade Business (consultório/clínica).
///
/// Resolve o businessId no login e mantém referência global.
class BusinessService {
  BusinessService._();
  static final instance = BusinessService._();

  final MockDataService _mock = MockDataService.instance;

  Business? _currentBusiness;
  Business? get currentBusiness => _currentBusiness;

  /// ID do business atual (atalho)
  String? get currentBusinessId => _currentBusiness?.id;

  /// Cria um novo business ao completar onboarding
  Future<Business> createBusiness({
    required String name,
    required String ownerUid,
    required List<AppModule> enabledModules,
    String plan = 'starter',
  }) async {
    final now = DateTime.now();
    final id = 'biz_${now.millisecondsSinceEpoch}';

    final business = Business(
      id: id,
      name: name,
      ownerUid: ownerUid,
      plan: plan,
      enabledModules: enabledModules,
      subscriptionStatus: 'trial',
      createdAt: now,
      updatedAt: now,
    );

    _mock.saveBusiness(business.toMap()..['id'] = id);
    _currentBusiness = business;
    return business;
  }

  /// Resolve o business do usuário logado
  Future<Business?> resolveBusinessForUser(String uid) async {
    final data = _mock.getBusinessByOwner(uid);
    if (data == null) return null;

    _currentBusiness = Business.fromMap(data['id'] as String, data);
    return _currentBusiness;
  }

  /// Atualiza o plano e módulos (após billing sync)
  Future<void> updatePlanAndModules({
    required String plan,
    required List<AppModule> enabledModules,
    required String subscriptionStatus,
    String? rcUserId,
  }) async {
    if (_currentBusiness == null) return;

    _currentBusiness = _currentBusiness!.copyWith(
      plan: plan,
      enabledModules: enabledModules,
      subscriptionStatus: subscriptionStatus,
      rcUserId: rcUserId,
    );

    _mock.saveBusiness(_currentBusiness!.toMap()..['id'] = _currentBusiness!.id);
  }

  /// Atualiza dados básicos do business
  Future<void> updateBusiness({
    String? name,
    List<AppModule>? enabledModules,
  }) async {
    if (_currentBusiness == null) return;

    _currentBusiness = _currentBusiness!.copyWith(
      name: name,
      enabledModules: enabledModules,
    );

    _mock.saveBusiness(_currentBusiness!.toMap()..['id'] = _currentBusiness!.id);
  }

  /// Verifica se módulo está habilitado
  bool isModuleEnabled(AppModule module) {
    return _currentBusiness?.isModuleEnabled(module) ?? false;
  }

  /// Limpa referência ao fazer logout
  void clear() {
    _currentBusiness = null;
  }
}
