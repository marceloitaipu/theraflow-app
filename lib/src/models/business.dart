import 'app_module.dart';

/// Entidade principal do sistema multi-tenant.
/// Representa um consultório, clínica ou profissional.
///
/// Firestore path: /businesses/{businessId}
class Business {
  final String id;
  final String name;
  final String ownerUid;
  final String plan; // starter, pro, clinic
  final List<AppModule> enabledModules;
  final String subscriptionStatus; // active, trial, expired, cancelled
  final String? rcUserId; // RevenueCat user ID
  final DateTime createdAt;
  final DateTime updatedAt;

  Business({
    required this.id,
    required this.name,
    required this.ownerUid,
    required this.plan,
    required this.enabledModules,
    this.subscriptionStatus = 'trial',
    this.rcUserId,
    required this.createdAt,
    DateTime? updatedAt,
  }) : updatedAt = updatedAt ?? createdAt;

  // ========== Plan helpers ==========

  bool get isStarter => plan == 'starter';
  bool get isPro => plan == 'pro';
  bool get isClinic => plan == 'clinic';

  String get planDisplayName {
    switch (plan) {
      case 'starter':
        return 'Starter';
      case 'pro':
        return 'Pro';
      case 'clinic':
        return 'Clínica';
      default:
        return 'Starter';
    }
  }

  int get clientLimit {
    switch (plan) {
      case 'starter':
        return 10;
      case 'pro':
        return 100;
      case 'clinic':
        return 999999;
      default:
        return 10;
    }
  }

  bool canCreateClient(int currentCount) => currentCount < clientLimit;

  bool isModuleEnabled(AppModule module) => enabledModules.contains(module);

  bool get canUsePackages => plan == 'pro' || plan == 'clinic';
  bool get canExportReports => plan == 'pro' || plan == 'clinic';
  bool get canUseSmartAlerts => plan == 'pro' || plan == 'clinic';
  bool get isSubscriptionActive =>
      subscriptionStatus == 'active' || subscriptionStatus == 'trial';

  // ========== Serialization ==========

  Map<String, dynamic> toMap() => {
        'name': name,
        'ownerUid': ownerUid,
        'plan': plan,
        'enabledModules': enabledModules.map((m) => m.name).toList(),
        'subscriptionStatus': subscriptionStatus,
        'rcUserId': rcUserId,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
      };

  static Business fromMap(String id, Map<String, dynamic> map) {
    final modulesList = (map['enabledModules'] as List<dynamic>?)
            ?.map((e) => AppModule.fromString(e as String))
            .whereType<AppModule>()
            .toList() ??
        [];

    return Business(
      id: id,
      name: (map['name'] ?? '') as String,
      ownerUid: (map['ownerUid'] ?? '') as String,
      plan: (map['plan'] ?? 'starter') as String,
      enabledModules: modulesList,
      subscriptionStatus:
          (map['subscriptionStatus'] ?? 'trial') as String,
      rcUserId: map['rcUserId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      updatedAt: map['updatedAt'] != null
          ? DateTime.parse(map['updatedAt'] as String)
          : null,
    );
  }

  Business copyWith({
    String? name,
    String? plan,
    List<AppModule>? enabledModules,
    String? subscriptionStatus,
    String? rcUserId,
    DateTime? updatedAt,
  }) {
    return Business(
      id: id,
      name: name ?? this.name,
      ownerUid: ownerUid,
      plan: plan ?? this.plan,
      enabledModules: enabledModules ?? this.enabledModules,
      subscriptionStatus: subscriptionStatus ?? this.subscriptionStatus,
      rcUserId: rcUserId ?? this.rcUserId,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
    );
  }
}
