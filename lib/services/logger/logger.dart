import 'package:logger/logger.dart';

Logger printLogger = Logger(printer: SimpleLogPrinter());

printLog(String text, {Level level = Level.debug}) {
  printLogger.log(level, text);
}

class SimpleLogPrinter extends LogPrinter {
  @override
  List<String> log(LogEvent event) {
    var color = PrettyPrinter.defaultLevelColors[event.level];
    var emoji = PrettyPrinter.defaultLevelEmojis[event.level];
    return [color!("$emoji  ${event.message}")];
  }
}
