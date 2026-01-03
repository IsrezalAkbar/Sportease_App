import 'package:cloud_firestore/cloud_firestore.dart';

class FieldRatingModel {
  final String ratingId;
  final String fieldId;
  final String userId;
  final double rating;
  final String comment;
  final Timestamp createdAt;

  FieldRatingModel({
    required this.ratingId,
    required this.fieldId,
    required this.userId,
    required this.rating,
    required this.comment,
    required this.createdAt,
  });

  factory FieldRatingModel.fromMap(Map<String, dynamic> map) =>
      FieldRatingModel(
        ratingId: map['ratingId'] as String,
        fieldId: map['fieldId'] as String,
        userId: map['userId'] as String,
        rating: (map['rating'] as num).toDouble(),
        comment: map['comment'] as String? ?? '',
        createdAt: map['createdAt'] as Timestamp,
      );

  Map<String, dynamic> toMap() => {
    'ratingId': ratingId,
    'fieldId': fieldId,
    'userId': userId,
    'rating': rating,
    'comment': comment,
    'createdAt': createdAt,
  };
}
