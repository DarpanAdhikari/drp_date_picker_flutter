import 'package:flutter/material.dart';

/// Theme configuration for `drp_date_picker` widgets.
///
/// Wire this into your app theme via `ThemeData.extensions`, or pass an
/// instance directly to a picker. Any null field falls back to a sensible
/// default derived from the surrounding `ColorScheme`.
@immutable
class DrpDatePickerTheme extends ThemeExtension<DrpDatePickerTheme> {
  /// Accent colour: selected day, Saturday, holiday accent.
  final Color? accent;

  /// Soft accent: hover / panel highlights.
  final Color? accentSoft;

  /// Today's outline ring colour.
  final Color? today;

  /// Background of the input field.
  final Color? inputBackground;

  /// Background of the calendar panel.
  final Color? panelBackground;

  /// Border colour.
  final Color? border;

  /// Primary text colour.
  final Color? text;

  /// Muted / secondary text colour.
  final Color? muted;

  /// Holiday dot colour.
  final Color? holiday;

  /// Corner radius for the panel.
  final double? radius;

  const DrpDatePickerTheme({
    this.accent,
    this.accentSoft,
    this.today,
    this.inputBackground,
    this.panelBackground,
    this.border,
    this.text,
    this.muted,
    this.holiday,
    this.radius,
  });

  static const DrpDatePickerTheme fallback = DrpDatePickerTheme(
    accent: Color(0xFFB3352B),
    accentSoft: Color(0xFFF4DED9),
    today: Color(0xFF1F4B7A),
    inputBackground: Color(0xFFFFFFFF),
    panelBackground: Color(0xFFFFFFFF),
    border: Color(0xFFE7DFD2),
    text: Color(0xFF2A241D),
    muted: Color(0xFF8C8272),
    holiday: Color(0xFFB3352B),
    radius: 12,
  );

  /// Resolves a theme from the ambient context, falling back to a scheme-based
  /// default when the extension is not present.
  factory DrpDatePickerTheme.of(BuildContext context) {
    final ext = Theme.of(context).extension<DrpDatePickerTheme>();
    final scheme = Theme.of(context).colorScheme;
    if (ext != null) {
      return ext._resolveMissing(scheme);
    }
    return _fromScheme(scheme);
  }

  DrpDatePickerTheme _resolveMissing(ColorScheme scheme) => DrpDatePickerTheme(
    accent: accent ?? _schemeAccent(scheme),
    accentSoft: accentSoft ?? accent?.withValues(alpha: 0.15),
    today:
        today ??
        (scheme.brightness == Brightness.dark
            ? scheme.primary
            : scheme.secondary),
    inputBackground: inputBackground ?? scheme.surface,
    panelBackground: panelBackground ?? scheme.surface,
    border: border ?? scheme.outlineVariant,
    text: text ?? scheme.onSurface,
    muted: muted ?? scheme.onSurfaceVariant,
    holiday: holiday ?? (accent ?? _schemeAccent(scheme)),
    radius: radius ?? 12,
  );

  static DrpDatePickerTheme _fromScheme(ColorScheme scheme) =>
      DrpDatePickerTheme(
        accent: _schemeAccent(scheme),
        accentSoft: _schemeAccent(scheme).withValues(alpha: 0.15),
        today: scheme.brightness == Brightness.dark
            ? scheme.primary
            : scheme.secondary,
        inputBackground: scheme.surface,
        panelBackground: scheme.surface,
        border: scheme.outlineVariant,
        text: scheme.onSurface,
        muted: scheme.onSurfaceVariant,
        holiday: _schemeAccent(scheme),
        radius: 12,
      );

  static Color _schemeAccent(ColorScheme scheme) =>
      scheme.brightness == Brightness.dark ? scheme.primary : scheme.tertiary;

  @override
  DrpDatePickerTheme copyWith({
    Color? accent,
    Color? accentSoft,
    Color? today,
    Color? inputBackground,
    Color? panelBackground,
    Color? border,
    Color? text,
    Color? muted,
    Color? holiday,
    double? radius,
  }) {
    return DrpDatePickerTheme(
      accent: accent ?? this.accent,
      accentSoft: accentSoft ?? this.accentSoft,
      today: today ?? this.today,
      inputBackground: inputBackground ?? this.inputBackground,
      panelBackground: panelBackground ?? this.panelBackground,
      border: border ?? this.border,
      text: text ?? this.text,
      muted: muted ?? this.muted,
      holiday: holiday ?? this.holiday,
      radius: radius ?? this.radius,
    );
  }

  @override
  DrpDatePickerTheme lerp(DrpDatePickerTheme? other, double t) {
    if (other == null) return this;
    Color? c(Color? a, Color? b) =>
        a == null || b == null ? null : Color.lerp(a, b, t);
    return DrpDatePickerTheme(
      accent: c(accent, other.accent),
      accentSoft: c(accentSoft, other.accentSoft),
      today: c(today, other.today),
      inputBackground: c(inputBackground, other.inputBackground),
      panelBackground: c(panelBackground, other.panelBackground),
      border: c(border, other.border),
      text: c(text, other.text),
      muted: c(muted, other.muted),
      holiday: c(holiday, other.holiday),
      radius: t < 0.5 ? radius : other.radius,
    );
  }
}
