import 'package:flutter_rename_app/src/models/config.dart';

changeIosDirectoriesNames(Config config) async {
  final String oldIOSDirectories = config.oldAppName.replaceAll(" ", "");
  print("oldIOSDirectories = $oldIOSDirectories");
}
