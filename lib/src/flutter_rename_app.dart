library flutter_rename_app;

import 'dart:io';

import 'package:flutter_rename_app/src/utils/logger.dart';
import 'package:process_run/shell_run.dart';

import 'changes/files_to_modify_content.dart';
import 'models/config.dart';
import 'models/required_change.dart';
import 'utils/get_config.dart';

renameApp(String newAppName) async {
  final Config config = await getConfig(newAppName);

  Logger.info("New name will be: $newAppName");
  Logger.info("New identifier will be: ${config.newIdentifier}");
  Logger.info("Current app identifier = ${config.oldIdentifier}");
  Logger.info("Current app name = ${config.oldAppName}");

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
}

changeAllFilesIn(String directoryPath, Config config) async {
  final Directory directory = Directory(directoryPath);
  if (directory.existsSync()) {
    final List<FileSystemEntity> files = directory.listSync(recursive: true);
    await Future.forEach(files, (FileSystemEntity fileSystemEntity) async {
      if (fileSystemEntity is File) {
        await changeContentInFile(
          fileSystemEntity.path,
          RegExp(config.oldIdentifier),
          config.newIdentifier,
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
