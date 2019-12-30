library flutter_rename_app;

import 'dart:io';

import 'package:flutter_rename_app/src/changes/files_to_modify_name.dart';
import 'package:flutter_rename_app/src/utils/logger.dart';
import 'package:process_run/shell_run.dart';

import 'changes/files_to_modify_content.dart';
import 'models/config.dart';
import 'models/errors.dart';
import 'models/required_change.dart';
import 'utils/get_config.dart';

renameApp() async {
  try {
    final Config config = await getConfig();
    Logger.info("Current app name: ${config.oldAppName}");
    Logger.info("New name will be: ${config.newAppName}");

    Logger.info("Current app application id = ${config.oldApplicationId}");
    Logger.info("New application id will be: ${config.newApplicationId}");

    Logger.info("Current app bundle id = ${config.oldBundleId}");
    Logger.info("New application bundle id will be: ${config.newBundleId}");

    Logger.info("Current app dart package = ${config.oldDartPackageName}");
    Logger.info("New app dart package: ${config.newDartPackageName}");

    Logger.info("Current app android package name = ${config.oldAndroidPackageName}");
    Logger.info("New app android package name: ${config.newAndroidPackageName}");

    final List<RequiredChange> contentChanges = getFilesToModifyContent(config);
    _applyContentChanges(contentChanges);

    final List<RequiredChange> nameChanges = getFilesToModifyName(config);
    _applyNameChanges(nameChanges);

    Logger.newLine();
    Logger.newLine();

    Logger.info("Let's change all in lib !");
    await _changeAllImportsIn("lib", config);

    Logger.info("Let's change all in tests !");
    await _changeAllImportsIn("test", config);

    ///await _changeAndroidPackageName(config);

    final shell = Shell();

    await shell.run("flutter pub get");
  } catch (error) {
    if (error is MissingConfiguration) {
      Logger.error(error.message);
      return;
    }
  }
}

_changeAndroidPackageName(Config config) async {
  Logger.newLine();
  Logger.info("Changing android package name");
  final String newPackageName = config.newAndroidPackageName;
  final List<String> newPackageNameParts = newPackageName.split(".");

  final Directory javaDirectory = Directory("android/app/src/main/java");
  int index = 0;
  javaDirectory.list(recursive: true).forEach((FileSystemEntity fileSystemEntity) {
    if (index < newPackageNameParts.length - 1 &&
        fileSystemEntity is Directory &&
        fileSystemEntity.path.endsWith(newPackageNameParts[index])) {
      fileSystemEntity.renameSync(newPackageNameParts[index]);
      print("CHANGED dir name from ${fileSystemEntity.path} to ${newPackageNameParts[index]} ");
      index++;
    }
  });

  final Directory kotlinDirectory = Directory("android/app/src/main/kotlin");
  index = 0;
  kotlinDirectory.list(recursive: true).forEach((FileSystemEntity fileSystemEntity) {
    if (index < newPackageNameParts.length - 1 &&
        fileSystemEntity is Directory &&
        fileSystemEntity.path.endsWith(newPackageNameParts[index])) {
      fileSystemEntity.renameSync(newPackageNameParts[index]);
      print("CHANGED dir name from ${fileSystemEntity.path} to ${newPackageNameParts[index]} ");
      index++;
    }
  });

  Logger.newLine();
}

_changeAllImportsIn(String directoryPath, Config config) async {
  final Directory directory = Directory(directoryPath);
  if (directory.existsSync()) {
    final List<FileSystemEntity> files = directory.listSync(recursive: true);
    await Future.forEach(files, (FileSystemEntity fileSystemEntity) async {
      if (fileSystemEntity is File) {
        await _changeContentInFile(
          fileSystemEntity.path,
          RegExp(config.oldDartPackageName),
          config.newDartPackageName,
        );
      }
    });
  } else {
    Logger.error("Missing $directoryPath, it will be ignored");
  }
}

_applyNameChanges(List<RequiredChange> requiredChanges) async {
  await Future.forEach(requiredChanges, (RequiredChange change) async {
    for (final path in change.paths) {
      await _changeFileName(path, change.regexp, change.replacement);
    }
  });
}

_applyContentChanges(List<RequiredChange> requiredChanges) async {
  await Future.forEach(requiredChanges, (RequiredChange change) async {
    for (final path in change.paths) {
      if (change.isDirectory) {
        final Directory directory = Directory(path);
        Future.forEach(directory.listSync(recursive: true), (FileSystemEntity entity) async {
          await _changeContentInFile(entity.path, change.regexp, change.replacement);
        });
      } else {
        await _changeContentInFile(path, change.regexp, change.replacement);
      }
    }
  });
}

_changeFileName(String filePath, RegExp regexp, String replacement) async {
  if (filePath.contains(regexp)) {
    try {
      final File file = File(filePath);
      file.renameSync(filePath.replaceAll(regexp, replacement));
    } on FileSystemException {
      Logger.error("File $filePath does not exist on this project");
    }
  }
}

_changeContentInFile(String filePath, RegExp regexp, String replacement) async {
  try {
    final File file = File(filePath);
    final String content = await file.readAsString();
    if (content.contains(regexp)) {
      final String newContent = content.replaceAll(regexp, replacement);
      await file.writeAsString(newContent);
      Logger.info("Changed file $filePath");
    }
  } on FileSystemException {
    Logger.error("File $filePath does not exist on this project");
  }
}
