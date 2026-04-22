import 'package:cloud_firestore/cloud_firestore.dart';
import 'auth_service.dart';
import 'client_service.dart';

class ProfileService {
  ProfileService._();
  static final instance = ProfileService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService.instance;

  // Salvar perfil do usuário após onboarding
  Future<void> saveProfile({
    required String name,
    required String phone,
    required String city,
    required int defaultDurationMinutes,
    required double defaultPrice,
    String? module,
    String? businessName,
    String? firstClientName,
    String? firstClientPhone,
  }) async {
    if (name.isEmpty) {
      throw Exception('Informe seu nome.');
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    final updates = <String, dynamic>{
      'name': name,
      'phone': phone,
      'city': city,
      'defaultDurationMinutes': defaultDurationMinutes,
      'defaultPrice': defaultPrice,
      'onboardingCompleted': true,
    };
    if (module != null && module.isNotEmpty) updates['module'] = module;
    if (businessName != null && businessName.isNotEmpty) {
      updates['businessName'] = businessName;
    }

    await _firestore.collection('users').doc(userId).update(updates);

    if (firstClientName != null && firstClientName.trim().isNotEmpty) {
      await ClientService.instance.createClient(
        name: firstClientName.trim(),
        phone: firstClientPhone ?? '',
      );
    }
  }

  Future<UserProfile?> getUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    final priceRaw = data['defaultPrice'] ?? 150.0;
    return UserProfile(
      name: (data['name'] ?? '') as String,
      phone: (data['phone'] ?? '') as String,
      city: (data['city'] ?? '') as String,
      module: (data['module'] ?? 'therapy') as String,
      businessName: (data['businessName'] ?? '') as String,
      defaultDurationMinutes: (data['defaultDurationMinutes'] ?? 60) as int,
      defaultPrice: priceRaw is int ? priceRaw.toDouble() : priceRaw as double,
    );
  }
}

class UserProfile {
  final String name;
  final String phone;
  final String city;
  final String module;
  final String businessName;
  final int defaultDurationMinutes;
  final double defaultPrice;

  UserProfile({
    required this.name,
    required this.phone,
    required this.city,
    required this.module,
    required this.businessName,
    required this.defaultDurationMinutes,
    required this.defaultPrice,
  });
}
