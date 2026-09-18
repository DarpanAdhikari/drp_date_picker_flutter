import 'package:flutter/material.dart';

import '../converters/bs_data.dart';
import '../converters/drp_calendar.dart';
import '../models/drp_calendar_day.dart';
import '../models/drp_calendar_month.dart';
import '../models/drp_event.dart';
import '../models/drp_picker_type.dart';
import '../theme/drp_date_picker_theme.dart';
import '../utils/digits.dart';
import 'calendar_grid.dart';
import 'month_header.dart';
import 'month_picker.dart';
import 'year_picker.dart' as yp;

enum _PickerMode { days, months, years }

/// The calendar popup content: month navigation, day grid, and the optional
/// month/year pickers plus a footer with Clear / Today actions.
class CalendarPopup extends StatefulWidget {
  final DrpCalendar calendar;
  final int viewYear;
  final int viewMonth;
  final DrpPickerType type;
  final bool markSaturday;
  final DrpDigits digits;
  final int firstDayOfWeek;
  final DrpDatePickerTheme theme;
  final List<DrpCalendarEvent> events;

  final bool Function(DrpCalendarDay day) isSelected;
  final bool Function(DrpCalendarDay day) isDisabled;
  final ValueChanged<DrpCalendarDay> onSelect;
  final VoidCallback onClear;
  final VoidCallback onToday;

  /// If non-null, the popup is shown inline (embedded) instead of floating.
  final bool inline;

  /// The popup width in logical pixels. Defaults to 300. The floating overlay
  /// drives this so it can shrink to fit narrow viewports.
  final double? width;

  /// Called whenever the popup's rendered size changes (e.g. month
  /// navigation changes its height). Lets the floating overlay reposition.
  final ValueChanged<Size>? onSizeChanged;

  const CalendarPopup({
    super.key,
    required this.calendar,
    required this.viewYear,
    required this.viewMonth,
    required this.type,
    required this.markSaturday,
    required this.digits,
    required this.firstDayOfWeek,
    required this.theme,
    required this.events,
    required this.isSelected,
    required this.isDisabled,
    required this.onSelect,
    required this.onClear,
    required this.onToday,
    this.inline = false,
    this.width,
    this.onSizeChanged,
  });

  @override
  State<CalendarPopup> createState() => _CalendarPopupState();
}

class _CalendarPopupState extends State<CalendarPopup> {
  late _PickerMode _mode;
  late int _viewYear;
  late int _viewMonth;

  @override
  void initState() {
    super.initState();
    _mode = _PickerMode.days;
    _viewYear = widget.viewYear;
    _viewMonth = widget.viewMonth;
  }

