import 'package:flutter/material.dart';

class SignaturePadSettings {
  Color backgroundColor;
  Color strokeColor;
  double minStrokeWidth;
  double maxStrokeWidth;

  SignaturePadSettings({
    this.backgroundColor = Colors.white,
    this.strokeColor = Colors.black,
    this.minStrokeWidth = 1.0,
    this.maxStrokeWidth = 4.0,
  });
}
