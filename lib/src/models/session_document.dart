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
