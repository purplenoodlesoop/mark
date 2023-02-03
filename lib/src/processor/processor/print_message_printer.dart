import 'dart:async';

import 'package:mark/src/message/log_message.dart';

void printMessage(LogMessage message, String data) {
  Zone.current.print(data);
}
