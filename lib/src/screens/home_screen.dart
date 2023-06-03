import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsighub_mobile/src/models/session.dart';
import 'package:xsighub_mobile/src/models/session_document.dart';
import 'package:xsighub_mobile/src/models/session_reference.dart';
import 'package:xsighub_mobile/src/screens/document_screen.dart';
import 'package:xsighub_mobile/src/screens/qr_scanner_screen.dart';
import 'package:xsighub_mobile/src/screens/signature_screen.dart';
import 'package:xsighub_mobile/src/services/session_document_service.dart';
import 'package:xsighub_mobile/src/services/session_service.dart';
import 'package:xsighub_mobile/src/theme/button.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _sessionService = SessionService();
  final _sessionDocumentService = SessionDocumentService();

  final _formKey = GlobalKey<FormState>();
  final _pairingKeyController = TextEditingController();

  late SessionReference? standaloneReference;
  late List<SessionReference>? documentReferences = [];

  bool _isPaired = true;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _pairingKeyController.text = prefs.getString('pairingKey') ?? '';
        _isPaired = _pairingKeyController.text.isNotEmpty;
      });
    });
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
                  if (!_isPaired) const SizedBox(height: 16.0),
                  if (!_isPaired)
                    Hero(
                      tag: 'scanButton',
                      child: _buildScanButton(),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 24.0),
            FutureBuilder(
              future: PackageInfo.fromPlatform(),
              builder: (context, snapshot) {
                return Text(
                  'v${snapshot.data?.version}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18.0),
                );
              },
            ),
            const SizedBox(height: 24.0),
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
            enabled: !_isPaired,
            validator: (value) {
              if (value == null || value.isEmpty || value.length < 6) {
                return 'Ingrese un código de emparejamiento válido';
              }
              return null;
            },
          ),
          const SizedBox(height: 16.0),
          _isPaired
              ? ElevatedButton.icon(
                  style: dangerButtonStyle,
                  onPressed: () {
                    _disconnect();
                  },
                  icon: const Icon(Icons.power_off_rounded),
                  label: const Text('Desconectar'),
                )
              : ElevatedButton.icon(
                  style: primaryButtonStyle,
                  onPressed: () {
                    if (_formKey.currentState!.validate()) {
                      _connect();
                    }
                  },
                  icon: const Icon(Icons.power_rounded),
                  label: const Text('Conectar'),
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

  Widget _buildModalBottomSheetForSignatureType() {
    bool hasStandaloneReference = standaloneReference != null;
    bool hasDocumentReferences = documentReferences!.isNotEmpty;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (hasStandaloneReference)
            ListTile(
              leading: const Icon(Icons.edit_note),
              title: const Text('Firma independiente'),
              onTap: () {
                Navigator.pop(context);
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => SignatureScreen(
                      referenceId: standaloneReference!.id,
                      incomingSource: SignatureScreenIncomingSource.standalone,
                    ),
                  ),
                );
              },
            ),
          if (hasStandaloneReference && hasDocumentReferences) const Divider(),
          if (hasDocumentReferences)
            ListTile(
              leading: const Icon(Icons.edit_document),
              title: const Text('Firma con documento'),
              onTap: () {
                Navigator.pop(context);
                showModalBottomSheet(
                  isScrollControlled: true,
                  context: context,
                  builder: (context) {
                    return Container(
                      constraints: BoxConstraints(
                        maxHeight: MediaQuery.of(context).size.height * 0.75,
                      ),
                      child: _buildModalBottomSheetForDocChooser(),
                    );
                  },
                );
              },
            ),
        ],
      ),
    );
  }

  Widget _buildModalBottomSheetForDocChooser() {
    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: documentReferences!
            .map((reference) => ListTile(
                  leading: const Icon(Icons.my_library_books_rounded),
                  title: Text(reference.name),
                  onTap: () async {
                    try {
                      final document = await _sessionDocumentService.create(
                        SessionDocument(
                          rawContent: reference.documentPlaceholder!,
                          referenceId: reference.id!,
                        ),
                      );

                      if (context.mounted) {
                        Navigator.pop(context);
                        Navigator.of(context).push(
                          MaterialPageRoute(
                            builder: (context) => DocumentScreen(
                              referenceId: document.referenceId,
                              documentId: document.id,
                            ),
                          ),
                        );
                      }
                    } catch (error) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(error.toString()),
                        ),
                      );
                    }
                  },
                ))
            .toList(),
      ),
    );
  }

  void _connect() async {
    try {
      final Session session = await _sessionService.findByPairingKey(
        _pairingKeyController.text,
      );

      SharedPreferences.getInstance().then((prefs) {
        prefs.setString('pairingKey', session.pairingKey);
      });

      await _sessionService.pair(session.pairingKey);

      setState(() {
        _isPaired = true;
      });

      if (context.mounted && session.references!.isEmpty) {
        showDialog(
          context: context,
          builder: (BuildContext context) => AlertDialog(
            title: const Text('No se encontraron referencias'),
            content: Text(
              'Por favor, adjunte referencias a la sesión ${session.id} desde el cliente web (${session.connection?.clientIp}) para acceder a la pantalla de firmas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      } else {
        standaloneReference = session.references
            ?.firstWhereOrNull((ref) => ref.type == 'standalone');

        documentReferences =
            session.references?.where((ref) => ref.type == 'document').toList();

        showModalBottomSheet(
          isScrollControlled: true,
          context: context,
          builder: (context) => _buildModalBottomSheetForSignatureType(),
        );
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );

      _disconnect();
    }
  }

  void _disconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      await _sessionService.unpair(prefs.getString('pairingKey') ?? '');

      prefs.remove('pairingKey');

      setState(() {
        _isPaired = false;
        _pairingKeyController.text = '';
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }
}
