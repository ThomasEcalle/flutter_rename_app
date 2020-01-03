import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/models/required_change.dart';

List<RequiredChange> getFilesToModifyName(
  Config config,
) {
  final String oldAppNameForDirectories = config.oldAppName.replaceAll(" ", "");
  final String newAppNameForDirectories = config.newAppName.replaceAll(" ", "");
  return [
    RequiredChange(
      regexp: RegExp(config.oldDartPackageName),
      replacement: config.newDartPackageName,
      paths: ["android/${config.oldDartPackageName}_android.iml"],
    ),
    RequiredChange(
      regexp: RegExp("$oldAppNameForDirectories|Runner"),
      replacement: newAppNameForDirectories,
      paths: [
        "ios/Runner",
        "ios/$oldAppNameForDirectories",
        "ios/$newAppNameForDirectories/Runner-Bridging-Header.h",
        "ios/$newAppNameForDirectories/$oldAppNameForDirectories-Bridging-Header.h",
        "ios/Runner.xcodeproj",
        "ios/$oldAppNameForDirectories.xcodeproj",
        "ios/$newAppNameForDirectories.xcodeproj/xcshareddata/xcschemes/Runner.xcscheme",
        "ios/$newAppNameForDirectories.xcodeproj/xcshareddata/xcschemes/$oldAppNameForDirectories.xcscheme",
        "ios/Runner.xcworkspace",
        "ios/$oldAppNameForDirectories.xcworkspace",
      ],
    ),
  ];
}
