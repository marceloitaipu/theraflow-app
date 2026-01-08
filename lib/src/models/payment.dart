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

  static Payment fromMap(String id, Map<String, dynamic> map) {
    return Payment(
      id: id,
      sessionId: (map['sessionId'] ?? '') as String,
      status: (map['status'] ?? 'pendente') as String,
      method: (map['method'] ?? 'dinheiro') as String,
      value: (map['value'] ?? 0.0) is int
          ? (map['value'] as int).toDouble()
          : (map['value'] ?? 0.0) as double,
      paidAt: map['paidAt'] != null
          ? DateTime.parse(map['paidAt'] as String)
          : null,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
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
