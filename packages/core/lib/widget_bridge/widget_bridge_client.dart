import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

/// Dart → native contract for feeding data to home-screen widgets, lock-screen
/// widgets, Live Activities, Glance widgets, and Wear tiles.
///
/// Payload rules (asserted in debug):
/// - Values must be `String`, `int`, `double`, `bool`, `List<String>`, or
///   `DateTime` (auto-encoded as ISO 8601). No nested maps or lists of
///   non-string types — DESIGN_GUIDE §4 says "one number or one line" for
///   widgets; nested structures aren't the point.
/// - App Group entitlement (iOS) and shared SharedPreferences file
///   (Android) are wired by the scaffolder; the bridge itself doesn't do
///   entitlements — if not set up, publish/read silently succeed but
///   widgets see nothing. See the `widgetkit-bridge` skill for details.
///
/// Rate limiting:
/// - `publish` **skips the write and widget reload entirely when the
///   payload is unchanged** since the last write. Matters most for iOS —
///   WidgetKit's reload budget is small and every reload counts.
/// - `publish` calls within the debounce window collapse into one
///   write with the last payload. Default window: 100ms real, 0ms
///   in-memory. Set 0 on real bridges only for tests that need
///   deterministic write ordering.
class WidgetBridge {
  WidgetBridge._({
    required String suiteName,
    required MethodChannel channel,
    required Duration debounce,
    Map<String, Object?>? inMemoryStore,
  })  : _suiteName = suiteName,
        _channel = channel,
        _debounce = debounce,
        _inMemory = inMemoryStore;

  /// Real bridge for an app. Suite name: `factory.widget.<appSlug>`.
  factory WidgetBridge.forSlug(
    String appSlug, {
    Duration debounce = const Duration(milliseconds: 100),
  }) {
    assert(
      appSlug.isNotEmpty,
      'WidgetBridge.forSlug requires a non-empty app slug.',
    );
    return WidgetBridge._(
      suiteName: 'factory.widget.$appSlug',
      channel: channel,
      debounce: debounce,
    );
  }

  /// In-memory bridge for tests. Never touches the platform channel and
  /// defaults to no debounce so `await publish; await read` sees the
  /// write immediately.
  factory WidgetBridge.inMemory({
    String slug = 'test',
    Duration debounce = Duration.zero,
  }) {
    return WidgetBridge._(
      suiteName: 'factory.widget.$slug',
      channel: channel,
      debounce: debounce,
      inMemoryStore: <String, Object?>{},
    );
  }

  @visibleForTesting
  static const MethodChannel channel =
      MethodChannel('factory_core/widget_bridge');

  final String _suiteName;
  final MethodChannel _channel;
  final Duration _debounce;
  final Map<String, Object?>? _inMemory;

  String? _lastPublishedEncoded;
  String? _pendingEncoded;
  Map<String, Object?>? _pendingPayload;
  Completer<void>? _pendingCompleter;
  Timer? _debounceTimer;

  bool get _isInMemory => _inMemory != null;

  /// Suite name the bridge writes to (`factory.widget.<slug>`). Exposed
  /// for native widget code that reads the same store.
  String get suiteName => _suiteName;

  // ---- Writes -----------------------------------------------------------

  /// Replace the payload in the shared store, then reload widget
  /// timelines. Apps call this on every state change that affects a
  /// widget — never on a timer.
  ///
  /// Coalescing: if the encoded payload matches the last write, this is
  /// a total no-op (no channel call, no reload). If a debounced write is
  /// already scheduled, this replaces the pending payload and joins the
  /// same completer.
  Future<void> publish(Map<String, Object?> payload) {
    final encoded = jsonEncode(_encodeForTransport(payload));

    // Unchanged since last write and nothing pending → true no-op.
    if (_pendingCompleter == null && encoded == _lastPublishedEncoded) {
      return Future.value();
    }

    _pendingEncoded = encoded;
    _pendingPayload = payload;
    final completer = _pendingCompleter ??= Completer<void>();

    _debounceTimer?.cancel();
    if (_debounce == Duration.zero) {
      _debounceTimer = null;
      unawaited(_flushPending());
    } else {
      _debounceTimer = Timer(_debounce, _flushPending);
    }

    return completer.future;
  }

