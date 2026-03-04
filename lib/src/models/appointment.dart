import 'appointment_metadata.dart';

/// Agendamento unificado que suporta todos os módulos.
///
/// Firestore path: /businesses/{businessId}/appointments/{appointmentId}
///
/// Substitui o model Session anterior, adicionando suporte a múltiplos
/// módulos via campo `module` e dados específicos via `metadata`.
class Appointment {
  final String id;
  final String clientId;
  final String? staffUid;
  final String? serviceId;
  final String module; // therapy, aesthetics, podiatry, massage
  final DateTime startAt;
  final DateTime endAt;
  final String status; // confirmado, realizada, faltou, remarcado, cancelado
  final double price;
  final String paymentStatus; // pago, pendente
  final Map<String, dynamic> metadata;
  final DateTime createdAt;
  final String? packageId;

  Appointment({
    required this.id,
    required this.clientId,
    this.staffUid,
    this.serviceId,
    required this.module,
    required this.startAt,
    required this.endAt,
    required this.status,
    required this.price,
    required this.paymentStatus,
    this.metadata = const {},
    required this.createdAt,
    this.packageId,
  });

  /// Retorna notas da sessão (para compatibilidade e exibição genérica)
  String get notes {
    if (module == 'therapy') {
      return (metadata['sessionNotes'] ?? '') as String;
    }
    return (metadata['notes'] ?? '') as String;
  }

  /// Duração em minutos
  int get durationMin => endAt.difference(startAt).inMinutes;

  // ========== Typed metadata getters ==========

  TherapyMetadata? get therapyMetadata =>
      module == 'therapy' && metadata.isNotEmpty
          ? TherapyMetadata.fromMap(metadata)
          : null;

  AestheticsMetadata? get aestheticsMetadata =>
      module == 'aesthetics' && metadata.isNotEmpty
          ? AestheticsMetadata.fromMap(metadata)
          : null;

  PodiatryMetadata? get podiatryMetadata =>
      module == 'podiatry' && metadata.isNotEmpty
          ? PodiatryMetadata.fromMap(metadata)
          : null;

  MassageMetadata? get massageMetadata =>
      module == 'massage' && metadata.isNotEmpty
          ? MassageMetadata.fromMap(metadata)
          : null;

  // ========== Serialization ==========

  Map<String, dynamic> toMap() => {
        'clientId': clientId,
        'staffUid': staffUid,
        'serviceId': serviceId,
        'module': module,
        'startAt': startAt.toIso8601String(),
        'endAt': endAt.toIso8601String(),
        'status': status,
        'price': price,
        'paymentStatus': paymentStatus,
        'metadata': metadata,
        'createdAt': createdAt.toIso8601String(),
        'packageId': packageId,
      };

  static Appointment fromMap(String id, Map<String, dynamic> map) {
    return Appointment(
      id: id,
      clientId: (map['clientId'] ?? '') as String,
      staffUid: map['staffUid'] as String?,
      serviceId: map['serviceId'] as String?,
      module: (map['module'] ?? 'therapy') as String,
      startAt: map['startAt'] != null
          ? DateTime.parse(map['startAt'] as String)
          : (map['dateTime'] != null
              ? DateTime.parse(map['dateTime'] as String)
              : DateTime.now()),
      endAt: map['endAt'] != null
          ? DateTime.parse(map['endAt'] as String)
          : (map['dateTime'] != null
              ? DateTime.parse(map['dateTime'] as String)
                  .add(const Duration(minutes: 50))
              : DateTime.now().add(const Duration(minutes: 50))),
      status: (map['status'] ?? 'confirmado') as String,
      price: map['price'] is int
          ? (map['price'] as int).toDouble()
          : (map['price'] is num
              ? (map['price'] as num).toDouble()
              : 0.0),
      paymentStatus: (map['paymentStatus'] ?? 'pendente') as String,
      metadata: (map['metadata'] as Map<String, dynamic>?) ?? {},
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
      packageId: map['packageId'] as String?,
    );
  }

  Appointment copyWith({
    String? clientId,
    String? staffUid,
    String? serviceId,
    String? module,
    DateTime? startAt,
    DateTime? endAt,
    String? status,
    double? price,
    String? paymentStatus,
    Map<String, dynamic>? metadata,
    String? packageId,
  }) {
    return Appointment(
      id: id,
      clientId: clientId ?? this.clientId,
      staffUid: staffUid ?? this.staffUid,
      serviceId: serviceId ?? this.serviceId,
      module: module ?? this.module,
      startAt: startAt ?? this.startAt,
      endAt: endAt ?? this.endAt,
      status: status ?? this.status,
      price: price ?? this.price,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      metadata: metadata ?? this.metadata,
      createdAt: createdAt,
      packageId: packageId ?? this.packageId,
    );
  }
}
