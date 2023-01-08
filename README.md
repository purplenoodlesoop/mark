# mark

[![Pub](https://img.shields.io/pub/v/mark.svg)](https://pub.dev/packages/mark)
[![GitHub Stars](https://img.shields.io/github/stars/purplenoodlesoop/mark.svg)](https://github.com/purplenoodlesoop/mark)
[![License: MIT](https://img.shields.io/badge/License-MIT-brightgreen.svg)](https://en.wikipedia.org/wiki/MIT_License)
[![Linter](https://img.shields.io/badge/style-custom-brightgreen)](https://github.com/purplenoodlesoop/stream-bloc/blob/master/analysis_options.yaml)
[![Code size](https://img.shields.io/github/languages/code-size/purplenoodlesoop/mark)](https://github.com/purplenoodlesoop/mark)

---

Extensible and customizable logging framework for Dart and Flutter.

## Index

- [Index](#index)
- [About](#about)
- [Motivation](#motivation)
- [Install](#install)
- [Usage](#usage)
  - [Basic](#basic)
  - [Advanced](#advanced)
    - [Processors](#processors)
      - [Custom processor](#custom-processor)
      - [Dynamically stating processors](#dynamically-stating-processors)
      - [Forking the logger](#forking-the-logger)
    - [Messages](#messages)
    - [Meta](#meta)
  - [Extras](#extras)
    - [Pattern matching](#pattern-matching)
    - [Formatter mixins](#formatter-mixins)

## About

`mark` is a logging framework for Dart. It is designed to be extensible and customizable, allowing the creation of custom logging messages and processors. It is also designed to be easy to use, with a simple API and a default configuration that is ready to use. 

## Motivation

Current logging solutions either do not provide enough customization, forcing you to use ad-hoc solutions, lack specific features, such as scoping, or lack the desired Developer Experience (DX). `mark` aims to solve these problems by providing a simple, yet powerful, logging framework that is easy to use, customize, extend and integrate.

`mark` tries to be as unopinionated as possible, allowing you to use it in any way you want. It is designed to be used in any Dart project, from small CLI tools to large Flutter applications, whilst trying to take care of the most common use cases and striving to provide a "framework" solution.

## Install

Add `mark` to your `pubspec.yaml` file:

```yaml
dependencies:
  mark: "current version"
```

Or do it via CLI.

For Flutter projects:

```bash
$ flutter pub add mark
```

For Dart projects:

```bash
$ dart pub add mark
```
## Usage

`mark` can be fitted to the needs of the project by utilizing only the needed features. 

The main actors of the framework are:
  - `Logger` - a class that is used to log messages
  - `LogMessage` - a class that represents a log message and is passed to the `Logger`
  - `MessageProcessor` - a class that processes a `LogMessage`

The `Logger` is the main actor of the framework, which is used to log messages. The `Logger` is configured with a list of `MessageProcessor`s, which are used to process the `LogMessage`s. This approach allows to create of custom `MessageProcessor`s, which can be used to customize the logging process, filter messages (as the list of `MessageProcessor`s can be configured dynamically), and process the messages in any way – from printing them to the console to sending them to a remote server.

### Basic

The most basic usage of `mark` is to use the default configuration. This can be done by importing the `mark` package, creating a global logger constant with a default message processor, and using the default logging methods:

```dart
final logger = Logger(processors: const [EphemeralMessageProcessor()]);

void main() {
  logger.info('Hello, World!');
}
```

The `EphemeralMessageProcessor` is a default message processor, which prints the message to the console with a platform-specific implementation of the source, and defining the logger as a global constant allows to use it in any part of the code, without the need to pass it as a parameter.

Since this object is a singleton, the disposing can be ignored. For loggers that are not singletons, the `dispose` method should be called to dispose of the resources used by the logger.

The `Logger` class provides a list of default logging methods, which really just call the `mark` method with an appropriate `LogMessage` type: `InfoMessage` for `info`, `WarningMessage` for `warning`, `ErrorMessage` for `error`, and `DebugMessage` for `debug`.


### Advanced

The default configuration is not always enough, and `mark` allows to create custom messages and processors, which can be used to customize the logging process. Most commonly, processors are customized in the first place, as they are the main actors of the logging process. 

Customization of the logging process can be done by creating a custom `MessageProcessor`, which can be used to filter messages, process them in any way, such as sending them to a remote server, and change the set of processors dynamically.

#### Processors

The `MessageProcessor` is a class that processes a `LogMessage`. It is a simple class, which has a single method, `processMessages`, which takes a `Stream<LogMessage>` and returns a `Stream<void>`. The `processMessages` method is called by the `Logger` when a message is logged.

##### Custom processor

To create a custom message processor, a `BaseMessageProcessor` class can be extended, which allows to select a subset of messages to process and to implement the way how messages are formatted, processed and the order of the processing by overriding the appropriate methods.

A custom message processor that sends messages to a remote server can be created as follows:

```dart
class RemoteMessageProcessor
    extends BaseMessageProcessor<LogMessage, Map<String, dynamic>> { // 1
  final RemoteLogService service;

  const RemoteMessageProcessor(this.service);

  @override
  Map<String, dynamic> format(LogMessage message) => message.toJson(); // 2

  @override
  Future<void> process(
    LogMessage message,
    Map<String, dynamic> formattedMessage,
  ) =>
      service.send(formattedMessage); // 3

  @override
  bool allow(LogMessage message) =>
      message.severityValue >= ErrorMessage.severity; // 4

  @override
  Stream<void> transform(
    EntryProcessorF<LogMessage, Map<String, dynamic>> processorF,
    Stream<LogEntry<LogMessage, Map<String, dynamic>>> entries,
  ) =>
      entries.asyncMap(processorF); // 5
}

```

1. The `BaseMessageProcessor` class takes two type parameters, the first one is the type of the message, and the second one is the type of the formatted message. The `RemoteMessageProcessor` is a generic class, which takes a `LogMessage` as a message type and a `Map<String, dynamic>` as a formatted message type. The `LogMessage` is the default message type, which is used by the `Logger` and allows for all messages, and the `Map<String, dynamic>` is a type that is used to send messages to a remote server.

2. The `format` method is used to format the message. It takes a `LogMessage` and returns a `Map<String, dynamic>`, which is used to send messages to a remote server.

3. The `process` method is used to process the formatted message. It takes a `LogMessage` and a formatted message, which is a `Map<String, dynamic>`, and returns a `FutureOr<void>`, (a `Future<void>` in this case) which allows processing the message in any way.

4. The `allow` method is used to filter messages. It takes a `LogMessage` and returns a `bool`, which allows filtering messages. In this case, only messages with a severity of `ErrorMessage` or higher are allowed.

5. The `transform` method is used to specify the order in which messages are processed. It takes an `EntryProcessorF` and a `Stream<LogEntry>`, and returns a `Stream<void>`. The `EntryProcessorF` is a function that takes a `LogEntry` and returns a `FutureOr<void>`. In this case, the messages are processed in the order in which they are received.

##### Dynamically stating processors

Processors are specified at the creation of `Logger`, and the list of processors can be assembled dynamically, for example by utilizing Dart's features in regard to conditional list entries. A Logger that prints messages to the console in debug and profile modes, and sends them to a remote server in release mode can be created as follows:

```dart

final logger = Logger(
  processors: [
    if (kReleaseMode)
      const RemoteMessageProcessor()
    else
      const EphemeralMessageProcessor(),
  ],
);

```

##### Forking the logger

The `fork` method of the `Logger` class allows to create a new `Logger` with an additional set of processors. Since the `Logger` object is immutable, altering the list of processors is not possible, and the `fork` method allows one to add them by creating a new `Logger` object.

It is important to always dispose of the `Logger` object, which is done by calling the `dispose` method. The `fork` method returns a new `Logger` object, which should be disposed of separately.

For example, this feature can be used to granularly improve traceability in a function with known bugs.

```dart

Future<void> main() async {
  final logger = Logger( // 1
    processors: const [
      EphemeralMessageProcessor(),
    ],
  );
  final remoteLogger = logger.fork( // 2
    processors: const [
      RemoteMessageProcessor(),
    ],
  );

  await buggyFunction(remoteLogger); // 3

  await remoteLogger.dispose(); // 4
  await logger.dispose();
}
```

1. The `Logger` object is created with a single processor, which prints messages to the console. This object can be viewed as a base, root logger.

2. The `fork` method is used to create a new `Logger` object with an additional set of processors. In this case, the `RemoteMessageProcessor` is added to the list of processors.

3. The `buggyFunction` is called with the `remoteLogger`, which allows to print messages to the console AND send them to a remote server.

4. All logger objects are disposed of after they are no longer needed.

#### Messages

In addition to custom processors, custom messages can be created. The `LogMessage` class is an interface that allows to create custom messages. Every log message has a severity, a stack trace, data, and an optional meta field. The severity is used to filter messages, the stack trace is used to provide traceability, the data is used to provide a message payload, and the meta field is used to provide additional information. The `LogMessage` is serializable via the `toJson()` method;

To create a custom message, a `BaseLogMessage` should be extended, which implements the `LogMessage` interface, and provides a default implementation of the fields, as well as a `toJson` method.

An example message of a login event can be described as follows:

```dart

class LoginEvent extends BaseLogMessage {
  static const int severity = 3;

  @override
  final String data;

  LoginEvent(String email, {super.stackTrace, super.meta}) : data = email;

  @override
  @override
  int get severityValue => severity;
}

```

However, usually custom events are represented as a union type, which can be used in a custom message processor to process messages only of a selected type.

#### Meta 

In addition, the `meta` field can be used to provide additional information about the message. Usually, it can be passed directly to the constructor of a `LogMessage`, but a `Zone` injection is also an option. The `ZonedMeta` namespace can be used to create a new Zone with a passed meta. 

```dart
ZonedMeta.attach('I came from the Zone!', body);
```

In this example, the `body` function will be executed in a new Zone, which will have the `I came from the Zone!` meta attached to it, in every message that leaves the constructor meta field empty.


### Extras 

A few uncategorized extras are provided by the `mark` package.

#### Pattern matching

Both `LogMessage` and the `PrimitiveLogMessage` can be pattern-matched to a more specific type. The `LogMessage` can be pattern-matched to a `PrimitiveLogMessage` or a `Log`, and the `PrimitiveLogMessage` can be pattern-matched to a concrete primitive message type, such as `InfoMessage` or `DebugMessage`.

An `EphemeralMessageProcessor`'s web implementation can be used as an example of pattern-matching.

```dart
void Function(Object? data) _matchPrinter(LogMessage message) {
  final console = window.console;
  final info = console.info;

  return message.matchPrimitive(
    primitive: (message) => message.match(
      info: (_) => info,
      debug: (_) => console.debug,
      warning: (_) => console.warn,
      error: (_) => console.error,
    ),
    orElse: (_) => info,
  );
}
```

#### Formatter mixins

The `mark` package provides a few formatter mixins, which can be used to format messages in a specific way based on a specified output type parameter:
  - `JsonMessageFormatterMixin` - formats messages to `Map<String, Object?>` using the `toJson` method.
  - `StringMessageFormatterMixin` – formats messages to `String` using the `toString` method.