import 'package:ansicolor/ansicolor.dart';

/// Simple logger
class Logger {
  /// Print the [message] in white and the [greenPart] in green
  static info(String message, {String greenPart = ""}) {
    final AnsiPen whitePen = new AnsiPen()..white(bold: true);
    final AnsiPen greenPen = new AnsiPen()..green(bold: true);
    print("${whitePen(message)} ${greenPen(greenPart)}");
  }

  /// Print the [message] in red
  static error(String message) {
    final AnsiPen redPen = new AnsiPen()..red(bold: true);
    print(redPen(message));
  }

  /// Print a new line
  static newLine() {
    print("\n");
  }
}
