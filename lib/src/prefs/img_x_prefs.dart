import 'dart:convert';
import 'dart:typed_data';

import 'package:imgx/src/cache/img_x_cache.dart';
import 'package:imgx/src/prefs/local_store.dart';

/// Created by lovepreetsingh on 14,November,2024

mixin ImgXPrefs {
  /// Save data in cache
  Future<void> saveImageCache(String key, CacheModel data) async {
    await LocalStore.instance.write(
      key,
      _encode(data.data),
      expiresAtMs: data.cacheDuration,
    );
  }

  /// Get data from cache
  Future<CacheModel?> getImageCache(String key) async {
    final entry = await LocalStore.instance.read(key);
    if (entry == null) {
      return null;
    }
    return CacheModel(data: entry.bytes, cacheDuration: entry.expiresAtMs);
  }

  /// Remove data from cache
  Future<void> remove(String key) => LocalStore.instance.delete(key);

  /// Clear all data from cache
  Future<void> clearAll() => LocalStore.instance.clear();

  /// Converts cached data to bytes so it can be written to a file.
  ///
  /// Image bytes are stored as-is, anything else is stored as JSON.
  Uint8List _encode(dynamic data) {
    if (data is Uint8List) {
      return data;
    }
    if (data is TypedData) {
      return data.buffer.asUint8List(data.offsetInBytes, data.lengthInBytes);
    }
    if (data is List<int>) {
      return Uint8List.fromList(data);
    }
    if (data is ByteBuffer) {
      return data.asUint8List();
    }
    return Uint8List.fromList(utf8.encode(jsonEncode(data)));
  }
}
