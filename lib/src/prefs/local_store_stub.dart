import 'dart:typed_data';

import 'package:imgx/src/prefs/local_store_entry.dart';

/// In-memory fallback used where `dart:io` is not available, such as the web.
///
/// Data does not survive a page reload. The web image loader does not use the
/// disk cache, so this exists only to keep the cache API usable there.
///
/// Created by lovepreetsingh on 26,October,2026
class LocalStore {
  LocalStore._();

  /// Shared store instance.
  static final LocalStore instance = LocalStore._();

  final Map<String, LocalStoreEntry> _entries = {};

  /// Stores [bytes] for [key] until [expiresAtMs].
  Future<void> write(
    String key,
    Uint8List bytes, {
    required int expiresAtMs,
  }) async {
    _entries[key] = LocalStoreEntry(
      bytes: Uint8List.fromList(bytes),
      expiresAtMs: expiresAtMs,
    );
  }

  /// Returns the entry stored for [key], or null when missing or expired.
  Future<LocalStoreEntry?> read(String key) async {
    final entry = _entries[key];
    if (entry == null) {
      return null;
    }
    if (DateTime.now().millisecondsSinceEpoch > entry.expiresAtMs) {
      _entries.remove(key);
      return null;
    }
    return entry;
  }

  /// Removes the entry stored for [key].
  Future<void> delete(String key) async {
    _entries.remove(key);
  }

  /// Removes every entry.
  Future<void> clear() async {
    _entries.clear();
  }
}
