import 'dart:io';

import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/utils/logger.dart';

changeAndroidPackageName(Config config) async {
  Logger.newLine();
  Logger.info("Changing android package name");
  final String newPackageName = config.newAndroidPackageName;
  final String oldPackageName = config.oldAndroidPackageName;
  final List<String> newPackageNameParts = newPackageName.split(".");
  final List<String> oldPackageNameParts = oldPackageName.split(".");

  final Directory workingDirectory = await _getDirectory(oldPackageNameParts);

  final String oldPackagePath = oldPackageNameParts.join("/");
  final String newPackagePath = newPackageNameParts.join("/");

  final Directory oldAndroidDirectory = Directory("${workingDirectory.path}/$oldPackagePath");
  final Directory newAndroidDirectory = Directory("${workingDirectory.path}/$newPackagePath");

  newAndroidDirectory.createSync(recursive: true);
  final List<FileSystemEntity> files = oldAndroidDirectory.listSync(recursive: true);

  await Future.forEach(files, (FileSystemEntity fileSystemEntity) async {
    print("looking on file ${fileSystemEntity.path}");
    if (fileSystemEntity is File) {
      print("test");
      try {
        final String fileName = fileSystemEntity.path.split("/").last;
        final File file = await fileSystemEntity.copy("${newAndroidDirectory.path}/$fileName");
        print("a ${newAndroidDirectory.path}");
        file.createSync(recursive: true);
      } catch (error) {
        print("error : $error");
      }
    }
  });
}

/// Get the directory for the Android files
/// Either it is a Kotlin or Java project
Future<Directory> _getDirectory(List<String> oldPackageNameParts) async {
  final String packagePath = oldPackageNameParts.join("/");
  final Directory javaDirectory = Directory("android/app/src/main/java/$packagePath");
  if (javaDirectory.existsSync()) {
    return Directory("android/app/src/main/java");
  }

  return Directory("android/app/src/main/kotlin");
}