  @override
  void didUpdateWidget(CalendarPopup oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.viewYear != widget.viewYear ||
        oldWidget.viewMonth != widget.viewMonth) {
      _viewYear = widget.viewYear;
      _viewMonth = widget.viewMonth;
      _mode = _PickerMode.days;
    }
  }

  void _shiftMonth(int delta) {
    setState(() {
      _viewMonth += delta;
      if (_viewMonth > 12) {
        _viewMonth = 1;
        _viewYear++;
      } else if (_viewMonth < 1) {
        _viewMonth = 12;
        _viewYear--;
      }
      _mode = _PickerMode.days;
    });
  }

  void _reportSize() {
    final callback = widget.onSizeChanged;
    if (callback == null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final box = context.findRenderObject() as RenderBox?;
      if (box == null || !box.hasSize) return;
      final size = box.size;
      final reported = _reportedSize;
      if (reported == size) return;
      _reportedSize = size;
      callback(size);
    });
  }

  Size? _reportedSize;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final isBs = widget.type == DrpPickerType.bs;

    final DrpCalendarMonth? month = isBs
        ? widget.calendar.calendarMonthNep(
            _viewYear,
            _viewMonth,
            events: widget.events,
          )
        : widget.calendar.calendarMonthEng(
            _viewYear,
            _viewMonth,
            events: widget.events,
          );

    // Exclude focus so interactive popup widgets (day cells, IconButtons,
    // buttons) never steal focus from the driving TextField — which would
    // otherwise blur it, hide the popup, and swallow the tap.
    _reportSize();
    return ExcludeFocus(
      excluding: !widget.inline,
      child: Container(
        width: widget.width ?? 300,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: widget.theme.panelBackground ?? scheme.surface,
          borderRadius: BorderRadius.circular(widget.theme.radius ?? 16),
          border: Border.all(
            color: (widget.theme.border ?? scheme.outlineVariant).withValues(
              alpha: 0.6,
            ),
          ),
          boxShadow: widget.inline
              ? null
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 4,
                    offset: const Offset(0, 1),
                  ),
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.18),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(widget.theme.radius ?? 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHeader(context, scheme),
              const SizedBox(height: 4),
              _buildBody(context, month),
              if (_mode == _PickerMode.days) _buildFooter(context),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, ColorScheme scheme) {
    if (_mode == _PickerMode.days) {
      final devanagari = widget.digits == DrpDigits.devanagari;
      final primaryIsBs = widget.type == DrpPickerType.bs;
      final title = primaryIsBs
          ? '${nepaliMonths[_viewMonth]} ${devanagari ? toDigitsString(_viewYear.toString()) : _viewYear}'
          : '${englishMonthsFull[_viewMonth]} $_viewYear';
      return MonthHeader(
        title: title,
        onPrev: () => _shiftMonth(-1),
        onNext: () => _shiftMonth(1),
        onTitleTap: () => setState(() => _mode = _PickerMode.months),
      );
    }

    // months or years mode: back button + title.
    final title = _mode == _PickerMode.months
        ? _viewYear.toString()
        : 'Select year';
    return Row(
      children: [
        IconButton(
          icon: Icon(
            Icons.arrow_back_rounded,
            size: 20,
            color: scheme.onSurface,
          ),
          tooltip: 'Back',
          onPressed: () => setState(
            () => _mode = _mode == _PickerMode.years
                ? _PickerMode.months
                : _PickerMode.days,
          ),
          style: IconButton.styleFrom(
            backgroundColor: scheme.surfaceContainerHighest.withValues(
              alpha: 0.5,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
          ),
          visualDensity: VisualDensity.compact,
        ),
        Expanded(
          child: InkWell(
            onTap: _mode == _PickerMode.months
                ? () => setState(() => _mode = _PickerMode.years)
                : null,
            borderRadius: BorderRadius.circular(8),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 14.5,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 48),
      ],
    );
  }

  Widget _buildBody(BuildContext context, DrpCalendarMonth? month) {
    switch (_mode) {
      case _PickerMode.days:
        if (month == null) {
          return const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Out of supported range'),
          );
        }
        final eventsByDate = <String, List<DrpCalendarEvent>>{};
        for (final e in widget.events) {
          eventsByDate.putIfAbsent(e.date.iso, () => []).add(e);
        }
        return CalendarGrid(
          month: month,
          primaryIsBs: widget.type == DrpPickerType.bs,
          markSaturday: widget.markSaturday,
          devanagari: widget.digits == DrpDigits.devanagari,
          firstDayOfWeek: widget.firstDayOfWeek,
          theme: widget.theme,
          events: eventsByDate,
          isSelected: widget.isSelected,
          isDisabled: widget.isDisabled,
          onSelect: widget.onSelect,
        );
      case _PickerMode.months:
        return MonthPicker(
          currentMonth: _viewMonth,
          primaryIsBs: widget.type == DrpPickerType.bs,
          devanagari: widget.digits == DrpDigits.devanagari,
          onSelect: (m) {
            setState(() {
              _viewMonth = m;
              _mode = _PickerMode.days;
            });
          },
        );
      case _PickerMode.years:
        return yp.YearPicker(
          currentYear: _viewYear,
          primaryIsBs: widget.type == DrpPickerType.bs,
          devanagari: widget.digits == DrpDigits.devanagari,
          onSelect: (y) {
            setState(() {
              _viewYear = y;
              _mode = _PickerMode.months;
            });
          },
        );
    }
  }

  Widget _buildFooter(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final accent = widget.theme.accent ?? scheme.primary;
    final muted = scheme.onSurfaceVariant;

    Widget footBtn(
      String label,
      VoidCallback onTap, {
      bool emphasized = false,
    }) {
      return Focus(
        canRequestFocus: false,
        child: TextButton(
          onPressed: onTap,
          style: TextButton.styleFrom(
            foregroundColor: emphasized ? accent : muted,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            minimumSize: Size.zero,
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(
            label,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
          ),
        ),
      );
    }

    return Padding(
      padding: const EdgeInsets.only(top: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          footBtn('Clear', widget.onClear),
          footBtn('Today', widget.onToday, emphasized: true),
        ],
      ),
    );
  }
}
