import 'dart:io';

import 'package:mark/mark.dart';

class FileMessageProcessor extends BaseMessageProcessor<LogMessage, String> {
  final IOSink _sink;

  FileMessageProcessor({
    required IOSink sink,
  }) : _sink = sink;

  static String _wrapWithQuotes(Object? source) => '"$source"';

  @override
  String format(LogMessage message) {
    final row = message.toJson().values.map(_wrapWithQuotes).join(',');

    return '$row\n';
  }

  @override
  void process(
    LogMessage message,
    String formattedMessage,
  ) {
    _sink.write(formattedMessage);
  }
}
