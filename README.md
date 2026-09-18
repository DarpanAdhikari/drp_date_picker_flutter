# drp_date_picker

> A native Flutter **Nepali (Bikram Sambat / BS) + English (Gregorian / AD)** date picker.
> Every day cell shows both calendars. BS ↔ AD conversion included, with holiday
> support, min/max constraints, and form integration.

[![pub version](https://img.shields.io/pub/v/drp_date_picker)](https://pub.dev/packages/drp_date_picker)
[![license](https://img.shields.io/badge/license-MIT-brightgreen)](LICENSE)

---

## What is drp_date_picker?

`drp_date_picker` is a production-oriented Flutter date picker for applications
that need to work with both the **Nepali Bikram Sambat (BS)** calendar and the
**English Gregorian (AD)** calendar.

- **It solves:** picking dates in BS while always keeping the AD equivalent in
  sync — and vice versa. No manual conversion, no hidden text fields.
- **Why it's different:** most Nepali date pickers in Flutter only show one
  calendar or are thin wrappers. `drp_date_picker` renders **both BS and AD on
  every day cell**, ships a **standalone conversion engine**, supports
  **developer-provided holidays and typed events**, and integrates with
  **Flutter `Form`** natively.
- **Zero runtime dependencies** — pure Flutter, no plugins.

### Use cases

- Nepali government & civic applications
- School / college & university systems
- HR / payroll systems
- Accounting / ERP software
- Banking & business applications
- Booking & scheduling systems
- Any app that must capture or display **BS + AD dates**
- Apps with **custom holiday** calendars (Dashain, Tihar, national holidays, etc.)

---

## Installation

```bash
flutter pub add drp_date_picker
```

Requires Dart >= 3.12 and Flutter >= 3.0 (Material 3 recommended but not required).

---

## Quick start (30 seconds)

```dart
import 'package:drp_date_picker/drp_date_picker.dart';
import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(home: Scaffold(body: Demo())));

class Demo extends StatelessWidget {
  const Demo({super.key});

  @override
  Widget build(BuildContext context) {
    return DrpDatePicker(
      onChanged: (date) {
        // date is a DrpDate carrying both calendars.
        print('BS: ${date?.bs.iso}  AD: ${date?.ad.iso}');
      },
    );
  }
}
```

That's it. The picker defaults to **BS-primary** mode (Nepali date in the input,
English shown small in each cell), opens as an overlay anchored to the field, and
supports keyboard and screen-reader-friendly interactions.

---

## BS + AD support

Every date is returned as a [`DrpDate`](#drpdate), which always carries **both**
representations of the same instant:

```dart
onChanged: (DrpDate? date) {
  date?.bs.year; // BS year, e.g. 2082
  date?.bs.iso;  // '2082-02-27'
  date?.ad.year; // AD year, e.g. 2025
  date?.ad.iso;  // '2025-06-10'
}
```

### Primary calendar (`type`)

- `type: DrpPickerType.bs` (default) — grid driven by BS; BS shown large.
- `type: DrpPickerType.ad` — grid driven by AD; AD shown large.

```dart
DrpDatePicker(type: DrpPickerType.ad);
```

### Standalone conversion engine

`DrpCalendar` is a pure-Dart BS ↔ AD engine you can use **without any UI**:

```dart
final cal = DrpCalendar();

final bs = cal.engToNep(2025, 6, 10);      // BsDate(2082, 2, 27)
final ad = cal.nepToEng(2082, 2, 27);      // AdDate(2025, 6, 10)

cal.isValidBsDate('2082-02-27');           // true
cal.formatBs(bs!, 'DD MMMM YYYY');         // '27 Jestha 2082'
final month = cal.calendarMonthNep(2082, 2); // full month grid, both calendars
```

> Supported ranges: **BS 2000–2098** / **AD 1944–2041**.

---

## Holidays & events

The calendar supports **typed events** — holidays, festivals, deadlines,
bookings, and more — all shown as an accent dot with a tooltip. Dates are
**developer-provided** and always specified in **BS** (canonical), regardless
of the picker's `type`. Multiple events can fall on the same day.

### Holidays (simple)

Use `DrpHoliday` (a thin, backward-compatible event subclass):

```dart
final holidays = [
  const DrpHoliday(date: BsDate(2082, 1, 1),  title: 'Nepali New Year'),
  const DrpHoliday(date: BsDate(2082, 7, 10), title: 'Vijaya Dashami'),
  const DrpHoliday(date: BsDate(2082, 10, 15), title: 'Tihar'),
];

DrpDatePicker(holidays: holidays);
```

### Typed events (general)

For other calendar markers, use `DrpCalendarEvent` with a `DrpEventType`:

```dart
final events = [
  const DrpCalendarEvent(
    date: BsDate(2082, 2, 15),
    title: 'Office closed',
    type: DrpEventType.event,       // holiday | festival | event | deadline | custom
  ),
  const DrpCalendarEvent(
    date: BsDate(2082, 2, 28),
    title: 'Salary day',
    type: DrpEventType.deadline,
    color: Colors.green,            // optional per-event colour
  ),
];

DrpDatePicker(events: events);
```

- `events` and `holidays` can be combined.
- Days with events show a **single dot** (first event's colour) and a
  **tooltip** listing all titles.
- `DrpHoliday` is just `DrpCalendarEvent` with `type: DrpEventType.holiday`, so
  it can also be placed in the `events` list.

No events are hard-coded. Build the lists from your own data, an API, or a
static file.

---

## Configuration

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `type` | `DrpPickerType` | `bs` | Calendar that drives the grid (`bs` \| `ad`) |
| `initialDate` | `DrpDate?` | — | Initial selection (uncontrolled) |
| `selectedDate` | `DrpDate?` | — | Controlled selection (picker follows it) |
| `minDate` / `minDateAd` | `BsDate?` / `AdDate?` | — | Earliest selectable date (inclusive) |
| `maxDate` / `maxDateAd` | `BsDate?` / `AdDate?` | — | Latest selectable date (inclusive) |
| `disabledDates` | `List<BsDate>` | `[]` | Specific BS dates to disable |
| `events` | `List<DrpCalendarEvent>` | `[]` | Developer-provided typed events (holidays, festivals, deadlines, ...) |
| `holidays` | `List<DrpHoliday>` | `[]` | **Deprecated.** Holiday shortcut for `events` |
| `markSaturday` | `bool` | `true` | Highlight Saturdays in the accent colour |
| `digits` | `DrpDigits` | `english` | `english` \| `devanagari` numerals |
| `firstDayOfWeek` | `int` | `0` | `0`=Sunday … `6`=Saturday |
| `format` | `String?` | — | Display format (tokens below) |
| `placeholder` | `String?` | — | Input hint text |
| `popupMode` | `DrpPopupMode` | `popup` | `popup` \| `inline` |
| `enabled` | `bool` | `true` | Enable/disable the field |
| `theme` | `DrpDatePickerTheme?` | — | Styling override |

`minDate` / `maxDate` can be given in **either** BS or AD (or both); the picker
enforces whichever is tighter.

### Format tokens

Used by the `format` parameter. Numeric tokens respect the `digits` setting.

| Token | Example (BS) | Example (AD) |
|-------|--------------|--------------|
| `YYYY` | `2082` | `2025` |
| `YY` | `82` | `25` |
| `MMMM` | `Jestha` | `June` |
| `MM` | `02` | `06` |
| `M` | `2` | `6` |
| `DD` | `27` | `27` |
| `D` | `27` | `27` |

```dart
DrpDatePicker(format: 'DD MMMM YYYY'); // '27 Jestha 2082' (BS) / '10 June 2025' (AD)
```

---

## Callbacks

| Callback | Signature | When |
|----------|-----------|------|
| `onChanged` | `ValueChanged<DrpDate?>` | Any selection or clear (both calendars) |
| `onChangedBS` | `ValueChanged<BsDate?>` | Selection/clear, BS-only |
| `onChangedAD` | `ValueChanged<AdDate?>` | Selection/clear, AD-only |
| `onPanelOpen` | `VoidCallback` | Popup opens |
| `onPanelClose` | `VoidCallback` | Popup closes |

```dart
DrpDatePicker(
  onChanged: (d) => save(d),
  onChangedBS: (bs) => log('BS ${bs?.iso}'),
  onChangedAD: (ad) => log('AD ${ad?.iso}'),
);
```

---

## Form usage

Use `DrpDatePickerFormField` (a `FormField<DrpDate?>`) or the convenience
`DrpDatePickerTextFormField` to integrate with Flutter's `Form` — validation,
`autovalidateMode`, `onSaved`, and required-field behaviour all work.

```dart
final _formKey = GlobalKey<FormState>();

Form(
  key: _formKey,
  child: Column(
    children: [
      DrpDatePickerTextFormField(
        label: 'Delivery date',
        validator: (v) => v == null ? 'Please select a date' : null,
      ),
      ElevatedButton(
        onPressed: () => _formKey.currentState!.validate(),
        child: const Text('Submit'),
      ),
    ],
  ),
)
```

---

## Customization

Style the picker globally through a `ThemeExtension`, or pass a `DrpDatePickerTheme`
directly:

```dart
ThemeData(
  extensions: [
    const DrpDatePickerTheme(
      accent: Color(0xFFB3352B),
      today: Color(0xFF1F4B7A),
      panelBackground: Color(0xFFFFFFFF),
      radius: 14,
    ),
  ],
)
```

Available theme fields: `accent`, `accentSoft`, `today`, `inputBackground`,
`panelBackground`, `border`, `text`, `muted`, `holiday`, `radius`. Unset fields
fall back to sensible defaults from the ambient `ColorScheme` (dark-mode
friendly).

---

## Examples

- `example/` — a complete app demonstrating BS and AD modes, holidays,
  Devanagari digits, inline layout, min/max, and form validation.

Run it:

```bash
cd example
flutter run
```

---

## Troubleshooting

**The popup doesn't open** — make sure `enabled: true` and the widget is inside a
`MaterialApp` (it needs an `Overlay`). If you're using `popupMode: inline`, no
overlay is used.

**Holidays don't show** — holiday dates must be in **BS** format (`BsDate`). If
your source data is AD, convert with `DrpCalendar().engToNep(...)` first. Dates
outside BS 2000–2098 are ignored.

**I want the input in English but the grid in Nepali (or vice versa)** — set
`type` to control the grid and `format`/`digits` to control display.

---

## Contributing

Contributions are welcome. Please:

1. Fork the repository.
2. Make changes on a feature branch.
3. Run `flutter analyze` and `flutter test`.
4. Open a pull request.

Guidelines: keep it dependency-free, maintain backward compatibility, add tests
for new behaviour.

---

## License

MIT — see [LICENSE](LICENSE).