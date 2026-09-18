import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../converters/bs_data.dart';
import '../converters/drp_calendar.dart';
import '../models/bs_date.dart';
import '../models/drp_calendar_day.dart';
import '../models/drp_date.dart';
import '../models/drp_event.dart';
import '../models/drp_holiday.dart';
import '../models/drp_picker_type.dart';
import '../theme/drp_date_picker_theme.dart';
import '../utils/digits.dart';
import 'calendar_popup.dart';

/// A flexible Nepali (Bikram Sambat / BS) + English (Gregorian / AD) date
/// picker for Flutter.
///
/// Every day cell shows both calendars. The picker can be driven by either
/// calendar (`type`), supports min/max and disabled dates, developer-provided
/// holidays (always specified in BS), Devanagari or Western digits, configurable
/// first day of week, and Saturday highlighting.
///
/// In [DrpPopupMode.popup] the calendar is shown in a floating overlay, which
/// requires an `Overlay` ancestor — use it under a `MaterialApp`/`Navigator`.
class DrpDatePicker extends StatefulWidget {
  final DrpCalendar? calendar;

  /// The initially selected date. Ignored when [selectedDate] is provided.
  final DrpDate? initialDate;

  /// A controlled selected date. When set, the picker follows it.
  final DrpDate? selectedDate;

  /// Which calendar drives the grid and is shown as the primary value.
  final DrpPickerType type;

  /// Earliest selectable date (inclusive). If null, the lower bound of the
  /// supported range applies. Accepts BS or AD — both are honoured.
  final BsDate? minDate;
  final AdDate? minDateAd;

  /// Latest selectable date (inclusive).
  final BsDate? maxDate;
  final AdDate? maxDateAd;

  final bool markSaturday;
  final DrpDigits digits;
  final int firstDayOfWeek;

  /// Developer-provided calendar events (holidays, festivals, deadlines, ...).
  final List<DrpCalendarEvent> events;

  /// Deprecated. Developer-provided holidays, always specified in BS.
  /// Equivalent to supplying holiday-typed [events].
  @Deprecated('Use events with DrpEventType.holiday instead')
  final List<DrpHoliday> holidays;

  /// All events, combining [events] and [holidays].
  List<DrpCalendarEvent> get _allEvents =>
      // ignore: deprecated_member_use
      [...events, ...holidays];

  /// Specific BS dates to disable.
  final List<BsDate> disabledDates;

  /// Display format for the input field using tokens
  /// (YYYY, YY, MMMM, MM, M, DD, D). If null, a friendly default is used.
  final String? format;

  final String? placeholder;
  final String? labelText;
  final bool enabled;

  final DrpPopupMode popupMode;

  final DrpDatePickerTheme? theme;

  /// Called with the full BS+AD date whenever a date is selected or cleared.
  final ValueChanged<DrpDate?>? onChanged;

  /// Called with the BS date on selection (or null on clear).
  final ValueChanged<BsDate?>? onChangedBS;

  /// Called with the AD date on selection (or null on clear).
  final ValueChanged<AdDate?>? onChangedAD;

  final VoidCallback? onPanelOpen;
  final VoidCallback? onPanelClose;

  final InputDecoration? decoration;

  /// Override for the input's text style.
  final TextStyle? textStyle;

  const DrpDatePicker({
    super.key,
    this.calendar,
    this.initialDate,
    this.selectedDate,
    this.type = DrpPickerType.bs,
    this.minDate,
    this.minDateAd,
    this.maxDate,
    this.maxDateAd,
    this.markSaturday = true,
    this.digits = DrpDigits.english,
    this.firstDayOfWeek = 0,
    this.events = const [],
    this.holidays = const [],
    this.disabledDates = const [],
    this.format,
    this.placeholder,
    this.labelText,
    this.enabled = true,
    this.popupMode = DrpPopupMode.popup,
    this.theme,
    this.onChanged,
    this.onChangedBS,
    this.onChangedAD,
    this.onPanelOpen,
    this.onPanelClose,
    this.decoration,
    this.textStyle,
  });

  @override
  State<DrpDatePicker> createState() => _DrpDatePickerState();
}

class _DrpDatePickerState extends State<DrpDatePicker> {
  late DrpCalendar _cal;
  late DrpDatePickerTheme _theme;
  bool _themeResolved = false;
  late BsDate? _selected;
  late int _viewYear;
  late int _viewMonth;
  bool _open = false;

  // Overlay bookkeeping.
  final GlobalKey _fieldKey = GlobalKey();
  OverlayEntry? _overlayEntry;
  final FocusNode _focusNode = FocusNode();
  final TextEditingController _controller = TextEditingController();

  /// True when a pointer-down landed inside the popup. Lets the focus handler
  /// ignore a blur caused by tapping a popup widget (web/desktop).
  bool _tapInPopup = false;

