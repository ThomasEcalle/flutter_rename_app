import 'package:flutter_rename_app/src/utils/logger.dart';
import 'package:flutter_rename_app/src/flutter_rename_app.dart';

void main(List<String> args) {
  if (args.length < 1) {
    Logger.error("Need new application's name");
    return;
  }

  final String newAppName =  args[0];
  renameApp(newAppName);
}
