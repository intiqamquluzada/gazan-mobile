import 'package:flutter_test/flutter_test.dart';
import 'package:qazan/core/config/app_config.dart';

void main() {
  group('AppConfig.mediaUrl', () {
    test('caps Unsplash photos to a phone-sized width', () {
      final Uri u = Uri.parse(AppConfig.mediaUrl(
          'https://images.unsplash.com/photo-1554118811-1e0d58224f24'));
      expect(u.queryParameters['w'], '1000');
      expect(u.queryParameters['auto'], 'format');
      expect(u.queryParameters['q'], '70');
    });

    test('keeps a smaller requested width and other params', () {
      final Uri u = Uri.parse(AppConfig.mediaUrl(
          'https://images.unsplash.com/photo-1?w=400&q=80&fit=max'));
      expect(u.queryParameters['w'], '400');
      expect(u.queryParameters['q'], '80');
      expect(u.queryParameters['fit'], 'max');
    });

    test('shrinks an oversized requested width', () {
      final Uri u = Uri.parse(AppConfig.mediaUrl(
          'https://images.unsplash.com/photo-1?w=2400'));
      expect(u.queryParameters['w'], '1000');
    });

    test('leaves other hosts and our own images alone', () {
      expect(AppConfig.mediaUrl('https://example.com/a.jpg?w=3000'),
          'https://example.com/a.jpg?w=3000');
      expect(AppConfig.mediaUrl('/api/v1/images/abc'),
          endsWith('/api/v1/images/abc'));
    });
  });
}
