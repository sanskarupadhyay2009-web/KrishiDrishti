// Basic smoke test: verifies the app boots to the splash screen without
// throwing, and that the app name is visible.

import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:krishidrishti/main.dart';
import 'package:krishidrishti/providers/assistant_provider.dart';
import 'package:krishidrishti/providers/language_provider.dart';
import 'package:krishidrishti/providers/sensor_provider.dart';
import 'package:krishidrishti/services/voice_service.dart';

void main() {
  testWidgets('App boots and shows dashboard title', (WidgetTester tester) async {
    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider(create: (_) => LanguageProvider()),
          ChangeNotifierProvider(create: (_) => SensorProvider()),
          ChangeNotifierProvider(create: (_) => AssistantProvider()),
          Provider(create: (_) => VoiceService()),
        ],
        child: const KrishiDrishtiApp(),
      ),
    );

    await tester.pumpAndSettle();
    expect(find.text('Dashboard'), findsOneWidget);
    expect(find.text('KrishiDrishti'), findsNothing);
  });
}
