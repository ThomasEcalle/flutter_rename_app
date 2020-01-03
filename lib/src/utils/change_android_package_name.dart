import 'dart:io';

import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/utils/logger.dart';

changeAndroidPackageName(Config config) async {
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
    if (fileSystemEntity is File) {
      try {
        final String fileName = fileSystemEntity.path.split("/").last;
        final File file = await fileSystemEntity.copy("${newAndroidDirectory.path}/$fileName");
        file.createSync(recursive: true);
      } catch (error) {
        Logger.error(error);
      }
    }
  });

  /// Deleting all inside old Android package
  print("Working directory = ${workingDirectory.path}");

  final Directory directoryToDelete = _getFirstDifferentDirectory(
    workingDirectory.path,
    oldPackageNameParts,
    newPackageNameParts,
  );

  directoryToDelete.deleteSync(recursive: true);
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

/// Get the first directory that is different
/// between old and new android package name
Directory _getFirstDifferentDirectory(
  String workingDirectoryPath,
  List<String> oldPackageParts,
  List<String> newPackageParts,
) {
  String path = "";
  for (int i = 0; i < oldPackageParts.length; i++) {
    path += "${oldPackageParts[i]}/";
    if (!newPackageParts.contains(oldPackageParts[i])) {
      break;
    }
  }

  print("PATH = $path");
  return Directory("$workingDirectoryPath/$path");
}
