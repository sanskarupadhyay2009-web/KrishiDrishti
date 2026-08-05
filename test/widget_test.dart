// Basic smoke test: verifies the app boots to the splash screen without
// throwing, and that the app name is visible.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';

import 'package:krishidrishti/main.dart';
import 'package:krishidrishti/providers/app_provider.dart';

void main() {
  testWidgets('App boots and shows splash screen', (WidgetTester tester) async {
    await tester.pumpWidget(
      ChangeNotifierProvider(
        create: (_) => AppProvider(),
        child: const KrishiDrishti(),
      ),
    );

    // Splash screen should be visible immediately.
    expect(find.text('KrishiDrishti'), findsOneWidget);
  });
}
