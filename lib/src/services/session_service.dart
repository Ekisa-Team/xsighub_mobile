import 'package:xsighub_mobile/src/environment.dart';
import 'package:xsighub_mobile/src/models/session.dart';

import 'http_service.dart';

class SessionService extends HttpService<Session> {
  SessionService()
      : super(
          api:
              "${Environment.config.api}/${Environment.config.version}/sessions",
          deserializer: (json) => Session.fromJson(json),
        );

  Future<Session> create() async => super.post();

  Future<Session> findByPairingKey(
    String pairingKey,
  ) async =>
      super.get(endpoint: pairingKey);

  Future<Session> pair(
    String pairingKey,
  ) async =>
      super.patch(endpoint: '$pairingKey/pair');

  Future<Session> unpair(
    String pairingKey,
  ) async =>
      super.patch(endpoint: '$pairingKey/unpair');
}
