import 'package:drp_date_picker_example/main.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('example app renders pickers', (WidgetTester tester) async {
    await tester.pumpWidget(const DrpExampleApp());
    await tester.pumpAndSettle();

    // Section titles render.
    expect(find.text('Basic BS picker'), findsOneWidget);
    expect(find.text('English (AD) first, with events + holidays'), findsOneWidget);
  });
}
