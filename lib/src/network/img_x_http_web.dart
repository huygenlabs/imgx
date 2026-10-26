import 'dart:async';
import 'dart:js_interop';
import 'dart:typed_data';

import 'package:imgx/src/network/img_x_http_types.dart';

/// Performs HTTP requests with `XMLHttpRequest` on the web.
///
/// The browser only exposes the payload once the request finishes, so the
/// body is emitted as a single chunk. Progress is reported from the native
/// `progress` event instead.
///
/// Created by lovepreetsingh on 26,October,2026
class ImgXHttp {
  const ImgXHttp._();

  /// Sends a GET request to [uri] with [headers].
  ///
  /// [onProgress] is called with `0.0` to `1.0` while the request is running
  /// when the browser can compute the total size.
  static Future<ImgXHttpResponse> get(
    Uri uri,
    Map<String, String> headers, {
    void Function(double progress)? onProgress,
  }) async {
    final completer = Completer<ImgXHttpResponse>();
    final request = _Request();

    request.open('GET', uri.toString());
    request.responseType = 'arraybuffer';
    headers.forEach((name, value) => request.setRequestHeader(name, value));

    request.onprogress = (JSObject event) {
      final progress = _ProgressEvent._(event);
      final total = progress.total;
      if (!progress.lengthComputable || total <= 0) {
        return;
      }
      onProgress?.call(progress.loaded / total);
    }.toJS;

    request.onload = (JSObject event) {
      if (completer.isCompleted) {
        return;
      }
      final raw = request.response;
      final bytes = raw == null
          ? Uint8List(0)
          : (raw as JSArrayBuffer).toDart.asUint8List();
      onProgress?.call(1);
      completer.complete(
        _WebResponse(
          bytes,
          statusCode: request.status,
          reasonPhrase: request.statusText,
        ),
      );
    }.toJS;

    request.onerror = (JSObject event) {
      if (!completer.isCompleted) {
        // The browser reports CORS and connection failures the same way and
        // hides the details. Neither gets better by repeating the request, so
        // the retry loop stops here.
        completer.completeError(
          ImgXHttpException(
            'Request to $uri failed. The server must allow cross origin '
            'requests (CORS).',
            retryable: false,
          ),
        );
      }
    }.toJS;

    request.send();
    return completer.future;
  }
}

class _WebResponse implements ImgXHttpResponse {
  _WebResponse(
    this._bytes, {
    required this.statusCode,
    required this.reasonPhrase,
  });

  final Uint8List _bytes;

  @override
  final int statusCode;

  @override
  final String reasonPhrase;

  @override
  Stream<List<int>> get body => Stream<List<int>>.value(_bytes);

  @override
  Future<void> close() async {}
}

@JS('XMLHttpRequest')
extension type _Request._(JSObject _) implements JSObject {
  external _Request();

  external void open(String method, String url);

  external void setRequestHeader(String header, String value);

  external void send();

  external int get status;

  external String get statusText;

  external JSAny? get response;

  external set responseType(String value);

  external set onload(JSFunction? handler);

  external set onerror(JSFunction? handler);

  external set onprogress(JSFunction? handler);
}

extension type _ProgressEvent._(JSObject _) implements JSObject {
  external bool get lengthComputable;

  external double get loaded;

  external double get total;
}
