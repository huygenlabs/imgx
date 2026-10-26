import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

import 'package:imgx/src/prefs/local_store_entry.dart';

/// File based key/value store used for the on-disk image cache.
///
/// Entries live in a private sub-directory of the system temporary directory,
/// so no plugin or platform channel is required. Each entry is a single file:
///
/// ```text
/// magic (4 bytes) | expiry (8 bytes) | key length (4 bytes) | key | payload
/// ```
///
/// All integers are little endian. The key is stored in the file so a hash
/// collision can never return another image. Files are written to a temporary
/// name first and then renamed, so a partially written image is never read.
///
/// Created by lovepreetsingh on 26,October,2026
class LocalStore {
  LocalStore._();

  /// Shared store instance.
  static final LocalStore instance = LocalStore._();

  /// Name of the directory created inside the system temporary directory.
  static const String directoryName = 'imgx_cache';

  static const int _magic = 0x494d4758; // "IMGX"
  static const int _headerSize = 16;
  static const String _extension = '.imgx';
  static const String _temporaryExtension = '.tmp';

  Directory? _resolved;
  Future<Directory>? _resolving;

  Future<Directory> _directory() async {
    final resolved = _resolved;
    if (resolved != null) {
      return resolved;
    }
    return _resolving ??= _createDirectory();
  }

  Future<Directory> _createDirectory() async {
    try {
      final directory = Directory(
        '${Directory.systemTemp.path}${Platform.pathSeparator}$directoryName',
      );
      if (!await directory.exists()) {
        await directory.create(recursive: true);
      }
      _resolved = directory;
      return directory;
    } finally {
      _resolving = null;
    }
  }

  String _pathFor(Directory directory, String key) =>
      '${directory.path}${Platform.pathSeparator}${_hashOf(key)}$_extension';

  /// FNV-1a hash rendered as 16 hex characters.
  ///
  /// The key itself is stored inside the file, so this only needs to spread
  /// keys across file names, not guarantee uniqueness.
  String _hashOf(String key) {
    var hash = 0xcbf29ce484222325;
    for (final byte in utf8.encode(key)) {
      hash ^= byte;
      hash *= 0x100000001b3;
    }
    final high = (hash >> 32) & 0xFFFFFFFF;
    final low = hash & 0xFFFFFFFF;
    return '${high.toRadixString(16).padLeft(8, '0')}'
        '${low.toRadixString(16).padLeft(8, '0')}';
  }

  /// Stores [bytes] for [key] until [expiresAtMs].
  Future<void> write(
    String key,
    Uint8List bytes, {
    required int expiresAtMs,
  }) async {
    try {
      final file = File(_pathFor(await _directory(), key));
      final keyBytes = Uint8List.fromList(utf8.encode(key));
      final header = ByteData(_headerSize)
        ..setUint32(0, _magic, Endian.little)
        ..setInt64(4, expiresAtMs, Endian.little)
        ..setUint32(12, keyBytes.length, Endian.little);
      final payload = BytesBuilder(copy: false)
        ..add(header.buffer.asUint8List())
        ..add(keyBytes)
        ..add(bytes);

      final temporary = File('${file.path}$_temporaryExtension');
      await temporary.writeAsBytes(payload.takeBytes(), flush: true);
      await temporary.rename(file.path);
    } on FileSystemException {
      // A cache must never break the caller, so storage failures are ignored.
    }
  }

  /// Returns the entry stored for [key], or null when missing or expired.
  Future<LocalStoreEntry?> read(String key) async {
    File? file;
    try {
      file = File(_pathFor(await _directory(), key));
      if (!await file.exists()) {
        return null;
      }
      final raw = await file.readAsBytes();
      if (raw.length < _headerSize) {
        return await _discard(file);
      }
      final header = ByteData.sublistView(raw, 0, _headerSize);
      if (header.getUint32(0, Endian.little) != _magic) {
        return await _discard(file);
      }
      final expiresAtMs = header.getInt64(4, Endian.little);
      final payloadStart = _headerSize + header.getUint32(12, Endian.little);
      if (raw.length < payloadStart) {
        return await _discard(file);
      }
      final storedKey = utf8.decode(
        Uint8List.sublistView(raw, _headerSize, payloadStart),
        allowMalformed: true,
      );
      if (storedKey != key) {
        // Hash collision with a different key, leave that file alone.
        return null;
      }
      if (DateTime.now().millisecondsSinceEpoch > expiresAtMs) {
        return await _discard(file);
      }
      return LocalStoreEntry(
        bytes: Uint8List.sublistView(raw, payloadStart),
        expiresAtMs: expiresAtMs,
      );
    } on FileSystemException {
      return null;
    }
  }

  Future<LocalStoreEntry?> _discard(File file) async {
    try {
      await file.delete();
    } on FileSystemException {
      // Already gone or locked, nothing else to do.
    }
    return null;
  }

  /// Removes the entry stored for [key].
  Future<void> delete(String key) async {
    try {
      final file = File(_pathFor(await _directory(), key));
      if (await file.exists()) {
        await file.delete();
      }
    } on FileSystemException {
      // Already gone or locked, nothing else to do.
    }
  }

  /// Removes every entry owned by this store.
  Future<void> clear() async {
    try {
      final directory = await _directory();
      await for (final entity in directory.list(followLinks: false)) {
        if (entity is! File) {
          continue;
        }
        try {
          await entity.delete();
        } on FileSystemException {
          // Another process may hold the file, skip it.
        }
      }
    } on FileSystemException {
      // The directory disappeared, so there is nothing to clear.
    }
  }
}
