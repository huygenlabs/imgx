<p align="center">
  <img src="https://raw.githubusercontent.com/huygenlabs/imgx/master/doc/icon.png" alt="ImgX icon" width="128">
</p>

It is a Flutter package for efficient image loading from URLs, supporting formats like PNG, JPG, WEBP, and GIF. It features memory/disk caching with expiration, a retry mechanism for failures, and real-time progress tracking for seamless server image handling.

# Usage

First, add `imgx` as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  imgx: ^0.1.6
```

Don't forget to `flutter pub get`.

## 1. Set up app global configuration (optional)

You can set global cacheType, cacheDuration, retryCount and errorLogging for the entire app. You can also set these on a widget level, where widget level params will take precedence over global configurations. If you don't set any of these, the default values will be used.

When error logging is enabled, failures are reported through `dart:developer`, so they appear in the Flutter debug console, DevTools, logcat and the Apple unified log without any extra dependency.

```dart
import 'package:example/home_page.dart';
import 'package:imgx/imgx.dart';

void main() {
  ImgXConfig.globalCacheType = CacheType.memory;
  ImgXConfig.globalCacheDuration = const Duration(days: 1);
  ImgXConfig.globalRetryCount = 3;
  ImgXConfig.globalLogErrors = true/false;

  runApp(const MyApp());
}

```

## 2. ImgX widget usage

If you have already set up global configurations, you can use the ImgX widget without any parameters. If you want to override the global configurations, you can set the parameters as shown in the example below.

```dart
import 'package:imgx/imgx.dart';

Widget build(BuildContext context) {
  return ImgX(
    width: 200,
    height: 200,
    imageUri: "https://www.loudegg.com/wp-content/uploads/2020/10/Fred-Flintstone.jpg",
    cacheType: CacheType.memory,
    cacheDuration: const Duration(days: 1),
    retryCount: 2,
    fit: BoxFit.fitHeight,
    headers: {"Authorization": "Bearer token"},
    progressWidget: const Center(
      child: CircularProgressIndicator(),
    ),
    errorWidget: const Center(
      child: Icon(Icons.error),
    ),
    onProgress: (progress) {
      /** Don't forget to remove print in your production code */
      print(
          "Download progress: ${(progress * 100).toStringAsFixed(2)}%");
    },
  );
}

```
## 3. Removing manually from cache

You can remove all cached images or use image url to remove single one as in following example.

```dart
import 'package:imgx/imgx.dart';

void removeCache(){
  //Partial Match
  ImgX.removeCacheWhere(key: "Fred-Flintstone.jpg");
  //Full Match
  ImgX.removeCacheWhere(key: "https://www.loudegg.com/wp-content/uploads/2020/10/Fred-Flintstone.jpg");
  ImgX.removeAllCache();
}

```

## 4. Where the disk cache lives

Disk caching needs no plugin. Cached images are written as individual files in an `imgx_cache` directory inside the platform temporary directory (`Directory.systemTemp`). The OS may clear that directory when storage runs low, which is fine for an image cache that has an expiry anyway. Nothing is written to the app documents folder or to `shared_preferences`.

Expired entries are deleted the next time they are read, and `ImgX.removeAllCache()` and `ImgX.removeCacheWhere()` only ever touch files owned by ImgX.

On web the disk cache falls back to memory, because `dart:io` is not available there.

## 5. Networking

ImgX has no dependencies outside the Flutter SDK. Downloads use `dart:io`'s `HttpClient` on iOS, Android, macOS, Windows and Linux, and `XMLHttpRequest` on the web.

Browsers only let JavaScript read a response body when the server sends CORS headers, so on web:

- images from servers that allow CORS (same-origin URLs and most CDNs) are downloaded, cached and report progress exactly like on native platforms;
- images from servers without CORS headers are drawn through an HTML `<img>` element instead, so they still show up, but they cannot be cached or report progress.

Those blocked requests are not retried, because a browser CORS decision never changes on a second attempt.

Custom `headers` are sent on web too, which makes the request non-simple and can trigger a CORS preflight. HTML elements cannot carry headers, so an image that needs custom headers can only load on web when the server allows CORS. Send no headers for public cross-origin images if you want the `<img>` fallback.

## 6. Support the package (optional)

If you find this package useful, you can support it for free by giving it a thumbs up at the top of this page. 


Congrats you finished your setup for ImgX.


# Bugs or Requests

If you encounter any problem or think the library is missing a feature, feel free to open an [issue](https://github.com/huygenlabs/imgx/issues/new). Pull request are also welcome.
