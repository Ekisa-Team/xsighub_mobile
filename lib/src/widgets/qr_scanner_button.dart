import 'package:flutter/material.dart';
import 'package:xsighub_mobile/src/screens/qr_scanner_screen.dart';

class QrScannerButtonWidget extends StatelessWidget {
  const QrScannerButtonWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ElevatedButton.icon(
      onPressed: () {
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const QrScannerScreen()),
        );
      },
      icon: const Icon(Icons.qr_code),
      label: const Text('Escanear código QR'),
    );
  }
}
