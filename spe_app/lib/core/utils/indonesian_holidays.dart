class IndonesianHolidays {
  static final Map<DateTime, String> holidays2025 = {
    DateTime(2025, 1, 1): 'Tahun Baru Masehi',
    DateTime(2025, 1, 29): 'Tahun Baru Imlek',
    DateTime(2025, 3, 29): 'Hari Raya Nyepi',
    DateTime(2025, 3, 31): 'Isra Mikraj',
    DateTime(2025, 4, 18): 'Wafat Yesus Kristus',
    DateTime(2025, 5, 1): 'Hari Buruh',
    DateTime(2025, 5, 12): 'Kenaikan Yesus Kristus',
    DateTime(2025, 5, 29): 'Hari Raya Waisak',
    DateTime(2025, 6, 1): 'Hari Lahir Pancasila',
    DateTime(2025, 6, 5): 'Idul Adha',
    DateTime(2025, 6, 26): 'Tahun Baru Hijriah',
    DateTime(2025, 8, 17): 'Hari Kemerdekaan RI',
    DateTime(2025, 9, 5): 'Maulid Nabi Muhammad',
    DateTime(2025, 12, 25): 'Hari Raya Natal',
  };

  static final Map<DateTime, String> holidays2026 = {
    DateTime(2026, 1, 1): 'Tahun Baru Masehi',
    DateTime(2026, 2, 17): 'Tahun Baru Imlek',
    DateTime(2026, 3, 19): 'Hari Raya Nyepi',
    DateTime(2026, 3, 20): 'Isra Mikraj',
    DateTime(2026, 4, 3): 'Wafat Yesus Kristus',
    DateTime(2026, 5, 1): 'Hari Buruh',
    DateTime(2026, 5, 14): 'Kenaikan Yesus Kristus',
    DateTime(2026, 5, 18): 'Hari Raya Waisak',
    DateTime(2026, 5, 25): 'Idul Adha',
    DateTime(2026, 6, 1): 'Hari Lahir Pancasila',
    DateTime(2026, 6, 15): 'Tahun Baru Hijriah',
    DateTime(2026, 8, 17): 'Hari Kemerdekaan RI',
    DateTime(2026, 8, 25): 'Maulid Nabi Muhammad',
    DateTime(2026, 12, 25): 'Hari Raya Natal',
  };

  static bool isHoliday(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return holidays2025.containsKey(normalized) ||
        holidays2026.containsKey(normalized);
  }

  static bool isSunday(DateTime date) {
    return date.weekday == DateTime.sunday;
  }

  static bool isRedDay(DateTime date) {
    return isHoliday(date) || isSunday(date);
  }

  static String? getHolidayName(DateTime date) {
    final normalized = DateTime(date.year, date.month, date.day);
    return holidays2025[normalized] ?? holidays2026[normalized];
  }
}
