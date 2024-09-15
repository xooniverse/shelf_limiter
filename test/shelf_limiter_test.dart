import 'dart:convert';
import 'dart:io' as io;
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_limiter/shelf_limiter.dart';
import 'package:test/test.dart';

void main() {
  group('shelf_limiter middleware', () {
    late Handler handler;
    late io.HttpServer server;
    late io.HttpClient client;

    setUp(() async {
      // Create a simple handler that just responds with 'OK'
      handler = const Pipeline()
          .addMiddleware(
            shelfLimiter(
              maxRequests: 2,
              windowSize: const Duration(seconds: 10),
            ),
          )
          .addHandler((request) => Response.ok('OK'));

      // Start the server and setup the HTTP client
      server = await shelf_io.serve(
        handler,
        'localhost',
        0,
      ); // Use port 0 to let the OS assign an available port
      client = io.HttpClient();
    });

    tearDown(() async {
      // Close the server and client after each test
      await server.close(force: true);
      client.close();
    });

    test('Allows requests within the limit', () async {
      final uri = Uri.parse('http://localhost:${server.port}');
      // Send 2 requests, which should be allowed
      final response1 =
          await client.getUrl(uri).then((request) => request.close());
      final response2 =
          await client.getUrl(uri).then((request) => request.close());

      expect(response1.statusCode, equals(200));
      expect(response2.statusCode, equals(200));
    });

    test('Blocks requests exceeding the limit', () async {
      final uri = Uri.parse('http://localhost:${server.port}');
      // Send 3 requests, the 3rd should be blocked
      await client.getUrl(uri).then((request) => request.close());
      await client.getUrl(uri).then((request) => request.close());
      final response3 =
          await client.getUrl(uri).then((request) => request.close());

      expect(response3.statusCode, equals(429));
      expect(
        response3.headers['X-RateLimit-Limit']?.first,
        equals('2'),
      );
      expect(
        response3.headers['X-RateLimit-Remaining']?.first,
        equals('0'),
      );
    });

    test('Includes custom headers and responses', () async {
      // Set up custom options
      final options = RateLimiterOptions(
        headers: {'X-Custom-Header': 'Rate Limited'},
        onRateLimitExceeded: (request) async {
          return Response(
            429,
            body: 'Custom rate limit exceeded message',
            headers: {'X-Custom-Response-Header': 'CustomValue'},
          );
        },
      );

      handler = const Pipeline()
          .addMiddleware(
            shelfLimiter(
              maxRequests: 2,
              windowSize: const Duration(seconds: 10),
              options: options,
            ),
          )
          .addHandler((request) => Response.ok('OK'));

      // Restart the server with new handler
      server = await shelf_io.serve(
        handler,
        'localhost',
        0,
      );

      final uri = Uri.parse('http://localhost:${server.port}');
      // Set up HTTP client
      client = io.HttpClient();

      // Send 2 requests to set up rate limiting
      await client.getUrl(uri).then((request) => request.close());
      await client.getUrl(uri).then((request) => request.close());

      // This request should trigger the custom rate limit response
      final response =
          await client.getUrl(uri).then((request) => request.close());

      expect(response.statusCode, equals(429));
      expect(
        response.headers['X-Custom-Response-Header']?.first,
        equals('CustomValue'),
      ); // Adjusted to access the first element of the list
      expect(
        await response.transform(utf8.decoder).join(),
        equals('Custom rate limit exceeded message'),
      );
    });
  });
}
