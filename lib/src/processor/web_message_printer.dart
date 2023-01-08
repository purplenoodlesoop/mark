import 'dart:html';

import 'package:mark/src/message/log_message.dart';

void Function(Object? data) _matchPrinter(LogMessage message) {
  final console = window.console;
  final info = console.info;

  return message.matchPrimitive(
    primitive: (message) => message.match(
      info: (_) => info,
      debug: (_) => console.debug,
      warning: (_) => console.warn,
      error: (_) => console.error,
    ),
    orElse: (_) => info,
  );
}

void printMessage(LogMessage message, String data) {
  _matchPrinter(message)(data);
}
