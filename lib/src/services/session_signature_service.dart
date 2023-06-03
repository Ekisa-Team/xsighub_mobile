import 'package:xsighub_mobile/src/environment.dart';
import 'package:xsighub_mobile/src/models/session_signature.dart';
import 'package:xsighub_mobile/src/services/http_service.dart';

class SessionSignatureService extends HttpService<SessionSignature> {
  SessionSignatureService()
      : super(
          api:
              "${Environment.config.api}/${Environment.config.version}/session-signatures",
          deserializer: (json) => SessionSignature.fromJson(json),
        );

  Future<SessionSignature> create(
    SessionSignature data,
  ) async =>
      super.post(
        data: data.toJson(),
      );

  Future<SessionSignature> findById(
    int signatureId,
  ) async =>
      super.get(endpoint: '$signatureId');

  Future<SessionSignature> update(
    int signatureId,
    SessionSignature data,
  ) async =>
      super.put(
        endpoint: '$signatureId',
        data: data.toJson(),
      );

  Future<SessionSignature> delete(
    int signatureId,
  ) async =>
      super.del(
        endpoint: '$signatureId',
      );
}
