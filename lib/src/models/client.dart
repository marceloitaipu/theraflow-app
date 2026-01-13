class Client {
  final String id;
  final String userId;
  final String name;
  final String phone;
  final String notes;
  final DateTime createdAt;
  final String status; // active, inactive

  Client({
    required this.id,
    required this.userId,
    required this.name,
    required this.phone,
    required this.notes,
    required this.createdAt,
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
        'status': status,
      };

  static Client fromMap(String id, Map<String, dynamic> map) => Client(
        id: id,
        userId: (map['userId'] ?? '') as String,
        name: (map['name'] ?? '') as String,
        phone: (map['phone'] ?? '') as String,
        notes: (map['notes'] ?? '') as String,
        createdAt: map['createdAt'] != null
            ? DateTime.parse(map['createdAt'] as String)
            : DateTime.now(),
        status: (map['status'] ?? 'active') as String,
      );

  Client copyWith({
    String? name,
    String? phone,
    String? notes,
    String? status,
  }) {
    return Client(
      id: id,
      userId: userId,
      name: name ?? this.name,
      phone: phone ?? this.phone,
      notes: notes ?? this.notes,
      createdAt: createdAt,
      status: status ?? this.status,
    );
  }

  /// Nome para exibição com indicador de status se inativo
  String get displayName => isInactive ? '$name (inativo)' : name;
}
