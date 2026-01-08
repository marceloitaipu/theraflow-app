import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user.dart';
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
    String? firstClientName,
    String? firstClientPhone,
  }) async {
    if (name.isEmpty) {
      throw Exception('Informe seu nome.');
    }

    final userId = _auth.currentUser?.uid;
    if (userId == null) throw Exception('Usuário não autenticado.');

    // Atualizar dados do usuário
    await _firestore.collection('users').doc(userId).update({
      'name': name,
      'phone': phone,
      'city': city,
      'defaultDurationMinutes': defaultDurationMinutes,
      'defaultPrice': defaultPrice,
      'onboardingCompleted': true,
    });

    // Criar primeiro cliente se informado
    if (firstClientName != null && firstClientName.trim().isNotEmpty) {
      await ClientService.instance.createClient(
        name: firstClientName.trim(),
        phone: firstClientPhone ?? '',
      );
    }
  }

  // Buscar perfil do usuário
  Future<UserProfile?> getUserProfile() async {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    final doc = await _firestore.collection('users').doc(userId).get();
    if (!doc.exists) return null;

    final data = doc.data()!;
    return UserProfile(
      name: data['name'] ?? '',
      phone: data['phone'] ?? '',
      city: data['city'] ?? '',
      defaultDurationMinutes: data['defaultDurationMinutes'] ?? 60,
      defaultPrice: (data['defaultPrice'] ?? 150.0) is int
          ? (data['defaultPrice'] as int).toDouble()
          : (data['defaultPrice'] ?? 150.0) as double,
    );
  }
}

class UserProfile {
  final String name;
  final String phone;
  final String city;
  final int defaultDurationMinutes;
  final double defaultPrice;

  UserProfile({
    required this.name,
    required this.phone,
    required this.city,
    required this.defaultDurationMinutes,
    required this.defaultPrice,
  });
}
