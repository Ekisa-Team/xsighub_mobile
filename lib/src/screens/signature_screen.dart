import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:xsighub_mobile/src/constants/color_constants.dart';
import 'package:xsighub_mobile/src/models/session.dart';
import 'package:xsighub_mobile/src/models/signature_pad_settings.dart';
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
  final _signaturePadSettings = SignaturePadSettings();

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
        title: Text("S:(${widget.pairingKey})"),
        backgroundColor: Colors.black,
        actions: [_buildClearButton(), _buildSaveButton()],
      ),
      body: _buildSignaturePad(),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          _buildCustomizeFloatingButton(),
        ],
      ),
    );
  }

  Widget _buildCustomizeFloatingButton() {
    return FloatingActionButton(
      backgroundColor: ColorConstants.secondary,
      foregroundColor: ColorConstants.white,
      onPressed: () {
        showModalBottomSheet(
          context: context,
          builder: (context) {
            return _buildModalBottomSheet();
          },
        );
      },
      child: const Icon(Icons.palette_outlined),
    );
  }

  Widget _buildClearButton() {
    return IconButton(
      onPressed: _handleClearButtonPressed,
      icon: const Icon(Icons.delete_outline_rounded),
    );
  }

  Widget _buildSaveButton() {
    return ElevatedButton.icon(
      style: successButtonStyle,
      onPressed: _handleSaveButtonPressed,
      icon: const Icon(Icons.upload_rounded),
      label: const Text("Guardar"),
    );
  }

  Widget _buildSignaturePad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
          padding: const EdgeInsets.all(10),
          child: Container(
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.shade600,
                  spreadRadius: 1,
                  blurRadius: 15,
                  offset: const Offset(5, 5),
                ),
                const BoxShadow(
                    color: Colors.white,
                    offset: Offset(-5, -5),
                    blurRadius: 15,
                    spreadRadius: 1),
              ],
            ),
            child: SfSignaturePad(
              key: _signaturePadKey,
              backgroundColor: _signaturePadSettings.backgroundColor,
              strokeColor: _signaturePadSettings.strokeColor,
              minimumStrokeWidth: _signaturePadSettings.minStrokeWidth,
              maximumStrokeWidth: _signaturePadSettings.maxStrokeWidth,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildModalBottomSheet() {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
      child: ListView(
        shrinkWrap: true,
        children: [
          const Text('Modal BottomSheet'),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Background color'),
            onPressed: () async {
              final selectedColor = await showDialog<Color>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Select a color'),
                    content: SingleChildScrollView(
                      child: MaterialPicker(
                        pickerColor: _signaturePadSettings.backgroundColor,
                        onColorChanged: (color) {
                          Navigator.of(context).pop(color);
                        },
                      ),
                    ),
                  );
                },
              );
              if (selectedColor != null) {
                setState(() {
                  _signaturePadSettings.backgroundColor = selectedColor;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            child: const Text('Stroke color'),
            onPressed: () async {
              final selectedColor = await showDialog<Color>(
                context: context,
                builder: (context) {
                  return AlertDialog(
                    title: const Text('Select a color'),
                    content: SingleChildScrollView(
                      child: MaterialPicker(
                        pickerColor: _signaturePadSettings.strokeColor,
                        onColorChanged: (color) {
                          Navigator.of(context).pop(color);
                        },
                      ),
                    ),
                  );
                },
              );
              if (selectedColor != null) {
                setState(() {
                  _signaturePadSettings.strokeColor = selectedColor;
                });
              }
            },
          ),
          const SizedBox(height: 16),
          const Text('Maximum Stroke Width'),
          Slider(
            value: _signaturePadSettings.minStrokeWidth,
            label: _signaturePadSettings.minStrokeWidth.round().toString(),
            min: 0.1,
            max: 3.9,
            onChanged: (value) =>
                setState(() => _signaturePadSettings.minStrokeWidth = value),
          ),
          const SizedBox(height: 16),
          const Text('Maximum Stroke Width'),
          Slider(
            value: _signaturePadSettings.maxStrokeWidth,
            label: _signaturePadSettings.maxStrokeWidth.round().toString(),
            min: 4.0,
            max: 10.0,
            onChanged: (value) =>
                setState(() => _signaturePadSettings.maxStrokeWidth = value),
          ),
          // const SizedBox(height: 16),
          // ElevatedButton(
          //   child: const Text('Close BottomSheet'),
          //   onPressed: () => Navigator.pop(context),
          // ),
        ],
      ),
    );
  }
}
