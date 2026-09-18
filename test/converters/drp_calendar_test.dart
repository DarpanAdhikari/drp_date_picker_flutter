import 'package:drp_date_picker/drp_date_picker.dart';
import 'package:drp_date_picker/src/utils/digits.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('DrpCalendar BS <-> AD conversion', () {
    final cal = DrpCalendar();

    test('engToNep known anchor: 2025-06-10 = 2082-02-27', () {
      final bs = cal.engToNep(2025, 6, 10);
      expect(bs, isNotNull);
      expect(bs!.year, 2082);
      expect(bs.month, 2);
      expect(bs.date, 27);
    });

    test('nepToEng known anchor: 2082-02-27 = 2025-06-10', () {
      final ad = cal.nepToEng(2082, 2, 27);
      expect(ad, isNotNull);
      expect(ad!.year, 2025);
      expect(ad.month, 6);
      expect(ad.date, 10);
    });

    test('engToNepDate string form', () {
      final bs = cal.engToNepDate('2025-06-10');
      expect(bs!.year, 2082);
      expect(bs.month, 2);
      expect(bs.date, 27);
    });

    test('nepToEngDate string form', () {
      final ad = cal.nepToEngDate('2082-02-27');
      expect(ad!.year, 2025);
      expect(ad.month, 6);
      expect(ad.date, 10);
    });

    test('round-trips over many dates', () {
      // Skip the extreme boundary years (2000/2098) which map to AD dates just
      // outside the documented AD 1944-2041 range (matching the npm engine).
      for (var year = 2001; year <= 2097; year++) {
        for (var month = 1; month <= 12; month++) {
          final days = cal.daysInBsMonth(year, month);
          for (var day = 1; day <= days; day += 11) {
            final ad = cal.nepToEng(year, month, day)!;
            final back = cal.engToNep(ad.year, ad.month, ad.date)!;
            expect(back.year, year, reason: '$year-$month-$day');
            expect(back.month, month, reason: '$year-$month-$day');
            expect(back.date, day, reason: '$year-$month-$day');
          }
        }
      }
    });

    test('out-of-range AD returns null', () {
      expect(cal.engToNep(1943, 1, 1), isNull);
      expect(cal.engToNep(2042, 1, 1), isNull);
    });

    test('out-of-range BS returns null', () {
      expect(cal.nepToEng(1999, 1, 1), isNull);
      expect(cal.nepToEng(2099, 1, 1), isNull);
    });

    test('invalid dates return null', () {
      expect(cal.engToNepDate('2025-13-01'), isNull);
      expect(cal.engToNepDate('2025-02-30'), isNull);
      expect(cal.engToNepDate('not-a-date'), isNull);
      expect(cal.nepToEngDate('2082-00-10'), isNull);
      expect(cal.nepToEngDate('2082-02-33'), isNull);
    });
  });

  group('month boundaries', () {
    final cal = DrpCalendar();

    test('monthDatesNep returns correct days', () {
      final info = cal.monthDatesNep(2082, 2);
      expect(info, isNotNull);
      expect(info!.start, '2082-02-01');
      expect(info.end, '2082-02-31');
      expect(info.days, 31);
    });

    test('monthDatesNep supports 32-day month', () {
      final info = cal.monthDatesNep(2082, 3); // Ashadh 2082 has 32 days
      expect(info!.days, 32);
      expect(info.end, '2082-03-32');
    });

    test('unknown BS year returns null', () {
      expect(cal.monthDatesNep(2200, 1), isNull);
    });
  });

  group('date offsets', () {
    final cal = DrpCalendar();

    test('dateOffsetNep forward', () {
      final result = cal.dateOffsetNep(const BsDate(2082, 2, 27), 10);
      // 2082-02-27 = AD 2025-06-10; +10 days = AD 2025-06-20 = 2082-03-06
      expect(result, const BsDate(2082, 3, 6));
    });

    test('dateOffsetNep backward', () {
      final result = cal.dateOffsetNep(const BsDate(2082, 2, 27), -5);
      expect(result, const BsDate(2082, 2, 22));
    });

    test('dateOffsetEng forward', () {
      final result = cal.dateOffsetEng(const AdDate(2025, 6, 10), 10);
      expect(result, const AdDate(2025, 6, 20));
    });
  });

  group('validation', () {
    final cal = DrpCalendar();

    test('isValidBsDate', () {
      expect(cal.isValidBsDate('2082-02-27'), isTrue);
      expect(cal.isValidBsDate('1999-01-01'), isFalse);
      expect(cal.isValidBsDate('2082-13-01'), isFalse);
      expect(cal.isValidBsDate('x'), isFalse);
    });

    test('isValidAdDate', () {
      expect(cal.isValidAdDate('2025-06-10'), isTrue);
      expect(cal.isValidAdDate('2025-02-30'), isFalse);
      expect(cal.isValidAdDate('1900-01-01'), isFalse);
    });

    test('isLeapYear', () {
      expect(cal.isLeapYear(2024), isTrue);
      expect(cal.isLeapYear(2025), isFalse);
      expect(cal.isLeapYear(2000), isTrue);
      expect(cal.isLeapYear(1900), isFalse);
    });
  });

  group('formatting', () {
    final cal = DrpCalendar();

    test('formatBs tokens', () {
      final s = cal.formatBs(const BsDate(2082, 2, 27), 'DD MMMM YYYY');
      expect(s, '27 Jestha 2082');
    });

    test('formatBs short tokens', () {
      expect(cal.formatBs(const BsDate(2082, 2, 7), 'YY/MM/DD'), '82/02/07');
    });

    test('formatAd tokens', () {
      expect(
        cal.formatAd(const AdDate(2025, 6, 10), 'DD MMMM YYYY'),
        '10 June 2025',
      );
      expect(
        cal.formatAd(const AdDate(2025, 6, 10), 'YYYY-MM-DD'),
        '2025-06-10',
      );
    });
  });

  group('calendar grid builders', () {
    final cal = DrpCalendar();

    test('calendarMonthNep returns all days with both calendars', () {
      final month = cal.calendarMonthNep(2082, 2);
      expect(month, isNotNull);
      expect(month!.days.length, 31);
      expect(month.monthName, 'Jestha');
      final day0 = month.days.first;
      expect(day0.bsDate, const BsDate(2082, 2, 1));
      expect(day0.adDate.year, 2025);
    });

    test('calendarMonthEng returns all days with BS equivalents', () {
      final month = cal.calendarMonthEng(2025, 6);
      expect(month, isNotNull);
      expect(month!.days.length, 30);
      final day0 = month.days.first;
      expect(day0.adDate, const AdDate(2025, 6, 1));
      expect(day0.bsDate.year, 2082);
    });

    test('holidays are flagged on matching BS days', () {
      final month = cal.calendarMonthNep(
        2082,
        2,
        holidays: [
          const DrpHoliday(date: BsDate(2082, 2, 15), title: 'Some Holiday'),
        ],
      );
      final holidayDay = month!.days.firstWhere((d) => d.bsDate.date == 15);
      expect(holidayDay.isHoliday, isTrue);
      expect(holidayDay.holidayTitle, 'Some Holiday');

      final normalDay = month.days.firstWhere((d) => d.bsDate.date == 1);
      expect(normalDay.isHoliday, isFalse);
    });

    test('holiday matches via BS in AD-driven grid', () {
      // Find the AD date corresponding to BS 2082-02-15 and verify flag.
      final adOfHoliday = cal.nepToEng(2082, 2, 15)!;
      final month = cal.calendarMonthEng(
        adOfHoliday.year,
        adOfHoliday.month,
        holidays: [
          const DrpHoliday(date: BsDate(2082, 2, 15), title: 'Dashain'),
        ],
      );
      final holidayDay = month!.days.firstWhere(
        (d) => d.bsDate == const BsDate(2082, 2, 15),
      );
      expect(holidayDay.isHoliday, isTrue);
      expect(holidayDay.holidayTitle, 'Dashain');
    });

    test('weekday is Saturday for matching days', () {
      final month = cal.calendarMonthNep(2082, 2)!;
      expect(month.days.every((d) => d.weekday >= 1 && d.weekday <= 7), isTrue);
    });

    test('events attach to matching days with their type', () {
      final month = cal.calendarMonthNep(
        2082,
        2,
        events: const [
          DrpCalendarEvent(
            date: BsDate(2082, 2, 15),
            title: 'Ropain Jayanti',
            type: DrpEventType.festival,
          ),
          DrpCalendarEvent(
            date: BsDate(2082, 2, 20),
            title: 'Payroll deadline',
            type: DrpEventType.deadline,
          ),
        ],
      );
      final festivalDay = month!.days.firstWhere((d) => d.bsDate.date == 15);
      expect(festivalDay.events.length, 1);
      expect(festivalDay.events.first.type, DrpEventType.festival);
      expect(festivalDay.events.first.title, 'Ropain Jayanti');
      expect(
        festivalDay.isHoliday,
        isFalse,
        reason: 'a festival is not a holiday',
      );

      final deadlineDay = month.days.firstWhere((d) => d.bsDate.date == 20);
      expect(deadlineDay.events.first.type, DrpEventType.deadline);

      // An unrelated day has no events.
      final normalDay = month.days.firstWhere((d) => d.bsDate.date == 5);
      expect(normalDay.events, isEmpty);
    });

    test('multiple events on the same day', () {
      final month = cal.calendarMonthNep(
        2082,
        2,
        events: const [
          DrpCalendarEvent(date: BsDate(2082, 2, 15), title: 'Dashain'),
          DrpCalendarEvent(
            date: BsDate(2082, 2, 15),
            title: 'Office closed',
            type: DrpEventType.event,
          ),
        ],
      );
      final day = month!.days.firstWhere((d) => d.bsDate.date == 15);
      expect(day.events.length, 2);
      expect(day.isHoliday, isTrue, reason: 'first event is a holiday');
    });

    test('deprecated holidays param still marks holidays', () {
      final month = cal.calendarMonthNep(
        2082,
        2,
        holidays: const [
          DrpHoliday(date: BsDate(2082, 2, 15), title: 'Some Holiday'),
        ],
      );
      final holidayDay = month!.days.firstWhere((d) => d.bsDate.date == 15);
      expect(holidayDay.isHoliday, isTrue);
      expect(holidayDay.holidayTitle, 'Some Holiday');
    });
  });

  group('digits', () {
    test('toDigits english', () {
      expect(toDigits(27), '27');
      expect(toDigits(27, devanagari: true), '२७');
      expect(toDigitsString('2082-02-27'), '२०८२-०२-२७');
    });
  });
}
