import 'package:cloud_functions/cloud_functions.dart';
import 'auth_service.dart';
import 'incremental_sync_service.dart';

/// Status da assinatura do usuário
enum SubscriptionStatus {
  free,
  active,
  expired,
  cancelled,
  unknown
}

/// Serviço de gerenciamento de assinaturas
/// 
/// Integra com:
/// - Cloud Functions para validação server-side
/// - In-App Purchase (Google Play / App Store)
/// - Firestore para verificação de status
class SubscriptionService {
  SubscriptionService._();
  static final instance = SubscriptionService._();

  final FirebaseFunctions _functions = FirebaseFunctions.instance;
  final AuthService _auth = AuthService.instance;

  SubscriptionStatus _currentStatus = SubscriptionStatus.unknown;
  String _currentPlan = 'free';
  DateTime? _expiryDate;

  SubscriptionStatus get currentStatus => _currentStatus;
  String get currentPlan => _currentPlan;
  DateTime? get expiryDate => _expiryDate;

  /// Verifica se o usuário tem assinatura ativa
  bool get hasActiveSubscription => _currentStatus == SubscriptionStatus.active;

  /// Verifica se o plano atual é gratuito
  bool get isFreePlan => _currentPlan == 'free';

  /// Verifica se o plano atual é Professional
  bool get isProfessionalPlan => _currentPlan == 'professional';

  /// Verifica se o plano atual é Premium
  bool get isPremiumPlan => _currentPlan == 'premium';

  /// Inicializa o serviço e carrega status da assinatura
  Future<void> initialize() async {
    AppLogger.info('Inicializando serviço de assinatura', 'SubscriptionService');
    await loadSubscriptionStatus();
  }

