import 'package:flutter/material.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:xsighub_mobile/src/markdown_builders/signature_builder.dart';
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ref: ${widget.referenceId} - Doc: ${widget.documentId}"),
        backgroundColor: Colors.black,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
      ),
      body: FutureBuilder(
        future: _sessionDocumentService.findById(widget.documentId!),
        builder: (context, snapshot) {
          return _buildDocument(snapshot.data?.rawContent ?? '');
        },
      ),
    );
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
                inlineSyntaxes: [SignatureSyntax()],
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
}
