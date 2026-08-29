import 'package:flutter_test/flutter_test.dart';
import 'package:precisioncare_app/main.dart';

void main() {
  testWidgets('PrecisionCare app smoke test', (WidgetTester tester) async {
    await tester.pumpWidget(const PrecisionCareApp());
    await tester.pump(const Duration(milliseconds: 100));
    expect(find.byType(PrecisionCareApp), findsOneWidget);
    await tester.pump(const Duration(milliseconds: 500));
  });
}
