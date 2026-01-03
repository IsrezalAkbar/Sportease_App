import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/field_model.dart';

class FieldDataSource {
  final _db = FirebaseFirestore.instance;

  Stream<List<FieldModel>> getApprovedFields() {
    return _db
        .collection("fields")
        .where("isApproved", isEqualTo: true)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => FieldModel.fromMap(d.data())).toList(),
        );
  }

  Stream<List<FieldModel>> getAllFields() {
    return _db
        .collection("fields")
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => FieldModel.fromMap(d.data())).toList(),
        );
  }

  /// New: dynamic query with search + facilities + price range
  Stream<List<FieldModel>> queryFields({
    String? searchQuery,
    List<String>? facilities,
    int? minPrice,
    int? maxPrice,
  }) {
    Query q = _db.collection("fields").where("isApproved", isEqualTo: true);

    if (searchQuery != null && searchQuery.trim().isNotEmpty) {
      // naive approach: search by name (prefix). For more advanced search use Algolia.
      q = q
          .where("name", isGreaterThanOrEqualTo: searchQuery)
          .where("name", isLessThanOrEqualTo: "$searchQuery\uf8ff");
    }

    if (minPrice != null) {
      q = q.where("pricePerHour", isGreaterThanOrEqualTo: minPrice);
    }
    if (maxPrice != null) {
      q = q.where("pricePerHour", isLessThanOrEqualTo: maxPrice);
    }

    // For facility filters we can't query multiple "array-contains" simultaneously easily.
    // We'll fetch results and filter client-side when `facilities` provided.
    return q.snapshots().map((snap) {
      final list = snap.docs
          .map((d) => FieldModel.fromMap(d.data() as Map<String, dynamic>))
          .toList();
      if (facilities != null && facilities.isNotEmpty) {
        return list
            .where(
              (f) => facilities.every((fac) => f.facilityList.contains(fac)),
            )
            .toList();
      }
      return list;
    });
  }

  Future<void> createField(FieldModel model) async {
    await _db.collection("fields").doc(model.fieldId).set(model.toMap());
  }

  Future<void> updateField(FieldModel model) async {
    await _db.collection("fields").doc(model.fieldId).update(model.toMap());
  }

  Future<void> deleteField(String id) async {
    await _db.collection("fields").doc(id).delete();
  }

  Future<void> approveField(String id) async {
    await _db.collection("fields").doc(id).update({"isApproved": true});
  }

  Stream<List<FieldModel>> getFieldsByOwner(String ownerId) {
    return _db
        .collection("fields")
        .where("ownerId", isEqualTo: ownerId)
        .snapshots()
        .map(
          (snap) => snap.docs.map((d) => FieldModel.fromMap(d.data())).toList(),
        );
  }

  Future<bool> hasApprovedField(String ownerId) async {
    final snapshot = await _db
        .collection("fields")
        .where("ownerId", isEqualTo: ownerId)
        .where("isApproved", isEqualTo: true)
        .limit(1)
        .get();
    return snapshot.docs.isNotEmpty;
  }
}
