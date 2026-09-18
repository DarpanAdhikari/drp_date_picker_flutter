import 'bs_date.dart';
import 'drp_event.dart';

/// A single day in a rendered calendar month, carrying both the BS and AD
/// dates plus rendering flags. This is what the grid renders.
class DrpCalendarDay {
  final BsDate bsDate;
  final AdDate adDate;

  /// Weekday 1 = Sunday ... 7 = Saturday.
  final int weekday;

  /// Whether this day is today.
  final bool isToday;

  /// The calendar events on this day (holidays, festivals, deadlines, ...).
  final List<DrpCalendarEvent> events;

  const DrpCalendarDay({
    required this.bsDate,
    required this.adDate,
    required this.weekday,
    required this.isToday,
    this.events = const [],
  });

  /// Whether this day matches a provided holiday.
  bool get isHoliday => events.any((e) => e.isHoliday);

  /// The first event's title if any event is present, otherwise null.
  /// Kept for backward compatibility with the original `holidayTitle` field.
  String? get holidayTitle => events.isNotEmpty ? events.first.title : null;

  /// The full weekday name (1 = Sunday).
  String get weekdayName {
    const names = [
      '',
      'Sunday',
      'Monday',
      'Tuesday',
      'Wednesday',
      'Thursday',
      'Friday',
      'Saturday',
    ];
    return names[weekday];
  }

  bool get isSaturday => weekday == 7;

  @override
  String toString() =>
      'DrpCalendarDay(bs=${bsDate.iso}, ad=${adDate.iso}, '
      'events=${events.length})';
}
