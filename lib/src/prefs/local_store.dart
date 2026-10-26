/// Platform selection for the local cache store.
///
/// Native platforms use a file based store, the web falls back to an
/// in-memory store because `dart:io` is not available there.
///
/// Created by lovepreetsingh on 26,October,2026
library;

export 'local_store_stub.dart' if (dart.library.io) 'local_store_io.dart';
