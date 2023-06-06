import 'dart:io';

import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsighub_mobile/src/screens/home_screen.dart';
import 'package:xsighub_mobile/src/services/session_service.dart';

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({Key? key}) : super(key: key);

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  late final _sessionService = SessionService();
  late final _qrKey = GlobalKey();

  QRViewController? _controller;
  String? _scannedCode;

  @override
  void reassemble() {
    super.reassemble();

    Platform.isAndroid
        ? _controller!.pauseCamera()
        : _controller!.resumeCamera();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: Stack(
        children: [_buildQrScanner(), _buildActions()],
      ),
    );
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  Widget _buildQrScanner() {
    var scanArea = (MediaQuery.of(context).size.width < 400 ||
            MediaQuery.of(context).size.height < 400)
        ? 150.0
        : 300.0;

    return QRView(
      key: _qrKey,
      onQRViewCreated: _onQRViewCreated,
      overlay: QrScannerOverlayShape(
        borderColor: Colors.red,
        borderRadius: 10,
        borderLength: 30,
        borderWidth: 10,
        cutOutSize: scanArea,
      ),
      onPermissionSet: (ctrl, p) => _onPermissionSet(context, ctrl, p),
    );
  }

  Widget _buildActions() {
    return Align(
      alignment: Alignment.bottomCenter,
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: FutureBuilder(
          future: _controller?.getFlashStatus(),
          builder: (context, snapshot) {
            bool isFlashOn = snapshot.data ?? false;

            return ElevatedButton.icon(
              onPressed: () {
                _controller?.toggleFlash();
                setState(() {});
              },
              icon: isFlashOn
                  ? const Icon(Icons.flash_off)
                  : const Icon(Icons.flash_on),
              label: const Text("Linterna"),
            );
          },
        ),
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    setState(() {
      _controller = controller;
    });

    _controller!.scannedDataStream.take(1).listen((event) => _connect(event));
  }

  void _onPermissionSet(
    BuildContext context,
    QRViewController ctrl,
    bool permission,
  ) {
    if (!permission) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('No se otorgaron permisos para acceder a la cámara.'),
        ),
      );
    }
  }

  void _connect(Barcode scannedData) async {
    try {
      _scannedCode = scannedData.code;

      await _sessionService.pair(_scannedCode.toString());

      final prefs = await SharedPreferences.getInstance();

      await prefs.setString('pairingKey', _scannedCode.toString());

      if (context.mounted) {
        Navigator.of(context).pop();
        Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => const HomeScreen()),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }
}
