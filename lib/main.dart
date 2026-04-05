import 'package:flutter/material.dart';

import 'app/cherrytree_flutter_app.dart';

// Lets `test/widget_test.dart` and `import …/main.dart as app` integration tests
// keep using `CherrytreeFlutterApp` / `main` without a second import path.
export 'app/cherrytree_flutter_app.dart' show CherrytreeFlutterApp;

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const CherrytreeFlutterApp());
}
