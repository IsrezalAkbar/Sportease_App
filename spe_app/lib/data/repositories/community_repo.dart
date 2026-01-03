import '../datasources/firestore_community_ds.dart';
import '../models/community_model.dart';

class CommunityRepo {
  final _ds = CommunityDataSource();

  Stream<List<CommunityModel>> get communities => _ds.getApprovedCommunities();

  Future<void> create(CommunityModel m) => _ds.createCommunity(m);

  Future<void> join(String uid, String cid) => _ds.joinCommunity(uid, cid);

  Future<void> approve(String cid) => _ds.approveCommunity(cid);

  Stream<List<CommunityModel>> getByCreator(String creatorId) =>
      _ds.getCommunitiesByCreator(creatorId);

  /// Get communities where user is a member
  Stream<List<CommunityModel>> getJoinedCommunities(String userId) =>
      _ds.getJoinedCommunities(userId);
}
