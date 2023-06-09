import 'dart:convert';
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:xsighub_mobile/src/constants/color_constants.dart';
import 'package:xsighub_mobile/src/models/session_document.dart';
import 'package:xsighub_mobile/src/models/session_signature.dart';
import 'package:xsighub_mobile/src/models/signature_pad_settings.dart';
import 'package:xsighub_mobile/src/screens/document_screen.dart';
import 'package:xsighub_mobile/src/screens/home_screen.dart';
import 'package:xsighub_mobile/src/services/session_document_service.dart';
import 'package:xsighub_mobile/src/services/session_signature_service.dart';
import 'package:xsighub_mobile/src/theme/button.dart';

enum SignatureScreenIncomingSource {
  standalone,
  document,
}

class SignatureScreen extends StatefulWidget {
  const SignatureScreen({
    Key? key,
    this.referenceId,
    this.documentId,
    this.signatureName,
    this.incomingSource,
  }) : super(key: key);

  final int? referenceId;
  final int? documentId;
  final String? signatureName;
  final SignatureScreenIncomingSource? incomingSource;

  @override
  State<SignatureScreen> createState() => _SignatureScreenState();
}

class _SignatureScreenState extends State<SignatureScreen> {
  late final _sessionSignatureService = SessionSignatureService();
  late final _sessionDocumentService = SessionDocumentService();

  late final _signaturePadKey = GlobalKey<SfSignaturePadState>();
  late var _signaturePadSettings = SignaturePadSettings();

  bool _isSignatureEmpty = true;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) async {
      final signaturePadSettings = prefs.getString('signaturePadSettings');

      _updateSignaturePadSettings(signaturePadSettings == null
          ? SignaturePadSettings()
          : SignaturePadSettings.fromJson(jsonDecode(signaturePadSettings)));
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ref: ${widget.referenceId}"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
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

  Widget _buildSignaturePad() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Padding(
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade900,
                    border: const Border(
                      bottom: BorderSide(
                        width: 3.0,
                        color: Colors.black,
                        style: BorderStyle.solid,
                      ),
                    ),
                  ),
                  child: SfSignaturePad(
                    key: _signaturePadKey,
                    backgroundColor: _signaturePadSettings.backgroundColor,
                    strokeColor: _signaturePadSettings.strokeColor,
                    minimumStrokeWidth: _signaturePadSettings.minStrokeWidth,
                    maximumStrokeWidth: _signaturePadSettings.maxStrokeWidth,
                    onDrawEnd: () {
                      setState(() {
                        _isSignatureEmpty = false;
                      });
                    },
                  ),
                ),
                const SizedBox(height: 48),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed:
                          _isSignatureEmpty ? null : _handleClearButtonPressed,
                      icon: const Icon(Icons.delete_outline_rounded),
                      label: const Text('Limpiar'),
                    ),
                    const SizedBox(width: 16),
                    ElevatedButton.icon(
                      style: primaryButtonStyle,
                      onPressed:
                          _isSignatureEmpty ? null : _handleSaveButtonPressed,
                      icon: const Icon(Icons.draw),
                      label: const Text('Firmar'),
                    )
                  ],
                )
              ],
            )),
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
                    style: TextStyle(fontSize: 22, color: Colors.white),
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
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
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
                        style:
                            const TextStyle(fontSize: 16, color: Colors.white),
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
                        onSettingsUpdated(SignaturePadSettings());
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

    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('signaturePadSettings', jsonEncode(settings.toJson()));
    });
  }

  void _handleClearButtonPressed() {
    _signaturePadKey.currentState!.clear();

    setState(() {
      _isSignatureEmpty = true;
    });
  }

  void _handleSaveButtonPressed() async {
    try {
      EasyLoading.show(
        status: 'Enviando firma al servidor...',
      );

      await Future.delayed(const Duration(milliseconds: 300));

      final signatureData = await _signaturePadKey.currentState!.toImage();
      final imageBytes =
          await signatureData.toByteData(format: ImageByteFormat.png);
      final imageEncoded =
          "data:image/png;base64,${base64.encode(imageBytes!.buffer.asUint8List())}";

      if (widget.incomingSource == SignatureScreenIncomingSource.document) {
        await _sessionDocumentService.attachSignature(
          widget.documentId!,
          SessionDocumentSignature(
            signatureName: widget.signatureName!,
            signatureData: imageEncoded,
          ),
        );

        if (context.mounted) {
          Navigator.pop(context);
          Navigator.of(context).push(MaterialPageRoute(
            builder: (context) => DocumentScreen(
              referenceId: widget.referenceId,
              documentId: widget.documentId,
            ),
          ));
        }
      } else {
        await _sessionSignatureService.create(
          SessionSignature(
            signatureData: imageEncoded,
            referenceId: widget.referenceId!,
          ),
        );

        _signaturePadKey.currentState!.clear();
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );

      MaterialPageRoute(builder: (context) => const HomeScreen());
    } finally {
      EasyLoading.dismiss();

      setState(() {
        _isSignatureEmpty = true;
      });
    }
  }
}
