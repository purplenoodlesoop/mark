import 'dart:io';

import 'package:mark/src/message/log_message.dart';
import 'package:mark/src/processor/processor/print_message_printer.dart'
    as printer;

void printMessage(LogMessage message, String data) {
  stdout.hasTerminal
      ? stdout.writeln(data)
      : printer.printMessage(message, data);
}
