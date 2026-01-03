import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/community_model.dart';
import '../models/field_rating_model.dart';

class FieldCommunityAndRatingDataSource {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get all communities for a specific field
  Stream<List<CommunityModel>> communitiesForFieldStream(String fieldId) {
    return _firestore
        .collection('communities')
        .where('fieldId', isEqualTo: fieldId)
        .where('isApproved', isEqualTo: true)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => CommunityModel.fromMap(doc.data()))
              .toList();
        });
  }

  /// Get ratings for a specific field
  Stream<List<FieldRatingModel>> ratingsForFieldStream(String fieldId) {
    return _firestore
        .collection('field_ratings')
        .where('fieldId', isEqualTo: fieldId)
        .snapshots()
        .map((snap) {
          return snap.docs
              .map((doc) => FieldRatingModel.fromMap(doc.data()))
              .toList();
        });
  }

  /// Get average rating for a field (non-stream)
  Future<double> getAverageRatingForField(String fieldId) async {
    final snap = await _firestore
        .collection('field_ratings')
        .where('fieldId', isEqualTo: fieldId)
        .get();

    if (snap.docs.isEmpty) return 0.0;

    final ratings = snap.docs
        .map((doc) => (doc.data()['rating'] as num).toDouble())
        .toList();

    final avg = ratings.fold<double>(0, (sum, r) => sum + r) / ratings.length;
    return double.parse(avg.toStringAsFixed(1));
  }

  /// Create a new rating
  Future<void> createRating({
    required String fieldId,
    required String userId,
    required double rating,
    required String comment,
  }) async {
    final ratingId = _firestore.collection('field_ratings').doc().id;

    await _firestore.collection('field_ratings').doc(ratingId).set({
      'ratingId': ratingId,
      'fieldId': fieldId,
      'userId': userId,
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Check if user already rated this field
  Future<FieldRatingModel?> getUserRatingForField(
    String fieldId,
    String userId,
  ) async {
    final snap = await _firestore
        .collection('field_ratings')
        .where('fieldId', isEqualTo: fieldId)
        .where('userId', isEqualTo: userId)
        .limit(1)
        .get();

    if (snap.docs.isEmpty) return null;
    return FieldRatingModel.fromMap(snap.docs.first.data());
  }

  /// Update existing rating
  Future<void> updateRating({
    required String ratingId,
    required double rating,
    required String comment,
  }) async {
    await _firestore.collection('field_ratings').doc(ratingId).update({
      'rating': rating,
      'comment': comment,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }
}
