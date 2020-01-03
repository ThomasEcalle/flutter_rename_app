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
    RequiredChange(
      regexp: RegExp('applicationId "${config.oldApplicationId}"'),
      replacement: 'applicationId "${config.newApplicationId}"',
      paths: ["android/app/build.gradle"],
    ),
    RequiredChange(
      regexp: RegExp(config.oldBundleId),
      replacement: config.newBundleId,
      paths: ["ios/Runner.xcodeproj/project.pbxproj"],
    ),
    RequiredChange(
      regexp: RegExp(config.oldAppName),
      replacement: config.newAppName,
      paths: ["ios/Runner/Info.plist"],
    ),
    RequiredChange(
      regexp: RegExp("${config.oldAppName}|Runner"),
      replacement: config.newAppName.replaceAll(" ", ""),
      paths: ["ios/Podfile"],
    ),
    RequiredChange(
      regexp: RegExp(config.oldAndroidPackageName),
      replacement: config.newAndroidPackageName,
      paths: [
        "android/app/src",
      ],
      isDirectory: true,
    ),
  ];
}
