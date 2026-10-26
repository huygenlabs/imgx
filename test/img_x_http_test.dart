import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:imgx/src/network/img_x_http.dart';

/// Created by lovepreetsingh on 26,October,2026
void main() {
  late HttpServer server;
  late Uri base;
  String? lastAuthorization;

  final payload = Uint8List.fromList(
    List<int>.generate(2048, (index) => index % 256),
  );

  setUp(() async {
    lastAuthorization = null;
    server = await HttpServer.bind(InternetAddress.loopbackIPv4, 0);
    base = Uri.parse('http://${server.address.address}:${server.port}');
    server.listen((request) async {
      lastAuthorization = request.headers.value(
        HttpHeaders.authorizationHeader,
      );
      switch (request.uri.path) {
        case '/redirect':
          request.response.statusCode = HttpStatus.found;
          request.response.headers.set(HttpHeaders.locationHeader, '/image');
          break;
        case '/missing':
          request.response.statusCode = HttpStatus.notFound;
          break;
        case '/empty':
          request.response.statusCode = HttpStatus.ok;
          request.response.headers.contentLength = 0;
          break;
        default:
          request.response.headers.contentType = ContentType.binary;
          request.response.headers.contentLength = payload.length;
          request.response.add(payload);
      }
      await request.response.close();
    });
  });

  tearDown(() async {
    await server.close(force: true);
  });

  Future<Uint8List> readBody(ImgXHttpResponse response) async {
    final chunks = <List<int>>[];
    var length = 0;
    await for (final chunk in response.body) {
      chunks.add(chunk);
      length += chunk.length;
    }
    final bytes = Uint8List(length);
    var offset = 0;
    for (final chunk in chunks) {
      bytes.setRange(offset, offset + chunk.length, chunk);
      offset += chunk.length;
    }
    return bytes;
  }

  test('downloads the full body and reports progress up to 1.0', () async {
    final progress = <double>[];
    final response = await ImgXHttp.get(
      base.resolve('/image'),
      const {},
      onProgress: progress.add,
    );

    try {
      expect(response.statusCode, 200);
      expect(await readBody(response), equals(payload));
    } finally {
      await response.close();
    }

    expect(progress, isNotEmpty);
    expect(progress.last, closeTo(1, 1e-9));
  });

  test('sends the provided headers', () async {
    final response = await ImgXHttp.get(base.resolve('/image'), const {
      'Authorization': 'Bearer token',
    });
    try {
      await readBody(response);
    } finally {
      await response.close();
    }
    expect(lastAuthorization, 'Bearer token');
  });

  test('exposes non success status codes', () async {
    final response = await ImgXHttp.get(base.resolve('/missing'), const {});
    try {
      expect(response.statusCode, 404);
      expect(response.reasonPhrase, isNotEmpty);
    } finally {
      await response.close();
    }
  });

  test('follows redirects', () async {
    final response = await ImgXHttp.get(base.resolve('/redirect'), const {});
    try {
      expect(response.statusCode, 200);
      expect(await readBody(response), equals(payload));
    } finally {
      await response.close();
    }
  });

  test('handles an empty body', () async {
    final response = await ImgXHttp.get(base.resolve('/empty'), const {});
    try {
      expect(response.statusCode, 200);
      expect(await readBody(response), isEmpty);
    } finally {
      await response.close();
    }
  });

  test('close can be called after the body was not read', () async {
    final response = await ImgXHttp.get(base.resolve('/image'), const {});
    await response.close();
    // Closing twice must stay safe.
    await response.close();
  });
}
