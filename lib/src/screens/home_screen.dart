import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:xsighub_mobile/src/models/session.dart';
import 'package:xsighub_mobile/src/screens/qr_scanner_screen.dart';
import 'package:xsighub_mobile/src/screens/signature_screen.dart';
import 'package:xsighub_mobile/src/services/session_service.dart';
import 'package:xsighub_mobile/src/theme/button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sessionService = SessionService();

  final _formKey = GlobalKey<FormState>();
  final _pairingKeyController = TextEditingController();

  void _connect() async {
    try {
      final Session session = await _sessionService.pair(
        _pairingKeyController.text,
      );

      if (context.mounted) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) =>
                SignatureScreen(pairingKey: session.pairingKey),
          ),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(error.toString())),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: _buildForm(),
                    ),
                  ),
                  const SizedBox(height: 16.0),
                  Hero(
                    tag: 'scanButton',
                    child: _buildScanButton(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            const Text(
              'Xsighub - v0.0.0',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16.0),
            ),
            const SizedBox(height: 16.0),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _pairingKeyController,
            keyboardType: TextInputType.number,
            decoration:
                const InputDecoration(hintText: '### ###', filled: true),
            style: const TextStyle(fontSize: 60),
            maxLength: 6,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            textAlign: TextAlign.center,
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'Ingrese un código de emparejamiento válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          ElevatedButton(
            style: primaryButtonStyle,
            onPressed: () {
              if (_formKey.currentState!.validate()) {
                _connect();
              }
            },
            child: const Text('Conectar'),
          ),
        ],
      ),
    );
  }

  Widget _buildScanButton() {
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
