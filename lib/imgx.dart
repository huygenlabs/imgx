library;

import 'package:flutter/cupertino.dart';
import 'package:imgx/src/cache/img_x_cache.dart';
import 'package:imgx/src/image_widget/img_x_widget.dart';

export 'src/cache/cache_type.dart';
export 'src/config/img_x_config.dart';

/// Created by Lovepreet Singh on 20/12/22.
class ImgX extends ImgXLoader {
  ///
  /// imageUri: Image URL
  /// width: Width of the image
  /// height: Height of the image
  /// fit: BoxFit
  /// headers: Headers for the image
  /// retryCount: Number of times to retry loading the image
  /// progressWidget: Widget to show while loading the image
  /// errorWidget: Widget to show if there is an error loading the image
  /// cacheType: Type of cache
  /// cacheDuration: Duration for which the image should be cached
  /// onProgress: Callback to get the download progress
  /// key: Unique key for the widget

  /**
   * No need to pass progressWidget, errorWidget, cacheType,
   * cacheDuration, retryCount if already set in [ImgXConfig]
   * */

  ///
  const ImgX(
      {super.key,
      required super.imageUri,
      super.width,
      super.height,
      super.fit = BoxFit.cover,
      super.headers,
      super.retryCount,
      super.progressWidget,
      super.errorWidget,
      super.cacheType,
      super.cacheDuration,
      super.onProgress});

  /// Remove cached image where key is [key]
  static Future removeCacheWhere({required String key}) =>
      ImgXCache.instance.remove(key);

  /// Remove all cached images
  static Future removeAllCache() => ImgXCache.instance.removeAll();
}
