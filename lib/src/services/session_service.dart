import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/session.dart';
import 'auth_service.dart';

class SessionService {
  SessionService._();
  static final instance = SessionService._();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _auth = AuthService.instance;

  // Referência da coleção de sessões do usuário atual
  CollectionReference<Map<String, dynamic>>? sessionsCollection() {
    final userId = _auth.currentUser?.uid;
    if (userId == null) return null;
    return _firestore.collection('users').doc(userId).collection('sessions');
  }

  // Stream de todas as sessões
  Stream<List<Session>> getSessionsStream() {
    final collection = sessionsCollection();
    if (collection == null) return Stream.value([]);

    return collection
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Session.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Buscar sessões de um cliente
  Stream<List<Session>> getClientSessionsStream(String clientId) {
    final collection = sessionsCollection();
    if (collection == null) return Stream.value([]);

    return collection
        .where('clientId', isEqualTo: clientId)
        .orderBy('dateTime', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Session.fromMap(doc.id, doc.data()))
            .toList());
  }

  // Buscar sessões do dia
  Future<List<Session>> getTodaySessions() async {
    final collection = sessionsCollection();
    if (collection == null) return [];

    final now = DateTime.now();
    final startOfDay = DateTime(now.year, now.month, now.day);
    final endOfDay = DateTime(now.year, now.month, now.day, 23, 59, 59);

    final snapshot = await collection
        .where('dateTime',
            isGreaterThanOrEqualTo: startOfDay.toIso8601String())
        .where('dateTime', isLessThanOrEqualTo: endOfDay.toIso8601String())
        .orderBy('dateTime')
        .get();

    return snapshot.docs
        .map((doc) => Session.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Buscar sessões por período
  Future<List<Session>> getSessionsByPeriod({
    required DateTime start,
    required DateTime end,
  }) async {
    final collection = sessionsCollection();
    if (collection == null) return [];

    final snapshot = await collection
        .where('dateTime', isGreaterThanOrEqualTo: start.toIso8601String())
        .where('dateTime', isLessThanOrEqualTo: end.toIso8601String())
        .orderBy('dateTime')
        .get();

    return snapshot.docs
        .map((doc) => Session.fromMap(doc.id, doc.data()))
        .toList();
  }

  // Buscar sessão por ID
  Future<Session?> getSessionById(String id) async {
    final collection = sessionsCollection();
    if (collection == null) return null;

    final doc = await collection.doc(id).get();
    if (!doc.exists) return null;
    return Session.fromMap(doc.id, doc.data()!);
  }

  // Criar sessão
  Future<String> createSession({
    required String clientId,
    required DateTime dateTime,
    required String therapyType,
    required double value,
    String? notes,
    String status = 'confirmado',
    String paymentStatus = 'pendente',
    String? packageId,
  }) async {
    final collection = sessionsCollection();
    if (collection == null) throw Exception('Usuário não autenticado.');

    final userId = _auth.currentUser!.uid;

    final session = Session(
      id: '',
      userId: userId,
      clientId: clientId,
      dateTime: dateTime,
      therapyType: therapyType,
      status: status,
      value: value,
      notes: notes ?? '',
      paymentStatus: paymentStatus,
      createdAt: DateTime.now(),
      packageId: packageId,
    );

    final docRef = await collection.add(session.toMap());
    return docRef.id;
  }

  // Atualizar sessão
  Future<void> updateSession(String id, {
    DateTime? dateTime,
    String? therapyType,
    String? status,
    double? value,
    String? notes,
    String? paymentStatus,
    String? packageId,
  }) async {
    final collection = sessionsCollection();
    if (collection == null) throw Exception('Usuário não autenticado.');

    final updates = <String, dynamic>{};
    if (dateTime != null) updates['dateTime'] = dateTime.toIso8601String();
    if (therapyType != null) updates['therapyType'] = therapyType;
    if (status != null) updates['status'] = status;
    if (value != null) updates['value'] = value;
    if (notes != null) updates['notes'] = notes;
    if (paymentStatus != null) updates['paymentStatus'] = paymentStatus;
    if (packageId != null) updates['packageId'] = packageId;

    if (updates.isEmpty) return;

    await collection.doc(id).update(updates);
  }

  // Deletar sessão
  Future<void> deleteSession(String id) async {
    final collection = sessionsCollection();
    if (collection == null) throw Exception('Usuário não autenticado.');

    await collection.doc(id).delete();
  }

  // Marcar sessão como paga
  Future<void> markAsPaid(String id) async {
    await updateSession(id, paymentStatus: 'pago');
  }

  // Marcar sessão como falta
  Future<void> markAsNoShow(String id) async {
    await updateSession(id, status: 'faltou');
  }

  // Buscar última sessão de um cliente (para ver notas anteriores)
  Future<Session?> getLastSessionByClient(String clientId, {String? excludeSessionId}) async {
    final collection = sessionsCollection();
    if (collection == null) return null;

    final snapshot = await collection
        .where('clientId', isEqualTo: clientId)
        .orderBy('dateTime', descending: true)
        .limit(excludeSessionId != null ? 2 : 1)
        .get();

    if (snapshot.docs.isEmpty) return null;

    // Se temos ID para excluir, pegar a segunda sessão
    for (final doc in snapshot.docs) {
      if (excludeSessionId == null || doc.id != excludeSessionId) {
        return Session.fromMap(doc.id, doc.data());
      }
    }

    return null;
  }
}
