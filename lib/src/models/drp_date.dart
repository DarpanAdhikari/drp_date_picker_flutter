import 'package:flutter/foundation.dart';

import 'bs_date.dart';

/// A single selected date carrying both the BS (Nepali) and AD (Gregorian)
/// representations. This is what the picker reports via `onChanged`.
///
/// Both [bs] and [ad] always describe the same instant.
@immutable
class DrpDate {
  final BsDate bs;
  final AdDate ad;

  const DrpDate({required this.bs, required this.ad});

  /// Weekday 1 = Sunday ... 7 = Saturday (derived from the AD date).
  int get weekday {
    // 1970-01-01 was a Thursday (4 in 1=Sunday..7=Saturday).
    final epoch = DateTime.utc(1970, 1, 1);
    final target = DateTime.utc(ad.year, ad.month, ad.date);
    final diff = target.difference(epoch).inDays;
    var wd = (4 + diff) % 7;
    if (wd <= 0) wd += 7;
    return wd;
  }

  /// The BS date in `'YYYY-MM-DD'` form.
  String get bsIso => bs.iso;

  /// The AD date in `'YYYY-MM-DD'` form.
  String get adIso => ad.iso;

  @override
  bool operator ==(Object other) =>
      other is DrpDate && other.bs == bs && other.ad == ad;

  @override
  int get hashCode => Object.hash(bs, ad);

  @override
  String toString() => 'DrpDate(bs=${bs.iso}, ad=${ad.iso})';
}
