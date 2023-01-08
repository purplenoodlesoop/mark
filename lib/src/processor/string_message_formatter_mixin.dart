import 'package:mark/src/message/log_message.dart';
import 'package:mark/src/processor/message_processor.dart';

/// A mixin for [MessageProcessor] that formats messages to string using the
/// [LogMessage.toString] method on the message.
mixin StringMessageFormatterMixin<M extends LogMessage>
    implements MessageFormatter<M, String> {
  @override
  String format(M message) => message.toString();
}
