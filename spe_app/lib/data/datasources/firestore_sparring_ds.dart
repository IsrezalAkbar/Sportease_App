import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/sparring_model.dart';

class SparringDataSource {
  final _db = FirebaseFirestore.instance;

  Stream<List<SparringModel>> getSparringList() {
    return _db
        .collection("sparring")
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => SparringModel.fromMap(d.data())).toList(),
        );
  }

  Future<void> createSparring(SparringModel model) async {
    await _db.collection("sparring").doc(model.sparringId).set(model.toMap());
  }

  Future<void> joinSparring(String uid, String id) async {
    await _db.collection("sparring").doc(id).update({
      "participantList": FieldValue.arrayUnion([uid]),
    });
  }

  Stream<List<SparringModel>> getSparringByOwner(String ownerId) {
    return _db
        .collection("sparring")
        .where("ownerId", isEqualTo: ownerId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => SparringModel.fromMap(d.data())).toList(),
        );
  }

  Stream<List<SparringModel>> getAllSparring() {
    return _db
        .collection("sparring")
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => SparringModel.fromMap(d.data())).toList(),
        );
  }

  Future<void> joinSparringWithTeamName(
    String sparringId,
    String userId,
    String teamName,
  ) async {
    await _db.collection("sparring").doc(sparringId).update({
      "participantList": FieldValue.arrayUnion([userId]),
      "challengerTeamName": teamName,
    });
  }

  Future<void> updateSparringPayment({
    required String sparringId,
    required String bookingId,
    required String paymentStatus,
    DateTime? date,
    String? time,
  }) async {
    final updateData = {"bookingId": bookingId, "paymentStatus": paymentStatus};

    if (date != null) {
      updateData["date"] = date.toIso8601String();
    }
    if (time != null) {
      updateData["time"] = time;
    }

    await _db.collection("sparring").doc(sparringId).update(updateData);
  }

  /// Get sparring where user is a participant
  Stream<List<SparringModel>> getJoinedSparring(String userId) {
    return _db
        .collection("sparring")
        .where("participantList", arrayContains: userId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => SparringModel.fromMap(d.data())).toList(),
        );
  }
}
