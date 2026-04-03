import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cherrytree_flutter/main.dart';

void main() {
  testWidgets('MaterialApp mounts', (WidgetTester tester) async {
    await tester.pumpWidget(const CherrytreeFlutterApp());
    expect(find.byType(MaterialApp), findsOneWidget);
  });
}
