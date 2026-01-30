import 'package:logger/web.dart';

class MyLogger {
  static Logger instance = Logger(
    filter: null,
    printer: PrettyPrinter(
      methodCount: 0,
      errorMethodCount: 8,
      lineLength: 120,
      colors: true,
      printEmojis: true,
    ),
  );
}
