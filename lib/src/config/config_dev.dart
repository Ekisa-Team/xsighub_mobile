import 'package:xsighub_mobile/src/config/config.dart';

class ConfigDev implements BaseConfig {
  @override
  String get api => 'http://10.0.2.2:3000/api';

  @override
  String get gateway => 'ws://10.0.2.2:3000/sessions';

  @override
  String get version => 'v=1.0';
}
