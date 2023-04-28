class Session {
  final String id;
  final String serverKey;
  final String mobileKey;
  final DateTime createdAt;
  final DateTime updatedAt;
  final SessionData data;

  Session(
      {required this.id,
      required this.serverKey,
      required this.mobileKey,
      required this.createdAt,
      required this.updatedAt,
      required this.data});

  factory Session.fromJson(Map<String, dynamic> json) {
    return Session(
        id: json['id'],
        serverKey: json['serverKey'],
        mobileKey: json['mobileKey'],
        createdAt: json['createdAt'],
        updatedAt: json['updatedAt'],
        data: SessionData.fromJson(json['data']));
  }
}

class SessionData {
  final String signature;

  SessionData({required this.signature});

  factory SessionData.fromJson(Map<String, dynamic> json) {
    return SessionData(signature: json['json']);
  }
}
