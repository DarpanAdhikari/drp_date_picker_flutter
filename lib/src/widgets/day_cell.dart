import 'package:flutter/material.dart';

import '../models/drp_calendar_day.dart';
import '../models/drp_event.dart';
import '../theme/drp_date_picker_theme.dart';
import '../utils/digits.dart';

/// A single day cell in the calendar grid, showing the primary BS/AD number
/// and the secondary equivalent, with today/selected/event/disabled states.
class DrpDayCell extends StatelessWidget {
  final DrpCalendarDay day;
  final bool primaryIsBs;

  /// Whether this day is the currently selected one.
  final bool isSelected;

  /// Whether this day is disabled (outside min/max, or explicitly disabled).
  final bool isDisabled;

  final bool markSaturday;

  /// Whether to render numeric dates in Devanagari.
  final bool devanagari;

  final VoidCallback onTap;

  /// The calendar events on this day (holidays, festivals, deadlines, ...).
  final List<DrpCalendarEvent> events;

  final DrpDatePickerTheme theme;

  const DrpDayCell({
    super.key,
    required this.day,
    required this.primaryIsBs,
    required this.isSelected,
    required this.isDisabled,
    required this.markSaturday,
    required this.devanagari,
    required this.onTap,
    required this.events,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    final primary = primaryIsBs ? day.bsDate.date : day.adDate.date;
    final secondary = primaryIsBs ? day.adDate.date : day.bsDate.date;

    final isSaturday = markSaturday && day.isSaturday;
    final accent = theme.accent!;
    final hasEvent = events.isNotEmpty;
    // The marker colour: the first event that declares a colour, else theme.
    Color? firstEventColor;
    for (final e in events) {
      if (e.color != null) {
        firstEventColor = e.color;
        break;
      }
    }
    final markerColor = firstEventColor ?? theme.holiday ?? theme.accent!;

    Color primaryColor = theme.text!;
    if (isSelected) {
      primaryColor = Colors.white;
    } else if (hasEvent) {
      primaryColor = markerColor;
    } else if (isSaturday) {
      primaryColor = accent;
    }

    Color secondaryColor = theme.muted!;
    if (isSelected) secondaryColor = Colors.white;

    final box = Container(
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: isSelected ? accent : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        border: day.isToday && !isSelected
            ? Border.all(color: theme.today!, width: 1.5)
            : null,
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          Center(
            child: Padding(
              padding: const EdgeInsets.only(right: 8, bottom: 6),
              child: Text(
                toDigits(primary, devanagari: devanagari),
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  color: primaryColor,
                ),
              ),
            ),
          ),
          Positioned(
            right: 3,
            bottom: 3,
            child: Text(
              toDigits(secondary, devanagari: devanagari),
              style: TextStyle(fontSize: 8, height: 1, color: secondaryColor),
            ),
          ),
          if (hasEvent)
            Positioned(
              top: 3,
              right: 4,
              child: Container(
                width: 4,
                height: 4,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.white : markerColor,
                ),
              ),
            ),
        ],
      ),
    );

    final titles = events.map((e) => e.title).whereType<String>().toList();
    final tooltipText = titles.join('\n');
    final semanticsLabel =
        '${day.bsDate.monthName} ${toDigits(day.bsDate.date, devanagari: true)}, '
        '${day.adDate.monthNameShort} ${day.adDate.date}'
        '${titles.isNotEmpty ? ', ${titles.join(', ')}' : ''}'
        '${isDisabled ? ', disabled' : ''}';

    Widget cell = InkWell(
      onTap: isDisabled ? null : onTap,
      borderRadius: BorderRadius.circular(9),
      child: box,
    );

    if (isDisabled) {
      cell = Opacity(opacity: 0.32, child: cell);
    }

    if (tooltipText.isNotEmpty && !isDisabled) {
      cell = Tooltip(
        message: tooltipText,
        waitDuration: const Duration(milliseconds: 300),
        child: cell,
      );
    }

    return Semantics(
      label: semanticsLabel,
      selected: isSelected,
      enabled: !isDisabled,
      button: true,
      child: cell,
    );
  }
}