  /// Carrega o status da assinatura do Firestore
  Future<void> loadSubscriptionStatus() async {
    try {
      final userId = _auth.currentUser?.uid;
      if (userId == null) {
        AppLogger.warning('Usuário não autenticado - status free', 'SubscriptionService');
        _currentStatus = SubscriptionStatus.free;
        _currentPlan = 'free';
        return;
      }

      // Buscar dados do usuário no Firestore
      final userDoc = await _auth.firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        AppLogger.warning('Documento do usuário não existe - status free', 'SubscriptionService');
        _currentStatus = SubscriptionStatus.free;
        _currentPlan = 'free';
        return;
      }

      final data = userDoc.data()!;
      final statusStr = data['subscriptionStatus'] as String?;
      _currentPlan = data['planId'] as String? ?? 'free';
      
      final periodEndTimestamp = data['currentPeriodEnd'];
      if (periodEndTimestamp != null) {
        _expiryDate = (periodEndTimestamp as dynamic).toDate();
      }

      // Mapear string para enum
      switch (statusStr) {
        case 'active':
          _currentStatus = SubscriptionStatus.active;
          break;
        case 'expired':
          _currentStatus = SubscriptionStatus.expired;
          break;
        case 'cancelled':
          _currentStatus = SubscriptionStatus.cancelled;
          break;
        default:
          _currentStatus = SubscriptionStatus.free;
      }

      AppLogger.info(
        'Status carregado: status=$_currentStatus, plan=$_currentPlan, expiry=$_expiryDate',
        'SubscriptionService'
      );

    } catch (e, stack) {
      AppLogger.error('Erro ao carregar status da assinatura', e, stack, 'SubscriptionService');
      _currentStatus = SubscriptionStatus.unknown;
    }
  }

  /// Valida uma compra com o servidor
  /// 
  /// Parâmetros:
  /// - platform: 'android' ou 'ios'
  /// - purchaseToken: Token de compra (Android) ou receipt (iOS)
  /// - productId: ID do produto/SKU
  Future<bool> validatePurchase({
    required String platform,
    required String purchaseToken,
    required String productId,
  }) async {
    try {
      AppLogger.info(
        'Validando compra: platform=$platform, productId=$productId',
        'SubscriptionService'
      );

      final callable = _functions.httpsCallable('validateSubscription');
      final result = await callable.call({
        'platform': platform,
        'purchaseToken': purchaseToken,
        'productId': productId,
      });

      final data = result.data as Map<String, dynamic>;
      final success = data['success'] as bool? ?? false;

      if (success) {
        _currentPlan = data['planId'] as String? ?? 'free';
        _currentStatus = SubscriptionStatus.active;
        
        final expiryTimestamp = data['expiryDate'] as int?;
        if (expiryTimestamp != null) {
          _expiryDate = DateTime.fromMillisecondsSinceEpoch(expiryTimestamp);
        }

        AppLogger.info('Compra validada com sucesso: plan=$_currentPlan', 'SubscriptionService');
        return true;
      } else {
        AppLogger.warning('Validação de compra falhou', 'SubscriptionService');
        return false;
      }

    } catch (e, stack) {
      AppLogger.error('Erro ao validar compra', e, stack, 'SubscriptionService');
      return false;
    }
  }

  /// Verifica se o usuário pode criar mais clientes
  Future<bool> canCreateClient() async {
    try {
      // Recarregar status para garantir dados atualizados
      await loadSubscriptionStatus();

      // Premium: sem limites
      if (isPremiumPlan && hasActiveSubscription) {
        return true;
      }

      // Buscar contagem de clientes do banco local
      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // TODO: Implementar contagem de clientes no DatabaseHelper
      // Por enquanto, permitir se não for free ou se tiver assinatura ativa
      
      if (isFreePlan && !hasActiveSubscription) {
        // Free plan: verificar limite (será validado no servidor)
        AppLogger.warning('Plano free - limite será validado no servidor', 'SubscriptionService');
        return true; // Deixar servidor validar
      }

      return true;

    } catch (e, stack) {
      AppLogger.error('Erro ao verificar permissão para criar cliente', e, stack, 'SubscriptionService');
      return false;
    }
  }

  /// Verifica se funcionalidades premium estão disponíveis
  bool canAccessPremiumFeatures() {
    return hasActiveSubscription && (isProfessionalPlan || isPremiumPlan);
  }

  /// Verifica se relatórios avançados estão disponíveis
  bool canAccessAdvancedReports() {
    return hasActiveSubscription && isPremiumPlan;
  }

  /// Verifica se exportação de dados está disponível
  bool canExportData() {
    // Permitir exportação mesmo em plano free (boa prática)
    return true;
  }

  /// Obtém limite de clientes para o plano atual
  int getClientLimit() {
    if (isPremiumPlan && hasActiveSubscription) {
      return -1; // Ilimitado
    } else if (isProfessionalPlan && hasActiveSubscription) {
      return 50;
    } else {
      return 5; // Free
    }
  }

  /// Obtém mensagem de status da assinatura
  String getStatusMessage() {
    switch (_currentStatus) {
      case SubscriptionStatus.active:
        if (_expiryDate != null) {
          return 'Assinatura ativa até ${_formatDate(_expiryDate!)}';
        }
        return 'Assinatura ativa';
      case SubscriptionStatus.expired:
        return 'Assinatura expirada';
      case SubscriptionStatus.cancelled:
        return 'Assinatura cancelada';
      case SubscriptionStatus.free:
        return 'Plano gratuito';
      case SubscriptionStatus.unknown:
        return 'Status desconhecido';
    }
  }

  /// Obtém nome do plano atual
  String getPlanName() {
    switch (_currentPlan) {
      case 'professional':
        return 'Professional';
      case 'premium':
        return 'Premium';
      case 'free':
      default:
        return 'Gratuito';
    }
  }

  /// Formata data para exibição
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/'
           '${date.month.toString().padLeft(2, '0')}/'
           '${date.year}';
  }

  /// Retorna lista de benefícios do plano atual
  List<String> getCurrentPlanBenefits() {
    if (isPremiumPlan) {
      return [
        '✓ Clientes ilimitados',
        '✓ Agendamento ilimitado',
        '✓ Relatórios avançados',
        '✓ Exportação de dados',
        '✓ Suporte prioritário',
        '✓ Backup automático na nuvem',
      ];
    } else if (isProfessionalPlan) {
      return [
        '✓ Até 50 clientes',
        '✓ Agendamento ilimitado',
        '✓ Relatórios básicos',
        '✓ Exportação de dados',
        '✓ Backup automático na nuvem',
      ];
    } else {
      return [
        '✓ Até 5 clientes',
        '✓ Agendamento básico',
        '✓ Dados locais',
      ];
    }
  }

  /// Abre tela de upgrade (navegar para PaywallScreen)
  /// Nota: Implementar navegação no app
  Future<void> showUpgradeScreen() async {
    AppLogger.info('Solicitação de upgrade de plano', 'SubscriptionService');
    // TODO: Implementar navegação para PaywallScreen
    // Navigator.of(context).push(MaterialPageRoute(builder: (_) => PaywallScreen()));
  }
}
