import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:xsighub_mobile/src/models/session.dart';

class SessionService {
  Future<Session> fetchSessions() async {
    final response = await http.get(Uri.parse('http://localhost:3000'));

    if (response.statusCode == 200) {
      return Session.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load sessions');
    }
  }
}
