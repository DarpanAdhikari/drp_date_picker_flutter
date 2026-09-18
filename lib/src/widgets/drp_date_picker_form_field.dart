import 'package:flutter/material.dart';

import '../converters/drp_calendar.dart';
import '../models/bs_date.dart';
import '../models/drp_date.dart';
import '../models/drp_event.dart';
import '../models/drp_holiday.dart';
import '../models/drp_picker_type.dart';
import '../theme/drp_date_picker_theme.dart';
import 'drp_date_picker.dart';

/// A [FormField] that integrates a [DrpDatePicker] into a Flutter [Form],
/// `FormBuilder`, or similar. Supports validation, autovalidate, onSaved, and
/// initial value.
class DrpDatePickerFormField extends FormField<DrpDate?> {
  DrpDatePickerFormField({
    super.key,
    super.validator,
    super.autovalidateMode,
    super.enabled,
    super.initialValue,
    super.onSaved,
    DrpCalendar? calendar,
    DrpPickerType type = DrpPickerType.bs,
    BsDate? minDate,
    AdDate? minDateAd,
    BsDate? maxDate,
    AdDate? maxDateAd,
    bool markSaturday = true,
    DrpDigits digits = DrpDigits.english,
    int firstDayOfWeek = 0,
    List<DrpCalendarEvent> events = const [],
    List<DrpHoliday> holidays = const [],
    List<BsDate> disabledDates = const [],
    String? format,
    String? placeholder,
    String? labelText,
    DrpPopupMode popupMode = DrpPopupMode.popup,
    DrpDatePickerTheme? theme,
    ValueChanged<DrpDate?>? onChanged,
    ValueChanged<BsDate?>? onChangedBS,
    ValueChanged<AdDate?>? onChangedAD,
    InputDecoration? decoration,
  }) : super(
         builder: (FormFieldState<DrpDate?> field) {
           final isEnabled = field.widget.enabled;
           final error = field.errorText;
           final effectiveDecoration = decoration?.copyWith(errorText: error);
           return DrpDatePicker(
             calendar: calendar,
             selectedDate: field.value,
             type: type,
             minDate: minDate,
             minDateAd: minDateAd,
             maxDate: maxDate,
             maxDateAd: maxDateAd,
             markSaturday: markSaturday,
             digits: digits,
             firstDayOfWeek: firstDayOfWeek,
             events: events,
             holidays: holidays,
             disabledDates: disabledDates,
             format: format,
             placeholder: placeholder,
             labelText: labelText,
             popupMode: popupMode,
             theme: theme,
             enabled: isEnabled,
             decoration: effectiveDecoration,
             onChanged: (date) {
               field.didChange(date);
               onChanged?.call(date);
               if (date != null) {
                 onChangedBS?.call(date.bs);
                 onChangedAD?.call(date.ad);
               }
             },
           );
         },
       );

  @override
  FormFieldState<DrpDate?> createState() => FormFieldState<DrpDate?>();
}

/// A ready-to-use text-field-style wrapper around [DrpDatePickerFormField]
/// that applies [InputDecoration].
class DrpDatePickerTextFormField extends StatelessWidget {
  final String? label;
  final String? hintText;
  final String? helperText;
  final String? errorText;
  final FormFieldValidator<DrpDate?>? validator;
  final AutovalidateMode? autovalidateMode;
  final DrpDate? initialValue;
  final DrpCalendar? calendar;
  final DrpPickerType type;
  final BsDate? minDate;
  final AdDate? minDateAd;
  final BsDate? maxDate;
  final AdDate? maxDateAd;
  final bool markSaturday;
  final DrpDigits digits;
  final int firstDayOfWeek;
  final List<DrpCalendarEvent> events;
  final List<DrpHoliday> holidays;
  final List<BsDate> disabledDates;
  final String? format;
  final String? placeholder;
  final DrpPopupMode popupMode;
  final DrpDatePickerTheme? theme;
  final ValueChanged<DrpDate?>? onChanged;
  final ValueChanged<BsDate?>? onChangedBS;
  final ValueChanged<AdDate?>? onChangedAD;
  final bool enabled;

  const DrpDatePickerTextFormField({
    super.key,
    this.label,
    this.hintText,
    this.helperText,
    this.errorText,
    this.validator,
    this.autovalidateMode,
    this.initialValue,
    this.calendar,
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
    this.popupMode = DrpPopupMode.popup,
    this.theme,
    this.onChanged,
    this.onChangedBS,
    this.onChangedAD,
    this.enabled = true,
  });

  @override
  Widget build(BuildContext context) {
    final base = InputDecoration(
      labelText: label,
      hintText: hintText ?? placeholder,
      helperText: helperText,
      errorText: errorText,
    );
    return DrpDatePickerFormField(
      validator: validator,
      autovalidateMode: autovalidateMode,
      initialValue: initialValue,
      calendar: calendar,
      type: type,
      minDate: minDate,
      minDateAd: minDateAd,
      maxDate: maxDate,
      maxDateAd: maxDateAd,
      markSaturday: markSaturday,
      digits: digits,
      firstDayOfWeek: firstDayOfWeek,
      events: events,
      holidays: holidays,
      disabledDates: disabledDates,
      format: format,
      placeholder: placeholder,
      popupMode: popupMode,
      theme: theme,
      enabled: enabled,
      onChanged: onChanged,
      onChangedBS: onChangedBS,
      onChangedAD: onChangedAD,
      decoration: base,
    );
  }
}
