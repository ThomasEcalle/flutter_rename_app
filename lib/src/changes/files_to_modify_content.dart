import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/models/required_change.dart';

/// List of required changes of files content
List<RequiredChange> getFilesToModifyContent(
  Config config,
) {
  return [
    RequiredChange(
      regexp: RegExp('name: ${config.oldDartPackageName}'),
      replacement: 'name: ${config.newDartPackageName}',
      paths: ["pubspec.yaml"],
      needChanges: config.oldDartPackageName != config.newDartPackageName,
    ),
    RequiredChange(
      regexp: RegExp('applicationId "${config.oldApplicationId}"'),
      replacement: 'applicationId "${config.newApplicationId}"',
      paths: ["android/app/build.gradle"],
      needChanges: config.oldApplicationId != config.newApplicationId,
    ),
    RequiredChange(
      regexp: RegExp(config.oldBundleId),
      replacement: config.newBundleId,
      paths: ["ios/Runner.xcodeproj/project.pbxproj"],
      needChanges: config.oldBundleId != config.newBundleId,
    ),
    RequiredChange(
      regexp: RegExp(config.oldAndroidPackageName),
      replacement: config.newAndroidPackageName,
      paths: [
        "android/app/src",
      ],
      isDirectory: true,
      needChanges: config.oldAndroidPackageName != config.newAndroidPackageName,
    ),
  ];
}
