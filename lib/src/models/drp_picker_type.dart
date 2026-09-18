/// Whether the picker is driven by the Bikram Sambat (BS) or Gregorian (AD)
/// calendar. Determines which date is shown as the "primary" value in the
/// input and which calendar drives the month/year grid.
enum DrpPickerType {
  /// Nepali-first: the grid is driven by the BS calendar and the primary
  /// value is BS, with the AD equivalent shown small.
  bs,

  /// English-first: the grid is driven by the Gregorian calendar and the
  /// primary value is AD, with the BS equivalent shown small.
  ad,
}

/// Which numeral system to display for numeric dates.
enum DrpDigits {
  /// Western digits (1, 2, 3 ... 9).
  english,

  /// Devanagari digits (१, २, ३ ... ९).
  devanagari,
}

/// How the calendar is presented.
enum DrpPopupMode {
  /// Opens as an overlay anchored below the field.
  popup,

  /// Always visible, embedded in the page flow.
  inline,
}
