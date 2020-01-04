import 'package:ansicolor/ansicolor.dart';

class Logger {
  static info(String message, {String greenPart = ""}) {
    final AnsiPen whitePen = new AnsiPen()..white(bold: true);
    final AnsiPen greenPen = new AnsiPen()..green(bold: true);
    print("${whitePen(message)} ${greenPen(greenPart)}");
  }

  static error(String message) {
    final AnsiPen redPen = new AnsiPen()..red(bold: true);
    print(redPen(message));
  }

  static newLine() {
    print("\n");
  }
}
