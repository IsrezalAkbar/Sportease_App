import '../datasources/firestore_booking_ds.dart';
import '../models/booking_model.dart';

class BookingRepo {
  final _ds = BookingDataSource();

  Stream<List<BookingModel>> getForUser(String uid) {
    return _ds.getUserBookings(uid);
  }

  Future<void> create(BookingModel m) => _ds.createBooking(m);

  Future<void> updateStatus(String id, String status) =>
      _ds.updatePaymentStatus(id, status);

  Future<void> updatePaymentSuccess({
    required String bookingId,
    required String paymentMethod,
    required DateTime paidAt,
  }) => _ds.updatePaymentSuccess(
    bookingId: bookingId,
    paymentMethod: paymentMethod,
    paidAt: paidAt,
  );

  Future<List<BookingModel>> getBookingsByInvoice({
    required String userId,
    required String invoiceId,
  }) => _ds.getBookingsByInvoice(userId: userId, invoiceId: invoiceId);
}
