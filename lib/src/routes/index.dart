import 'package:flutter/material.dart';
import 'package:xsighub_mobile/src/screens/document_screen.dart';
import 'package:xsighub_mobile/src/screens/home_screen.dart';
import 'package:xsighub_mobile/src/screens/qr_scanner_screen.dart';
import 'package:xsighub_mobile/src/screens/signature_screen.dart';

Route routes(RouteSettings settings) {
  switch (settings.name) {
    case '/':
      return MaterialPageRoute(builder: (_) => const HomeScreen());

    case '/qr-scanner':
      return MaterialPageRoute(builder: (_) => const QrScannerScreen());

    case '/signature':
      return MaterialPageRoute(builder: (_) => const SignatureScreen());

    case '/documents':
      return MaterialPageRoute(builder: (_) => const DocumentScreen());

    default:
      return MaterialPageRoute(builder: (_) => const HomeScreen());
  }
}
