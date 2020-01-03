import 'dart:io';

import 'package:flutter_rename_app/src/models/config.dart';

changeIosDirectoriesNames(Config config) {
  final String oldIOSDirectoriesName = config.oldAppName.replaceAll(" ", "");
  final String newIOSDirectoriesName = config.newAppName.replaceAll(" ", "");
  print("oldIOSDirectories = $oldIOSDirectoriesName");

  final Directory iosDirectory = Directory("ios");
  iosDirectory.listSync().forEach((FileSystemEntity entity) {
    if (entity is Directory &&
        (entity.path.contains(oldIOSDirectoriesName) || entity.path.contains("Runner"))) {
      print("Need to change ${entity.path} name");
      final String nameToReplace =
          entity.path.contains(oldIOSDirectoriesName) ? oldIOSDirectoriesName : "Runner";
      final String newPath = entity.path.replaceAll(nameToReplace, newIOSDirectoriesName);

      entity.renameSync(newPath);
    }
  });
}
