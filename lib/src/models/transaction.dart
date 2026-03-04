/// Transação financeira.
///
/// Firestore path: /businesses/{businessId}/transactions/{txId}
class Transaction {
  final String id;
  final String type; // income, expense
  final double amount;
  final String method; // dinheiro, pix, cartao, outro
  final String? appointmentId;
  final DateTime createdAt;

  Transaction({
    required this.id,
    required this.type,
    required this.amount,
    required this.method,
    this.appointmentId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() => {
        'type': type,
        'amount': amount,
        'method': method,
        'appointmentId': appointmentId,
        'createdAt': createdAt.toIso8601String(),
      };

  static Transaction fromMap(String id, Map<String, dynamic> map) {
    return Transaction(
      id: id,
      type: (map['type'] ?? 'income') as String,
      amount: (map['amount'] ?? 0.0) is int
          ? (map['amount'] as int).toDouble()
          : (map['amount'] ?? 0.0) as double,
      method: (map['method'] ?? 'dinheiro') as String,
      appointmentId: map['appointmentId'] as String?,
      createdAt: map['createdAt'] != null
          ? DateTime.parse(map['createdAt'] as String)
          : DateTime.now(),
    );
  }

  Transaction copyWith({
    String? type,
    double? amount,
    String? method,
    String? appointmentId,
  }) {
    return Transaction(
      id: id,
      type: type ?? this.type,
      amount: amount ?? this.amount,
      method: method ?? this.method,
      appointmentId: appointmentId ?? this.appointmentId,
      createdAt: createdAt,
    );
  }
}
