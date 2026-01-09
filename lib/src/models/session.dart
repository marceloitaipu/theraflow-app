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
        'packageId': packageId,
      };

  static Session fromMap(String id, Map<String, dynamic> map) {
    return Session(
      id: id,
      userId: (map['userId'] ?? '') as String,
      clientId: (map['clientId'] ?? '') as String,
      dateTime: map['dateTime'] != null
          ? DateTime.parse(map['dateTime'] as String)
          : DateTime.now(),
      therapyType: (map['therapyType'] ?? '') as String,
      status: (map['status'] ?? 'confirmado') as String,
      value: (map['value'] ?? 0.0) is int
          ? (map['value'] as int).toDouble()
          : (map['value'] ?? 0.0) as double,
      notes: (map['notes'] ?? '') as String,
      paymentStatus: (map['paymentStatus'] ?? 'pendente') as String,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
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
      packageId: packageId ?? this.packageId,
    );
  }
}
