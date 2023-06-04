import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';
import 'package:xsighub_mobile/src/constants/color_constants.dart';
import 'package:xsighub_mobile/src/routes/index.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Xsighub',
      theme: ThemeData.light(useMaterial3: true),
      color: ColorConstants.primary,
      onGenerateRoute: routes,
      builder: EasyLoading.init(),
    );
  }
}
