import 'package:imgx/src/cache/cache_type.dart';
import 'package:imgx/src/prefs/img_x_prefs.dart';

/// Created by Lovepreet Singh on 20/12/22.

class CacheModel {
  dynamic data;
  int cacheDuration;

  CacheModel({required this.data, required this.cacheDuration});

  Map<String, dynamic> toJson() {
    return {
      'data': data,
      'cacheDuration': cacheDuration,
    };
  }
}

class ImgXCache with ImgXPrefs {
  ImgXCache._();
  static ImgXCache instance = ImgXCache._();

  Map<String, CacheModel> cacheMemoryMap = {};

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

  dynamic getCache(String key, Duration cacheDuration) =>
      _getFromMemory(key, cacheDuration);

  Future<dynamic> getCacheAsync(String key, Duration cacheDuration) async {
    dynamic data = _getFromMemory(key, cacheDuration);
    if (data != null) {
      return data;
    }
    return await _getFromDisk(key);
  }

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

  Future removeWhere(String keyword) async {
    cacheMemoryMap.removeWhere((key, value) => key.contains(keyword));
    await super.remove(keyword);
  }

  Future removeAll() async {
    cacheMemoryMap.clear();
    await super.clearAll();
  }
}
