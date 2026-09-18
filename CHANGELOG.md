# 0.0.1

- Initial release of `drp_date_picker`.
- Bikram Sambat (BS) <-> Gregorian (AD) conversion engine (`DrpCalendar`), pure Dart, usable standalone.
- `<DrpDatePicker>` widget with dual-calendar day cells (BS + AD shown together).
- `type` to drive the grid by BS or AD.
- **Typed calendar events**: `DrpCalendarEvent` with `DrpEventType`
  (`holiday`, `festival`, `event`, `deadline`, `custom`), colours, and multiple
  events per day (single dot + combined tooltip).
- Backward-compatible `DrpHoliday` (subclass of `DrpCalendarEvent`) for the
  original `holidays:` API.
- Min/max date constraints, disabled dates, Saturday highlighting.
- Western or Devanagari numerals.
- Configurable first day of week.
- Popup (overlay) and inline presentation.
- Form integration via `DrpDatePickerFormField` and `DrpDatePickerTextFormField`.
- Theming via `DrpDatePickerTheme` (a `ThemeExtension`).