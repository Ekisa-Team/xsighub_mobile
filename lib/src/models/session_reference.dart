import 'package:xsighub_mobile/src/models/session_signature.dart';

class SessionReference {
  int? id;
  String type;
  String name;
  String? documentPlaceholder;
  List<SessionSignature>? signatures;
  int sessionId;

  SessionReference({
    this.id,
    required this.type,
    required this.name,
    this.documentPlaceholder,
    this.signatures = const [],
    required this.sessionId,
  });

  factory SessionReference.fromJson(Map<String, dynamic> json) {
    final signatures = (json['signatures'] as List<dynamic>)
        .map((signatureJson) => SessionSignature.fromJson(signatureJson))
        .toList();

    return SessionReference(
      id: json['id'] as int,
      type: json['type'] as String,
      name: json['name'] as String,
      documentPlaceholder: json['documentPlaceholder'] as String?,
      signatures: signatures,
      sessionId: json['sessionId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'type': type,
      'name': name,
      'documentPlaceholder': documentPlaceholder,
      'signatures': signatures?.map((s) => s.toJson()).toList(),
      'sessionId': sessionId,
    };
  }
}
