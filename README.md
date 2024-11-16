It is a Flutter package for efficient image loading from URLs, supporting formats like PNG, JPG, WEBP, and GIF. It features memory/disk caching with expiration, a retry mechanism for failures, and real-time progress tracking for seamless server image handling.

# Usage

First, add `imgx` as a dependency in your pubspec.yaml file.

```yaml
dependencies:
  imgx: ^0.1.2
```

Don't forget to `flutter pub get`.

## 1. Set up app global configuration (optional)

You can set global cacheType, cacheDuration, and retryCount for the entire app. You can also set these on a widget level, where widget level params will take precedence over global configurations. If you don't set any of these, the default values will be used.

```dart
import 'package:example/home_page.dart';
import 'package:imgx/imgx.dart';

void main() {
  ImgXConfig.globalCacheType = CacheType.memory;
  ImgXConfig.globalCacheDuration = const Duration(days: 1);
  ImgXConfig.globalRetryCount = 3;

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
  ImgX.removeCacheWhere(key: "https://www.loudegg.com/wp-content/uploads/2020/10/Fred-Flintstone.jpg");
  ImgX.removeAllCache();
}

```

## 4. Support the package (optional)

If you find this package useful, you can support it for free by giving it a thumbs up at the top of this page. 


Congrats you finished your setup for ImgX.


# Bugs or Requests

If you encounter any problem or think the library is missing a feature, feel free to open an [issue](https://github.com/huygenlabs/imgx/issues/new). Pull request are also welcome.
