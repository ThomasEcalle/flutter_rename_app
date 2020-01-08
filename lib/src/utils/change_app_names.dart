import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/utils/utils.dart';

changeAppNames(Config config) async {
  await _changeAndroidAppNames(config);
  await _changeIosAppNames(config);
}

_changeAndroidAppNames(Config config) async {
  await _changeAndroidManifest();
}

_changeAndroidManifest() async {
  final String androidManifestPath = "android/app/src/main/AndroidManifest.xml";
  final String result = await Utils.searchInFile(
    filePath: androidManifestPath,
    pattern: RegExp('android:label="@string/app_name"'),
  );

  if (result != null) return;

  await Utils.changeContentInFile(
    androidManifestPath,
    RegExp('android:label="(.*)"'),
    'android:label="@string/app_name"',
  );
}

_changeIosAppNames(Config config) async {
  if (config.oldAppName != config.newAppName) {
    Utils.changeContentInFile(
      "ios/Runner/Info.plist",
      RegExp(config.oldAppName),
      config.newAppName,
    );
  }
}
