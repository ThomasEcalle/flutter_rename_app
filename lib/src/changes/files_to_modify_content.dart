import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/models/required_change.dart';

List<RequiredChange> getFilesToModifyContent(
  Config config,
) {
  return [
    RequiredChange(
      regexp: RegExp(config.oldApplicationId),
      replacement: config.newApplicationId,
      paths: ["pubspec.yaml"],
    ),
    RequiredChange(
      regexp: RegExp(config.oldAppName),
      replacement: config.newAppName,
      paths: ["pubspec.yaml"],
    ),
  ];
}
