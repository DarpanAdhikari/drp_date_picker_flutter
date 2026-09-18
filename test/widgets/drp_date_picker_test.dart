import 'package:drp_date_picker/drp_date_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

void main() {
  group('DrpDatePicker selection', () {
    testWidgets('shows selected date and fires onChanged on selection', (
      tester,
    ) async {
      DrpDate? changed;
      await tester.pumpWidget(
        wrap(
          DrpDatePicker(type: DrpPickerType.bs, onChanged: (d) => changed = d),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Select a day in the visible month.
      await tester.tap(find.byType(InkWell).at(5));
      await tester.pumpAndSettle();

      expect(changed, isNotNull);
      expect(changed!.bs.year, greaterThan(2000));
      expect(changed!.ad.year, greaterThan(1940));
    });

    testWidgets('puts the selected date into the field and closes the popup', (
      tester,
    ) async {
      await tester.pumpWidget(
        wrap(DrpDatePicker(type: DrpPickerType.bs, onChanged: (d) {})),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Popup visible.
      expect(
        find.byKey(const ValueKey('drp-date-picker-popup')),
        findsOneWidget,
      );

      // Pick a specific day (the 15th of the visible BS month).
      await tester.tap(find.text('15').first);
      await tester.pumpAndSettle();

      // Popup closed.
      expect(find.byKey(const ValueKey('drp-date-picker-popup')), findsNothing);

      // The field now shows the selected date.
      final field = tester.widget<TextField>(find.byType(TextField));
      expect(field.controller!.text, isNotEmpty);
      expect(field.controller!.text, contains('15'));
    });
  });

  group('holidays', () {
    testWidgets('shows a Tooltip on a holiday day', (tester) async {
      // Holiday BS 2082-02-15 = AD 2025-05-29.
      final holidays = [
        const DrpHoliday(date: BsDate(2082, 2, 15), title: 'Ropain Jayanti'),
      ];

      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 10),
              ad: AdDate(2025, 5, 24),
            ),
            holidays: holidays,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Locate the holiday cell (BS date 15).
      final tooltip = find.byWidgetPredicate(
        (w) => w is Tooltip && w.message == 'Ropain Jayanti',
      );
      expect(tooltip, findsOneWidget);
    });

    testWidgets('shows a combined tooltip for multiple events on one day', (
      tester,
    ) async {
      final events = [
        const DrpCalendarEvent(
          date: BsDate(2082, 2, 15),
          title: 'Dashain',
          type: DrpEventType.holiday,
        ),
        const DrpCalendarEvent(
          date: BsDate(2082, 2, 15),
          title: 'Office closed',
          type: DrpEventType.event,
        ),
      ];

      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 10),
              ad: AdDate(2025, 5, 24),
            ),
            events: events,
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final tooltip = find.byWidgetPredicate(
        (w) => w is Tooltip && w.message == 'Dashain\nOffice closed',
      );
      expect(tooltip, findsOneWidget);
    });
  });

  group('min/max', () {
    testWidgets('disables days outside min/max', (tester) async {
      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            minDate: const BsDate(2082, 2, 10),
            maxDate: const BsDate(2082, 2, 20),
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 15),
              ad: AdDate(2025, 5, 29),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Day cells disabled before min: check the InkWell has no tap.
      final disabledCells = tester.widgetList<InkWell>(find.byType(InkWell));
      final withNullTap = disabledCells.where((w) => w.onTap == null);
      expect(
        withNullTap.isNotEmpty,
        isTrue,
        reason: 'Expected some day cells to be disabled',
      );
    });
  });

  group('month/year navigation', () {
    testWidgets('navigates to next month', (tester) async {
      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 1),
              ad: AdDate(2025, 5, 15),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final nextBtn = find.byTooltip('Next month');
      expect(nextBtn, findsOneWidget);
      await tester.tap(nextBtn);
      await tester.pumpAndSettle();
      // Header should now show Jestha -> Ashadh (2082-03).
      expect(find.textContaining('Ashadh'), findsOneWidget);
    });

    testWidgets('shows month picker on header tap', (tester) async {
      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 1),
              ad: AdDate(2025, 5, 15),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Jestha 2082'));
      await tester.pumpAndSettle();

      expect(find.text('Baisakh'), findsOneWidget);
      expect(find.text('Chaitra'), findsOneWidget);
    });
  });

  group('digits', () {
    testWidgets('renders Devanagari digits in the input', (tester) async {
      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            digits: DrpDigits.devanagari,
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 27),
              ad: AdDate(2025, 6, 10),
            ),
          ),
        ),
      );

      await tester.pumpAndSettle();
      expect(find.text('२७ जेठ २०८२'), findsOneWidget);
    });
  });

  group('focus open/close', () {
    testWidgets('opens popup on field focus', (tester) async {
      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 1),
              ad: AdDate(2025, 5, 15),
            ),
          ),
        ),
      );

      expect(find.byTooltip('Next month'), findsNothing);

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      // Popup visible (month header present).
      expect(find.byTooltip('Next month'), findsOneWidget);
    });

    testWidgets('closes popup on focus loss', (tester) async {
      await tester.pumpWidget(
        wrap(
          Column(
            children: [
              DrpDatePicker(
                type: DrpPickerType.bs,
                initialDate: const DrpDate(
                  bs: BsDate(2082, 2, 1),
                  ad: AdDate(2025, 5, 15),
                ),
              ),
              TextField(),
            ],
          ),
        ),
      );

      await tester.tap(find.byType(TextField).first);
      await tester.pumpAndSettle();
      expect(find.byTooltip('Next month'), findsOneWidget);

      // Focus the second field -> picker loses focus -> popup closes.
      await tester.tap(find.byType(TextField).at(1));
      await tester.pumpAndSettle();

      expect(find.byTooltip('Next month'), findsNothing);
    });
  });

  group('form integration', () {
    testWidgets('validates required date via Form', (tester) async {
      final formKey = GlobalKey<FormState>();

      await tester.pumpWidget(
        wrap(
          Form(
            key: formKey,
            child: Column(
              children: [
                DrpDatePickerTextFormField(
                  validator: (v) => v == null ? 'Please select a date' : null,
                  onChanged: (d) {},
                ),
                ElevatedButton(
                  onPressed: () {
                    formKey.currentState!.validate();
                  },
                  child: const Text('Submit'),
                ),
              ],
            ),
          ),
        ),
      );

      await tester.tap(find.text('Submit'));
      await tester.pumpAndSettle();

      expect(find.text('Please select a date'), findsOneWidget);
    });
  });

  group('responsive popup positioning', () {
    Finder popup() => find.byKey(const ValueKey('drp-date-picker-popup'));

    void setSurface(WidgetTester tester, Size size) {
      tester.view.physicalSize = size;
      tester.view.devicePixelRatio = 1.0;
      addTearDown(tester.view.reset);
    }

    testWidgets('opens below the field when there is room', (tester) async {
      setSurface(tester, const Size(800, 1200));

      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 1),
              ad: AdDate(2025, 5, 15),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final field = tester.getRect(find.byType(TextField));
      final popupRect = tester.getRect(popup());

      expect(popupRect.top, greaterThanOrEqualTo(field.bottom));
      expect(popupRect.bottom, lessThanOrEqualTo(1200));
    });

    testWidgets('flips above the field when near the bottom', (tester) async {
      setSurface(tester, const Size(800, 1000));

      await tester.pumpWidget(
        wrap(
          Align(
            alignment: Alignment.bottomCenter,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: DrpDatePicker(
                type: DrpPickerType.bs,
                initialDate: const DrpDate(
                  bs: BsDate(2082, 2, 1),
                  ad: AdDate(2025, 5, 15),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final field = tester.getRect(find.byType(TextField));
      final popupRect = tester.getRect(popup());

      // Popup should appear above the field and stay fully on-screen.
      expect(popupRect.bottom, lessThanOrEqualTo(field.top));
      expect(popupRect.top, greaterThanOrEqualTo(0));
    });

    testWidgets('clamps horizontally near the right edge', (tester) async {
      setSurface(tester, const Size(1000, 1200));

      await tester.pumpWidget(
        wrap(
          Align(
            alignment: Alignment.centerRight,
            child: Padding(
              padding: const EdgeInsets.only(right: 8),
              child: DrpDatePicker(
                type: DrpPickerType.bs,
                initialDate: const DrpDate(
                  bs: BsDate(2082, 2, 1),
                  ad: AdDate(2025, 5, 15),
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final popupRect = tester.getRect(popup());
      expect(popupRect.right, lessThanOrEqualTo(1000));
      expect(popupRect.left, greaterThanOrEqualTo(0));
    });

    testWidgets('shrinks width on a narrow viewport', (tester) async {
      setSurface(tester, const Size(240, 800));

      await tester.pumpWidget(
        wrap(
          DrpDatePicker(
            type: DrpPickerType.bs,
            initialDate: const DrpDate(
              bs: BsDate(2082, 2, 1),
              ad: AdDate(2025, 5, 15),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      final popupRect = tester.getRect(popup());
      // 240 - 2*8 margin = 224 max.
      expect(popupRect.width, lessThanOrEqualTo(240 - 16));
      expect(popupRect.right, lessThanOrEqualTo(240));
    });

    testWidgets('re-positions while scrolling so it stays visible', (
      tester,
    ) async {
      setSurface(tester, const Size(800, 600));

      // The field is visible near the top of an 800px-tall scroll area.
      await tester.pumpWidget(
        wrap(
          SingleChildScrollView(
            child: SizedBox(
              height: 800,
              child: Padding(
                padding: const EdgeInsets.only(top: 100),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    DrpDatePicker(
                      type: DrpPickerType.bs,
                      initialDate: const DrpDate(
                        bs: BsDate(2082, 2, 1),
                        ad: AdDate(2025, 5, 15),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(TextField));
      await tester.pumpAndSettle();

      var field = tester.getRect(find.byType(TextField));
      var popupRect = tester.getRect(popup());
      expect(popupRect.top, greaterThanOrEqualTo(field.bottom));

      // Scroll down while the popup is open — the popup must track the field
      // and stay on-screen.
      await tester.dragFrom(const Offset(700, 60), const Offset(0, -120));
      await tester.pumpAndSettle();

      field = tester.getRect(find.byType(TextField));
      popupRect = tester.getRect(popup());
      expect(popupRect.bottom, lessThanOrEqualTo(600));
      expect(popupRect.top, greaterThanOrEqualTo(0));
      // Still attached to the field (either just below or just above it).
      final below = popupRect.top >= field.bottom;
      final above = popupRect.bottom <= field.top;
      expect(
        below || above,
        isTrue,
        reason:
            'popup should hug the field after scrolling: '
            'field=$field popup=$popupRect',
      );
    });
  });
}
