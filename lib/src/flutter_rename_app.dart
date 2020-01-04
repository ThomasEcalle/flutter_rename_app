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

    Logger.newLine();

    if (config.oldDartPackageName != config.newDartPackageName) {
      Logger.info("Let's change all in lib !");
      _changeAllImportsIn("lib", config);

      Logger.info("Let's change all in tests !");
      _changeAllImportsIn("test", config);
    }

    if (config.oldAndroidPackageName != config.newAndroidPackageName) {
      await changeAndroidPackageName(config);
    }

    final List<RequiredChange> contentChanges = getFilesToModifyContent(config);
    _applyContentChanges(contentChanges);

    final List<RequiredChange> nameChanges = getFilesToModifyName(config);
    _applyNameChanges(nameChanges);

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
_changeAllImportsIn(String directoryPath, Config config) {
  final Directory directory = Directory(directoryPath);
  if (directory.existsSync()) {
    final List<FileSystemEntity> files = directory.listSync(recursive: true);
    files.forEach((FileSystemEntity fileSystemEntity) {
      if (fileSystemEntity is File) {
        _changeContentInFile(
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
_applyNameChanges(List<RequiredChange> requiredChanges) {
  requiredChanges.forEach((RequiredChange change) {
    if (change.needChanges) {
      for (final path in change.paths) {
        _changeFileName(path, change.regexp, change.replacement);
      }
    }
  });
}

/// Apply the list of required files content changes
_applyContentChanges(List<RequiredChange> requiredChanges) {
  requiredChanges.forEach((RequiredChange change) {
    if (change.needChanges) {
      for (final path in change.paths) {
        if (change.isDirectory) {
          final Directory directory = Directory(path);
          directory.listSync(recursive: true).forEach((FileSystemEntity entity) {
            _changeContentInFile(entity.path, change.regexp, change.replacement);
          });
        } else {
          _changeContentInFile(path, change.regexp, change.replacement);
        }
      }
    }
  });
}

/// Change the name of the File at the given path by the given replacement name
_changeFileName(String filePath, RegExp regexp, String replacement) {
  if (filePath.contains(regexp)) {
    try {
      final File file = File(filePath);
      file.renameSync(filePath.replaceAll(regexp, replacement));
    } catch (error) {}
  }
}

/// Change content of the given File by the given content
_changeContentInFile(String filePath, RegExp regexp, String replacement) {
  try {
    final File file = File(filePath);
    final String content = file.readAsStringSync();
    if (content.contains(regexp)) {
      final String newContent = content.replaceAll(regexp, replacement);
      file.writeAsStringSync(newContent);
      Logger.info("$filePath has been modified");
    }
  } catch (error) {}
}
