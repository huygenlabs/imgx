/// Types shared by the platform specific network implementations.
///
/// Created by lovepreetsingh on 26,October,2026
library;

/// Thrown when a request cannot be completed.
///
/// Created by lovepreetsingh on 27,October,2026
class ImgXHttpException implements Exception {
  /// Creates an exception with a message describing the failure.
  ///
  /// Set [retryable] to `false` when repeating the same request cannot
  /// succeed, such as when a browser blocks it for missing CORS headers.
  const ImgXHttpException(this.message, {this.retryable = true});

  /// Description of the failure.
  final String message;

  /// Whether sending the same request again may succeed.
  final bool retryable;

  @override
  String toString() => message;
}

/// A response returned by [ImgXHttp].
abstract class ImgXHttpResponse {
  /// HTTP status code of the response.
  int get statusCode;

  /// HTTP reason phrase of the response.
  String get reasonPhrase;

  /// Response payload. May be a single chunk on platforms that cannot stream.
  Stream<List<int>> get body;

  /// Releases the underlying connection. Safe to call more than once.
  Future<void> close();
}
