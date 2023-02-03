import 'dart:async';

import 'package:mark/src/logger/logger.dart';
import 'package:mark/src/message/log_message.dart';
import 'package:meta/meta.dart';

/// An interface for message processors.
///
/// A message processor is a class that processes messages that are logged
/// by the [Logger],  and can be used to perform additional actions with the
/// messages.
///
/// For example, a message processor can be used to send messages to a remote
/// logging service, or to write messages to a file.
abstract class MessageProcessor {
  /// Processes the messages that are logged by the [Logger].
  ///
  /// The [messages] stream contains all messages that are logged by the
  /// [Logger].
  Stream<void> processMessages(Stream<LogMessage> messages);
}

/// A class that represents a log entry that is processed by a
/// [MessageProcessor].
///
/// A log entry contains the [message] that will be logged by the [Logger],
/// and the [formattedMessage] that was formatted by the [MessageProcessor].
@immutable
class LogEntry<M extends LogMessage, R extends Object> {
  final M message;
  final R formattedMessage;

  const LogEntry(this.message, this.formattedMessage);
}

/// A function that processes a [LogEntry].
typedef EntryProcessorF<M extends LogMessage, R extends Object> = FutureOr<void>
    Function(LogEntry<M, R> entry);

/// An interface for message formatters of a specific type [M] to a specific
/// type [R].
abstract class MessageFormatter<M extends LogMessage, R extends Object> {
  /// Formats the [message] that is logged by the [Logger].
  @visibleForOverriding
  @protected
  R format(M message);
}

/// A base class for message processors that process messages of a specific
/// type [M].
///
/// This class provides a default base implementation for [MessageProcessor]
/// that can be extended to provide additional functionality.
///
/// This class provides a default implementation of [processMessages] that
/// processes messages of type [M] that are logged by the [Logger] and passes
/// them to the [process] method.
abstract class BaseMessageProcessor<M extends LogMessage, R extends Object>
    implements MessageProcessor, MessageFormatter<M, R> {
  const BaseMessageProcessor();

  @visibleForOverriding
  @protected
  @override
  R format(M message);

  /// Processes the [message] that is logged by the [Logger].
  @visibleForOverriding
  @protected
  FutureOr<void> process(M message, R formattedMessage);

  /// Determines whether the [message] should be processed.
  @visibleForOverriding
  @protected
  bool allow(M message) => true;

  /// Transforms the [entries] stream using the [processorF] function.
  ///
  /// This method is used to transform the [entries] stream using the
  /// [processorF] function. This method is used to specify the order in which
  /// asynchronous operations are performed on the [entries] stream.
  @visibleForOverriding
  @protected
  Stream<void> transform(
    EntryProcessorF<M, R> processorF,
    Stream<LogEntry<M, R>> entries,
  ) =>
      entries.asyncMap(processorF);

  FutureOr<void> _processEntry(LogEntry<M, R> entry) => process(
        entry.message,
        entry.formattedMessage,
      );

  bool _isAppropriateType(LogMessage message) => message is M;

  LogEntry<M, R> _assembleEntry(M message) => LogEntry(
        message,
        format(message),
      );

  @override
  @internal
  @nonVirtual
  Stream<void> processMessages(Stream<LogMessage> messages) => transform(
        _processEntry,
        messages
            .where(_isAppropriateType)
            .cast<M>()
            .where(allow)
            .map(_assembleEntry),
      );
}
