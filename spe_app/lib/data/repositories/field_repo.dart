import '../datasources/firestore_field_ds.dart';
import '../models/field_model.dart';

class FieldRepo {
  final _ds = FieldDataSource();

  Stream<List<FieldModel>> get fields => _ds.getApprovedFields();
  Stream<List<FieldModel>> get allFields => _ds.getAllFields();

  Stream<List<FieldModel>> queryFields({
    String? searchQuery,
    List<String>? facilities,
    int? minPrice,
    int? maxPrice,
  }) {
    return _ds.queryFields(
      searchQuery: searchQuery,
      facilities: facilities,
      minPrice: minPrice,
      maxPrice: maxPrice,
    );
  }

  Future<void> create(FieldModel m) => _ds.createField(m);
  Future<void> update(FieldModel m) => _ds.updateField(m);
  Future<void> delete(String id) => _ds.deleteField(id);
  Future<void> approve(String id) => _ds.approveField(id);
  Stream<List<FieldModel>> getByOwner(String ownerId) =>
      _ds.getFieldsByOwner(ownerId);
  Future<bool> hasApprovedField(String ownerId) =>
      _ds.hasApprovedField(ownerId);
}
