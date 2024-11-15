import 'dart:convert';

import 'package:imgx/src/cache/img_x_cache.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Created by lovepreetsingh on 14,November,2024

mixin ImgXPrefs {
  Future saveImageCache(String key, CacheModel data) async {
    return (await SharedPreferences.getInstance())
        .setString(key, jsonEncode(data.toJson()));
  }

  Future<CacheModel?> getImageCache(String key) async {
    var data = (await SharedPreferences.getInstance()).getString(key);
    if (data == null) {
      return null;
    }
    Map<String, dynamic> jsonData = jsonDecode(data);
    return CacheModel(
        data: jsonData['data'], cacheDuration: jsonData['cacheDuration']);
  }

  Future remove(String key) async {
    await (await SharedPreferences.getInstance()).remove(key);
  }

  Future clearAll() async {
    await (await SharedPreferences.getInstance()).clear();
  }
}