  @override
  void initState() {
    super.initState();
    _cal = widget.calendar ?? DrpCalendar();
    _theme = DrpDatePickerTheme.fallback;
    _selected = _resolveInitial();
    final view = _deriveView();
    _viewYear = view.$1;
    _viewMonth = view.$2;
    _syncController();

    _focusNode.addListener(_onFocusChanged);
  }

  @override
  void didUpdateWidget(DrpDatePicker oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.calendar != null && widget.calendar != oldWidget.calendar) {
      _cal = widget.calendar!;
    }
    // Controlled mode: follow the externally provided date.
    if (widget.selectedDate != null) {
      final newBs = widget.selectedDate!.bs;
      if (newBs != _selected) {
        _selected = newBs;
        _syncController();
      }
    } else if (widget.initialDate != null &&
        oldWidget.initialDate != widget.initialDate) {
      _selected = _resolveInitial();
      _syncController();
    }
  }

  @override
  void dispose() {
    _focusNode.removeListener(_onFocusChanged);
    _removeOverlay();
    _focusNode.dispose();
    _controller.dispose();
    super.dispose();
  }

  BsDate? _resolveInitial() {
    final sel = widget.selectedDate ?? widget.initialDate;
    if (sel != null) return sel.bs;
    return null;
  }

  (int, int) _deriveView() {
    final isBs = widget.type == DrpPickerType.bs;
    final sel = _selected;
    if (sel != null) {
      if (isBs) return (sel.year, sel.month);
      final ad = _cal.nepToEng(sel.year, sel.month, sel.date);
      if (ad != null) return (ad.year, ad.month);
    }
    final today = _cal.todayNep();
    if (isBs) return (today.year, today.month);
    final todayAd = _cal.todayEng();
    return (todayAd.year, todayAd.month);
  }

  // ── selection ─────────────────────────────────────────────────────────

  void _select(BsDate bs) {
    final ad = _cal.nepToEng(bs.year, bs.month, bs.date);
    if (ad == null) return;
    setState(() {
      _selected = bs;
      final view = _deriveView();
      _viewYear = view.$1;
      _viewMonth = view.$2;
    });
    _syncController();
    final date = DrpDate(bs: bs, ad: ad);
    widget.onChanged?.call(date);
    widget.onChangedBS?.call(bs);
    widget.onChangedAD?.call(ad);
    if (widget.popupMode == DrpPopupMode.popup) close();
  }

  void _clear() {
    setState(() => _selected = null);
    _syncController();
    widget.onChanged?.call(null);
    widget.onChangedBS?.call(null);
    widget.onChangedAD?.call(null);
  }

  void _selectToday() {
    final today = _cal.todayNep();
    if (_isDisabled(today)) return;
    _select(today);
  }

  // ── disabling ─────────────────────────────────────────────────────────

  bool _isDisabled(BsDate bs) {
    final ad = _cal.nepToEng(bs.year, bs.month, bs.date);
    if (ad == null) return true;

    final minBs = widget.minDate;
    final minAd = widget.minDateAd;
    if (minBs != null && _compareBs(bs, minBs) < 0) return true;
    if (minAd != null && _compareAd(ad, minAd) < 0) return true;

    final maxBs = widget.maxDate;
    final maxAd = widget.maxDateAd;
    if (maxBs != null && _compareBs(bs, maxBs) > 0) return true;
    if (maxAd != null && _compareAd(ad, maxAd) > 0) return true;

    if (widget.disabledDates.contains(bs)) return true;

    // Respect the supported range.
    return !(bs.year >= bsYearMin && bs.year <= bsYearMax);
  }

  int _compareBs(BsDate a, BsDate b) =>
      (a.year - b.year) * 10000 + (a.month - b.month) * 100 + (a.date - b.date);

  int _compareAd(AdDate a, AdDate b) {
    final da = DateTime.utc(a.year, a.month, a.date);
    final db = DateTime.utc(b.year, b.month, b.date);
    return da.compareTo(db);
  }

  bool _isSelected(DrpCalendarDay day) =>
      _selected != null &&
      _selected!.year == day.bsDate.year &&
      _selected!.month == day.bsDate.month &&
      _selected!.date == day.bsDate.date;

  // ── input display ─────────────────────────────────────────────────────

  void _syncController() {
    final sel = _selected;
    final devanagari = widget.digits == DrpDigits.devanagari;
    if (sel == null) {
      _controller.clear();
      return;
    }
    final ad = _cal.nepToEng(sel.year, sel.month, sel.date);
    final isBs = widget.type == DrpPickerType.bs;

    String text;
    if (widget.format != null) {
      text = isBs
          ? _cal.formatBs(sel, widget.format!)
          : _cal.formatAd(ad!, widget.format!);
      if (devanagari) text = toDigitsString(text);
    } else {
      if (isBs) {
        text = devanagari
            ? '${toDigits(sel.date, devanagari: true)} ${sel.monthNameNe} ${toDigits(sel.year, devanagari: true)}'
            : '${sel.date} ${sel.monthName} ${sel.year}';
      } else {
        text = ad == null
            ? ''
            : devanagari
            ? '${toDigits(ad.date, devanagari: true)} ${ad.monthName} ${toDigits(ad.year, devanagari: true)}'
            : '${ad.date} ${ad.monthName} ${ad.year}';
      }
    }
    if (_controller.text != text) {
      _controller.text = text;
      _controller.selection = TextSelection.collapsed(offset: text.length);
    }
  }

  String _placeholder() =>
      widget.placeholder ??
      (widget.type == DrpPickerType.ad
          ? 'Select date (AD)'
          : 'Select date (BS)');

  // ── overlay / popup ───────────────────────────────────────────────────

  void _ensureTheme() {
    if (_themeResolved) return;
    _theme = widget.theme ?? DrpDatePickerTheme.of(context);
    _themeResolved = true;
  }

  void _onFocusChanged() {
    if (widget.popupMode != DrpPopupMode.popup) return;
    if (_focusNode.hasFocus) {
      open();
    } else {
      // On web/desktop the popup widgets can steal focus while the user is
      // tapping a day. Don't tear the popup down mid-tap, or the selection
      // never lands. Tapping another field (no popup pointer-down) still
      // closes it via this blur handler.
      if (_tapInPopup) {
        _tapInPopup = false;
        return;
      }
      close();
    }
  }

  void open() {
    if (widget.popupMode != DrpPopupMode.popup) return;
    if (!widget.enabled || _open) return;
    _tapInPopup = false;
    _ensureTheme();
    setState(() {
      _open = true;
      final view = _deriveView();
      _viewYear = view.$1;
      _viewMonth = view.$2;
    });
    _insertOverlay();
    widget.onPanelOpen?.call();
  }

  void close() {
    if (widget.popupMode != DrpPopupMode.popup) return;
    if (!_open) return;
    setState(() => _open = false);
    _removeOverlay();
    widget.onPanelClose?.call();
  }

  void _insertOverlay() {
    if (_overlayEntry != null) return;
    final overlay = Overlay.of(context);
    final fieldContext = _fieldKey.currentContext;

    _overlayEntry = OverlayEntry(
      builder: (context) {
        return _PickerPopupOverlay(
          fieldContext: fieldContext,
          scrollPosition: fieldContext == null
              ? null
              : Scrollable.maybeOf(fieldContext)?.position,
          calendar: _cal,
          viewYear: _viewYear,
          viewMonth: _viewMonth,
          type: widget.type,
          markSaturday: widget.markSaturday,
          digits: widget.digits,
          firstDayOfWeek: widget.firstDayOfWeek,
          theme: _theme,
          events: widget._allEvents,
          isSelected: _isSelected,
          isDisabled: (d) => _isDisabled(d.bsDate),
          onSelect: (d) => _select(d.bsDate),
          onClear: _clear,
          onToday: _selectToday,
          onPopupPointerDown: () => _tapInPopup = true,
        );
      },
    );
    overlay.insert(_overlayEntry!);
  }

  void _removeOverlay() {
    _overlayEntry?.remove();
    _overlayEntry = null;
  }

  // ── build ─────────────────────────────────────────────────────────────

  InputDecoration _decoration() {
    final radius = _theme.radius ?? 12;
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(
        color: (_theme.border ?? Theme.of(context).colorScheme.outlineVariant)
            .withValues(alpha: 0.7),
      ),
    );
    final base =
        widget.decoration ??
        InputDecoration(
          border: border,
          enabledBorder: border,
          focusedBorder: border.copyWith(
            borderSide: BorderSide(
              color: _theme.accent ?? Theme.of(context).colorScheme.primary,
              width: 1.5,
            ),
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 14,
          ),
          labelText: widget.labelText,
          hintText: _placeholder(),
        );
    return base.copyWith(
      suffixIcon: Icon(
        Icons.calendar_today_outlined,
        size: 18,
        color: Theme.of(context).colorScheme.onSurfaceVariant,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    _ensureTheme();

    final field = TextField(
      key: _fieldKey,
      controller: _controller,
      focusNode: _focusNode,
      enabled: widget.enabled,
      readOnly: true,
      onTap: widget.popupMode == DrpPopupMode.popup ? open : null,
      decoration: _decoration(),
      style: widget.textStyle,
    );

    final content = Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        field,
        if (widget.popupMode == DrpPopupMode.inline)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: CalendarPopup(
              calendar: _cal,
              viewYear: _viewYear,
              viewMonth: _viewMonth,
              type: widget.type,
              markSaturday: widget.markSaturday,
              digits: widget.digits,
              firstDayOfWeek: widget.firstDayOfWeek,
              theme: _theme,
              events: widget._allEvents,
              isSelected: _isSelected,
              isDisabled: (d) => _isDisabled(d.bsDate),
              onSelect: (d) => _select(d.bsDate),
              onClear: _clear,
              onToday: _selectToday,
              inline: true,
            ),
          ),
      ],
    );

    return content;
  }
}

