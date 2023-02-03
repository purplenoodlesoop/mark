import 'dart:async';

import 'package:mark/src/message/log_message.dart';
import 'package:mark/src/message/primitive_log_messages.dart';
import 'package:mark/src/processor/processor/message_processor.dart';

/// A collection of [MessageProcessor]s.
typedef MessageProcessors = Iterable<MessageProcessor>;

/// A [LoggerLifecycle] is a class that defines the lifecycle of a [Logger].
///
/// A [Logger] must be disposed when it is no longer needed, as failing to do so
/// may result in memory leaks.
///
/// A [Logger] can be forked to create a new [Logger] with the same
/// configuration as the original [Logger], but with additional
/// [MessageProcessor]s.
abstract class LoggerLifecycle {
  /// Disposes the [Logger].
  Future<void> dispose();

  /// Forks the [Logger] to create a new [Logger] with the same configuration as
  /// the original [Logger], but with additional [processors].
  Logger fork({required MessageProcessors processors});
}

/// A [LoggerMarker] is a class that can be used to log primitive [LogMessage]s.
abstract class LoggerMarker {
  /// Logs a custom [message] using this [Logger].
  void mark(LogMessage message);
}

/// A [Logger] is a class that can be used to log [PrimitiveLogMessage]s.
abstract class PrimitivesLogMarker {
  /// Logs a message with [data] and [meta] at the [InfoMessage.severity] level
  /// using [InfoMessage] as the [LogMessage] implementation.
  void info(
    Object? data, {
    StackTrace? stackTrace,
    Object? meta,
  });

  /// Logs a message with [data] and [meta] at the [DebugMessage.severity] level
  /// using [DebugMessage] as the [LogMessage] implementation.
  void debug(
    Object? data, {
    StackTrace? stackTrace,
    Object? meta,
  });

  /// Logs a message with [data] and [meta] at the [WarningMessage.severity]
  /// level using [WarningMessage] as the [LogMessage] implementation.
  void warning(
    Object? data, {
    StackTrace? stackTrace,
    Object? meta,
  });

  /// Logs a message with [data] and [meta] at the [ErrorMessage.severity] level
  /// using [ErrorMessage] as the [LogMessage] implementation.
  void error(
    Object? data, {
    StackTrace? stackTrace,
    Object? meta,
  });
}

/// A [Logger] is a class that can be used to log messages.
///
/// A [Logger] can be used to log messages of different severity levels, such as
/// [info], [debug], [warning], and [error], as well as [mark] that can be used
/// to log any custom implementation of [LogMessage].
///
/// A [Logger] can be configured with a list of [MessageProcessor]s that will
/// process the messages, such as printing them to the console, or sending them
/// to a remote server.
///
/// A [Logger] must be disposed when it is no longer needed, as failing to do so
/// may result in memory leaks.
abstract class Logger
    implements LoggerMarker, PrimitivesLogMarker, LoggerLifecycle {
  factory Logger({
    MessageProcessors processors,
  }) = _Logger;
}

class _Logger implements Logger {
  final Logger? _source;
  late final StreamController<LogMessage> _messagesController =
      StreamController.broadcast(sync: true);
  late final List<StreamSubscription<void>> _subscriptions;

  _Logger({
    MessageProcessors processors = const [],
    Logger? source,
  }) : _source = source {
    _subscriptions = processors
        .map(
          (processor) => processor
              .processMessages(_messagesController.stream)
              .listen(null),
        )
        .toList();
  }
  @override
  void mark(LogMessage message) {
    _source?.mark(message);
    _messagesController.add(message);
  }

  @override
  void info(
    Object? data, {
    StackTrace? stackTrace,
    Object? meta,
  }) {
    mark(
      InfoMessage(
        data,
        stackTrace: stackTrace,
        meta: meta,
      ),
    );
  }

  @override
  void debug(
    Object? data, {
    StackTrace? stackTrace,
    Object? meta,
  }) {
    mark(
      DebugMessage(
        data,
        stackTrace: stackTrace,
        meta: meta,
      ),
    );
  }

  @override
  void warning(
    Object? data, {
    StackTrace? stackTrace,
    Object? meta,
  }) {
    mark(
      WarningMessage(
        data,
        stackTrace: stackTrace,
        meta: meta,
      ),
    );
  }

  @override
  void error(
    Object? data, {
    StackTrace? stackTrace,
    Object? meta,
  }) {
    mark(
      ErrorMessage(
        data,
        stackTrace: stackTrace,
        meta: meta,
      ),
    );
  }

  @override
  Future<void> dispose() async {
    for (final subscription in _subscriptions) {
      await subscription.cancel();
    }
    await _messagesController.close();
  }

  @override
  Logger fork({required MessageProcessors processors}) => _Logger(
        processors: processors,
        source: this,
      );
}
