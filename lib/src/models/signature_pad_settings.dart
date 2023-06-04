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

  Map<String, dynamic> toJson() {
    return {
      'backgroundColor': backgroundColor.value,
      'strokeColor': strokeColor.value,
      'minStrokeWidth': minStrokeWidth,
      'maxStrokeWidth': maxStrokeWidth,
    };
  }

  static SignaturePadSettings fromJson(Map<String, dynamic> json) {
    return SignaturePadSettings(
      backgroundColor:
          Color(json['backgroundColor'] as int? ?? Colors.white.value),
      strokeColor: Color(json['strokeColor'] as int? ?? Colors.black.value),
      minStrokeWidth: json['minStrokeWidth'] ?? 1.0,
      maxStrokeWidth: json['maxStrokeWidth'] ?? 4.0,
    );
  }
}
