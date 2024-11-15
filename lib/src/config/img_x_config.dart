import 'package:flutter/material.dart';
import 'package:imgx/src/cache/cache_type.dart';

/// Created by lovepreetsingh on 15,November,2024

class ImgXConfig {
  static CacheType globalCacheType = CacheType.memory;
  static Duration globalCacheDuration = const Duration(hours: 1);
  static Widget? globalProgressWidget;
  static Widget? globalErrorWidget;
  static int globalRetryCount = 0;
}
