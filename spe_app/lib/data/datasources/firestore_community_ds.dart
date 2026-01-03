import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_model.dart';

class CommunityDataSource {
  final _db = FirebaseFirestore.instance;

  Stream<List<CommunityModel>> getApprovedCommunities() {
    return _db
        .collection("communities")
        .where("isApproved", isEqualTo: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => CommunityModel.fromMap(d.data())).toList(),
        );
  }

  Future<void> createCommunity(CommunityModel model) async {
    await _db
        .collection("communities")
        .doc(model.communityId)
        .set(model.toMap());
  }

  Future<void> joinCommunity(String uid, String communityId) async {
    await _db.runTransaction((txn) async {
      final ref = _db.collection("communities").doc(communityId);
      final snap = await txn.get(ref);
      if (!snap.exists) {
        throw Exception('Komunitas tidak ditemukan');
      }

      final data = snap.data() as Map<String, dynamic>;
      final members = List<String>.from(data['memberList'] ?? []);

      if (members.contains(uid)) {
        return; // sudah join, no-op
      }

      if (members.length >= 50) {
        throw Exception('Komunitas sudah penuh (50 anggota)');
      }

      members.add(uid);
      txn.update(ref, {'memberList': members});
    });
  }

  Future<void> approveCommunity(String id) async {
    await _db.collection("communities").doc(id).update({"isApproved": true});
  }

  Stream<List<CommunityModel>> getCommunitiesByCreator(String creatorId) {
    return _db
        .collection("communities")
        .where("createdBy", isEqualTo: creatorId)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => CommunityModel.fromMap(d.data())).toList(),
        );
  }

  Future<void> updateCommunity(CommunityModel model) async {
    await _db
        .collection("communities")
        .doc(model.communityId)
        .update(model.toMap());
  }

  Future<void> deleteCommunity(String id) async {
    await _db.collection("communities").doc(id).delete();
  }

  /// Get communities where user is a member
  Stream<List<CommunityModel>> getJoinedCommunities(String userId) {
    return _db
        .collection("communities")
        .where("memberList", arrayContains: userId)
        .where("isApproved", isEqualTo: true)
        .snapshots()
        .map(
          (snap) =>
              snap.docs.map((d) => CommunityModel.fromMap(d.data())).toList(),
        );
  }
}
