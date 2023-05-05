class Session {
  final String pairingKey;
  final SessionConnection connection;
  final SessionData data;

  Session({
    required this.pairingKey,
    required this.connection,
    required this.data,
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
      pairingKey: json['pairingKey'],
      connection: SessionConnection.fromJson(json['connection']),
      data: SessionData.fromJson(json['data']),
    );
  }

  Map<String, dynamic> toJson() => {
        'pairingKey': pairingKey,
        'connection': connection.toJson(),
        'data': data.toJson(),
      };
}

class SessionConnection {
  final String clientIp;
  final String userAgent;
  final bool isPaired;
  final DateTime pairedAt;

  SessionConnection({
    required this.clientIp,
    required this.userAgent,
    required this.isPaired,
    required this.pairedAt,
  });

  factory SessionConnection.fromJson(Map<String, dynamic> json) {
    return SessionConnection(
      clientIp: json['clientIp'],
      userAgent: json['userAgent'],
      isPaired: json['isPaired'],
      pairedAt: DateTime.parse(json['pairedAt']),
    );
  }

  Map<String, dynamic> toJson() => {
        'clientIp': clientIp,
        'userAgent': userAgent,
        'isPaired': isPaired,
        'pairedAt': pairedAt.toIso8601String(),
      };
}

class SessionData {
  final String? signature;

  SessionData({required this.signature});

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(
      signature: json['json'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'signature': signature,
      };
}
