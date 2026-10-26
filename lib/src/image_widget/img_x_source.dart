import 'dart:typed_data';

import 'package:imgx/src/cache/cache_type.dart';
import 'package:imgx/src/cache/img_x_cache.dart';
import 'package:imgx/src/network/img_x_http.dart';
import 'package:imgx/src/utils/img_x_logger.dart';

/// Created by lovepreetsingh on 14, November, 2024

mixin ImgXSource {
  /// Saved Image data
  Uint8List? data;

  /// Get Image from network
  Future<Uint8List?> getImage(
    String url,
    Map<String, String> headers,
    CacheType cacheType,
    Duration cacheDuration,
    int retryCount,
    bool logErrors, {
    void Function(double progress)? onProgress,
  }) async {
    // Return if present from cache
    List<dynamic>? cachedData = await ImgXCache.instance.getCacheAsync(
      url,
      cacheDuration,
    );
    List<int>? cachedDataInt = cachedData?.map((e) => e as int).toList();
    if (cachedDataInt != null) {
      data = Uint8List.fromList(cachedDataInt);
      return data!;
    }

    for (int i = 0; i <= retryCount; i++) {
      ImgXHttpResponse? response;
      try {
        response = await ImgXHttp.get(
          Uri.parse(url),
          headers,
          onProgress: onProgress,
        );

        if (response.statusCode == 200) {
          final chunks = <List<int>>[];
          var length = 0;
          await for (final chunk in response.body) {
            chunks.add(chunk);
            length += chunk.length;
          }

          final imageData = Uint8List(length);
          var offset = 0;
          for (final chunk in chunks) {
            imageData.setRange(offset, offset + chunk.length, chunk);
            offset += chunk.length;
          }

          if (cacheType != CacheType.none) {
            ImgXCache.instance.putCache(
              url,
              imageData,
              cacheType: cacheType,
              cacheDuration: cacheDuration,
            );
          }

          data = imageData;
          return imageData;
        } else {
          if (logErrors) {
            ImgXLogger.error(
              'Error: ${response.statusCode} - ${response.reasonPhrase}',
            );
          }
        }
      } catch (e) {
        if (logErrors) {
          ImgXLogger.error(
            'Error fetching image : $e',
            error: e,
            stackTrace: StackTrace.current,
          );
        }
        // Retrying cannot fix a blocked or refused request, so stop early
        // instead of repeating it.
        if (e is ImgXHttpException && !e.retryable) {
          break;
        }
      } finally {
        if (response != null) {
          await response.close();
        }
      }
    }

    return data;
  }
}
