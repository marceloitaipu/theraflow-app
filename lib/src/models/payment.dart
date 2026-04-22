import 'package:cloud_firestore/cloud_firestore.dart';

class Payment {
  final String id;
  final String sessionId;
  final String status; // pago, pendente
  final String method; // dinheiro, pix, cartao, outro
  final double value;
  final DateTime? paidAt;
  final DateTime createdAt;

  Payment({
    required this.id,
    required this.sessionId,
    required this.status,
    required this.method,
    required this.value,
    this.paidAt,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'sessionId': sessionId,
        'status': status,
        'method': method,
        'value': value,
        'paidAt': paidAt?.toIso8601String(),
        'createdAt': createdAt.toIso8601String(),
      };

  static DateTime _parseDateTime(dynamic value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String && value.isNotEmpty) {
      return DateTime.tryParse(value) ?? DateTime.now();
    }
    return DateTime.now();
  }

  static double _parseDouble(dynamic value) {
    if (value is num) return value.toDouble();
    if (value is String) return double.tryParse(value) ?? 0.0;
    return 0.0;
  }

  static Payment fromMap(String id, Map<String, dynamic> map) {
    return Payment(
      id: id,
      sessionId: (map['sessionId'] ?? '') as String,
      status: (map['status'] ?? 'pendente') as String,
      method: (map['method'] ?? 'dinheiro') as String,
      value: _parseDouble(map['value']),
      paidAt: map['paidAt'] != null ? _parseDateTime(map['paidAt']) : null,
      createdAt: _parseDateTime(map['createdAt']),
    );
  }

  Payment copyWith({
    String? status,
    String? method,
    double? value,
    DateTime? paidAt,
  }) {
    return Payment(
      id: id,
      sessionId: sessionId,
      status: status ?? this.status,
      method: method ?? this.method,
      value: value ?? this.value,
      paidAt: paidAt ?? this.paidAt,
      createdAt: createdAt,
    );
  }
}
