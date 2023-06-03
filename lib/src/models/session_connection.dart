class SessionConnection {
  int? id;
  String clientIp;
  String userAgent;
  bool isPaired;
  DateTime? pairedAt;
  int sessionId;

  SessionConnection({
    this.id,
    required this.clientIp,
    required this.userAgent,
    required this.isPaired,
    this.pairedAt,
    required this.sessionId,
  });

  factory SessionConnection.fromJson(Map<String, dynamic> json) {
    return SessionConnection(
      id: json['id'] as int,
      clientIp: json['clientIp'] as String,
      userAgent: json['userAgent'] as String,
      isPaired: json['isPaired'] as bool,
      pairedAt: json['pairedAt'] != null
          ? DateTime.parse(json['pairedAt'] as String)
          : null,
      sessionId: json['sessionId'] as int,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'clientIp': clientIp,
      'userAgent': userAgent,
      'isPaired': isPaired,
      'pairedAt': pairedAt?.toIso8601String(),
      'sessionId': sessionId,
    };
  }
}
