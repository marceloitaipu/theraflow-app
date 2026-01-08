import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/client.dart';
import 'auth_service.dart';

class ClientService {
  ClientService._();
  static final instance = ClientService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService.instance;

  // Referência da coleção de clientes do usuário atual
  CollectionReference<Map<String, dynamic>>? _clientsCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('clients');
  }

  // Stream de todos os clientes
  Stream<List<Client>> getClientsStream() {
    final collection = _clientsCollection();
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('name')
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Client.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Buscar todos os clientes (uma vez)
  Future<List<Client>> getClients() async {
    final collection = _clientsCollection();
    if (collection == null) return [];

    final snapshot = await collection.orderBy('name').get();
    return snapshot.docs
        .map((doc) => Client.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Buscar cliente por ID
  Future<Client?> getClientById(String id) async {
    final collection = _clientsCollection();
    if (collection == null) return null;

    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return Client.fromMap(doc.id, doc.data()!);
  }

  // Criar cliente
  Future<String> createClient({
    required String name,
    required String phone,
    String? notes,
  }) async {
    final collection = _clientsCollection();
    if (collection == null) throw Exception('Usuário não autenticado.');

    final userId = _auth.currentUser!.uid;

    // Verificar limite do plano
    await _checkClientLimit();

    final client = Client(
      id: '', // Será gerado pelo Firestore
      userId: userId,
      name: name,
      phone: phone,
      notes: notes ?? '',
      createdAt: DateTime.now(),
    );

    final docRef = await collection.add(client.toMap());
    return docRef.id;
  }

  // Atualizar cliente
  Future<void> updateClient(String id, {
    String? name,
    String? phone,
    String? notes,
  }) async {
    final collection = _clientsCollection();
    if (collection == null) throw Exception('Usuário não autenticado.');

    final updates = <String, dynamic>{};
    if (name != null) updates['name'] = name;
    if (phone != null) updates['phone'] = phone;
    if (notes != null) updates['notes'] = notes;

    if (updates.isEmpty) return;

    await collection.doc(id).update(updates);
  }

  // Deletar cliente
  Future<void> deleteClient(String id) async {
    final collection = _clientsCollection();
    if (collection == null) throw Exception('Usuário não autenticado.');

    await collection.doc(id).delete();
  }

  // Buscar clientes por nome
  Future<List<Client>> searchClients(String query) async {
    final clients = await getClients();
    if (query.isEmpty) return clients;

    final lowerQuery = query.toLowerCase();
    return clients
        .where((client) =>
            client.name.toLowerCase().contains(lowerQuery) ||
            client.phone.contains(query))
        .toList();
  }

  // Contar clientes do usuário
  Future<int> getClientCount() async {
    final collection = _clientsCollection();
    if (collection == null) return 0;

    final snapshot = await collection.count().get();
    return snapshot.count ?? 0;
  }

  // Verificar limite de clientes do plano
  Future<void> _checkClientLimit() async {
    final userData = await _auth.getCurrentUserData();
    if (userData == null) throw Exception('Dados do usuário não encontrados.');

    final currentCount = await getClientCount();
    if (currentCount >= userData.clientLimit) {
      throw Exception(
          'Limite de ${userData.clientLimit} clientes atingido. Faça upgrade do seu plano.');
    }
  }
}
