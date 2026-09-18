import 'package:flutter/widgets.dart';

import 'bs_date.dart';

/// The type/category of a calendar event. Used to style events differently
/// and to distinguish holidays from other markers.
enum DrpEventType {
  /// A public or cultural holiday (e.g. Dashain, Tihar, Nepali New Year).
  holiday,

  /// A festival or celebration.
  festival,

  /// A general event (meeting, booking, deadline, etc.).
  event,

  /// A deadline or due date.
  deadline,

  /// A custom event type not covered by the predefined categories.
  custom,
}

/// A general calendar event displayed inside the calendar.
///
/// Events are always specified in the **Bikram Sambat (BS)** calendar,
/// regardless of the picker's primary `type`. This mirrors the canonical
/// behaviour of the reference `drp-datepicker` package.
///
/// Events are developer-provided — no built-in list is assumed. Pass an
/// arbitrary number of [DrpCalendarEvent] instances to the picker via its
/// `events` parameter (the older `holidays` parameter still works and simply
/// supplies `holiday`-typed events).
///
/// See also [DrpHoliday], a thin subclass that keeps the legacy API working.
class DrpCalendarEvent {
  /// The BS date this event falls on.
  final BsDate date;

  /// Optional title shown in a tooltip and alongside the day.
  final String? title;

  /// Optional accent colour for this event's marker.
  ///
  /// If null, the picker theme's event/holiday colour is used.
  final Color? color;

  /// The category of this event. Defaults to [DrpEventType.holiday].
  final DrpEventType type;

  /// Optional icon for the event.
  final IconData? icon;

  const DrpCalendarEvent({
    required this.date,
    this.title,
    this.color,
    this.type = DrpEventType.holiday,
    this.icon,
  });

  /// Convenience constructor from raw BS parts.
  factory DrpCalendarEvent.from(
    int year,
    int month,
    int date, {
    String? title,
    Color? color,
    DrpEventType type = DrpEventType.holiday,
    IconData? icon,
  }) => DrpCalendarEvent(
    date: BsDate(year, month, date),
    title: title,
    color: color,
    type: type,
    icon: icon,
  );

  /// Whether this event is a holiday (i.e. its type is [DrpEventType.holiday]).
  bool get isHoliday => type == DrpEventType.holiday;

  @override
  bool operator ==(Object other) =>
      other is DrpCalendarEvent &&
      other.date == date &&
      other.title == title &&
      other.color == color &&
      other.type == type &&
      other.icon == icon;

  @override
  int get hashCode => Object.hash(date, title, color, type, icon);

  @override
  String toString() =>
      'DrpCalendarEvent(${date.iso}, ${type.name}'
      '${title != null ? ', $title' : ''})';
}
