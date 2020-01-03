import 'dart:io';

import 'package:flutter_rename_app/src/models/config.dart';

changeIosDirectoriesNames(Config config) {
  final String oldIOSDirectoriesName = config.oldAppName.replaceAll(" ", "");
  final String newIOSDirectoriesName = config.newAppName.replaceAll(" ", "");
  print("oldIOSDirectories = $oldIOSDirectoriesName");

  ///_changeContents(oldIOSDirectoriesName, newIOSDirectoriesName);
  ///_changeNames(oldIOSDirectoriesName, newIOSDirectoriesName);
}

_changeNames(String oldDirectoriesName, String newDirectoriesName) {
  final Directory iosDirectory = Directory("ios");
  final RegExp regExp = RegExp("$oldDirectoriesName|Runner");
  iosDirectory.listSync(recursive: true).forEach((FileSystemEntity entity) {
    if (entity.existsSync()) {
      if (entity.path.contains(regExp)) {
        print("Need to change ${entity.path} file  name");
        final String newPath = entity.path.replaceAll(regExp, newDirectoriesName);

        entity.renameSync(newPath);
      }
    }
  });
}

_changeContents(String oldDirectoriesName, String newDirectoriesName) {
  final Directory iosDirectory = Directory("ios");
  final RegExp regExp = RegExp("$oldDirectoriesName|Runner");
  iosDirectory.listSync(recursive: true).forEach((FileSystemEntity entity) {
    if (entity.existsSync()) {
      if (entity is File) {
        try {
          final String content = entity.readAsStringSync();
          if (content.contains(regExp)) {
            final String newContent = content.replaceAll(regExp, newDirectoriesName);
            entity.writeAsStringSync(newContent);
          }
        } catch (error) {}
      }
    }
  });
}
