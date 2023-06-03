import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:xsighub_mobile/src/models/session.dart';
import 'package:xsighub_mobile/src/models/session_document.dart';
import 'package:xsighub_mobile/src/models/session_reference.dart';
import 'package:xsighub_mobile/src/screens/document_screen.dart';
import 'package:xsighub_mobile/src/screens/signature_screen.dart';
import 'package:xsighub_mobile/src/services/session_document_service.dart';
import 'package:xsighub_mobile/src/services/session_service.dart';
import 'package:xsighub_mobile/src/theme/button.dart';
import 'package:xsighub_mobile/src/widgets/qr_scanner_button.dart';

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

  late SessionReference? standaloneReference = null;
  late List<SessionReference>? documentReferences = [];

  bool _isPaired = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) {
      setState(() {
        _pairingKeyController.text = prefs.getString('pairingKey') ?? '';
      });

      _connect();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
      ),
      body: SingleChildScrollView(
        child: Container(
          margin: const EdgeInsets.all(12.0),
          child: Wrap(
            runSpacing: 16,
            children: [
              _buildFormContainer(),
              if (!_isPaired) const QrScannerButtonWidget(),
              if (standaloneReference != null) _buildStandaloneRefContainer(),
              if (documentReferences!.isNotEmpty) _buildDocumentRefsContainer(),
              // const VersionTextWidget()
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFormContainer() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
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
        ),
      ),
    );
  }

  Widget _buildStandaloneRefContainer() {
    return Card(
      child: ListTile(
        leading: const Icon(Icons.post_add_rounded),
        title: const Text('Firma independiente'),
        subtitle:
            Text('#${standaloneReference!.id} - ${standaloneReference!.name}'),
        trailing: const Icon(Icons.arrow_outward_rounded),
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
    );
  }

  Widget _buildDocumentRefsContainer() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const SizedBox(height: 16.0),
        const Text(
          'Documentos registrados',
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 8.0),
        Card(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: documentReferences!.asMap().entries.map(
              (entry) {
                final index = entry.key;
                final reference = entry.value;

                return Column(
                  children: [
                    ListTile(
                      leading: const Icon(Icons.document_scanner_rounded),
                      title: Text(reference.name),
                      trailing: const Icon(Icons.arrow_outward_rounded),
                      onTap: () async {
                        try {
                          EasyLoading.show(
                            status:
                                'Creando documento con referencia ${reference.id}...',
                          );

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
                        } finally {
                          EasyLoading.dismiss();
                        }
                      },
                    ),
                    if (index >= 0 && index < documentReferences!.length - 1)
                      const Divider(),
                  ],
                );
              },
            ).toList(),
          ),
        ),
      ],
    );
  }

  void _connect() async {
    if (_pairingKeyController.text.isEmpty) return;

    EasyLoading.show(status: 'Estableciendo conexión con el servidor...');

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
      }
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );

      _disconnect();
    } finally {
      EasyLoading.dismiss();
    }
  }

  void _disconnect() async {
    try {
      final prefs = await SharedPreferences.getInstance();

      final pairingKey = prefs.getString('pairingKey') ?? '';

      if (pairingKey.isNotEmpty) {
        await _sessionService.unpair(prefs.getString('pairingKey') ?? '');
      }

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
