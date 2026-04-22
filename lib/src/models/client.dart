import 'package:cloud_firestore/cloud_firestore.dart';

class Client {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String notes;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String status; // active, inactive

  Client({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.notes,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    this.status = 'active',
  });

  /// Verifica se o cliente está ativo
  bool get isActive => status == 'active';

  /// Verifica se o cliente está inativo/arquivado
  bool get isInactive => status == 'inactive';

  Map<String, dynamic> toMap() => {
        'userId': userId,
        'name': name,
        'phone': phone,
        'notes': notes,
        'createdAt': createdAt.toIso8601String(),
        'updatedAt': updatedAt.toIso8601String(),
        'deletedAt': deletedAt?.toIso8601String(),
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

  static Client fromMap(String id, Map<String, dynamic> map) => Client(
        id: id,
        userId: (map['userId'] ?? '') as String,
        name: (map['name'] ?? '') as String,
        phone: (map['phone'] ?? '') as String,
        notes: (map['notes'] ?? '') as String,
        createdAt: _parseDateTime(map['createdAt']),
        updatedAt: _parseDateTime(map['updatedAt']),
        deletedAt: map['deletedAt'] != null ? _parseDateTime(map['deletedAt']) : null,
        status: (map['status'] ?? 'active') as String,
      );

  Client copyWith({
    String? name,
    String? phone,
    String? notes,
    String? status,
    DateTime? updatedAt,
    DateTime? deletedAt,
  }) {
    return Client(
      id: id,
      userId: userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      updatedAt: updatedAt ?? DateTime.now(),
      deletedAt: deletedAt ?? this.deletedAt,
      status: status ?? this.status,
    );
  }

  /// Nome para exibição com indicador de status se inativo
  String get displayName => isInactive ? '$name (inativo)' : name;
}
