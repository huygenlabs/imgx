import 'dart:io';

import 'package:imgx/src/network/img_x_http_types.dart';

/// Performs HTTP requests with `dart:io`'s [HttpClient].
///
/// Created by lovepreetsingh on 26,October,2026
class ImgXHttp {
  const ImgXHttp._();

  /// Sends a GET request to [uri] with [headers].
  ///
  /// [onProgress] is called with `0.0` to `1.0` while the body is consumed,
  /// when the server reports a content length. The returned response must be
  /// closed by the caller.
  static Future<ImgXHttpResponse> get(
    Uri uri,
    Map<String, String> headers, {
    void Function(double progress)? onProgress,
  }) async {
    final client = HttpClient();
    try {
      final request = await client.getUrl(uri);
      headers.forEach(request.headers.set);
      final response = await request.close();
      return _IoResponse(client, response, onProgress);
    } catch (_) {
      client.close(force: true);
      rethrow;
    }
  }
}

class _IoResponse implements ImgXHttpResponse {
  _IoResponse(
    this._client,
    this._response,
    void Function(double progress)? onProgress,
  ) : _body = _measure(_response, _response.contentLength, onProgress);

  final HttpClient _client;
  final HttpClientResponse _response;
  final Stream<List<int>> _body;

  @override
  int get statusCode => _response.statusCode;

  @override
  String get reasonPhrase => _response.reasonPhrase;

  @override
  Stream<List<int>> get body => _body;

  @override
  Future<void> close() async {
    try {
      // Drain anything the caller did not read so the socket can be reused.
      await _response.drain<void>();
    } catch (_) {
      // The body may already be consumed or the connection may be gone.
    }
    _client.close();
  }

  static Stream<List<int>> _measure(
    Stream<List<int>> source,
    int? contentLength,
    void Function(double progress)? onProgress,
  ) {
    if (onProgress == null || contentLength == null || contentLength <= 0) {
      return source;
    }
    return _measureStream(source, contentLength, onProgress);
  }

  static Stream<List<int>> _measureStream(
    Stream<List<int>> source,
    int contentLength,
    void Function(double progress) onProgress,
  ) async* {
    var downloaded = 0;
    await for (final chunk in source) {
      downloaded += chunk.length;
      onProgress(downloaded / contentLength);
      yield chunk;
    }
  }
}
