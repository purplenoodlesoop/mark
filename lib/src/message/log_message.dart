import 'package:mark/src/logger/logger.dart';
import 'package:mark/src/message/primitive_log_messages.dart';
import 'package:mark/src/shared/zoned_meta.dart';

/// An interface for log messages.
///
/// A log message is a message that is logged by the [Logger]. It contains
/// the [severityValue] of the message, the [stackTrace] of the message, and
/// optional [meta] and [data] that can be used to provide additional
/// information.
abstract class LogMessage {
  const LogMessage();

  /// The severity of the message.
  int get severityValue;

  /// The stack trace of the message.
  StackTrace get stackTrace;

  /// The data of the message.
  Object? get data;

  /// The meta data of the message.
  Object? get meta;

  Map<String, Object?> toJson();

  T matchPrimitive<T>({
    required T Function(PrimitiveLogMessage message) primitive,
    required T Function(LogMessage message) orElse,
  });

  @override
  String toString();
}

/// A base class for log messages.
///
/// This class provides a default base implementation for [LogMessage] that
/// can be extended to provide additional functionality.
///
/// Includes the [stackTrace] and [meta] of the message in the base constructor
/// and provides a default implementation of [toJson].
abstract class BaseLogMessage implements LogMessage {
  @override
  final StackTrace stackTrace;

  @override
  final Object? meta;

  BaseLogMessage({StackTrace? stackTrace, Object? meta})
      : stackTrace = stackTrace ?? StackTrace.current,
        meta = meta ?? ZonedMeta.current;

  /// Converts the message to a JSON object, represented by
  /// a [Map<String, Object?>].
  @override
  Map<String, Object?> toJson() => {
        'type': runtimeType.toString(),
        'severity': severityValue,
        'data': data.toString(),
        'meta': meta.toString(),
      };

  @override
  String toString() {
    final buffer = StringBuffer();
    if (meta != null) {
      buffer
        ..write(meta)
        ..write(' ');
    }
    buffer.write(data);

    return buffer.toString();
  }

  @override
  T matchPrimitive<T>({
    required T Function(PrimitiveLogMessage message) primitive,
    required T Function(LogMessage message) orElse,
  }) =>
      orElse(this);
}
