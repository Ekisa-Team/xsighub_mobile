import 'package:xsighub_mobile/src/config/config.dart';

class ConfigProd implements BaseConfig {
  @override
  String get api => 'https://xsighub.azurewebsites.net/api';

  @override
  String get gateway => 'https://xsighub.azurewebsites.net/sessions';

  @override
  String get version => 'v=1.0';
}
