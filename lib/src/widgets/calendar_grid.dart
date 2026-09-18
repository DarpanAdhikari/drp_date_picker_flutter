import 'package:flutter/material.dart';

import '../converters/bs_data.dart';
import '../models/drp_calendar_day.dart';
import '../models/drp_calendar_month.dart';
import '../models/drp_event.dart';
import '../theme/drp_date_picker_theme.dart';
import 'day_cell.dart';

/// The weekday header + day grid for a calendar month.
class CalendarGrid extends StatelessWidget {
  final DrpCalendarMonth month;
  final bool primaryIsBs;
  final bool markSaturday;
  final bool devanagari;
  final int firstDayOfWeek;
  final DrpDatePickerTheme theme;

  /// Maps a BS date ISO to its calendar events, if any.
  final Map<String, List<DrpCalendarEvent>> events;

  /// Whether a given BS date is currently selected.
  final bool Function(DrpCalendarDay day) isSelected;

  /// Whether a given BS date is disabled.
  final bool Function(DrpCalendarDay day) isDisabled;

  final ValueChanged<DrpCalendarDay> onSelect;

  const CalendarGrid({
    super.key,
    required this.month,
    required this.primaryIsBs,
    required this.markSaturday,
    required this.devanagari,
    required this.firstDayOfWeek,
    required this.theme,
    required this.events,
    required this.isSelected,
    required this.isDisabled,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    final offset = (month.startWeekday - 1 - firstDayOfWeek + 7) % 7;
    final wd = devanagari ? weekdaysShortNe : weekdaysShort;
    final reordered = [
      ...wd.sublist(firstDayOfWeek),
      ...wd.sublist(0, firstDayOfWeek),
    ];
    final satIndex = (6 - firstDayOfWeek + 7) % 7;

    final cells = <Widget>[
      for (var i = 0; i < offset; i++) const SizedBox.shrink(),
      for (var i = 0; i < month.days.length; i++)
        _buildDay(context, month.days[i]),
    ];

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          children: [
            for (var i = 0; i < reordered.length; i++)
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Text(
                    reordered[i],
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                      color: i == satIndex ? theme.accent : theme.muted,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 4),
        GridView.count(
          crossAxisCount: 7,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          mainAxisSpacing: 3,
          crossAxisSpacing: 3,
          childAspectRatio: 0.95,
          children: cells,
        ),
      ],
    );
  }

  Widget _buildDay(BuildContext context, DrpCalendarDay day) {
    return DrpDayCell(
      day: day,
      primaryIsBs: primaryIsBs,
      isSelected: isSelected(day),
      isDisabled: isDisabled(day),
      markSaturday: markSaturday,
      devanagari: devanagari,
      events: events[day.bsDate.iso] ?? const [],
      theme: theme,
      onTap: () => onSelect(day),
    );
  }
}
