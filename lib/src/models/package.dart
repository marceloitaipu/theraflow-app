import 'package:cloud_firestore/cloud_firestore.dart';

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

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static int _parseInt(dynamic value) {
    if (value is num) return value.toInt();
    if (value is String) return int.tryParse(value) ?? 0;
    return 0;
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Package fromMap(String id, Map<String, dynamic> map) {
    return Package(
      id: id,
      clientId: (map['clientId'] ?? '') as String,
      totalSessions: _parseInt(map['totalSessions']),
      remainingSessions: _parseInt(map['remainingSessions']),
      price: _parseDouble(map['price']),
      createdAt: _parseDateTime(map['createdAt']),
      expirationDate: map['expirationDate'] != null
          ? _parseDateTime(map['expirationDate'])
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
