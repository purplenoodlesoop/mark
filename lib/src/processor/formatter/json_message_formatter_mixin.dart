import 'package:mark/src/message/log_message.dart';
import 'package:mark/src/processor/processor/message_processor.dart';

/// A mixin for [MessageProcessor] that formats messages to JSON using the
/// [LogMessage.toJson] method on the message.
mixin JsonMessageFormatterMixin<M extends LogMessage>
    implements MessageFormatter<M, Map<String, Object?>> {
  @override
  Map<String, Object?> format(M message) => message.toJson();
}
