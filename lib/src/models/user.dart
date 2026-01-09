class User {
  final String id;
  final String name;
  final String email;
  final String plan; // free, professional, premium
  final DateTime createdAt;
  final bool onboardingCompleted;
  final int clientLimit;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.createdAt,
    this.onboardingCompleted = false,
    int? clientLimit,
  }) : clientLimit = clientLimit ?? _getClientLimitForPlan(plan);

  static int _getClientLimitForPlan(String plan) {
    switch (plan) {
      case 'free':
        return 5;
      case 'professional':
        return 50;
      case 'premium':
        return 999999; // ilimitado
      default:
        return 5;
    }
  }

  // ========== HELPERS DE PERMISSÕES ==========

  /// Verifica se pode criar mais clientes
  bool canCreateClient(int currentCount) {
    return currentCount < clientLimit;
  }

  /// Verifica se pode usar pacotes
  bool canUsePackages() {
    return plan == 'professional' || plan == 'premium';
  }

  /// Verifica se pode exportar relatórios
  bool canExportReports() {
    return plan == 'professional' || plan == 'premium';
  }

  /// Verifica se pode usar alertas inteligentes
  bool canUseSmartAlerts() {
    return plan == 'professional' || plan == 'premium';
  }

  /// Verifica se é plano free
  bool get isFree => plan == 'free';

  /// Verifica se é plano pro ou superior
  bool get isPro => plan == 'professional' || plan == 'premium';

  /// Verifica se é premium
  bool get isPremium => plan == 'premium';

  /// Nome amigável do plano
  String get planDisplayName {
    switch (plan) {
      case 'free':
        return 'Gratuito';
      case 'professional':
        return 'Profissional';
      case 'premium':
        return 'Premium';
      default:
        return 'Gratuito';
    }
  }

  Map<String, dynamic> toMap() => {
        'name': name,
        'email': email,
        'plan': plan,
        'createdAt': createdAt.toIso8601String(),
        'onboardingCompleted': onboardingCompleted,
      };

  static User fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      plan: (map['plan'] ?? 'free') as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      onboardingCompleted: (map['onboardingCompleted'] ?? false) as bool,
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? plan,
    DateTime? createdAt,
    bool? onboardingCompleted,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
    );
  }
}
