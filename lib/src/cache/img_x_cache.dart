import 'package:imgx/src/cache/cache_type.dart';
import 'package:imgx/src/prefs/img_x_prefs.dart';

/// Created by Lovepreet Singh on 20/12/22.

class CacheModel {

  /// dynamic param to save image data
  dynamic data;

  /// param to save cache duration
  int cacheDuration;

  /// CacheModel constructor
  CacheModel({required this.data, required this.cacheDuration});

  /// Convert to json
  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'cacheDuration': cacheDuration,
    };
  }
}

/// Cache class
class ImgXCache with ImgXPrefs {
  ImgXCache._();

  /// Singleton instance
  static ImgXCache instance = ImgXCache._();

  /// Memory cache map
  Map<String, CacheModel> cacheMemoryMap = {};

  /// Save data in cache
  void putCache(String key, dynamic data,
      {required CacheType cacheType, required Duration cacheDuration}) {
    if (cacheType == CacheType.memory) {
      cacheMemoryMap[key] = CacheModel(
        data: data,
        cacheDuration: DateTime.now().millisecondsSinceEpoch +
            cacheDuration.inMilliseconds,
      );
      return;
    }
    /** save in disk */
    super.saveImageCache(
        key,
        CacheModel(
            data: data,
            cacheDuration: DateTime.now().millisecondsSinceEpoch +
                cacheDuration.inMilliseconds));
  }

  /// Get data from cache
  dynamic getCache(String key, Duration cacheDuration) =>
      _getFromMemory(key, cacheDuration);


  /// Get data from cache asynchronously
  Future<dynamic> getCacheAsync(String key, Duration cacheDuration) async {
    dynamic data = _getFromMemory(key, cacheDuration);
    if (data != null) {
      return data;
    }
    return await _getFromDisk(key);
  }

  /// Get data from memory
  dynamic _getFromMemory(String key, Duration cacheDuration) {
    var item = cacheMemoryMap[key];
    if (item == null) {
      return null;
    }
    if (DateTime.now().millisecondsSinceEpoch > item.cacheDuration) {
      /**
       * cache has expired
       * */
      cacheMemoryMap.remove(key);
      return null;
    }
    return item.data;
  }

  /// Get data from disk
  dynamic _getFromDisk(String key) async {
    CacheModel? cachedData = await super.getImageCache(key);
    if (cachedData == null) {
      return null;
    }
    if (DateTime.now().millisecondsSinceEpoch > cachedData.cacheDuration) {
      /**
       * cache has expired
       * */
      super.remove(key);
      return null;
    }
    return cachedData.data;
  }

  /// Remove data from cache
  Future removeWhere(String keyword) async {
    cacheMemoryMap.removeWhere((key, value) => key.contains(keyword));
    await super.remove(keyword);
  }

  /// Clear all data from cache
  Future removeAll() async {
    cacheMemoryMap.clear();
    await super.clearAll();
  }
}
