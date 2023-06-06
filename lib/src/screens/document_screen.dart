import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:xsighub_mobile/src/markdown_builders/signature_builder.dart';
import 'package:xsighub_mobile/src/models/session_document.dart';
import 'package:xsighub_mobile/src/screens/home_screen.dart';
import 'package:xsighub_mobile/src/screens/signature_screen.dart';
import 'package:xsighub_mobile/src/services/session_document_service.dart';

class DocumentScreen extends StatefulWidget {
  const DocumentScreen({
    Key? key,
    this.referenceId,
    this.documentId,
  }) : super(key: key);

  final int? referenceId;
  final int? documentId;

  @override
  State<DocumentScreen> createState() => _DocumentScreenState();
}

class _DocumentScreenState extends State<DocumentScreen> {
  final _sessionDocumentService = SessionDocumentService();

  late SessionDocument? _document = null;

  @override
  void initState() {
    super.initState();

    try {
      _sessionDocumentService
          .findById(widget.documentId!)
          .then((document) async {
        setState(
          () => _document = document,
        );

        if (!(await _validateMetadata())) return;
        if (!(await _validateSignatures())) return;

        setState(
          () => _document!.rawContent = _parseDocumentMetadata(_document!),
        );
      });
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(error.toString()),
        ),
      );

      Navigator.of(context).pop();
      Navigator.of(context).push(
        MaterialPageRoute(builder: (context) => const HomeScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text("Ref: ${widget.referenceId} - Doc: ${widget.documentId}"),
          leading: IconButton(
            icon: const Icon(Icons.arrow_back),
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            ),
          ),
        ),
        body: _buildDocument(_document?.rawContent ?? ''));
  }

  Widget _buildDocument(String rawMarkdown) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Center(
        child: Column(
          children: [
            Expanded(
              child: Markdown(
                data: rawMarkdown,
                inlineSyntaxes: [
                  SignatureSyntax(),
                ],
                builders: {
                  'signature': SignatureBuilder(onPressed: (signatureName) {
                    Navigator.pop(context);
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (context) => SignatureScreen(
                          referenceId: widget.referenceId,
                          documentId: widget.documentId,
                          signatureName: signatureName,
                          incomingSource:
                              SignatureScreenIncomingSource.document,
                        ),
                      ),
                    );
                  }),
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _parseDocumentMetadata(SessionDocument document) {
    String parsedContent = document.rawContent;

    if (document.metadata == null) return parsedContent;

    for (var entry in document.metadata!.entries) {
      final metadataName = entry.key;
      final data = entry.value ?? '';

      parsedContent =
          parsedContent.replaceAll('[metadata:$metadataName]', data);
    }

    return parsedContent;
  }

  Future<bool> _validateMetadata() {
    final metadataPattern = RegExp(r"\[metadata(?:\:\w+)?\]");

    final matches = metadataPattern.allMatches(_document?.rawContent ?? '');

    if (matches.isEmpty) {
      return Future.value(true);
    }

    for (final match in matches) {
      final name = match.group(0);

      if (name == "[metadata]") {
        showDialog(
          context: context,
          builder: (context) => _buildAlertForMisconfiguredDocument(),
        );

        return Future.value(false);
      }
    }

    return Future.value(true);
  }

  Future<bool> _validateSignatures() {
    final signaturesPattern = RegExp(r'\[signature:(.*?)\]\((.*?)\)');

    final matches = signaturesPattern.allMatches(_document?.rawContent ?? '');

    if (matches.isEmpty) {
      return Future.value(true);
    }

    final signatureEntities = <String, String>{};

    for (final match in matches) {
      final name = match.group(1)!;
      final data = match.group(2)!;

      if (name.isEmpty || data.isEmpty) {
        showDialog(
          context: context,
          builder: (context) => _buildAlertForMisconfiguredDocument(),
        );

        return Future.value(false);
      }

      if (data.startsWith('data:image/png;base64,')) {
        final base64Data = data.substring('data:image/png;base64,'.length);
        signatureEntities[name] = base64Data;
      }
    }

    if (signatureEntities.length == matches.length) {
      showDialog(
        context: context,
        builder: (context) => _buildAlertForDocumentAlreadySigned(),
      );
    }

    return Future.value(true);
  }

  Widget _buildAlertForMisconfiguredDocument() {
    return AlertDialog(
      title: const Text('Documento incorrecto'),
      content: const Text(
          'Se detectaron configuraciones incorrectas en el documento. Asegúrese de que las entidades tengan un nombre asignado.'),
      actions: [
        TextButton(
          child: const Text('Aceptar'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ],
    );
  }

  Widget _buildAlertForDocumentAlreadySigned() {
    return AlertDialog(
      title: const Text('El documento ha sido firmado'),
      content: const Text('¿Qué desea hacer a continuación?'),
      actions: [
        TextButton(
          child: const Text('Permanecer aquí'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
        TextButton(
          child: const Text('Regresar a Inicio'),
          onPressed: () {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          },
        ),
      ],
    );
  }
}
