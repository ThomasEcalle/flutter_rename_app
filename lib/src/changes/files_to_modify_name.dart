import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/models/required_change.dart';

/// List of the required changes of files names
List<RequiredChange> getFilesToModifyName(
  Config config,
) {
  return [
    RequiredChange(
      regexp: RegExp(config.oldDartPackageName),
      replacement: config.newDartPackageName,
      paths: ["android/${config.oldDartPackageName}_android.iml"],
      needChanges: config.oldDartPackageName != config.newDartPackageName,
    ),
  ];
}
