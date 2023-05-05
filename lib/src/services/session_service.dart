import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xsighub_mobile/src/models/session.dart';

class SessionService {
  final _api = "http://192.168.1.35:3000/api/v1/sessions";

  Future<Session> retrieve(String pairingKey) async {
    final response = await http.get(
      Uri.parse("$_api/$pairingKey"),
    );

    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to retrieve session ${response.body}');
    }
  }

  Future<Session> pair(String pairingKey) async {
    final response = await http.patch(
      Uri.parse("$_api/$pairingKey/connections"),
    );

    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to pair session ${response.body}');
    }
  }

  Future<Session> update(String pairingKey, SessionData data) async {
    final response = await http.patch(
      Uri.parse("$_api/$pairingKey/data"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(data.toJson()),
    );

    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update session ${response.body}');
    }
  }
}
