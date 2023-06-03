class SessionSignature {
  int? id;
  String signatureData;
  int referenceId;

  SessionSignature({
    this.id,
    required this.signatureData,
    required this.referenceId,
  });

  factory SessionSignature.fromJson(Map<String, dynamic> json) {
    return SessionSignature(
      id: json['id'] as int,
      signatureData: json['signatureData'] as String,
      referenceId: json['referenceId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'signatureData': signatureData,
      'referenceId': referenceId,
    };
  }
}
