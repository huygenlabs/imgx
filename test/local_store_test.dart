import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:imgx/src/cache/cache_type.dart';
import 'package:imgx/src/cache/img_x_cache.dart';
import 'package:imgx/src/prefs/local_store.dart';

/// Created by lovepreetsingh on 26,October,2026
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  final store = LocalStore.instance;

  int expiryIn({required Duration duration}) =>
      DateTime.now().add(duration).millisecondsSinceEpoch;

  tearDown(() async {
    await store.clear();
    ImgXCache.instance.clearAllMemoryCache();
  });

  group('LocalStore', () {
    test('round-trips raw image bytes', () async {
      final key = 'https://example.com/a.png';
      final bytes = Uint8List.fromList(
        List<int>.generate(4096, (i) => i % 256),
      );

      await store.write(
        key,
        bytes,
        expiresAtMs: expiryIn(duration: const Duration(hours: 1)),
      );

      final entry = await store.read(key);
      expect(entry, isNotNull);
      expect(entry!.bytes, equals(bytes));
    });

    test('returns null for a missing key', () async {
      expect(await store.read('https://example.com/missing.png'), isNull);
    });

    test('drops expired entries', () async {
      final key = 'https://example.com/expired.png';
      await store.write(
        key,
        Uint8List.fromList([1, 2, 3]),
        expiresAtMs: expiryIn(duration: const Duration(seconds: -1)),
      );

      expect(await store.read(key), isNull);
      // Second read must stay empty, the file is removed on the first read.
      expect(await store.read(key), isNull);
    });

    test('delete removes only the requested key', () async {
      final keep = 'https://example.com/keep.png';
      final drop = 'https://example.com/drop.png';
      final expiry = expiryIn(duration: const Duration(hours: 1));

      await store.write(keep, Uint8List.fromList([1]), expiresAtMs: expiry);
      await store.write(drop, Uint8List.fromList([2]), expiresAtMs: expiry);
      await store.delete(drop);

      expect(await store.read(drop), isNull);
      expect(await store.read(keep), isNotNull);
    });

    test('clear removes every entry', () async {
      final expiry = expiryIn(duration: const Duration(hours: 1));
      await store.write(
        'key-one',
        Uint8List.fromList([1]),
        expiresAtMs: expiry,
      );
      await store.write(
        'key-two',
        Uint8List.fromList([2]),
        expiresAtMs: expiry,
      );

      await store.clear();

      expect(await store.read('key-one'), isNull);
      expect(await store.read('key-two'), isNull);
    });

    test('handles keys that share a very similar prefix', () async {
      final expiry = expiryIn(duration: const Duration(hours: 1));
      const prefix = 'https://example.com/very/long/path/that/keeps/going/';

      await store.write(
        '${prefix}one.png',
        Uint8List.fromList([1]),
        expiresAtMs: expiry,
      );
      await store.write(
        '${prefix}two.png',
        Uint8List.fromList([2]),
        expiresAtMs: expiry,
      );

      expect((await store.read('${prefix}one.png'))!.bytes, equals([1]));
      expect((await store.read('${prefix}two.png'))!.bytes, equals([2]));
    });
  });

  group('ImgXCache disk cache', () {
    test('persists bytes and reads them back without a restart', () async {
      const key = 'https://example.com/disk.png';
      final bytes = Uint8List.fromList(
        List<int>.generate(1024, (i) => i % 256),
      );

      await ImgXCache.instance.saveImageCache(
        key,
        CacheModel(
          data: bytes,
          cacheDuration: expiryIn(duration: const Duration(hours: 1)),
        ),
      );

      final cached = await ImgXCache.instance.getCacheAsync(
        key,
        const Duration(hours: 1),
      );
      expect(cached, isNotNull);
      expect(List<int>.from(cached as List), equals(bytes));
    });

    test('putCache with CacheType.disk writes through to the store', () async {
      const key = 'https://example.com/put-disk.png';
      final bytes = Uint8List.fromList([9, 8, 7, 6]);

      ImgXCache.instance.putCache(
        key,
        bytes,
        cacheType: CacheType.disk,
        cacheDuration: const Duration(hours: 1),
      );

      // The write is fire-and-forget, so wait for it to land.
      List<int>? cached;
      for (var attempt = 0; attempt < 50; attempt++) {
        final value = await ImgXCache.instance.getCacheAsync(
          key,
          const Duration(hours: 1),
        );
        if (value != null) {
          cached = List<int>.from(value as List);
          break;
        }
        await Future<void>.delayed(const Duration(milliseconds: 10));
      }

      expect(cached, equals(bytes));
    });

    test('removeAll clears the disk cache', () async {
      const key = 'https://example.com/remove-all.png';
      await ImgXCache.instance.saveImageCache(
        key,
        CacheModel(
          data: Uint8List.fromList([5, 5, 5]),
          cacheDuration: expiryIn(duration: const Duration(hours: 1)),
        ),
      );
      expect(
        await ImgXCache.instance.getCacheAsync(key, const Duration(hours: 1)),
        isNotNull,
      );

      await ImgXCache.instance.removeAll();

      expect(
        await ImgXCache.instance.getCacheAsync(key, const Duration(hours: 1)),
        isNull,
      );
    });
  });
}
