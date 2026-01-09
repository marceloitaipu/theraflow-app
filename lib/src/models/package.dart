/// Model de Pacote de Sessões para monetização
class Package {
  final String id;
  final String clientId;
  final int totalSessions;
  final int remainingSessions;
  final double price;
  final DateTime createdAt;
  final DateTime? expirationDate;
  final String status; // active, expired, completed

  Package({
    required this.id,
    required this.clientId,
    required this.totalSessions,
    required this.remainingSessions,
    required this.price,
    required this.createdAt,
    this.expirationDate,
    this.status = 'active',
  });

  /// Valor por sessão
  double get pricePerSession => totalSessions > 0 ? price / totalSessions : 0;

  /// Sessões utilizadas
  int get usedSessions => totalSessions - remainingSessions;

  /// Porcentagem de uso
  double get usagePercentage => 
      totalSessions > 0 ? (usedSessions / totalSessions) * 100 : 0;

  /// Se está acabando (2 ou menos)
  bool get isLow => remainingSessions <= 2 && remainingSessions > 0;

  /// Se expirou
  bool get isExpired => 
      expirationDate != null && DateTime.now().isAfter(expirationDate!);

  /// Se está ativo (não expirado e com sessões restantes)
  bool get isActive => 
      status == 'active' && remainingSessions > 0 && !isExpired;

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'totalSessions': totalSessions,
        'remainingSessions': remainingSessions,
        'price': price,
        'createdAt': createdAt.toIso8601String(),
        'expirationDate': expirationDate?.toIso8601String(),
        'status': status,
      };

  static Package fromMap(String id, Map<String, dynamic> map) {
    return Package(
      id: id,
      clientId: (map['clientId'] ?? '') as String,
      totalSessions: (map['totalSessions'] ?? 0) as int,
      remainingSessions: (map['remainingSessions'] ?? 0) as int,
      price: (map['price'] ?? 0.0) is int
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0) as double,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      expirationDate: map['expirationDate'] != null
          ? DateTime.parse(map['expirationDate'] as String)
          : null,
      status: (map['status'] ?? 'active') as String,
    );
  }

  Package copyWith({
    int? totalSessions,
    int? remainingSessions,
    double? price,
    DateTime? expirationDate,
    String? status,
  }) {
    return Package(
      id: id,
      clientId: clientId,
      totalSessions: totalSessions ?? this.totalSessions,
      remainingSessions: remainingSessions ?? this.remainingSessions,
      price: price ?? this.price,
      createdAt: createdAt,
      expirationDate: expirationDate ?? this.expirationDate,
      status: status ?? this.status,
    );
  }
}
