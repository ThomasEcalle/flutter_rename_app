import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/utils/utils.dart';

changeAppNames(Config config) async {
  await _changeAndroidAppNames(config);
  await _changeIosAppNames(config);
}

_changeAndroidAppNames(Config config) async {
  if (config.oldAppName != config.newAppName) {
    Utils.changeContentInFile(
      "android/app/src/main/AndroidManifest.xml",
      RegExp('android:label="${config.oldAppName}"'),
      'android:label="${config.newAppName}"',
    );
  }
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
