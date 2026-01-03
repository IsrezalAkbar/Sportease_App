import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/booking_providers.dart';
import '../../../router/app_router.dart';
import '../../../data/repositories/active_booking_repo.dart';
import '../../../core/utils/indonesian_holidays.dart';
import '../../../core/utils/booking_cleanup.dart';
import '../../../data/repositories/field_community_rating_repo.dart';

class BookingPage extends ConsumerWidget {
  const BookingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final field = args == null
        ? null
        : _FieldItem(
            id: args['id'] as String,
            name: args['name'] as String,
            address: args['address'] as String,
            pricePerHour: args['pricePerHour'] as int,
            image: args['image'] as String,
          );

    final bookingState = ref.watch(bookingProvider);
    final controller = ref.read(bookingProvider.notifier);

    const primary = Color(0xFF8D153A);

    if (field != null && bookingState.selectedFieldId != field.id) {
      Future.microtask(
        () => controller.selectField(
          fieldId: field.id,
          pricePerHour: field.pricePerHour,
        ),
      );
    }

    final today = DateTime.now();
    final dates = List.generate(
      7,
      (i) => DateTime(today.year, today.month, today.day + i),
    );
    final selectedDate = bookingState.focusedDate ?? dates.first;

    if (bookingState.focusedDate == null) {
      Future.microtask(() => controller.chooseDate(selectedDate));
    }

    // Clean up expired bookings when page loads
    Future.microtask(() => BookingCleanup.expireOldPendingBookings());

    final timeSlots = <String>[
      '06:00 - 07:00',
      '07:00 - 08:00',
      '08:00 - 09:00',
      '09:00 - 10:00',
      '10:00 - 11:00',
      '11:00 - 12:00',
      '12:00 - 13:00',
      '13:00 - 14:00',
      '14:00 - 15:00',
      '15:00 - 16:00',
      '16:00 - 17:00',
      '17:00 - 18:00',
      '18:00 - 19:00',
      '19:00 - 20:00',
      '20:00 - 21:00',
      '21:00 - 22:00',
      '22:00 - 23:00',
      '23:00 - 00:00',
    ];

    final activeRepo = ActiveBookingRepo();
    final communityRepo = FieldCommunityAndRatingRepo();

    final totalPrice = bookingState.selectedSlots.fold<int>(
      0,
      (sum, slot) => sum + slot.price,
    );
    final selectedCount = bookingState.selectedSlots.length;
    final selectedField = field;

