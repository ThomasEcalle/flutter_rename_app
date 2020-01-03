import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/models/required_change.dart';

List<RequiredChange> getFilesToModifyContent(
  Config config,
) {
  final String oldAppNameForDirectories = config.oldAppName.replaceAll(" ", "");
  final String newAppNameForDirectories = config.newAppName.replaceAll(" ", "");
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
      regexp: RegExp("$oldAppNameForDirectories|Runner"),
      replacement: newAppNameForDirectories,
      paths: [
        "ios/Podfile",
        "ios/Flutter/Debug.xcconfig",
        "ios/Flutter/Release.xcconfig",
        "ios/Runner",
        "ios/$oldAppNameForDirectories",
        "ios/Runner/Runner-Bridging-Header.h",
        "ios/$oldAppNameForDirectories/$oldAppNameForDirectories-Bridging-Header.h",
        "ios/Runner.xcodeproj",
        "ios/$oldAppNameForDirectories.xcodeproj",
        "ios/Runner.xcodeproj/project.pbxproj",
        "ios/$oldAppNameForDirectories.xcodeproj/project.pbxproj",
        "ios/Runner.xcodeproj/project.xcworkspace/contents.xcworkspacedata",
        "ios/$oldAppNameForDirectories.xcodeproj/project.xcworkspace/contents.xcworkspacedata",
        "ios/Runner.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme",
        "ios/$oldAppNameForDirectories.xcodeproj/xcshareddata/xcschemes/$oldAppNameForDirectories.xcscheme",
        "ios/Runner.xcworkspace",
        "ios/$oldAppNameForDirectories.xcworkspace",
        "ios/Runner.xcworkspace/contents.xcworkspacedata",
        "ios/$oldAppNameForDirectories.xcworkspace/contents.xcworkspacedata",
        "ios/Flutter/Debug.xcconfig",
        "ios/Flutter/Release.xcconfig",
      ],
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
