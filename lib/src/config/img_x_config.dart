import 'package:flutter/material.dart';
import 'package:imgx/src/cache/cache_type.dart';

/// Created by lovepreetsingh on 15,November,2024

class ImgXConfig {
  /// Global cache type
  static CacheType globalCacheType = CacheType.memory;

  /// Global cache duration
  static Duration globalCacheDuration = const Duration(hours: 1);

  /// Global progress widget
  static Widget? globalProgressWidget;

  /// Global error widget
  static Widget? globalErrorWidget;

  /// Global retry count
  static int globalRetryCount = 0;

  /// Log errors
  static bool globalLogErrors = false;
}
