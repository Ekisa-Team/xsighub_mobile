import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:xsighub_mobile/src/models/session.dart';
import 'package:xsighub_mobile/src/screens/signature_screen.dart';
import 'package:xsighub_mobile/src/services/session_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final _sessionService = SessionService();

  final GlobalKey _gLobalkey = GlobalKey();

  QRViewController? controller;
  Barcode? result;

  void _qr(QRViewController controller) {
    this.controller = controller;
    controller.scannedDataStream.take(1).listen((event) {
      setState(() {
        _connect(event);
      });
    });
  }

  void _connect(Barcode barcode) async {
    try {
      final Session session = await _sessionService.pair(barcode.code ?? '');

      if (context.mounted) {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) =>
                SignatureScreen(pairingKey: session.pairingKey),
          ),
          (route) => false,
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: <Widget>[
          Container(
            height: 400,
            width: 400,
            child: QRView(
              key: _gLobalkey,
              onQRViewCreated: _qr,
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller?.dispose();
    super.dispose();
  }
}
