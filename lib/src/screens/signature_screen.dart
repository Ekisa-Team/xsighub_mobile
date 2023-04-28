import 'package:flutter/material.dart';
import 'package:xsighub_mobile/src/constants/color_constants.dart';

class SignatureScreen extends StatelessWidget {
  const SignatureScreen({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.scaffoldBackgroundLight,
      appBar: AppBar(
        title: Text(title),
      ),
      body: const Center(child: Text("Signature screen")),
    );
  }
}
