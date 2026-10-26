import 'package:imgx/src/network/img_x_http_types.dart';

/// Fallback used on platforms that have neither `dart:io` nor JS interop.
///
/// Created by lovepreetsingh on 26,October,2026
class ImgXHttp {
  const ImgXHttp._();

  /// Always throws, this platform cannot perform network requests.
  static Future<ImgXHttpResponse> get(
    Uri uri,
    Map<String, String> headers, {
    void Function(double progress)? onProgress,
  }) {
    throw UnsupportedError(
      'Network requests are not supported on this platform.',
    );
  }
}
