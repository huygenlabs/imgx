@TestOn('browser')
library;

import 'dart:convert';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:imgx/src/network/img_x_http.dart';

/// Created by lovepreetsingh on 26,October,2026
void main() {
  test('downloads bytes and reports completion on the web', () async {
    final payload = Uint8List.fromList(List<int>.generate(64, (i) => i));
    final uri = Uri.parse(
      'data:application/octet-stream;base64,${base64Encode(payload)}',
    );
    final progress = <double>[];

    final response = await ImgXHttp.get(
      uri,
      const {},
      onProgress: progress.add,
    );
    try {
      expect(response.statusCode, 200);
      final chunks = <List<int>>[];
      await for (final chunk in response.body) {
        chunks.add(chunk);
      }
      final bytes = chunks.expand((chunk) => chunk).toList();
      expect(bytes, equals(payload));
    } finally {
      await response.close();
    }

    expect(progress.last, 1.0);
  });
}
