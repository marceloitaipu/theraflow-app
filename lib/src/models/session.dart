import 'package:cloud_firestore/cloud_firestore.dart';

class Session {
  final String id;
  final String userId;
  final String clientId;
  final DateTime dateTime;
  final String therapyType;
  final String status; // confirmado/realizada/faltou/remarcado
  final double value;
  final String notes;
  final String paymentStatus; // pago/pendente
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String? packageId; // ID do pacote vinculado (se houver)

  Session({
    required this.id,
    required this.userId,
    required this.clientId,
    required this.dateTime,
    required this.therapyType,
    required this.status,
    required this.value,
    required this.notes,
    required this.paymentStatus,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.packageId,
  });

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'clientId': clientId,
        'dateTime': dateTime.toIso8601String(),
        'therapyType': therapyType,
        'status': status,
        'value': value,
        'notes': notes,
        'paymentStatus': paymentStatus,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
        'packageId': packageId,
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

  static Session fromMap(String id, Map<String, dynamic> map) {
    return Session(
      id: id,
      userId: (map['userId'] ?? '') as String,
      clientId: (map['clientId'] ?? '') as String,
      dateTime: _parseDateTime(map['dateTime']),
      therapyType: (map['therapyType'] ?? '') as String,
      status: (map['status'] ?? 'confirmado') as String,
      value: _parseDouble(map['value']),
      notes: (map['notes'] ?? '') as String,
      paymentStatus: (map['paymentStatus'] ?? 'pendente') as String,
      createdAt: _parseDateTime(map['createdAt']),
      updatedAt: _parseDateTime(map['updatedAt']),
      deletedAt: map['deletedAt'] != null ? _parseDateTime(map['deletedAt']) : null,
      packageId: map['packageId'] as String?,
    );
  }

  Session copyWith({
    DateTime? dateTime,
    String? therapyType,
    String? status,
    double? value,
    String? notes,
    String? paymentStatus,
    String? packageId,
    DateTime? updatedAt,
  }) {
    return Session(
      id: id,
      userId: userId,
      clientId: clientId,
      dateTime: dateTime ?? this.dateTime,
      therapyType: therapyType ?? this.therapyType,
      status: status ?? this.status,
      value: value ?? this.value,
      notes: notes ?? this.notes,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      deletedAt: deletedAt,
      packageId: packageId ?? this.packageId,
    );
  }
}
