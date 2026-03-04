import 'app_module.dart';

/// Serviço oferecido pelo profissional/clínica.
///
/// Firestore path: /businesses/{businessId}/services/{serviceId}
class ServiceItem {
  final String id;
  final String name;
  final AppModule module;
  final int durationMin;
  final double price;
  final bool active;

  ServiceItem({
    required this.id,
    required this.name,
    required this.module,
    required this.durationMin,
    required this.price,
    this.active = true,
  });

  Map<String, dynamic> toMap() => {
        'name': name,
        'module': module.name,
        'durationMin': durationMin,
        'price': price,
        'active': active,
      };

  static ServiceItem fromMap(String id, Map<String, dynamic> map) {
    return ServiceItem(
      id: id,
      name: (map['name'] ?? '') as String,
      module: AppModule.fromString(map['module'] as String? ?? 'therapy'),
      durationMin: (map['durationMin'] ?? 50) as int,
      price: (map['price'] ?? 0.0) is int
          ? (map['price'] as int).toDouble()
          : (map['price'] ?? 0.0) as double,
      active: (map['active'] ?? true) as bool,
    );
  }

  ServiceItem copyWith({
    String? name,
    AppModule? module,
    int? durationMin,
    double? price,
    bool? active,
  }) {
    return ServiceItem(
      id: id,
      name: name ?? this.name,
      module: module ?? this.module,
      durationMin: durationMin ?? this.durationMin,
      price: price ?? this.price,
      active: active ?? this.active,
    );
  }
}
