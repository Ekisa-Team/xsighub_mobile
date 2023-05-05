import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:xsighub_mobile/src/models/session.dart';
import 'package:xsighub_mobile/src/services/session_service.dart';
import 'package:xsighub_mobile/src/theme/button.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({Key? key, this.pairingKey}) : super(key: key);

  final String? pairingKey;

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  final _sessionService = SessionService();

  final _signaturePadKey = GlobalKey<SfSignaturePadState>();

  @override
  void initState() {
    super.initState();
  }

  void _handleClearButtonPressed() {
    _signaturePadKey.currentState!.clear();
  }

  void _handleSaveButtonPressed() async {
    final signatureData = await _signaturePadKey.currentState!.toImage();
    final bytes = await signatureData.toByteData(format: ImageByteFormat.png);
    final imageEncoded =
        "data:image/png;base64,${base64.encode(bytes!.buffer.asUint8List())}";

    await _sessionService.update(
      widget.pairingKey ?? '',
      SessionData(signature: imageEncoded),
    );

    _signaturePadKey.currentState!.clear();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("Firma - ${widget.pairingKey}"),
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.delete_outline_rounded),
            onPressed: () {
              _handleClearButtonPressed();
            },
          ),
          IconButton(
            icon: const Icon(Icons.save),
            style: successButtonStyle,
            onPressed: () {
              _handleSaveButtonPressed();
            },
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Padding(
            padding: const EdgeInsets.all(10),
            child: Container(
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade400),
              ),
              child: SfSignaturePad(
                key: _signaturePadKey,
                backgroundColor: Colors.white,
                strokeColor: Colors.black,
                minimumStrokeWidth: 1,
                maximumStrokeWidth: 4.0,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
