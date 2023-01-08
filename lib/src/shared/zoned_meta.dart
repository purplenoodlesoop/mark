import 'dart:async';

extension ZonedMeta on Never {
  static final Object _metaKey = Object();

  /// The metadata attached to the current zone using [attach].
  static Object? get current => Zone.current[_metaKey];

  /// Attaches [meta] to the current zone, and executes [body] in that zone.
  static T attach<T>(Object? meta, T Function() body) => runZoned(
        body,
        zoneValues: {_metaKey: meta},
      );
}
