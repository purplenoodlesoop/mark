import 'package:mark/src/message/log_message.dart';
import 'package:meta/meta.dart';

/// A base class for primitive log messages.
///
/// Primitive log messages are log messages that do not contain any additional
/// information, and only contain a single [data] field. They represent
/// informational, debug, warning, and error messages.
@sealed
@immutable
abstract class PrimitiveLogMessage implements LogMessage {
  const PrimitiveLogMessage._();

  T match<T>({
    required T Function(InfoMessage message) info,
    required T Function(DebugMessage message) debug,
    required T Function(WarningMessage message) warning,
    required T Function(ErrorMessage message) error,
  });
}

abstract class _BasePrimitiveLogMessage extends BaseLogMessage
    implements PrimitiveLogMessage {
  @override
  final Object? data;

  _BasePrimitiveLogMessage(this.data, {super.stackTrace, super.meta});

  @override
  T matchPrimitive<T>({
    required T Function(PrimitiveLogMessage message) primitive,
    required T Function() orElse,
  }) =>
      primitive(this);
}

/// A log message that represents an informational message.
class InfoMessage extends _BasePrimitiveLogMessage {
  static const int severity = 0;

  InfoMessage(super.data, {super.stackTrace, super.meta});

  @override
  int get severityValue => severity;

  @override
  T match<T>({
    required T Function(InfoMessage message) info,
    required T Function(DebugMessage message) debug,
    required T Function(WarningMessage message) warning,
    required T Function(ErrorMessage message) error,
  }) =>
      info(this);
}

/// A log message that represents a debug message.
class DebugMessage extends _BasePrimitiveLogMessage {
  static const int severity = 1;

  DebugMessage(super.data, {super.stackTrace, super.meta});

  @override
  int get severityValue => severity;

  @override
  T match<T>({
    required T Function(InfoMessage message) info,
    required T Function(DebugMessage message) debug,
    required T Function(WarningMessage message) warning,
    required T Function(ErrorMessage message) error,
  }) =>
      debug(this);
}

/// A log message that represents a warning message.
class WarningMessage extends _BasePrimitiveLogMessage {
  static const int severity = 2;

  WarningMessage(super.data, {super.stackTrace, super.meta});

  @override
  int get severityValue => severity;

  @override
  T match<T>({
    required T Function(InfoMessage message) info,
    required T Function(DebugMessage message) debug,
    required T Function(WarningMessage message) warning,
    required T Function(ErrorMessage message) error,
  }) =>
      warning(this);
}

/// A log message that represents an error message.
class ErrorMessage extends _BasePrimitiveLogMessage {
  static const int severity = 3;

  ErrorMessage(super.data, {super.stackTrace, super.meta});

  @override
  int get severityValue => severity;

  @override
  T match<T>({
    required T Function(InfoMessage message) info,
    required T Function(DebugMessage message) debug,
    required T Function(WarningMessage message) warning,
    required T Function(ErrorMessage message) error,
  }) =>
      error(this);
}
