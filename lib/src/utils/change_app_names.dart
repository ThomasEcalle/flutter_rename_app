import 'dart:io';

import 'package:flutter_rename_app/src/models/config.dart';
import 'package:flutter_rename_app/src/utils/utils.dart';
import 'package:xml/xml.dart' as xml;

changeAppNames(Config config) async {
  await _changeAndroidAppNames(config);
  await _changeIosAppNames(config);
}

_changeIosAppNames(Config config) async {
  if (config.oldAppName != config.newAppName) {
    Utils.changeContentInFile(
      "ios/Runner/Info.plist",
      RegExp(config.oldAppName),
      config.newAppName,
    );
  }
}

_changeAndroidAppNames(Config config) async {
  await _changeAndroidManifest();
  await _changeAndroidValues(config);
}

_changeAndroidValues(Config config) async {
  final Directory androidResources = Directory("android/app/src/main/res");
  final List<FileSystemEntity> resourcesEntities = androidResources.listSync();

  final Map<String, String> newI18nAppNames = config.newI18nAppNames;

  for (final FileSystemEntity resourceEntity in resourcesEntities) {
    final String resourceName = Utils.getFileName(resourceEntity.path);

    if (resourceName.contains("values") && resourceEntity is Directory) {
      final String lang = Utils.getLangFromAndroidValuesDir(resourceName);

      print("topiqueur: ${resourceEntity.path}");

      /// if lang is null, then we are in the default values directory
      if (lang == null) {
        await _changeNameInValueDirectory(
          newI18nAppNames,
          "android/app/src/main/res/values/strings.xml",
          lang,
          isDefault: true,
          newDefaultName: config.newAppName,
        );
      } else {
        final String stringsFilePath = "android/app/src/main/res/values-$lang/strings.xml";
        if (newI18nAppNames.containsKey(lang)) {
          await _changeNameInValueDirectory(
            newI18nAppNames,
            stringsFilePath,
            lang,
          );
        } else {
          await _removeNameInValueDirectory(
            newI18nAppNames,
            stringsFilePath,
          );
        }
      }
    }
  }
}

/// Write the new name in the strings.xml of the concerned values dir
/// There is 3 case :
/// * strings.xml does not exist in Directory
/// * <string name="app_name">(.*)</string> is Already present, the we modify it
/// * <string name="app_name">(.*)</string> is not present and we add it
_changeNameInValueDirectory(
  Map<String, String> newI18nAppNames,
  String valuesStringsPath,
  String lang, {
  bool isDefault = false,
  String newDefaultName = "",
}) async {
  // TODO: Handle strings.xml existence, <resources> existence, etc.

  final File file = File(valuesStringsPath);
  final String name = isDefault ? newDefaultName : newI18nAppNames[lang];
  if (file.existsSync()) {
    final String result = await Utils.searchInFile(
      filePath: valuesStringsPath,
      pattern: RegExp('<string name="app_name">(.*)</string>'),
    );

    if (result != null) {
      await Utils.changeContentInFile(
        valuesStringsPath,
        RegExp('<string name="app_name">(.*)</string>'),
        '<string name="app_name">$name</string>',
      );
    } else {
      final String stringsContent = File(valuesStringsPath).readAsStringSync();
      final xml.XmlDocument document = xml.parse(stringsContent);
      final List<xml.XmlElement> elements = document.findElements("resources").toList();
      final xml.XmlElement resourcesElement = elements.first;
      print("resourcesElement = $resourcesElement");
    }
  } else {
    file.createSync(recursive: true);
    final String content = """
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <string name="app_name">$name</string>
</resources>
    """;
    file.writeAsStringSync(content);
  }
}

/// Remove name that is no longer used in strings.xml of the concerned locale
_removeNameInValueDirectory(Map<String, String> newI18nAppNames, String lang) async {
  final File stringsXml = File("android/app/src/main/res/values-$lang/strings.xml");
  final String content = stringsXml.readAsStringSync();
  final newContent = content.replaceAll(RegExp('<string name="app_name">(.*)</string>'), "");
  stringsXml.writeAsStringSync(newContent);
}

/// Look in AndroidManifest for the presence of @string/app_name value in android:label
/// If not, the function writes it
_changeAndroidManifest() async {
  final String androidManifestPath = "android/app/src/main/AndroidManifest.xml";
  final String result = await Utils.searchInFile(
    filePath: androidManifestPath,
    pattern: RegExp('android:label="(@string/app_name)"'),
  );

  if (result != null) return;

  await Utils.changeContentInFile(
    androidManifestPath,
    RegExp('android:label="(.*)"'),
    'android:label="@string/app_name"',
  );
}
