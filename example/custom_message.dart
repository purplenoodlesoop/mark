import 'dart:collection';

import 'package:mark/mark.dart';

class CounterMessage extends BaseLogMessage {
  static const int severity = InfoMessage.severity;

  @override
  final int data;

  CounterMessage(this.data, {super.stackTrace, super.meta});

  @override
  int get severityValue => severity;
}

class CounterMessagesProcessor
    extends BaseMessageProcessor<CounterMessage, int> {
  CounterMessagesProcessor();

  late final List<int> _history = [];

  List<int> get history => UnmodifiableListView(_history);

  @override
  int format(CounterMessage message) => message.data;

  @override
  void process(CounterMessage message, int formattedMessage) {
    _history.add(formattedMessage);
  }
}

extension CounterMessageX on Logger {
  void counter(int data, {Object? meta, StackTrace? stackTrace}) {
    mark(CounterMessage(data, meta: meta, stackTrace: stackTrace));
  }
}
