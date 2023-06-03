import 'package:xsighub_mobile/src/environment.dart';
import 'package:xsighub_mobile/src/models/session_reference.dart';
import 'package:xsighub_mobile/src/services/http_service.dart';

class SessionReferenceService extends HttpService<SessionReference> {
  SessionReferenceService()
      : super(
          api:
              "${Environment.config.api}/${Environment.config.version}/session-references",
          deserializer: (json) => SessionReference.fromJson(json),
        );

  Future<SessionReference> create(
    SessionReference data,
  ) async =>
      super.post(
        data: data.toJson(),
      );

  Future<SessionReference> update(
    int referenceId,
    SessionReference data,
  ) async =>
      super.put(
        endpoint: '$referenceId',
        data: data.toJson(),
      );

  Future<SessionReference> delete(
    int referenceId,
  ) async =>
      super.del(
        endpoint: '$referenceId',
      );
}
