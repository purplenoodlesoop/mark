import 'package:mark/src/message/log_message.dart';
import 'package:mark/src/processor/processor/message_processor.dart';

/// A mixin for [MessageProcessor] that returns the original message as the
/// formatted message.
mixin IdentityMessageFormatterMixin<M extends LogMessage>
    implements MessageFormatter<M, M> {
  @override
  M format(M message) => message;
}
