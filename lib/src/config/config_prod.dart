import 'package:xsighub_mobile/src/config/config.dart';

class ConfigProd implements BaseConfig {
  @override
  String get api => 'https://xsighub.azurewebsites.net/api';

  @override
  String get gateway => 'ws://xsighub.azurewebsites.net/sessions';

  @override
  String get version => 'v=1.0';
}
