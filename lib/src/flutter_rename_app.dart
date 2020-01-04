library flutter_rename_app;

import 'dart:io';

import 'package:flutter_rename_app/src/changes/files_to_modify_name.dart';
import 'package:flutter_rename_app/src/utils/logger.dart';
import 'package:process_run/shell_run.dart';

import 'changes/files_to_modify_content.dart';
import 'models/config.dart';
import 'models/errors.dart';
import 'models/required_change.dart';
import 'utils/change_android_package_name.dart';
import 'utils/get_config.dart';

const Duration fakeDelay = Duration(milliseconds: 500);

renameApp() async {
  try {
    final Config config = await getConfig();
    bool requireChanges = false;

    if (config.oldAppName != config.newAppName) {
      Logger.info(
          "Need to change the application name from : ${config.oldAppName} to ${config.newAppName}");
      requireChanges = true;
    }

    if (config.oldApplicationId != config.newApplicationId) {
      Logger.info(
          "Need to change the application id from : ${config.oldApplicationId} to ${config.newApplicationId}");
      requireChanges = true;
    }

    if (config.oldBundleId != config.newBundleId) {
      Logger.info(
          "Need to change the bundle id from : ${config.oldBundleId} to ${config.newBundleId}");
      requireChanges = true;
    }

    if (config.oldDartPackageName != config.newDartPackageName) {
      Logger.info(
          "Need to change the dart package from : ${config.oldDartPackageName} to ${config.newDartPackageName}");
      requireChanges = true;
    }

    if (config.oldAndroidPackageName != config.newAndroidPackageName) {
      Logger.info(
          "Need to change the android package name from : ${config.oldAndroidPackageName} to ${config.newAndroidPackageName}");
      requireChanges = true;
    }

    if (!requireChanges) {
      Logger.info("It seems that no changes are required since last time !");
      return;
    }

    await Future.delayed(fakeDelay);

    Logger.newLine();

    if (config.oldDartPackageName != config.newDartPackageName) {
      await _changeAllImportsIn("lib", config);
      await _changeAllImportsIn("test", config);
    }

    if (config.oldAndroidPackageName != config.newAndroidPackageName) {
      await changeAndroidPackageName(config);
    }

    final List<RequiredChange> contentChanges = getFilesToModifyContent(config);
    await _applyContentChanges(contentChanges);

    final List<RequiredChange> nameChanges = getFilesToModifyName(config);
    await _applyNameChanges(nameChanges);

    final shell = Shell();

    await shell.run("flutter pub get");
  } catch (error) {
    if (error is MissingConfiguration) {
      Logger.error(error.message);
      return;
    }
  }
}

/// Change all imports in given path (recursively)
/// Needed in order to change dart package name in lib or test
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

/// Apply the list of required files name changes
_applyNameChanges(List<RequiredChange> requiredChanges) async {
  await Future.forEach(requiredChanges, (RequiredChange change) async {
    if (change.needChanges) {
      for (final path in change.paths) {
        await _changeFileName(path, change.regexp, change.replacement);
      }
    }
  });
}

/// Apply the list of required files content changes
_applyContentChanges(List<RequiredChange> requiredChanges) async {
  await Future.forEach(requiredChanges, (RequiredChange change) async {
    if (change.needChanges) {
      for (final path in change.paths) {
        if (change.isDirectory) {
          final Directory directory = Directory(path);
          await Future.forEach(directory.listSync(recursive: true),
              (FileSystemEntity entity) async {
            await _changeContentInFile(entity.path, change.regexp, change.replacement);
          });
        } else {
          await _changeContentInFile(path, change.regexp, change.replacement);
        }
      }
    }
  });
}

/// Change the name of the File at the given path by the given replacement name
_changeFileName(String filePath, RegExp regexp, String replacement) async {
  if (filePath.contains(regexp)) {
    try {
      final File file = File(filePath);
      file.renameSync(filePath.replaceAll(regexp, replacement));
      Logger.info("$filePath", greenPart: "MODIFIED");
      await Future.delayed(fakeDelay);
    } catch (error) {}
  }
}

/// Change content of the given File by the given content
_changeContentInFile(String filePath, RegExp regexp, String replacement) async {
  try {
    final File file = File(filePath);
    final String content = file.readAsStringSync();
    if (content.contains(regexp)) {
      final String newContent = content.replaceAll(regexp, replacement);
      file.writeAsStringSync(newContent);
      Logger.info("$filePath", greenPart: "MODIFIED");
      await Future.delayed(fakeDelay);
    }
  } catch (error) {}
}
