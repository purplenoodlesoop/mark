import 'dart:io';

import 'package:mark/mark.dart';

import 'custom_message.dart';
import 'custom_processor.dart';

Future<void> main(List<String> args) async {
  final logs = File('logs.csv').openWrite(mode: FileMode.append)
    ..write(
      'Type, Meta, StackTrace, Data\n',
    );

  final logger = Logger(
    processors: [
      const EphemeralMessageProcessor(),
      FileMessageProcessor(sink: logs),
    ],
  )..info('Started example');

  await ZonedMeta.attach(
    'Counter',
    () => counterExample(logger),
  );
  ZonedMeta.attach(
    'Exceptions',
    () => exceptionsExample(logger),
  );
  logger.info('Finished example');
  await logs.flush();
  await logs.close();
  await logger.dispose();
}

Future<void> counterExample(Logger sourceLogger) async {
  final counterProcessor = CounterMessagesProcessor();
  final logger = sourceLogger.fork(
    processors: [
      counterProcessor,
    ],
  );
  var counter = 0;
  void mutateCounter(int delta) {
    counter += delta;
    logger.counter(delta);
  }

  while (counter < 10) {
    mutateCounter(1);
  }
  mutateCounter(-2);
  logger.info('Deltas history: ${counterProcessor.history}');
  await logger.dispose();
}

void exceptionsExample(Logger logger) {
  try {
    throw Exception('Example exception');
  } on Object catch (e, s) {
    logger.error(e, stackTrace: s);
  }
}
