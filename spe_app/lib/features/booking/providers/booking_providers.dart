import 'package:flutter_riverpod/flutter_riverpod.dart';

class BookingSlot {
  final DateTime date;
  final String time;
  final int price;

  BookingSlot({required this.date, required this.time, required this.price});
}

class BookingState {
  final String? selectedFieldId;
  final DateTime? focusedDate;
  final List<BookingSlot> selectedSlots;
  final int pricePerHour;

  BookingState({
    this.selectedFieldId,
    this.focusedDate,
    this.selectedSlots = const [],
    required this.pricePerHour,
  });

  BookingState copyWith({
    String? selectedFieldId,
    DateTime? focusedDate,
    List<BookingSlot>? selectedSlots,
    int? pricePerHour,
  }) {
    return BookingState(
      selectedFieldId: selectedFieldId ?? this.selectedFieldId,
      focusedDate: focusedDate ?? this.focusedDate,
      selectedSlots: selectedSlots ?? this.selectedSlots,
      pricePerHour: pricePerHour ?? this.pricePerHour,
    );
  }
}

final bookingProvider = StateNotifierProvider<BookingController, BookingState>((
  ref,
) {
  return BookingController();
});

class BookingController extends StateNotifier<BookingState> {
  BookingController()
    : super(
        BookingState(
          selectedFieldId: null,
          focusedDate: null,
          selectedSlots: const [],
          pricePerHour: 0,
        ),
      );

  void selectField({required String fieldId, required int pricePerHour}) {
    state = BookingState(
      selectedFieldId: fieldId,
      focusedDate: state.focusedDate,
      selectedSlots: const [],
      pricePerHour: pricePerHour,
    );
  }

  void chooseDate(DateTime date) {
    state = state.copyWith(focusedDate: date);
  }

  void toggleSlot(DateTime date, String time) {
    final current = List<BookingSlot>.from(state.selectedSlots);
    final idx = current.indexWhere(
      (s) => _isSameDay(s.date, date) && s.time == time,
    );

    if (idx >= 0) {
      current.removeAt(idx);
    } else {
      current.add(
        BookingSlot(date: date, time: time, price: state.pricePerHour),
      );
    }

    state = state.copyWith(selectedSlots: current);
  }

  void reset() {
    state = BookingState(
      selectedFieldId: null,
      focusedDate: null,
      selectedSlots: const [],
      pricePerHour: 0,
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
