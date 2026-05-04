import 'package:cloud_functions/cloud_functions.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../config/app_config.dart';
import 'auth_service.dart';
import 'client_service.dart';
import 'incremental_sync_service.dart';
import '../database/database_helper.dart';

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
      final firestore = FirebaseFirestore.instance;
      final userDoc = await firestore.collection('users').doc(userId).get();
      
      if (!userDoc.exists) {
        AppLogger.warning('Documento do usuário não existe - status free', 'SubscriptionService');
        _currentStatus = SubscriptionStatus.free;
        _currentPlan = 'free';
        return;
      }

      final data = userDoc.data()!;
      final statusStr = data['subscriptionStatus'] as String?;
      _currentPlan = data['planId'] as String? ?? data['plan'] as String? ?? 'free';

      if (AppConfig.isWebTestMode && _currentPlan == 'free') {
        _currentStatus = SubscriptionStatus.active;
      }
      
      final periodEndTimestamp = data['currentPeriodEnd'];
      if (periodEndTimestamp is Timestamp) {
        _expiryDate = periodEndTimestamp.toDate();
      } else if (periodEndTimestamp is String) {
        _expiryDate = DateTime.tryParse(periodEndTimestamp);
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
          _currentStatus = AppConfig.isWebTestMode
              ? SubscriptionStatus.active
              : SubscriptionStatus.free;
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

      final userId = _auth.currentUser?.uid;
      if (userId == null) return false;

      // Premium: sem limites
      if (isPremiumPlan && hasActiveSubscription) {
        return true;
      }

      // Na web, usa Firestore diretamente via serviço de clientes.
      final clientCount = kIsWeb
          ? await ClientService.instance.getClientCount()
          : await DatabaseHelper.instance.countClients(userId);
      final limit = getClientLimit();

      // Se limite é -1 (ilimitado), sempre permitir
      if (limit == -1) return true;

      // Verificar se já atingiu o limite
      final canCreate = clientCount < limit;
      
      if (!canCreate) {
        AppLogger.warning(
          'Limite de clientes atingido: $clientCount/$limit',
          'SubscriptionService'
        );
      }

      return canCreate;

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
