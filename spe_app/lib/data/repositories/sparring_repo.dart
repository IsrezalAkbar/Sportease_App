import '../datasources/firestore_sparring_ds.dart';
import '../models/sparring_model.dart';

class SparringRepo {
  final _ds = SparringDataSource();

  Stream<List<SparringModel>> get list => _ds.getSparringList();

  Future<void> create(SparringModel m) => _ds.createSparring(m);

  Future<void> join(String uid, String id) => _ds.joinSparring(uid, id);

  Stream<List<SparringModel>> getByOwner(String ownerId) =>
      _ds.getSparringByOwner(ownerId);

  Stream<List<SparringModel>> getAllSparring() => _ds.getAllSparring();

  Future<void> joinSparring({
    required String sparringId,
    required String userId,
    required String challengerTeamName,
  }) => _ds.joinSparringWithTeamName(sparringId, userId, challengerTeamName);

  /// Get sparring where user is a participant
  Stream<List<SparringModel>> getJoinedSparring(String userId) =>
      _ds.getJoinedSparring(userId);

  Future<void> updateSparringPayment({
    required String sparringId,
    required String bookingId,
    required String paymentStatus,
    DateTime? date,
    String? time,
  }) => _ds.updateSparringPayment(
    sparringId: sparringId,
    bookingId: bookingId,
    paymentStatus: paymentStatus,
    date: date,
    time: time,
  );
}
