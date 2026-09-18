import '../converters/bs_data.dart';

/// A date in the Bikram Sambat (BS / Nepali) calendar.
///
/// Months are 1-12, days 1-32 (BS months may have up to 32 days).
class BsDate {
  final int year;
  final int month;
  final int date;

  const BsDate(this.year, this.month, this.date);

  /// The BS month name, e.g. `'Jestha'`.
  String get monthName => nepaliMonths[month];

  /// The BS month name in Devanagari, e.g. `'जेठ'`.
  String get monthNameNe => nepaliMonthsNe[month];

  /// The number of days in this BS month.
  int get daysInMonth => bsData[year - bsYearMin][month];

  /// `'YYYY-MM-DD'` string with zero-padded month and day.
  String get iso =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${date.toString().padLeft(2, '0')}';

  /// Whether this date is within the supported BS range.
  bool get isValid =>
      year >= bsYearMin &&
      year <= bsYearMax &&
      month >= 1 &&
      month <= 12 &&
      date >= 1 &&
      date <= daysInMonth;

  @override
  bool operator ==(Object other) =>
      other is BsDate &&
      other.year == year &&
      other.month == month &&
      other.date == date;

  @override
  int get hashCode => Object.hash(year, month, date);

  @override
  String toString() => 'BsDate($year-$month-$date)';
}

/// A date in the Gregorian (AD / English) calendar.
class AdDate {
  final int year;
  final int month;
  final int date;

  const AdDate(this.year, this.month, this.date);

  /// Full English month name, e.g. `'June'`.
  String get monthName => englishMonthsFull[month];

  /// Short English month name, e.g. `'Jun'`.
  String get monthNameShort => englishMonths[month];

  /// `'YYYY-MM-DD'` string with zero-padded month and day.
  String get iso =>
      '${year.toString().padLeft(4, '0')}-'
      '${month.toString().padLeft(2, '0')}-'
      '${date.toString().padLeft(2, '0')}';

  @override
  bool operator ==(Object other) =>
      other is AdDate &&
      other.year == year &&
      other.month == month &&
      other.date == date;

  @override
  int get hashCode => Object.hash(year, month, date);

  @override
  String toString() => 'AdDate($year-$month-$date)';
}
