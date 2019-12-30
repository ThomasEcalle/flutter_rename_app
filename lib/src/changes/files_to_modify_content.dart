import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/models/required_change.dart';

List<RequiredChange> getFilesToModifyContent(
  Config config,
) {
  return [
    RequiredChange(
      regexp: RegExp(config.oldDartPackageName),
      replacement: config.newDartPackageName,
      paths: ["pubspec.yaml"],
    ),
    RequiredChange(
      regexp: RegExp('android:label="${config.oldAppName}"'),
      replacement: 'android:label="${config.newAppName}"',
      paths: ["android/app/src/main/AndroidManifest.xml"],
    ),
  ];
}
