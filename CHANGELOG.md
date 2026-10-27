## [0.1.6] - (26th October 2026)

- Removed the `shared_preferences` dependency.
- Disk cache is now a bundled file store in the system temporary directory, written atomically as raw bytes instead of JSON encoded arrays.
- Web falls back to an in-memory store instead of `shared_preferences_web`.
- Removed the `logger` dependency; errors are reported through `dart:developer` instead.
- Removed the `http` dependency; downloads use `dart:io`'s `HttpClient` on native platforms and `XMLHttpRequest` on the web.
- Web builds can now cache and report download progress for CORS enabled images, with `Image.network` kept as a fallback.
- Web images blocked by CORS are now drawn with an HTML `<img>` element (`WebHtmlElementStrategy.fallback`) instead of showing the error widget, and blocked requests are no longer retried.
- A rebuild of `ImgX` no longer starts a second download, because the request future is kept in the widget state.
- Disk entries written by 0.1.5 are not migrated or re-read; they stay behind in the platform preferences and disappear when app data is cleared.
- Minimum SDK raised to Dart 3.13 / Flutter 3.47, CI now runs Flutter 3.47.7, and sources were reformatted with the current `dart format` style.

## [0.1.5] - (30th June 2025)

- Global option to set error logs.
- Updated to Flutter 3.32.5

## [0.1.4] - (8th January 2025)

- Fix for cache removal from memory.
- Updated dependencies.

## [0.1.3] - (16th November 2024)

- Added test cases for the package.

## [0.1.2] - (16th November 2024)

- Improved documentation and score.

## [0.1.1] - (16th November 2024)

- Improved package score.

## [0.1.0] - (15th November 2024)

- Initial release: Load images from a url, cache it in memory or disk and a retry mechanism in case of failure.
