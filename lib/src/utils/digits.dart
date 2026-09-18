import '../converters/bs_data.dart';

/// Converts a number to a numeral string in the given system.
///
/// With [devanagari] = true, Western digits are replaced with Devanagari
/// numerals (०-९).
String toDigits(int value, {bool devanagari = false}) {
  final s = value.toString();
  if (!devanagari) return s;
  final buffer = StringBuffer();
  for (final ch in s.split('')) {
    if (ch.codeUnitAt(0) >= 0x30 && ch.codeUnitAt(0) <= 0x39) {
      buffer.write(nepaliDigits[ch.codeUnitAt(0) - 0x30]);
    } else {
      buffer.write(ch);
    }
  }
  return buffer.toString();
}

/// Converts a raw string (e.g. an ISO date) to Devanagari digits.
String toDigitsString(String value) {
  final buffer = StringBuffer();
  for (final ch in value.split('')) {
    final code = ch.codeUnitAt(0);
    if (code >= 0x30 && code <= 0x39) {
      buffer.write(nepaliDigits[code - 0x30]);
    } else {
      buffer.write(ch);
    }
  }
  return buffer.toString();
}

/// The full weekday name for a [DrpCalendarDay] (1 = Sunday ... 7 = Saturday).
String weekdayName(int weekday) => [
  '',
  'Sunday',
  'Monday',
  'Tuesday',
  'Wednesday',
  'Thursday',
  'Friday',
  'Saturday',
][weekday];
