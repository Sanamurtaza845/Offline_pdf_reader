import 'package:flutter_test/flutter_test.dart';
import 'package:get/get.dart';

import 'package:offline_pdf_reader/core/controllers/theme_controller.dart';
import 'package:offline_pdf_reader/main.dart';

void main() {
  setUp(() {
    Get.testMode = true;
    Get.put(ThemeController(initialDarkMode: false));
  });

  tearDown(() {
    Get.reset();
  });

  testWidgets('Offline PDF Reader app launches successfully',
      (WidgetTester tester) async {
    await tester.pumpWidget(const OfflinePdfReader());

    await tester.pump();

    expect(find.byType(OfflinePdfReader), findsOneWidget);
  });
}