    return Scaffold(
      backgroundColor: const Color(0xFFF8F9FA),
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        centerTitle: true,
        elevation: 0,
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [primary, primary.withOpacity(0.8)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        title: Text(
          selectedField?.name ?? 'Pilih Lapangan',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
      ),
      body: field == null
          ? Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text('Pilih lapangan terlebih dahulu'),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () => Navigator.pushReplacementNamed(
                      context,
                      AppRouter.fieldList,
                    ),
                    child: const Text('Ke daftar lapangan'),
                  ),
                ],
              ),
            )
          : Column(
              children: [
                _FieldHeader(field: field, primary: primary),
                const Divider(height: 1),
                Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 6,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: _DateSelector(
                          dates: dates,
                          selected: selectedDate,
                          onSelect: controller.chooseDate,
                          primary: primary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.calendar_month, size: 24),
                        tooltip: 'Pilih dari kalender',
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                        onPressed: () async {
                          final picked = await showDatePicker(
                            context: context,
                            initialDate: selectedDate,
                            firstDate: today,
                            lastDate: today.add(const Duration(days: 90)),
                            locale: const Locale('id', 'ID'),
                            builder: (context, child) {
                              return Theme(
                                data: Theme.of(context).copyWith(
                                  colorScheme: ColorScheme.light(
                                    primary: primary,
                                    onPrimary: Colors.white,
                                  ),
                                  textButtonTheme: TextButtonThemeData(
                                    style: TextButton.styleFrom(
                                      foregroundColor: primary,
                                    ),
                                  ),
                                ),
                                child: child!,
                              );
                            },
                          );
                          if (picked != null) {
                            controller.chooseDate(picked);
                          }
                        },
                      ),
                    ],
                  ),
                ),
                const Divider(height: 1),
                Expanded(
                  child: StreamBuilder(
                    stream: activeRepo.activeForFieldOnDateStream(
                      fieldId: field.id,
                      date: selectedDate,
                    ),
                    builder: (context, snapshot) {
                      final active = snapshot.data ?? const [];

                      return StreamBuilder(
                        stream: communityRepo.communitiesForField(field.id),
                        builder: (context, commSnap) {
                          final communities = commSnap.data ?? const [];

                          bool slotUnavailable(String slot) {
                            final parts = slot.split(' - ');
                            final startHour = int.parse(parts[0].split(':')[0]);
                            final start = DateTime(
                              selectedDate.year,
                              selectedDate.month,
                              selectedDate.day,
                              startHour,
                            );
                            final end = start.add(const Duration(hours: 1));

                            // Check if slot is in the past
                            final now = DateTime.now();
                            if (end.isBefore(now) || start.isBefore(now)) {
                              return true;
                            }

                            // Check booking conflicts
                            for (final b in active) {
                              if (start.isBefore(b.endAt) &&
                                  end.isAfter(b.startAt)) {
                                return true;
                              }
                            }

                            // Check weekly community schedule blocks
                            final weekday = selectedDate.weekday; // 1..7
                            for (final c in communities) {
                              if (c.weeklyWeekday == null ||
                                  c.weeklyStart == null ||
                                  c.weeklyEnd == null)
                                continue;
                              if (c.weeklyWeekday != weekday) continue;
                              try {
                                final startParts = (c.weeklyStart!).split(':');
                                final endParts = (c.weeklyEnd!).split(':');
                                final blockStart = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  int.parse(startParts[0]),
                                  int.parse(startParts[1]),
                                );
                                final blockEnd = DateTime(
                                  selectedDate.year,
                                  selectedDate.month,
                                  selectedDate.day,
                                  int.parse(endParts[0]),
                                  int.parse(endParts[1]),
                                );
                                if (start.isBefore(blockEnd) &&
                                    end.isAfter(blockStart)) {
                                  return true;
                                }
                              } catch (_) {}
                            }

                            return false;
                          }

                          return ListView.builder(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            itemCount: timeSlots.length,
                            itemBuilder: (context, index) {
                              final slot = timeSlots[index];
                              final isUnavailable = slotUnavailable(slot);
                              final isSelected = bookingState.selectedSlots.any(
                                (s) =>
                                    _isSameDay(s.date, selectedDate) &&
                                    s.time == slot,
                              );
                              final bgColor = isUnavailable
                                  ? Colors.grey[200]
                                  : isSelected
                                  ? primary.withOpacity(0.12)
                                  : Colors.white;
                              final borderColor = isUnavailable
                                  ? Colors.grey[300]!
                                  : isSelected
                                  ? primary.withOpacity(0.4)
                                  : Colors.grey[300]!;

                              return Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                  vertical: 6,
                                ),
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(14),
                                  onTap: isUnavailable
                                      ? null
                                      : () {
                                          controller.toggleSlot(
                                            selectedDate,
                                            slot,
                                          );
                                        },
                                  child: Container(
                                    decoration: BoxDecoration(
                                      gradient: isSelected
                                          ? LinearGradient(
                                              colors: [
                                                primary,
                                                primary.withOpacity(0.85),
                                              ],
                                              begin: Alignment.topLeft,
                                              end: Alignment.bottomRight,
                                            )
                                          : null,
                                      color: isSelected ? null : bgColor,
                                      borderRadius: BorderRadius.circular(14),
                                      border: Border.all(
                                        color: isSelected
                                            ? primary
                                            : borderColor,
                                        width: isSelected ? 2 : 1,
                                      ),
                                      boxShadow: isSelected
                                          ? [
                                              BoxShadow(
                                                color: primary.withOpacity(0.3),
                                                blurRadius: 8,
                                                offset: const Offset(0, 3),
                                              ),
                                            ]
                                          : null,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 16,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Row(
                                          children: [
                                            if (isUnavailable) ...[
                                              const Icon(
                                                Icons.lock_clock,
                                                size: 18,
                                                color: Colors.grey,
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                            Text(
                                              slot,
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: isUnavailable
                                                    ? Colors.grey
                                                    : isSelected
                                                    ? Colors.white
                                                    : Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Row(
                                          children: [
                                            Text(
                                              bookingState.pricePerHour == 0
                                                  ? '-'
                                                  : _formatRupiah(
                                                      bookingState.pricePerHour,
                                                    ),
                                              style: TextStyle(
                                                fontSize: 15,
                                                fontWeight: FontWeight.w700,
                                                color: isUnavailable
                                                    ? Colors.grey
                                                    : isSelected
                                                    ? Colors.white
                                                    : primary,
                                              ),
                                            ),
                                            if (isSelected) ...[
                                              const SizedBox(width: 8),
                                              const Icon(
                                                Icons.check_circle,
                                                color: Colors.white,
                                                size: 20,
                                              ),
                                            ],
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              );
                            },
                          );
                        },
                      );
                    },
                  ),
                ),
                if (bookingState.selectedSlots.isNotEmpty)
                  _BottomSummary(
                    total: totalPrice,
                    count: selectedCount,
                    primary: primary,
                    onNext: () {
                      Navigator.pushNamed(
                        context,
                        AppRouter.reviewOrder,
                        arguments: {
                          'fieldId': field.id,
                          'fieldName': field.name,
                          'fieldAddress': field.address,
                          'fieldImage': field.image,
                          'fieldLocation': field.address,
                          'total': totalPrice,
                          'slots': bookingState.selectedSlots
                              .map(
                                (s) => {
                                  'date': s.date.toIso8601String(),
                                  'time': s.time,
                                  'price': s.price,
                                },
                              )
                              .toList(),
                          if (args?['sparringId'] != null)
                            'sparringId': args!['sparringId'],
                        },
                      );
                    },
                  ),
              ],
            ),
    );
  }
}

class _FieldItem {
  final String id;
  final String name;
  final String address;
  final int pricePerHour;
  final String image;

  const _FieldItem({
    required this.id,
    required this.name,
    required this.address,
    required this.pricePerHour,
    required this.image,
  });
}

class _FieldHeader extends StatelessWidget {
  const _FieldHeader({required this.field, required this.primary});

  final _FieldItem field;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 12, 8, 8),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.08),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: primary.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: Image.network(
                field.image,
                width: 80,
                height: 80,
                fit: BoxFit.cover,
                errorBuilder: (_, __, ___) => Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [
                        primary.withOpacity(0.3),
                        primary.withOpacity(0.1),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Icon(Icons.sports_soccer, color: primary, size: 32),
                ),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  field.name,
                  style: const TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Colors.black87,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Icon(Icons.location_on, size: 14, color: Colors.grey[600]),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        field.address,
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [primary, primary.withOpacity(0.8)],
                    ),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    'Rp${_formatRupiah(field.pricePerHour)}/jam',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          ElevatedButton(
            onPressed: () {
              Navigator.pushReplacementNamed(context, AppRouter.fieldList);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: primary,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(10),
                side: BorderSide(color: primary),
              ),
            ),
            child: const Text(
              'Ganti',
              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _DateSelector extends StatelessWidget {
  const _DateSelector({
    required this.dates,
    required this.selected,
    required this.onSelect,
    required this.primary,
  });

  final List<DateTime> dates;
  final DateTime? selected;
  final void Function(DateTime) onSelect;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    const weekdays = ['Min', 'Sen', 'Sel', 'Rab', 'Kam', 'Jum', 'Sab'];

    return SizedBox(
      height: 95,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        itemBuilder: (context, index) {
          final date = dates[index];
          final isSelected = selected != null && _isSameDay(date, selected!);
          final isRedDay = IndonesianHolidays.isRedDay(date);
          final holidayName = IndonesianHolidays.getHolidayName(date);

          return InkWell(
            borderRadius: BorderRadius.circular(10),
            onTap: () => onSelect(date),
            child: Container(
              width: 64,
              decoration: BoxDecoration(
                color: isSelected ? primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isSelected
                      ? primary
                      : isRedDay
                      ? Colors.red.shade300
                      : Colors.grey[300]!,
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              padding: const EdgeInsets.symmetric(vertical: 6),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  if (index == 0)
                    Icon(
                      Icons.calendar_today_outlined,
                      color: isSelected ? Colors.white : Colors.black54,
                      size: 22,
                    )
                  else ...[
                    Text(
                      weekdays[date.weekday % 7],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isRedDay
                            ? Colors.red
                            : Colors.black54,
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      date.day.toString().padLeft(2, '0'),
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isRedDay
                            ? Colors.red
                            : Colors.black87,
                        fontSize: 16,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      [
                        'Jan',
                        'Feb',
                        'Mar',
                        'Apr',
                        'Mei',
                        'Jun',
                        'Jul',
                        'Agu',
                        'Sep',
                        'Okt',
                        'Nov',
                        'Des',
                      ][date.month - 1],
                      style: TextStyle(
                        color: isSelected
                            ? Colors.white
                            : isRedDay
                            ? Colors.red
                            : Colors.black54,
                        fontSize: 11,
                      ),
                    ),
                  ],
                  if (holidayName != null && index != 0)
                    Padding(
                      padding: const EdgeInsets.only(top: 1),
                      child: Icon(
                        Icons.celebration,
                        size: 10,
                        color: isSelected ? Colors.white : Colors.red,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
        separatorBuilder: (_, __) => const SizedBox(width: 10),
        itemCount: dates.length,
      ),
    );
  }

  bool _isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}

class _BottomSummary extends StatelessWidget {
  const _BottomSummary({
    required this.total,
    required this.count,
    required this.primary,
    required this.onNext,
  });

  final int total;
  final int count;
  final Color primary;
  final VoidCallback? onNext;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 12,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Total Biaya',
                        style: TextStyle(color: Colors.black54, fontSize: 12),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        total == 0 ? 'Rp0' : 'Rp${_formatRupiah(total)}',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w700,
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  Text(
                    count == 0 ? '0 jadwal dipilih' : '$count jadwal dipilih',
                    style: const TextStyle(color: Colors.black54, fontSize: 12),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              SizedBox(
                width: double.infinity,
                height: 46,
                child: ElevatedButton(
                  onPressed: onNext,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: primary,
                    disabledBackgroundColor: Colors.grey[300],
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: const Text(
                    'Selanjutnya',
                    style: TextStyle(fontWeight: FontWeight.w700, fontSize: 15),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

bool _isSameDay(DateTime a, DateTime b) {
  return a.year == b.year && a.month == b.month && a.day == b.day;
}

String _formatRupiah(int value) {
  final buffer = StringBuffer();
  final chars = value.toString().split('').reversed.toList();
  for (int i = 0; i < chars.length; i++) {
    if (i != 0 && i % 3 == 0) buffer.write('.');
    buffer.write(chars[i]);
  }
  return buffer.toString().split('').reversed.join();
}
