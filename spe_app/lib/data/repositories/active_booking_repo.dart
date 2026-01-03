import '../datasources/firestore_active_booking_ds.dart';
import '../models/active_booking_model.dart';

class ActiveBookingRepo {
  final _ds = ActiveBookingDataSource();

  Stream<List<ActiveBookingModel>> activeForFieldOnDateStream({
    required String fieldId,
    required DateTime date,
  }) => _ds.activeForFieldOnDateStream(lapanganId: fieldId, date: date);

  Future<List<ActiveBookingModel>> activeForFieldOnDate({
    required String fieldId,
    required DateTime date,
  }) => _ds.activeForFieldOnDate(lapanganId: fieldId, date: date);

  Future<bool> isSlotAvailable({
    required String fieldId,
    required DateTime startAt,
    required DateTime endAt,
  }) => _ds.isSlotAvailable(
    lapanganId: fieldId,
    newStart: startAt,
    newEnd: endAt,
  );

  Future<void> create(ActiveBookingModel model) => _ds.create(model);
}
