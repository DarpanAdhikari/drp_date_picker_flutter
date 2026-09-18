import 'drp_calendar_day.dart';

/// A fully-built calendar month grid, ready for rendering.
class DrpCalendarMonth {
  /// 'bs' or 'ad' — which calendar drove this grid.
  final String system;

  final int year;
  final int month;

  /// Primary month name in the grid's system.
  final String monthName;

  /// Number of days in this (primary) month.
  final int daysInMonth;

  /// Weekday of the 1st of the month (1 = Sunday ... 7 = Saturday).
  final int startWeekday;

  /// Every day in the month, each with both BS and AD dates.
  final List<DrpCalendarDay> days;

  const DrpCalendarMonth({
    required this.system,
    required this.year,
    required this.month,
    required this.monthName,
    required this.daysInMonth,
    required this.startWeekday,
    required this.days,
  });

  /// Number of blank leading cells before day 1 (based on Sunday-first grid).
  int get leadingBlanks => startWeekday - 1;

  @override
  String toString() =>
      'DrpCalendarMonth(system=$system, $year-$month, '
      '${days.length} days)';
}
