import 'package:xsighub_mobile/src/models/session_document.dart';
import 'package:xsighub_mobile/src/models/session_signature.dart';

class SessionReference {
  int? id;
  String type;
  String name;
  String? documentPlaceholder;
  List<SessionSignature>? signatures;
  List<SessionDocument>? documents;
  int sessionId;

  SessionReference({
    this.id,
    required this.type,
    required this.name,
    this.documentPlaceholder,
    this.signatures = const [],
    this.documents = const [],
    required this.sessionId,
  });

  factory SessionReference.fromJson(Map<String, dynamic> json) {
    final signatures = (json['signatures'] as List<dynamic>)
        .map((signatureJson) => SessionSignature.fromJson(signatureJson))
        .toList();

    final documents = (json['documents'] as List<dynamic>)
        .map((documentJson) => SessionDocument.fromJson(documentJson))
        .toList();

    return SessionReference(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      documentPlaceholder: json['documentPlaceholder'] as String?,
      signatures: signatures,
      documents: documents,
      sessionId: json['sessionId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'documentPlaceholder': documentPlaceholder,
      'signatures': signatures?.map((signature) => signature.toJson()).toList(),
      'documents': documents?.map((document) => document.toJson()).toList(),
      'sessionId': sessionId,
    };
  }
}
