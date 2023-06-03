import 'package:xsighub_mobile/src/config/config.dart';
import 'package:xsighub_mobile/src/config/config_dev.dart';
import 'package:xsighub_mobile/src/config/config_prod.dart';

class Environment {
  static const envDev = 'dev';
  static const envProd = 'prod';

  static String _currentEnvironment = envDev;

  static final Map<String, BaseConfig> _configs = {
    envDev: ConfigDev(),
    envProd: ConfigProd(),
  };

  static BaseConfig get config => _configs[_currentEnvironment] as BaseConfig;

  static void init(String environment) {
    _currentEnvironment = environment;
  }
}
