import 'package:mark/src/message/log_message.dart';
import 'package:mark/src/processor/message_processor.dart';
import 'package:mark/src/processor/print_message_printer.dart'
    if (dart.library.html) 'package:mark/src/processor/web_message_printer.dart'
    if (dart.library.io) 'package:mark/src/processor/io_message_printer.dart';
import 'package:mark/src/processor/string_message_formatter_mixin.dart';

/// A [MessageProcessor] that prints the formatted message to the console, using
/// platform-specific methods.
///
/// On the web, this uses `window.console` to print the message,
/// on the VM, this uses `stdout.writeln`, and if neither of those are
/// available, this uses `Zone.current.print`.
class EphemeralMessageProcessor extends BaseMessageProcessor<LogMessage, String>
    with StringMessageFormatterMixin {
  const EphemeralMessageProcessor();

  @override
  void process(LogMessage message, String formattedMessage) {
    printMessage(message, formattedMessage);
  }
}
