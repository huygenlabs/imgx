import 'package:flutter_test/flutter_test.dart';
import 'package:imgx/src/cache/cache_type.dart';
import 'package:imgx/src/cache/img_x_cache.dart';
import 'package:mockito/mockito.dart';
import 'package:imgx/src/prefs/img_x_prefs.dart'; // For mocking ImgXPrefs if necessary

class ImgxTest extends Mock with ImgXPrefs {}

void main() {
  group('ImgXCache Tests', () {
    late ImgXCache imgXCache;

    setUp(() {
      imgXCache = ImgXCache.instance;
    });

    test('Put data in memory cache and retrieve it', () {
      final key = 'image_1';
      final data = 'test_image_data';
      final cacheDuration = Duration(minutes: 5);
      imgXCache.putCache(key, data,
          cacheType: CacheType.memory, cacheDuration: cacheDuration);

      // Check if the data is stored in memory cache
      final cachedData = imgXCache.getFromMemory(key, cacheDuration);
      expect(cachedData, equals(data));
    });

    test('Get null if data in memory cache is expired', () {
      final key = 'image_3';
      final data = 'expired_data';
      final cacheDuration = Duration(
          milliseconds: -1); // Set a negative duration to expire immediately
      imgXCache.putCache(key, data,
          cacheType: CacheType.memory, cacheDuration: cacheDuration);

      final cachedData = imgXCache.getFromMemory(key, cacheDuration);
      expect(cachedData, isNull);
    });

    test('Remove data from memory cache', () async {
      final key = 'image_4';
      final data = 'data_to_remove';
      final cacheDuration = Duration(minutes: 5);
      imgXCache.putCache(key, data,
          cacheType: CacheType.memory, cacheDuration: cacheDuration);

      // Remove the data
      imgXCache.removeFromMemory('image_4');

      // Check if the data is removed from memory cache
      final cachedData = imgXCache.getFromMemory(key, cacheDuration);
      expect(cachedData, isNull);
    });

    test('Clear all data from memory cache', () async {
      final key1 = 'image_5';
      final data1 = 'data_1';
      final key2 = 'image_6';
      final data2 = 'data_2';
      final cacheDuration = Duration(minutes: 5);
      imgXCache.putCache(key1, data1,
          cacheType: CacheType.memory, cacheDuration: cacheDuration);
      imgXCache.putCache(key2, data2,
          cacheType: CacheType.memory, cacheDuration: cacheDuration);

      // Clear all data
      imgXCache.clearAllMemoryCache();

      // Check if all data is removed from memory cache
      final cachedData1 = imgXCache.getFromMemory(key1, cacheDuration);
      final cachedData2 = imgXCache.getFromMemory(key2, cacheDuration);
      expect(cachedData1, isNull);
      expect(cachedData2, isNull);
    });
  });
}
