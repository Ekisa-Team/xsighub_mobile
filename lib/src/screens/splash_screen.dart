import 'package:flutter/material.dart';
import 'package:xsighub_mobile/src/constants/color_constants.dart';
import 'package:xsighub_mobile/src/constants/image_constants.dart';

class SplashScreen extends StatelessWidget {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackgroundLight,
      body: Center(child: Image.asset(ImageConstants.logo)),
    );
  }
}