  Future<void> _flushPending() async {
    final encoded = _pendingEncoded;
    final payload = _pendingPayload;
    final completer = _pendingCompleter;
    _pendingEncoded = null;
    _pendingPayload = null;
    _pendingCompleter = null;
    _debounceTimer = null;

    if (encoded == null || payload == null || completer == null) return;

    // Second unchanged-check inside the debounce window (a rapid A→B→A
    // sequence lands as A and the last write was already A).
    if (encoded == _lastPublishedEncoded) {
      completer.complete();
      return;
    }

    _lastPublishedEncoded = encoded;

    if (_isInMemory) {
      _inMemory!
        ..clear()
        ..addAll(payload);
      completer.complete();
      return;
    }

    try {
      await _channel.invokeMethod<void>('publish', <String, Object?>{
        'suiteName': _suiteName,
        'payload': encoded,
      });
    } on PlatformException catch (e, st) {
      _warn('publish failed', e, st);
    } on MissingPluginException catch (e, st) {
      _warn('publish channel missing', e, st);
    } finally {
      completer.complete();
    }
  }

  /// Read the payload the app previously published. Returns `null` when
  /// nothing has been written yet, when the payload is malformed, or when
  /// the platform channel is unavailable.
  Future<Map<String, Object?>?> read() async {
    if (_isInMemory) {
      return _inMemory!.isEmpty ? null : Map.of(_inMemory);
    }
    try {
      final raw = await _channel.invokeMethod<String?>(
        'read',
        <String, Object?>{'suiteName': _suiteName},
      );
      if (raw == null || raw.isEmpty) return null;
      final decoded = jsonDecode(raw);
      if (decoded is Map<String, dynamic>) return decoded;
      return null;
    } on PlatformException catch (e, st) {
      _warn('read failed', e, st);
      return null;
    } on MissingPluginException {
      return null;
    }
  }

  /// Wipe the shared store and reload widget timelines. Bypasses debounce
  /// and unchanged-skip — always fires immediately.
  Future<void> clear() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;
    _pendingEncoded = null;
    _pendingPayload = null;
    _lastPublishedEncoded = null;
    final pending = _pendingCompleter;
    _pendingCompleter = null;

    if (_isInMemory) {
      _inMemory!.clear();
      pending?.complete();
      return;
    }

    try {
      await _channel.invokeMethod<void>(
        'clear',
        <String, Object?>{'suiteName': _suiteName},
      );
    } on PlatformException catch (e, st) {
      _warn('clear failed', e, st);
    } on MissingPluginException {
      // no-op
    }
    pending?.complete();
  }

  /// Explicit widget-timeline reload. `publish()` and `clear()` already
  /// call this; only invoke directly if you mutate data outside the
  /// bridge and want native surfaces to reload anyway.
  Future<void> reloadAllWidgets() async {
    if (_isInMemory) return;
    try {
      await _channel
          .invokeMethod<void>('reloadAllWidgets', <String, Object?>{});
    } on PlatformException catch (e, st) {
      _warn('reloadAllWidgets failed', e, st);
    } on MissingPluginException {
      // no-op
    }
  }

  // ---- Encoding --------------------------------------------------------

  /// Validates and rewrites the payload for JSON transport. Auto-encodes
  /// `DateTime` as ISO 8601. Asserts on unsupported types in debug.
  Map<String, Object?> _encodeForTransport(Map<String, Object?> payload) {
    final out = <String, Object?>{};
    for (final entry in payload.entries) {
      out[entry.key] = _encodeValue(entry.key, entry.value);
    }
    return out;
  }

  Object? _encodeValue(String key, Object? value) {
    if (value == null) return null;
    if (value is String || value is int || value is double || value is bool) {
      return value;
    }
    if (value is DateTime) return value.toIso8601String();
    if (value is List) {
      assert(
        value.every((e) => e is String),
        'WidgetBridge payload key "$key": list values must be List<String>. '
        'Got ${value.runtimeType}.',
      );
      return value.cast<String>();
    }
    assert(
      false,
      'WidgetBridge payload key "$key": unsupported value type '
      '${value.runtimeType}. Allowed: String, int, double, bool, '
      'List<String>, DateTime.',
    );
    return null;
  }

  void _warn(String label, Object error, StackTrace stack) {
    if (kDebugMode) {
      debugPrint('⚠️  [factory_core/widget_bridge] $label: $error');
    }
  }
}
