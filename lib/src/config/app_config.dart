// Configuração do aplicativo.
// Permite alternar entre modo mock (desenvolvimento) e Firebase (produção).

class AppConfig {
  /// Define se o app está em modo mock (sem Firebase)
  /// 
  /// true = usa mock services (dados em memória, sem Firebase)
  /// false = usa Firebase real (requer configuração)
  static const bool useMockServices = false;

  /// Versão do app
  static const String appVersion = '1.0.0';

  /// Nome do app
  static const String appName = 'TheraFlow';

  /// Configurações de limites por plano
  static const Map<String, int> planLimits = {
    'free': 5,
    'professional': 50,
    'premium': 999999,
  };

  /// Configurações de duração padrão (minutos)
  static const int defaultSessionDuration = 60;

  /// Configurações de preço padrão (R$)
  static const double defaultSessionPrice = 150.0;

  /// Habilitar logs de debug
  static const bool debugMode = true;

  /// URL da landing page (para redirecionamento)
  static const String landingPageUrl = 'https://theraflow.com.br';

  /// Informações de contato/suporte
  static const String supportEmail = 'contato@theraflow.com.br';
}
