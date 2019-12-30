import 'package:flutter/material.dart';
import 'package:package_info/package_info.dart';

class AwesomeWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
      future: PackageInfo.fromPlatform(),
      builder: (BuildContext context, AsyncSnapshot<PackageInfo> snapshot) {
        if (snapshot.hasData) {
          final PackageInfo packageInfo = snapshot.data;
          final String appName = packageInfo.appName;
          final String packageName = packageInfo.packageName;

          return Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Text("App name : $appName"),
              Text("Package name : $packageName"),
            ],
          );
        }

        return Text("Loading");
      },
    );
  }
}
