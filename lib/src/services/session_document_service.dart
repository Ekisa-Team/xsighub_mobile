import 'package:xsighub_mobile/src/environment.dart';
import 'package:xsighub_mobile/src/models/session_document.dart';
import 'package:xsighub_mobile/src/services/http_service.dart';

class SessionDocumentService extends HttpService<SessionDocument> {
  SessionDocumentService()
      : super(
          api:
              "${Environment.config.api}/${Environment.config.version}/session-documents",
          deserializer: (json) => SessionDocument.fromJson(json),
        );

  Future<SessionDocument> create(
    SessionDocument data,
  ) async =>
      super.post(
        data: data.toJson(),
      );

  Future<SessionDocument> findById(
    int documentId,
  ) async =>
      super.get(endpoint: '$documentId');

  Future<SessionDocument> update(
    int documentId,
    SessionDocument data,
  ) async =>
      super.put(
        endpoint: '$documentId',
        data: data.toJson(),
      );

  Future<SessionDocument> delete(
    int documentId,
  ) async =>
      super.del(
        endpoint: '$documentId',
      );
}
