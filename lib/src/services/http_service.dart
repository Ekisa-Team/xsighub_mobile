import 'dart:convert';

import 'package:http/http.dart' as http;

abstract class HttpService<ModelType> {
  final String api;
  final ModelType Function(Map<String, dynamic> json) deserializer;

  HttpService({
    required this.api,
    required this.deserializer,
  });

  Future<ModelType> get({
    String? endpoint,
  }) async {
    final response = await http.get(
      Uri.parse('$api/${endpoint ?? ''}'),
    );
    return _response<ModelType>(response);
  }

  Future<ModelType> post({
    String? endpoint,
    Map<String, dynamic>? data,
  }) async {
    final response = await http.post(
      Uri.parse('$api/${endpoint ?? ''}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: _resolveBody(data),
    );
    return _response<ModelType>(response);
  }

  Future<ModelType> put({
    String? endpoint,
    Map<String, dynamic>? data,
  }) async {
    final response = await http.put(
      Uri.parse('$api/${endpoint ?? ''}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: _resolveBody(data),
    );
    return _response<ModelType>(response);
  }

  Future<ModelType> patch({
    String? endpoint,
    Map<String, dynamic>? data,
  }) async {
    final response = await http.patch(
      Uri.parse('$api/${endpoint ?? ''}'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: _resolveBody(data),
    );
    return _response<ModelType>(response);
  }

  Future<ModelType> del({
    String? endpoint,
  }) async {
    final response = await http.delete(Uri.parse('$api/$endpoint'));
    return _response<ModelType>(response);
  }

  String? _resolveBody(Map<String, dynamic>? data) {
    if (data == null) {
      return null;
    }

    data.removeWhere((_, value) => value == null);

    return jsonEncode(data);
  }

  Future<ResponseType> _response<ResponseType>(http.Response response) async {
    final responseBody = json.decode(response.body);

    if (response.statusCode < 200 || response.statusCode >= 400) {
      final String message = responseBody['responseMessage']?.toString() ??
          'Ocurrió un error en la solicitud.';

      throw Exception(message);
    }

    return deserializer(responseBody) as ResponseType;
  }
}
