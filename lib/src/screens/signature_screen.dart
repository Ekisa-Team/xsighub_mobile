import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:xsighub_mobile/src/constants/color_constants.dart';
import 'package:xsighub_mobile/src/models/session.dart';
import 'package:xsighub_mobile/src/models/signature_pad_settings.dart';
import 'package:xsighub_mobile/src/screens/home_screen.dart';
import 'package:xsighub_mobile/src/services/session_service.dart';
import 'package:xsighub_mobile/src/theme/button.dart';

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({Key? key, this.pairingKey}) : super(key: key);

  final String? pairingKey;

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late final _sessionService = SessionService();
  late final _signaturePadKey = GlobalKey<SfSignaturePadState>();
  late var _signaturePadSettings = SignaturePadSettings();

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text("S:(${widget.pairingKey})"),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
        actions: [_buildClearButton(), _buildSaveButton()],
      ),
      body: _buildSignaturePad(),
      floatingActionButton: _buildCustomizeFloatingButton(),
    );
  }

  Widget _buildCustomizeFloatingButton() {
    return FloatingActionButton(
      backgroundColor: ColorConstants.primary,
      foregroundColor: ColorConstants.white,
      onPressed: () {
        showModalBottomSheet(
          backgroundColor: Colors.transparent,
          isScrollControlled: true,
          context: context,
          builder: (context) =>
              _buildModalBottomSheet(_updateSignaturePadSettings),
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

  Widget _buildModalBottomSheet(
    Function(SignaturePadSettings) onSettingsUpdated,
  ) {
    Color computeContrastingColor(Color color) =>
        color.computeLuminance() > 0.5 ? Colors.black : Colors.white;

    return StatefulBuilder(
      builder: (BuildContext context, StateSetter setState) => Wrap(
        children: [
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
            child: Container(
              padding: const EdgeInsets.all(16),
              child: ListView(
                shrinkWrap: true,
                children: [
                  const Text(
                    'Personalizar firma',
                    style: TextStyle(fontSize: 22),
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => _signaturePadSettings.backgroundColor),
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => computeContrastingColor(
                              _signaturePadSettings.backgroundColor)),
                    ),
                    child: const Text('Color de fondo'),
                    onPressed: () async {
                      await showDialog<Color>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Seleccionar color'),
                            content: SingleChildScrollView(
                              child: MaterialPicker(
                                pickerColor:
                                    _signaturePadSettings.backgroundColor,
                                onColorChanged: (color) {
                                  setState(() {
                                    _signaturePadSettings.backgroundColor =
                                        color;
                                    onSettingsUpdated(_signaturePadSettings);
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: ButtonStyle(
                      backgroundColor: MaterialStateColor.resolveWith(
                          (states) => _signaturePadSettings.strokeColor),
                      foregroundColor: MaterialStateColor.resolveWith(
                          (states) => computeContrastingColor(
                              _signaturePadSettings.strokeColor)),
                    ),
                    child: const Text('Color del trazo'),
                    onPressed: () async {
                      await showDialog<Color>(
                        context: context,
                        builder: (context) {
                          return AlertDialog(
                            title: const Text('Seleccionar color'),
                            content: SingleChildScrollView(
                              child: MaterialPicker(
                                pickerColor: _signaturePadSettings.strokeColor,
                                onColorChanged: (color) {
                                  setState(() {
                                    _signaturePadSettings.strokeColor = color;
                                    onSettingsUpdated(_signaturePadSettings);
                                    Navigator.of(context).pop();
                                  });
                                },
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Text(
                        'Ancho mínimo del trazo: ${_signaturePadSettings.minStrokeWidth.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Slider(
                        activeColor: _signaturePadSettings.strokeColor,
                        value: _signaturePadSettings.minStrokeWidth,
                        min: 0.5,
                        max: 4.0,
                        divisions: ((4.0 - 0.5) / 0.1).round(),
                        onChanged: (value) {
                          setState(() {
                            _signaturePadSettings.minStrokeWidth = value;
                            onSettingsUpdated(_signaturePadSettings);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Column(
                    children: [
                      Text(
                        'Ancho máximo del trazo: ${_signaturePadSettings.maxStrokeWidth.toStringAsFixed(2)}',
                        style: const TextStyle(fontSize: 16),
                      ),
                      Slider(
                        activeColor: _signaturePadSettings.strokeColor,
                        value: _signaturePadSettings.maxStrokeWidth,
                        min: 4.0,
                        max: 8.0,
                        divisions: ((8.0 - 4.0) / 0.1).round(),
                        onChanged: (value) {
                          setState(() {
                            _signaturePadSettings.maxStrokeWidth = value;
                            onSettingsUpdated(_signaturePadSettings);
                          });
                        },
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    style: primaryButtonStyle,
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                    child: const Text('Aceptar'),
                  ),
                  const Divider(height: 16),
                  ElevatedButton(
                    style: secondaryButtonStyle,
                    onPressed: () {
                      setState(() {
                        _signaturePadSettings = SignaturePadSettings();
                        onSettingsUpdated(_signaturePadSettings);
                      });
                    },
                    child: const Text('Restablecer valores predeterminados'),
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  void _updateSignaturePadSettings(SignaturePadSettings settings) {
    setState(() {
      _signaturePadSettings.backgroundColor = settings.backgroundColor;
      _signaturePadSettings.strokeColor = settings.strokeColor;
      _signaturePadSettings.minStrokeWidth = settings.minStrokeWidth;
      _signaturePadSettings.maxStrokeWidth = settings.maxStrokeWidth;
    });
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
}
