import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:socket_io_client/socket_io_client.dart' as io;
import 'package:xsighub_mobile/src/environment.dart';
import 'package:xsighub_mobile/src/models/session.dart';
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

  final io.Socket _socket = io.io(
    Environment.config.gateway,
    io.OptionBuilder()
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
  }

  @override
  void dispose() {
    _socket.disconnect();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inicio'),
        automaticallyImplyLeading: false,
      ),
      body: SafeArea(
        child: Stack(
          children: [
            ListView(
              padding: const EdgeInsets.all(12.0),
              children: [
                _buildFormContainer(),
                if (!_isPaired) const QrScannerButtonWidget(),
                if (_session != null)
                  Column(
                    children: [
                      const SizedBox(height: 120.0),
                      Text(
                        'Escuchando señales desde el cliente ${_session!.connection?.clientIp ?? '0.0.0.0'}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontSize: 16.0),
                      ),
                      const SizedBox(height: 16.0),
                      Icon(
                        Icons.satellite_alt_rounded,
                        size: 48.0,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 64.0),
                    ],
                  ),
              ],
            ),
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

  Future<void> _connect() async {
    if (_pairingKeyController.text.isEmpty) return;

    EasyLoading.show(status: 'Estableciendo conexión con el servidor...');

    await Future.delayed(const Duration(milliseconds: 300));

    try {
      _session = await _sessionService.findByPairingKey(
        _pairingKeyController.text,
      );

      if (_session != null) {
        _socket.emit('handshake', {
          'sessionId': _session?.id,
          'client': 'mobile',
        });
      }

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

      _setupSocketEvents();

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

    _socket.on('referenceOpenedRequested', (data) {
      final event = data['body'];

      if (context.mounted) {
        switch (event['kind']) {
          case 'standalone':
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => SignatureScreen(
                  referenceId: event['referenceId'],
                  incomingSource: SignatureScreenIncomingSource.standalone,
                ),
              ),
            );
            break;
          case 'document':
            Navigator.pop(context);
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => DocumentScreen(
                  referenceId: event['referenceId'],
                  documentId: event['documentId'],
                ),
              ),
            );
            break;
        }
      }
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
