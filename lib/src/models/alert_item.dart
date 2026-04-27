/// Prioridade do alerta — determina ordem de exibição.
enum AlertPriority { high, medium, low }

/// Tipos de alerta suportados pelo sistema.
enum AlertType {
  paymentOverdue,      // pagamento atrasado
  packageEnding,       // pacote com poucas sessões
  clientAtRisk,        // sem retorno há muito tempo
  clientNoNextSession, // sem próxima sessão agendada
  sessionTomorrow,     // sessão agendada para amanhã
  manyAbsences,        // cliente com muitas faltas
}

/// Item de alerta acionável exibido na Home e em outras telas.
class AlertItem {
  final AlertType type;
  final AlertPriority priority;
  final String message;

  /// Se o alerta está relacionado a um cliente específico.
  final String? clientId;
  final String? clientName;

  /// Rota de navegação ao tocar no alerta.
  final String route;

  const AlertItem({
    required this.type,
    required this.priority,
    required this.message,
    this.clientId,
    this.clientName,
    required this.route,
  });
}
