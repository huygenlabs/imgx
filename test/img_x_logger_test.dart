import 'package:flutter_test/flutter_test.dart';
import 'package:imgx/src/utils/img_x_logger.dart';

/// Created by lovepreetsingh on 26,October,2026
void main() {
  group('ImgXLogger', () {
    test('logs a plain message without throwing', () {
      expect(() => ImgXLogger.error('boom'), returnsNormally);
    });

    test('logs an error with a stack trace without throwing', () {
      expect(
        () => ImgXLogger.error(
          'Error fetching image',
          error: Exception('network down'),
          stackTrace: StackTrace.current,
        ),
        returnsNormally,
      );
    });
  });
}
