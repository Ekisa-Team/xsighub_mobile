import 'package:flutter/material.dart';
import 'package:xsighub_mobile/src/app.dart';
import 'package:xsighub_mobile/src/environment.dart';

void main() {
  const String environment = String.fromEnvironment(
    'ENVIRONMENT',
    defaultValue: Environment.envDevNetwork,
  );

  Environment.init(environment);

  WidgetsFlutterBinding.ensureInitialized();

  runApp(const App());
}
