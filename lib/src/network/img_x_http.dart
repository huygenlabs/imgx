/// Platform selection for the network implementation.
///
/// Native platforms use `dart:io`'s HttpClient, the web uses XMLHttpRequest
/// through `dart:js_interop`. No third party HTTP client is involved.
///
/// Created by lovepreetsingh on 26,October,2026
library;

export 'img_x_http_stub.dart'
    if (dart.library.io) 'img_x_http_io.dart'
    if (dart.library.js_interop) 'img_x_http_web.dart';

export 'img_x_http_types.dart';
