library flutter_rename_app;

import 'dart:io';

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

    return;

    final List<RequiredChange> requiredChanges = getFilesToModifyContent(config);
    applyContentChanges(requiredChanges);

    Logger.newLine();
    Logger.newLine();

    Logger.info("Let's change all in lib !");
    await changeAllFilesIn("lib", config);

    Logger.info("Let's change all in tests !");
    await changeAllFilesIn("test", config);

    var shell = Shell();

    await shell.run("flutter pub get");
  } catch (error) {
    if (error is MissingConfiguration) {
      Logger.error(error.message);
      return;
    }
  }
}

changeAllFilesIn(String directoryPath, Config config) async {
  final Directory directory = Directory(directoryPath);
  if (directory.existsSync()) {
    final List<FileSystemEntity> files = directory.listSync(recursive: true);
    await Future.forEach(files, (FileSystemEntity fileSystemEntity) async {
      if (fileSystemEntity is File) {
        await changeContentInFile(
          fileSystemEntity.path,
          RegExp(config.oldApplicationId),
          config.newApplicationId,
        );
      }
    });
  } else {
    Logger.error("Missing $directoryPath, it will be ignored");
  }
}

applyContentChanges(List<RequiredChange> requiredChanges) async {
  await Future.forEach(requiredChanges, (RequiredChange change) async {
    for (var path in change.paths) {
      await changeContentInFile(path, change.regexp, change.replacement);
    }
  });
}

changeContentInFile(String filePath, RegExp regexp, String replacement) async {
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
