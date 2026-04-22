import 'package:cloud_firestore/cloud_firestore.dart';

class User {
  final String id;
  final String name;
  final String email;
  final String plan; // free, professional, premium
  final DateTime createdAt;
  final bool onboardingCompleted;
  final int clientLimit;

  // Campos de perfil de negócio (preenchidos no onboarding)
  final String? module;
  final String? businessName;
  final String? phone;
  final String? city;
  final int? defaultDurationMinutes;
  final double? defaultPrice;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.plan,
    required this.createdAt,
    this.onboardingCompleted = false,
    int? clientLimit,
    this.module,
    this.businessName,
    this.phone,
    this.city,
    this.defaultDurationMinutes,
    this.defaultPrice,
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
        if (module != null) 'module': module,
        if (businessName != null) 'businessName': businessName,
        if (phone != null) 'phone': phone,
        if (city != null) 'city': city,
        if (defaultDurationMinutes != null)
          'defaultDurationMinutes': defaultDurationMinutes,
        if (defaultPrice != null) 'defaultPrice': defaultPrice,
      };

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) return double.tryParse(value);
    return null;
  }

  static User fromMap(String id, Map<String, dynamic> map) {
    return User(
      id: id,
      name: (map['name'] ?? '') as String,
      email: (map['email'] ?? '') as String,
      plan: (map['plan'] ?? 'free') as String,
      createdAt: _parseDateTime(map['createdAt']),
      onboardingCompleted: (map['onboardingCompleted'] ?? false) as bool,
      module: map['module'] as String?,
      businessName: map['businessName'] as String?,
      phone: map['phone'] as String?,
      city: map['city'] as String?,
      defaultDurationMinutes: map['defaultDurationMinutes'] as int?,
      defaultPrice: _parseDouble(map['defaultPrice']),
    );
  }

  User copyWith({
    String? name,
    String? email,
    String? plan,
    DateTime? createdAt,
    bool? onboardingCompleted,
    String? module,
    String? businessName,
    String? phone,
    String? city,
    int? defaultDurationMinutes,
    double? defaultPrice,
  }) {
    return User(
      id: id,
      name: name ?? this.name,
      email: email ?? this.email,
      plan: plan ?? this.plan,
      createdAt: createdAt ?? this.createdAt,
      onboardingCompleted: onboardingCompleted ?? this.onboardingCompleted,
      module: module ?? this.module,
      businessName: businessName ?? this.businessName,
      phone: phone ?? this.phone,
      city: city ?? this.city,
      defaultDurationMinutes:
          defaultDurationMinutes ?? this.defaultDurationMinutes,
      defaultPrice: defaultPrice ?? this.defaultPrice,
    );
  }
}
