import '../models/bs_date.dart';
import '../models/drp_calendar_day.dart';
import '../models/drp_calendar_month.dart';
import '../models/drp_event.dart';
import '../models/drp_holiday.dart';
import 'bs_data.dart';

/// Bikram Sambat (BS) <-> Gregorian (AD) date conversion and calendar engine.
///
/// Pure Dart — no Flutter dependency — so it can be used standalone, exactly
/// like the `DrpNepaliCalendar` class in the reference npm package.
///
/// Supported ranges:
/// * AD: 1944-04-14 -> 2041-04-14
/// * BS: 2000-01-01 -> 2098-12-31
class DrpCalendar {
  DrpCalendar();

  /// Returns the number of days in the given BS month, or 0 if out of range.
  int daysInBsMonth(int year, int month) {
    if (year < bsYearMin || year > bsYearMax || month < 1 || month > 12) {
      return 0;
    }
    return bsData[year - bsYearMin][month];
  }

  /// Whether the given year is a Gregorian leap year.
  bool isLeapYear(int year) {
    if (year % 100 == 0) return year % 400 == 0;
    return year % 4 == 0;
  }

  // ── validation ───────────────────────────────────────────────────────

  bool _isRangeEng(int yy, int mm, int dd) =>
      yy >= adYearMin &&
      yy <= adYearMax &&
      mm >= 1 &&
      mm <= 12 &&
      dd >= 1 &&
      dd <= 31;

  bool _isRangeNep(int yy, int mm, int dd) =>
      yy >= bsYearMin &&
      yy <= bsYearMax &&
      mm >= 1 &&
      mm <= 12 &&
      dd >= 1 &&
      dd <= 32;

