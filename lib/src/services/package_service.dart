import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/package.dart';
import 'auth_service.dart';

/// Service para gerenciamento de pacotes de sessões
class PackageService {
  PackageService._();
  static final instance = PackageService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService.instance;

  /// Referência da coleção de pacotes de um cliente
  CollectionReference<Map<String, dynamic>>? _packagesCollection(String clientId) {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore
        .collection('users')
        .doc(userId)
        .collection('clients')
        .doc(clientId)
        .collection('packages');
  }

  /// Listar todos os pacotes de um cliente
  Future<List<Package>> listPackages(String clientId) async {
    final collection = _packagesCollection(clientId);
    if (collection == null) return [];

    final snapshot = await collection
        .orderBy('createdAt', descending: true)
        .get();

    return snapshot.docs
        .map((doc) => Package.fromMap(doc.id, doc.data()))
        .toList();
  }

  /// Stream de pacotes de um cliente
  Stream<List<Package>> getPackagesStream(String clientId) {
    final collection = _packagesCollection(clientId);
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Package.fromMap(doc.id, doc.data()))
            .toList());
  }

  /// Buscar pacote ativo de um cliente (mais recente com remaining > 0)
  Future<Package?> getActivePackage(String clientId) async {
    final collection = _packagesCollection(clientId);
    if (collection == null) return null;

    final snapshot = await collection
        .where('status', isEqualTo: 'active')
        .where('remainingSessions', isGreaterThan: 0)
        .orderBy('remainingSessions')
        .orderBy('createdAt', descending: true)
        .limit(1)
        .get();

    if (snapshot.docs.isEmpty) return null;
    return Package.fromMap(snapshot.docs.first.id, snapshot.docs.first.data());
  }

  /// Buscar pacote por ID
  Future<Package?> getPackageById(String clientId, String packageId) async {
    final collection = _packagesCollection(clientId);
    if (collection == null) return null;

    final doc = await collection.doc(packageId).get();
    if (!doc.exists) return null;
    return Package.fromMap(doc.id, doc.data()!);
  }

  /// Criar novo pacote
  Future<String> createPackage({
    required String clientId,
    required int totalSessions,
    required double price,
    DateTime? expirationDate,
  }) async {
    final collection = _packagesCollection(clientId);
    if (collection == null) throw Exception('Usuário não autenticado.');

    final package = Package(
      id: '',
      clientId: clientId,
      totalSessions: totalSessions,
      remainingSessions: totalSessions,
      price: price,
      createdAt: DateTime.now(),
      expirationDate: expirationDate,
      status: 'active',
    );

    final docRef = await collection.add(package.toMap());
    return docRef.id;
  }

  /// Decrementar sessão do pacote
  Future<Package?> decrementPackage(String packageId) async {
    // Precisamos encontrar o pacote primeiro para saber o clientId
    // Como packageId inclui o path, vamos buscar diretamente
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;

    // Buscar o pacote em todos os clientes
    final clientsSnapshot = await _firestore
        .collection('users')
        .doc(userId)
        .collection('clients')
        .get();

    for (final clientDoc in clientsSnapshot.docs) {
      final packageDoc = await _firestore
          .collection('users')
          .doc(userId)
          .collection('clients')
          .doc(clientDoc.id)
          .collection('packages')
          .doc(packageId)
          .get();

      if (packageDoc.exists) {
        final package = Package.fromMap(packageDoc.id, packageDoc.data()!);
        
        if (package.remainingSessions <= 0) {
          throw Exception('Pacote sem sessões restantes.');
        }

        final newRemaining = package.remainingSessions - 1;
        final newStatus = newRemaining == 0 ? 'completed' : 'active';

        await packageDoc.reference.update({
          'remainingSessions': newRemaining,
          'status': newStatus,
        });

        return package.copyWith(
          remainingSessions: newRemaining,
          status: newStatus,
        );
      }
    }

    return null;
  }

  /// Decrementar pacote por clientId e packageId (mais eficiente)
  Future<Package?> decrementPackageByClient(String clientId, String packageId) async {
    final collection = _packagesCollection(clientId);
    if (collection == null) return null;

    final doc = await collection.doc(packageId).get();
    if (!doc.exists) return null;

    final package = Package.fromMap(doc.id, doc.data()!);

    if (package.remainingSessions <= 0) {
      throw Exception('Pacote sem sessões restantes.');
    }

    final newRemaining = package.remainingSessions - 1;
    final newStatus = newRemaining == 0 ? 'completed' : 'active';

    await collection.doc(packageId).update({
      'remainingSessions': newRemaining,
      'status': newStatus,
    });

    return package.copyWith(
      remainingSessions: newRemaining,
      status: newStatus,
    );
  }

  /// Verificar se cliente tem pacote ativo
  Future<bool> hasActivePackage(String clientId) async {
    final package = await getActivePackage(clientId);
    return package != null;
  }

  /// Deletar pacote
  Future<void> deletePackage(String clientId, String packageId) async {
    final collection = _packagesCollection(clientId);
    if (collection == null) throw Exception('Usuário não autenticado.');

    await collection.doc(packageId).delete();
  }
}
