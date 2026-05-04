import 'dart:convert';
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
  final String status; // active, inactive (soft-delete dimension)

  // ── Campos CRM (Fase 1) ──────────────────────────────────────────────────
  /// Objetivo do tratamento, ex: "tratar lombalgia", "reduzir estresse".
  final String? goal;

  /// Frequência ideal de retorno: "semanal", "quinzenal", "mensal".
  final String? idealFrequency;

  /// Tags livres: 'VIP', 'retorno', 'pacote', 'inadimplente', 'novo'.
  final List<String> tags;

  /// Status CRM manual: 'novo', 'ativo', 'pausado', 'em risco', 'inativo'.
  final String clientStatus;

  /// Próxima ação a tomar com este cliente, ex: "Ligar para confirmar retorno".
  final String? nextAction;

  /// Data sugerida para executar a próxima ação (lembrete).
  final DateTime? nextActionDate;

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
    this.goal,
    this.idealFrequency,
    this.tags = const [],
    this.clientStatus = 'ativo',
    this.nextAction,
    this.nextActionDate,
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
        'goal': goal,
        'idealFrequency': idealFrequency,
        'tags': jsonEncode(tags),
        'clientStatus': clientStatus,
        'nextAction': nextAction,
        'nextActionDate': nextActionDate?.toIso8601String(),
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
        goal: map['goal'] as String?,
        idealFrequency: map['idealFrequency'] as String?,
        tags: _parseTags(map['tags']),
        clientStatus: (map['clientStatus'] ?? 'ativo') as String,
        nextAction: map['nextAction'] as String?,
        nextActionDate: map['nextActionDate'] != null
            ? _parseDateTime(map['nextActionDate'])
            : null,
      );

  static List<String> _parseTags(dynamic value) {
    if (value == null) return const [];
    if (value is List) return value.map((e) => e.toString()).toList();
    if (value is String && value.isNotEmpty) {
      try {
        final decoded = jsonDecode(value);
        if (decoded is List) return decoded.map((e) => e.toString()).toList();
      } catch (_) {}
    }
    return const [];
  }

  Client copyWith({
    String? name,
    String? phone,
    String? notes,
    String? status,
    DateTime? updatedAt,
    DateTime? deletedAt,
    String? goal,
    String? idealFrequency,
    List<String>? tags,
    String? clientStatus,
    String? nextAction,
    DateTime? nextActionDate,
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
      goal: goal ?? this.goal,
      idealFrequency: idealFrequency ?? this.idealFrequency,
      tags: tags ?? this.tags,
      clientStatus: clientStatus ?? this.clientStatus,
      nextAction: nextAction ?? this.nextAction,
      nextActionDate: nextActionDate ?? this.nextActionDate,
    );
  }

  /// Nome para exibição com indicador de status se inativo
  String get displayName => isInactive ? '$name (inativo)' : name;
}
