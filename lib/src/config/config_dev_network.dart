import 'package:xsighub_mobile/src/config/config.dart';

class ConfigDevNetwork implements BaseConfig {
  @override
  String get api => 'http://192.168.1.37:3000/api';

  @override
  String get gateway => 'ws://192.168.1.37:3000/sessions';

  @override
  String get version => 'v=1.0';
}
