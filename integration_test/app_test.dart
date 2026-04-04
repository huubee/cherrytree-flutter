// Integration test step logging; prints are intentional for device/CI logs.
// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';

import 'package:cherrytree_flutter/main.dart' as app;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('load -> edit -> background -> relaunch sequence',
      (WidgetTester tester) async {
    // 1. Initial Load
    print("Step 1: Initial load");
    app.main();
    await tester.pumpAndSettle();

    // 2. Add a new root note
    print("Step 2: Add root note");
    final addIcon = find.byIcon(Icons.note_add_outlined);
    expect(addIcon, findsOneWidget);
    await tester.tap(addIcon);
    await tester.pumpAndSettle();

    // 3. Edit title and body
    print("Step 3: Edit note");
    final textFields = find.byType(TextField);
    expect(textFields, findsNWidgets(2));

    final testTitle = 'Integration Test Title ${DateTime.now().millisecondsSinceEpoch}';
    final testBody = 'Integration Test Body ${DateTime.now().millisecondsSinceEpoch}';

    await tester.enterText(textFields.at(0), testTitle);
    await tester.enterText(textFields.at(1), testBody);
    await tester.pumpAndSettle();

    // Wait a brief moment to ensure UI settled
    await tester.pump(const Duration(milliseconds: 500));

    // 4. Simulate Background (triggers immediate save via didChangeAppLifecycleState)
    print("Step 4: Simulate background");
    WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.paused);

    // In Flutter, pumping frames while paused will hang because the engine stops rendering.
    // Instead, immediately transition back to resumed before awaiting the pump.
    print("Step 4.2: Restore to resumed");
    WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    WidgetsBinding.instance.handleAppLifecycleStateChanged(AppLifecycleState.resumed);

    // Give it a moment to run the async save and stop animations
    for (int i = 0; i < 50; i++) {
      await tester.pump(const Duration(milliseconds: 100));
    }

    // 5. Simulate Relaunch
    print("Step 5: Simulate recreate");
    // Unmount the current app to simulate process termination
    await tester.pumpWidget(const SizedBox());
    print("Step 5.1: Pump and settle Sizedbox");
    await tester.pumpAndSettle();

    // Recreate the app widget from scratch.
    print("Step 5.2: app.main()");
    app.main();
    
    print("Step 5.3: final pumpAndSettle");
    await tester.pumpAndSettle();

    // 6. Verify data loaded correctly
    print("Step 6: Verify data");
    // Our test title and body should have persisted to disk and loaded back.
    expect(find.text(testTitle), findsWidgets);
    expect(find.text(testBody), findsWidgets);
    print("Test finished successfully.");
  });
}
