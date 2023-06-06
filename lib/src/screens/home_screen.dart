import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;
import 'package:xsighub_mobile/src/environment.dart';
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

  late Session? _session = null;
  late SessionReference? _standaloneReference = null;
  late List<SessionReference>? _documentReferences = [];

  final IO.Socket _socket = IO.io(
    Environment.config.gateway,
    IO.OptionBuilder()
        .setTransports(['websocket'])
        .disableAutoConnect()
        .build(),
  );

  bool _isPaired = false;

  @override
  void initState() {
    super.initState();

    SharedPreferences.getInstance().then((prefs) async {
      final pairingKey = prefs.getString('pairingKey') ?? '';

      if (pairingKey.isNotEmpty) {
        setState(() {
          _pairingKeyController.text = pairingKey;
        });

        await _connect();
      }
    });

    _setupSocketEvents();
  }

  @override
  void dispose() {
    _socket.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final hasStandaloneReference = _standaloneReference != null;
    final hasDocumentReferences = _documentReferences?.isNotEmpty ?? false;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16.0),
                children: [
                  _buildFormContainer(),
                  if (!_isPaired) const QrScannerButtonWidget(),
                  if (hasStandaloneReference) _buildStandaloneRefContainer(),
                  if (hasDocumentReferences) _buildDocumentRefsContainer(),
                  if (_session != null &&
                      !hasStandaloneReference &&
                      !hasDocumentReferences)
                    Column(
                      children: [
                        const SizedBox(height: 120.0),
                        const Text(
                          'Detectando referencias adjuntas a la sesión.',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 16.0),
                        ),
                        const SizedBox(height: 16.0),
                        Icon(
                          Icons.satellite_alt_rounded,
                          size: 48.0,
                          color: Colors.grey[400],
                        ),
                      ],
                    ),
                ],
              ),
            ),
            // const SizedBox(height: 16.0),
            // const VersionTextWidget(),
            // const SizedBox(height: 16.0)
          ],
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
        subtitle: Text(
            '#${_standaloneReference!.id} - ${_standaloneReference!.name}'),
        trailing: const Icon(Icons.arrow_outward_rounded),
        onTap: () {
          Navigator.pop(context);
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => SignatureScreen(
                referenceId: _standaloneReference!.id,
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
            children: _documentReferences!.asMap().entries.map(
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

                          await Future.delayed(
                              const Duration(milliseconds: 500));

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
                    if (index >= 0 && index < _documentReferences!.length - 1)
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

  Future<void> _connect() async {
    if (_pairingKeyController.text.isEmpty) return;

    EasyLoading.show(status: 'Estableciendo conexión con el servidor...');

    await Future.delayed(const Duration(milliseconds: 500));

    try {
      _session = await _sessionService.findByPairingKey(
        _pairingKeyController.text,
      );

      if (context.mounted && _session!.references!.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => AlertDialog(
            title: const Text('No se encontraron referencias'),
            content: Text(
              'La conexión con el servidor se ha establecido correctamente, sin embargo, no se han encontrado referencias. Por favor, asegúrese de adjuntar las referencias correspondientes a la sesión ${_session!.pairingKey} desde el cliente web (${_session!.connection?.clientIp}) para poder acceder a la pantalla de firmas.',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Aceptar'),
              ),
            ],
          ),
        );
      }

      await _pairSession();

      _socket.connect();
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(error.toString()),
          ),
        );
      }

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

      _resetState();
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );
    }
  }

  Future<void> _pairSession() async {
    SharedPreferences.getInstance().then((prefs) {
      prefs.setString('pairingKey', _session!.pairingKey);
    });

    await _sessionService.pair(_session!.pairingKey);

    setState(() {
      _isPaired = true;
    });
  }

  void _updateReferences() {
    if (mounted) {
      setState(() {
        _standaloneReference = _session?.references
            ?.firstWhereOrNull((ref) => ref.type == 'standalone');

        _documentReferences = _session?.references
            ?.where((ref) => ref.type == 'document')
            .toList();
      });
    }
  }

  void _setupSocketEvents() {
    _socket.onConnect((data) {
      _updateReferences();
    });

    _socket.on('sessionUpdated', (data) {
      if (mounted) {
        setState(() {
          _session = Session.fromJson(data['session']);
        });

        _updateReferences();
      }
    });

    _socket.on('sessionUnpaired', (data) {
      _socket.disconnect();
      _resetState();
    });

    _socket.on('sessionDestroyed', (data) {
      _socket.disconnect();
      _resetState();
    });
  }

  void _resetState() {
    if (mounted) {
      setState(() {
        _isPaired = false;
        _pairingKeyController.text = '';
        _session = null;
        _standaloneReference = null;
        _documentReferences = [];
      });
    }

    _socket.disconnect();
  }
}
