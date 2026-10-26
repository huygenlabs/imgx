import 'dart:typed_data';

/// A single value read back from the local cache store.
///
/// Created by lovepreetsingh on 26,October,2026
class LocalStoreEntry {
  /// Raw bytes that were stored for the entry.
  final Uint8List bytes;

  /// Absolute expiry, in milliseconds since epoch.
  final int expiresAtMs;

  /// Creates an entry with its payload and absolute expiry.
  const LocalStoreEntry({required this.bytes, required this.expiresAtMs});
}
