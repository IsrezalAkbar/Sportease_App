import 'package:cloud_firestore/cloud_firestore.dart';

import '../models/active_booking_model.dart';
import '../models/booking_model.dart';

class ActiveBookingDataSource {
  final _db = FirebaseFirestore.instance;
  CollectionReference<Map<String, dynamic>> get _col =>
      _db.collection('bookings');

  /// Create a new booking document with status 'active'.
  /// Note: legacy method, prefer creating BookingModel via BookingDataSource.
  Future<void> create(ActiveBookingModel model) async {
    await _col.doc(model.bookingId).set(model.toMap());
  }

  /// Query active bookings for a particular field and date.
  /// Spark-friendly: equality filters + single range on endAt to ignore expired.
  Stream<List<ActiveBookingModel>> activeForFieldOnDateStream({
    required String lapanganId,
    required DateTime date,
  }) {
    final now = DateTime.now();
    final dateKey = ActiveBookingModel.buildDateKey(date);
    final q = _col
        .where('fieldId', isEqualTo: lapanganId)
        .where('dateKey', isEqualTo: dateKey)
        .where('paymentStatus', whereIn: ['pending', 'paid']);

    return q.snapshots().map((snap) {
      return snap.docs
          .map((d) {
            final data = d.data();
            final booking = BookingModel.fromMap(data);
            if (booking.paymentStatus == 'pending') {
              final exp = booking.holdExpiresAt;
              if (exp != null && exp.isBefore(now)) return null;
            }
            final slotStart = _slotStart(booking.date, booking.time);
            final slotEnd = slotStart.add(const Duration(hours: 1));
            return ActiveBookingModel(
              bookingId: booking.bookingId,
              lapanganId: booking.fieldId,
              userId: booking.userId,
              startAt: slotStart,
              endAt: slotEnd,
              status: booking.paymentStatus,
              dateKey: booking.dateKey,
              createdAt: booking.createdAt,
            );
          })
          .whereType<ActiveBookingModel>()
          .toList();
    });
  }

  Future<List<ActiveBookingModel>> activeForFieldOnDate({
    required String lapanganId,
    required DateTime date,
  }) async {
    final now = DateTime.now();
    final dateKey = ActiveBookingModel.buildDateKey(date);
    final snap = await _col
        .where('fieldId', isEqualTo: lapanganId)
        .where('dateKey', isEqualTo: dateKey)
        .where('paymentStatus', whereIn: ['pending', 'paid'])
        .get();

    return snap.docs
        .map((d) {
          final booking = BookingModel.fromMap(d.data());
          if (booking.paymentStatus == 'pending') {
            final exp = booking.holdExpiresAt;
            if (exp != null && exp.isBefore(now)) return null;
          }
          final slotStart = _slotStart(booking.date, booking.time);
          final slotEnd = slotStart.add(const Duration(hours: 1));
          return ActiveBookingModel(
            bookingId: booking.bookingId,
            lapanganId: booking.fieldId,
            userId: booking.userId,
            startAt: slotStart,
            endAt: slotEnd,
            status: booking.paymentStatus,
            dateKey: booking.dateKey,
            createdAt: booking.createdAt,
          );
        })
        .whereType<ActiveBookingModel>()
        .toList();
  }

  /// Validation for anti-double booking.
  /// Fetch bookings that could overlap using a single range on `startAt` (< newEnd),
  /// then apply logical overlap on client: newStart < existingEnd && newEnd > existingStart.
  Future<bool> isSlotAvailable({
    required String lapanganId,
    required DateTime newStart,
    required DateTime newEnd,
  }) async {
    final now = DateTime.now();
    final dateKey = ActiveBookingModel.buildDateKey(newStart);

    final snap = await _col
        .where('fieldId', isEqualTo: lapanganId)
        .where('dateKey', isEqualTo: dateKey)
        .where('paymentStatus', whereIn: ['pending', 'paid'])
        .get();

    final existing = snap.docs.map((d) => BookingModel.fromMap(d.data()));

    for (final b in existing) {
      if (b.paymentStatus == 'pending') {
        final exp = b.holdExpiresAt;
        if (exp != null && exp.isBefore(now)) continue;
      }
      final start = _slotStart(b.date, b.time);
      final end = start.add(const Duration(hours: 1));
      final overlaps = newStart.isBefore(end) && newEnd.isAfter(start);
      if (overlaps) return false;
    }
    return true;
  }

  DateTime _slotStart(DateTime date, String timeRange) {
    try {
      final parts = timeRange.split(' - ');
      final startParts = parts.first.split(':');
      final hour = int.parse(startParts[0]);
      final minute = int.parse(startParts[1]);
      return DateTime(date.year, date.month, date.day, hour, minute);
    } catch (_) {
      return DateTime(date.year, date.month, date.day, 0, 0);
    }
  }
}
