import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:imgx/src/cache/cache_type.dart';
import 'package:imgx/src/cache/img_x_cache.dart';
import 'package:logger/logger.dart';

/// Created by lovepreetsingh on 14, November, 2024

mixin ImgXSource {
  /// Logger instance
  final logger = Logger(
    printer: PrettyPrinter(
      colors: true,
      printEmojis: true,
      dateTimeFormat: DateTimeFormat.dateAndTime,
    ),
  );

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
    Function(double progress)? onProgress,
  }) async {
    // Return if present from cache
    List<dynamic>? cachedData =
        await ImgXCache.instance.getCacheAsync(url, cacheDuration);
    List<int>? cachedDataInt = cachedData?.map((e) => e as int).toList();
    if (cachedDataInt != null) {
      data = Uint8List.fromList(cachedDataInt);
      return data!;
    }

    for (int i = 0; i <= retryCount; i++) {
      try {
        final request = http.Request('GET', Uri.parse(url));
        request.headers.addAll(headers);

        final response = await request.send();

        if (response.statusCode == 200) {
          final contentLength = response.contentLength ?? 0;
          final List<int> bytes = [];
          int downloaded = 0;

          await for (var chunk in response.stream) {
            bytes.addAll(chunk);
            downloaded += chunk.length;

            // Report progress
            if (contentLength > 0 && onProgress != null) {
              onProgress(downloaded / contentLength);
            }
          }

          final imageData = Uint8List.fromList(bytes);

          if (cacheType != CacheType.none) {
            ImgXCache.instance.putCache(url, imageData,
                cacheType: cacheType, cacheDuration: cacheDuration);
          }

          data = imageData;
          return data;
        } else {
          if (logErrors) {
            logger
                .e("Error: ${response.statusCode} - ${response.reasonPhrase}");
          }
        }
      } catch (e) {
        if (logErrors) {
          logger.e("Error fetching image : $e",
              error: e, stackTrace: StackTrace.current);
        }
      }
    }

    return data;
  }
}
