import 'package:flutter/material.dart';
import 'package:xsighub_mobile/src/screens/home_screen.dart';
import 'package:xsighub_mobile/src/screens/signature_screen.dart';

Route routes(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const HomeScreen());

    case '/sessions':
      return MaterialPageRoute(builder: (_) => const SignatureScreen());

    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