  /// Whether a BS date string (`'YYYY-MM-DD'`) is valid and in range.
  bool isValidBsDate(String date) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) return false;
    final parts = date.split('-').map(int.parse).toList();
    return _isRangeNep(parts[0], parts[1], parts[2]);
  }

  /// Whether an AD date string (`'YYYY-MM-DD'`) is a real date in range.
  bool isValidAdDate(String date) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) return false;
    final parts = date.split('-').map(int.parse).toList();
    final y = parts[0], m = parts[1], d = parts[2];
    if (!_isRangeEng(y, m, d)) return false;
    final daysInMonth = _adDaysInMonth(y, m);
    return d >= 1 && d <= daysInMonth;
  }

  int _adDaysInMonth(int year, int month) {
    if (month < 1 || month > 12) return 0;
    const normal = [0, 31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    const leap = [0, 31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    return isLeapYear(year) ? leap[month] : normal[month];
  }

  // ── core conversion ──────────────────────────────────────────────────

  /// AD -> BS. Returns null if out of range.
  BsDate? engToNep(int yy, int mm, int dd) {
    if (!_isRangeEng(yy, mm, dd)) return null;

    const month = [31, 28, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];
    const lmonth = [31, 29, 31, 30, 31, 30, 31, 31, 30, 31, 30, 31];

    // Anchor: AD 1944-01-01 == BS 2000-09-17
    const defEyy = 1944, defNyy = 2000, defNmm = 9;
    var defNdd = 16; // 17 - 1 (loop increments before compare)
    var day = 6; // weekday seed

    var totalEDays = 0;
    for (var i = 0; i < yy - defEyy; i++) {
      final src = isLeapYear(defEyy + i) ? lmonth : month;
      for (var d = 0; d < src.length; d++) {
        totalEDays += src[d];
      }
    }
    final src = isLeapYear(yy) ? lmonth : month;
    for (var i = 0; i < mm - 1; i++) {
      totalEDays += src[i];
    }
    totalEDays += dd;

    var i = 0, j = defNmm, totalNDays = defNdd, m = defNmm, y = defNyy;

    while (totalEDays != 0) {
      final daysInMonth = bsData[i][j];
      totalNDays++;
      day++;
      if (totalNDays > daysInMonth) {
        m++;
        totalNDays = 1;
        j++;
      }
      if (day > 7) day = 1;
      if (m > 12) {
        y++;
        m = 1;
      }
      if (j > 12) {
        j = 1;
        i++;
      }
      totalEDays--;
    }

    return BsDate(y, m, totalNDays);
  }

  /// AD -> BS from a `'YYYY-MM-DD'` AD string. Returns null if invalid.
  BsDate? engToNepDate(String date) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) return null;
    final parts = date.split('-').map(int.parse).toList();
    final y = parts[0], m = parts[1], d = parts[2];
    if (d < 1 || d > _adDaysInMonth(y, m)) return null;
    return engToNep(y, m, d);
  }

  /// BS -> AD. Returns null if out of range.
  AdDate? nepToEng(int yy, int mm, int dd) {
    if (!_isRangeNep(yy, mm, dd)) return null;

    // Anchor: BS 2000-01-01 = AD 1943-04-14, day seed 3 (Wednesday)
    const defEyy = 1943, defEmm = 4, defEdd = 13, defNyy = 2000;
    var day = 3;

    var totalNDays = 0;
    var k = 0;
    for (var i = 0; i < yy - defNyy; i++) {
      for (var j = 1; j <= 12; j++) {
        totalNDays += bsData[k][j];
      }
      k++;
    }
    for (var j = 1; j < mm; j++) {
      totalNDays += bsData[k][j];
    }
    totalNDays += dd;

    var totalEDays = defEdd, m = defEmm, y = defEyy;
    while (totalNDays != 0) {
      final daysInMonth = _adDaysInMonth(y, m);
      totalEDays++;
      day++;
      if (totalEDays > daysInMonth) {
        m++;
        totalEDays = 1;
        if (m > 12) {
          y++;
          m = 1;
        }
      }
      if (day > 7) day = 1;
      totalNDays--;
    }

    return AdDate(y, m, totalEDays);
  }

  /// BS -> AD from a `'YYYY-MM-DD'` BS string. Returns null if invalid.
  AdDate? nepToEngDate(String date) {
    if (!RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(date)) return null;
    final parts = date.split('-').map(int.parse).toList();
    return nepToEng(parts[0], parts[1], parts[2]);
  }

  // ── month boundaries ─────────────────────────────────────────────────

  /// Start and end ISO strings for a BS month.
  ({String start, String end, int days})? monthDatesNep(int year, int month) {
    final days = daysInBsMonth(year, month);
    if (days == 0) return null;
    final pad2 = _pad2;
    final y = year.toString().padLeft(4, '0');
    return (
      start: '$y-${pad2(month)}-01',
      end: '$y-${pad2(month)}-${pad2(days)}',
      days: days,
    );
  }

  // ── date offset ──────────────────────────────────────────────────────

  /// Offset a BS date by [days] days (positive = future). Returns null if
  /// the result is out of range.
  BsDate? dateOffsetNep(BsDate date, int days) {
    final ad = nepToEng(date.year, date.month, date.date);
    if (ad == null) return null;
    final dt = _adDay(ad, days);
    return engToNep(dt.year, dt.month, dt.date);
  }

  AdDate _adDay(AdDate date, int offset) {
    final asEpoch = DateTime.utc(
      date.year,
      date.month,
      date.date,
    ).add(Duration(days: offset));
    return AdDate(asEpoch.year, asEpoch.month, asEpoch.day);
  }

  /// Offset an AD date by [days] days.
  AdDate dateOffsetEng(AdDate date, int days) => _adDay(date, days);

  // ── today ────────────────────────────────────────────────────────────

  /// Today's date as BS.
  BsDate todayNep() {
    final now = DateTime.now();
    return engToNep(now.year, now.month, now.day) ?? const BsDate(2000, 1, 1);
  }

  /// Today's date as AD.
  AdDate todayEng() {
    final now = DateTime.now();
    return AdDate(now.year, now.month, now.day);
  }

  // ── formatting ───────────────────────────────────────────────────────

  String _pad2(int n) => n.toString().padLeft(2, '0');

  /// Format a BS date using tokens: YYYY, YY, MMMM, MM, M, DD, D.
  String formatBs(BsDate date, String format) {
    final year = date.year.toString();
    return format
        .replaceAll('YYYY', year)
        .replaceAll(
          'YY',
          year.length >= 2 ? year.substring(year.length - 2) : year,
        )
        .replaceAll('MMMM', date.monthName)
        .replaceAll('MM', _pad2(date.month))
        .replaceAll('M', date.month.toString())
        .replaceAll('DD', _pad2(date.date))
        .replaceAll('D', date.date.toString());
  }

  /// Format an AD date using tokens: YYYY, YY, MMMM, MM, M, DD, D.
  String formatAd(AdDate date, String format) {
    final year = date.year.toString();
    return format
        .replaceAll('YYYY', year)
        .replaceAll(
          'YY',
          year.length >= 2 ? year.substring(year.length - 2) : year,
        )
        .replaceAll('MMMM', date.monthName)
        .replaceAll('MM', _pad2(date.month))
        .replaceAll('M', date.month.toString())
        .replaceAll('DD', _pad2(date.date))
        .replaceAll('D', date.date.toString());
  }

  // ── calendar grid builders ───────────────────────────────────────────

  Map<String, List<DrpCalendarEvent>> _eventMap(List<DrpCalendarEvent> events) {
    final map = <String, List<DrpCalendarEvent>>{};
    for (final e in events) {
      map.putIfAbsent(e.date.iso, () => []).add(e);
    }
    return map;
  }

  /// Build a full month grid driven by the BS calendar.
  ///
  /// [events] (and the deprecated [holidays] alias) are matched by BS date
  /// and attached to each day.
  DrpCalendarMonth? calendarMonthNep(
    int year,
    int month, {
    List<DrpCalendarEvent> events = const [],
    List<DrpHoliday> holidays = const [],
  }) {
    final info = monthDatesNep(year, month);
    if (info == null) return null;

    final eventMap = _eventMap([...events, ...holidays]);
    final todayBs = todayNep();

    final firstAd = nepToEng(year, month, 1);
    if (firstAd == null) return null;
    final startWeekday = _adWeekday(firstAd);

    final days = <DrpCalendarDay>[];
    for (var d = 1; d <= info.days; d++) {
      final weekday = ((startWeekday - 1 + (d - 1)) % 7) + 1;
      final adDate = _adDay(firstAd, d - 1);
      final bsDate = BsDate(year, month, d);
      days.add(
        DrpCalendarDay(
          bsDate: bsDate,
          adDate: adDate,
          weekday: weekday,
          isToday: bsDate == todayBs,
          events: eventMap[bsDate.iso] ?? const [],
        ),
      );
    }

    return DrpCalendarMonth(
      system: 'bs',
      year: year,
      month: month,
      monthName: nepaliMonths[month],
      daysInMonth: info.days,
      startWeekday: startWeekday,
      days: days,
    );
  }

  /// Build a full month grid driven by the Gregorian calendar.
  ///
  /// [events] (and the deprecated [holidays] alias) are matched by their
  /// canonical BS date and attached to the corresponding AD day.
  DrpCalendarMonth? calendarMonthEng(
    int year,
    int month, {
    List<DrpCalendarEvent> events = const [],
    List<DrpHoliday> holidays = const [],
  }) {
    if (year < adYearMin || year > adYearMax || month < 1 || month > 12) {
      return null;
    }
    final daysInMonth = _adDaysInMonth(year, month);
    final eventMap = _eventMap([...events, ...holidays]);
    final todayBs = todayNep();

    final firstBs = engToNep(year, month, 1);
    if (firstBs == null) return null;
    final startWeekday = _adWeekday(AdDate(year, month, 1));

    final days = <DrpCalendarDay>[];
    for (var d = 1; d <= daysInMonth; d++) {
      final weekday = ((startWeekday - 1 + (d - 1)) % 7) + 1;
      final adDate = AdDate(year, month, d);
      final bsDate = engToNep(year, month, d)!;
      days.add(
        DrpCalendarDay(
          bsDate: bsDate,
          adDate: adDate,
          weekday: weekday,
          isToday: bsDate == todayBs,
          events: eventMap[bsDate.iso] ?? const [],
        ),
      );
    }

    return DrpCalendarMonth(
      system: 'ad',
      year: year,
      month: month,
      monthName: englishMonthsFull[month],
      daysInMonth: daysInMonth,
      startWeekday: startWeekday,
      days: days,
    );
  }

  /// Weekday (1 = Sunday ... 7 = Saturday) of a Gregorian date, computed via
  /// the reference algorithm used by the npm package.
  int _adWeekday(AdDate date) {
    // Reuse the same day-counting seed as the JS implementation: compute the
    // BS weekday then map. Simplest correct approach: convert to BS weekday.
    final bs = engToNep(date.year, date.month, date.date);
    if (bs == null) return 1;
    // Reproduce the weekday from the BS->AD walking seed.
    return _weekdayOfAd(date);
  }

  int _weekdayOfAd(AdDate date) {
    // Anchor BS 2000-01-01 = AD 1943-04-14, day seed 3 (Wednesday).
    final base = DateTime.utc(1943, 4, 14);
    final target = DateTime.utc(date.year, date.month, date.date);
    final diff = target.difference(base).inDays;
    var wd = (3 + diff) % 7;
    if (wd <= 0) wd += 7;
    return wd; // 1=Sunday ... 7=Saturday
  }
}
