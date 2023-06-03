class SessionDocument {
  int? id;
  String rawContent;
  int referenceId;

  SessionDocument({
    this.id,
    required this.rawContent,
    required this.referenceId,
  });

  factory SessionDocument.fromJson(Map<String, dynamic> json) {
    return SessionDocument(
      id: json['id'] as int,
      rawContent: json['rawContent'] as String,
      referenceId: json['referenceId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'rawContent': rawContent,
      'referenceId': referenceId,
    };
  }
}

class SessionDocumentSignature {
  String signatureName;
  String signatureData;

  SessionDocumentSignature({
    required this.signatureName,
    required this.signatureData,
  });

  factory SessionDocumentSignature.fromJson(Map<String, dynamic> json) {
    return SessionDocumentSignature(
      signatureName: json['signatureName'] as String,
      signatureData: json['signatureData'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'signatureName': signatureName,
      'signatureData': signatureData,
    };
  }
}
