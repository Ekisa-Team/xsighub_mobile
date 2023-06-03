import 'package:xsighub_mobile/src/models/session_connection.dart';
import 'package:xsighub_mobile/src/models/session_reference.dart';

class Session {
  int? id;
  String pairingKey;
  SessionConnection? connection;
  List<SessionReference>? references;

  Session({
    this.id,
    required this.pairingKey,
    this.connection,
    this.references = const [],
  });

  factory Session.fromJson(Map<String, dynamic> json) {
    final referencesJson = json['references'] as List<dynamic>;
    final references = referencesJson
        .map((referenceJson) => SessionReference.fromJson(referenceJson))
        .toList();

    return Session(
      id: json['id'] as int,
      pairingKey: json['pairingKey'] as String,
      connection: json['connection'] != null
          ? SessionConnection.fromJson(json['connection'])
          : null,
      references: references,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'pairingKey': pairingKey,
      'connection': connection?.toJson(),
      'references': references?.map((r) => r.toJson()).toList(),
    };
  }
}
