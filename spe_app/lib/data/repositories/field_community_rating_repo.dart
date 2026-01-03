import '../datasources/field_community_rating_ds.dart';
import '../models/community_model.dart';
import '../models/field_rating_model.dart';

class FieldCommunityAndRatingRepo {
  final _ds = FieldCommunityAndRatingDataSource();

  Stream<List<CommunityModel>> communitiesForField(String fieldId) =>
      _ds.communitiesForFieldStream(fieldId);

  Stream<List<FieldRatingModel>> ratingsForField(String fieldId) =>
      _ds.ratingsForFieldStream(fieldId);

  Future<double> getAverageRating(String fieldId) =>
      _ds.getAverageRatingForField(fieldId);

  Future<void> createRating({
    required String fieldId,
    required String userId,
    required double rating,
    required String comment,
  }) => _ds.createRating(
    fieldId: fieldId,
    userId: userId,
    rating: rating,
    comment: comment,
  );

  Future<FieldRatingModel?> getUserRating(String fieldId, String userId) =>
      _ds.getUserRatingForField(fieldId, userId);

  Future<void> updateRating({
    required String ratingId,
    required double rating,
    required String comment,
  }) => _ds.updateRating(ratingId: ratingId, rating: rating, comment: comment);
}
