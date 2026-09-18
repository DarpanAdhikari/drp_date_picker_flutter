import 'package:flutter/widgets.dart';

import 'bs_date.dart';
import 'drp_event.dart';

/// A holiday displayed inside the calendar.
///
/// This is a thin, backward-compatible subclass of [DrpCalendarEvent] that
/// always creates a `holiday`-typed event. It is kept so that code written
/// against the original `holidays:` API keeps working unchanged.
///
/// Holiday/event dates are always specified in the **Bikram Sambat (BS)**
/// calendar, regardless of the picker's primary `type`.
///
/// Use [DrpCalendarEvent] directly when you need other event types
/// (festivals, deadlines, bookings, etc.).
class DrpHoliday extends DrpCalendarEvent {
  const DrpHoliday({required super.date, super.title, super.color})
    : super(type: DrpEventType.holiday);

  /// Convenience constructor from raw BS parts.
  factory DrpHoliday.from(
    int year,
    int month,
    int date, {
    String? title,
    Color? color,
  }) => DrpHoliday(date: BsDate(year, month, date), title: title, color: color);

  @override
  String toString() =>
      'DrpHoliday(${date.iso}${title != null ? ', $title' : ''})';
}
