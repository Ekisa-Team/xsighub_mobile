import 'package:flutter/material.dart';
import 'package:package_info_plus/package_info_plus.dart';

class VersionTextWidget extends StatelessWidget {
  const VersionTextWidget({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const CircularProgressIndicator();
        } else if (snapshot.hasError) {
          return const Text('Error retrieving package info');
        } else {
          final version = snapshot.data?.version ?? '';
          return Text(
            'v$version',
            textAlign: TextAlign.center,
            style: const TextStyle(fontSize: 18.0),
          );
        }
      },
    );
  }
}