/// The floating popup for [DrpDatePicker].
///
/// Measures the popup's real size, then places it relative to the driving
/// field so it always stays inside the viewport:
/// - flips above the field when there isn't room below,
/// - shifts horizontally to avoid the screen edges,
/// - shrinks its width on narrow viewports,
/// - re-positions while the user scrolls or the window resizes.
class _PickerPopupOverlay extends StatefulWidget {
  final BuildContext? fieldContext;
  final ScrollPosition? scrollPosition;

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

  /// Called when a pointer-down lands inside the popup.
  final VoidCallback? onPopupPointerDown;

  const _PickerPopupOverlay({
    this.fieldContext,
    this.scrollPosition,
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
    this.onPopupPointerDown,
  });

  @override
  State<_PickerPopupOverlay> createState() => _PickerPopupOverlayState();
}

class _PickerPopupOverlayState extends State<_PickerPopupOverlay> {
  static const double _margin = 8;
  static const double _gap = 4;
  static const double _maxWidth = 300;

  Size? _popupSize;

  ScrollPosition? _listenedScroll;

  @override
  void initState() {
    super.initState();
    _listenedScroll = widget.scrollPosition;
    _listenedScroll?.addListener(_onScroll);
  }

  @override
  void didUpdateWidget(_PickerPopupOverlay oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.scrollPosition != widget.scrollPosition) {
      _listenedScroll?.removeListener(_onScroll);
      _listenedScroll = widget.scrollPosition;
      _listenedScroll?.addListener(_onScroll);
    }
  }

  @override
  void dispose() {
    _listenedScroll?.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    if (!mounted) return;
    setState(() {});
  }

  Rect? _fieldRect() {
    final ctx = widget.fieldContext;
    final box = ctx?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return null;
    final rect = box.localToGlobal(Offset.zero) & box.size;
    if (rect.isEmpty) return null;
    return rect;
  }

  void _setPopupSize(Size size) {
    if (!mounted || size == _popupSize) return;
    setState(() => _popupSize = size);
  }

  double _viewportWidth(Size viewport) => math
      .min(_maxWidth, viewport.width - _margin * 2)
      .clamp(_margin, _maxWidth);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final viewport = Size(constraints.maxWidth, constraints.maxHeight);
        final field = _fieldRect();
        final width = _viewportWidth(viewport);
        final height = _popupSize?.height;

        double top;
        double left;
        if (field == null) {
          top = _margin;
          left = _margin;
        } else {
          // Horizontal: align to the field's left edge, shifted to stay
          // inside the viewport.
          left = field.left.clamp(
            _margin,
            math.max(_margin, viewport.width - width - _margin),
          );
          // Vertical: below the field if there's room, otherwise above.
          double? popupHeight = height;
          if (popupHeight == null ||
              field.bottom + _gap + popupHeight <= viewport.height - _margin) {
            top = field.bottom + _gap;
          } else {
            top = field.top - _gap - popupHeight;
            top = top.clamp(_margin, math.max(_margin, field.top));

            // If the popup is taller than the viewport, allow it to start at
            // the field's top rather than being pushed off-screen.
            if (popupHeight > viewport.height - _margin * 2) {
              top = _margin;
            }
          }
        }

        final visible = _popupSize != null && field != null;

        return Stack(
          children: [
            Positioned(
              left: left,
              top: top,
              width: width,
              child: Listener(
                onPointerDown: (_) => widget.onPopupPointerDown?.call(),
                child: Opacity(
                  opacity: visible ? 1 : 0,
                  child: Material(
                    key: const ValueKey('drp-date-picker-popup'),
                    elevation: 8,
                    borderRadius: BorderRadius.circular(
                      widget.theme.radius ?? 14,
                    ),
                    color: Colors.transparent,
                    child: CalendarPopup(
                      calendar: widget.calendar,
                      viewYear: widget.viewYear,
                      viewMonth: widget.viewMonth,
                      type: widget.type,
                      markSaturday: widget.markSaturday,
                      digits: widget.digits,
                      firstDayOfWeek: widget.firstDayOfWeek,
                      theme: widget.theme,
                      events: widget.events,
                      isSelected: widget.isSelected,
                      isDisabled: widget.isDisabled,
                      onSelect: widget.onSelect,
                      onClear: widget.onClear,
                      onToday: widget.onToday,
                      width: width,
                      onSizeChanged: _setPopupSize,
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}
