import 'package:cloud_firestore/cloud_firestore.dart';
import '../../data/repositories/booking_repo.dart';

/// Utility to clean up expired pending bookings
class BookingCleanup {
  static final _bookingRepo = BookingRepo();
  static final _firestore = FirebaseFirestore.instance;

  /// Expire all pending bookings whose holdExpiresAt has passed
  static Future<void> expireOldPendingBookings() async {
    try {
      final now = DateTime.now();

      // Query pending bookings with expired holds
      final snapshot = await _firestore
          .collection('bookings')
          .where('paymentStatus', isEqualTo: 'pending')
          .where('holdExpiresAt', isLessThan: Timestamp.fromDate(now))
          .get();

      for (final doc in snapshot.docs) {
        await _bookingRepo.updateStatus(doc.id, 'expired');
      }

      if (snapshot.docs.isNotEmpty) {
        print(
          'BookingCleanup: Expired ${snapshot.docs.length} old pending bookings',
        );
      }
    } catch (e) {
      print('BookingCleanup error: $e');
    }
  }
}
