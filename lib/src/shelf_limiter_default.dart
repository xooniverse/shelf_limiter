part of '../shelf_limiter.dart';

/// A middleware function that applies rate limiting to incoming HTTP requests.
///
/// This middleware tracks the number of requests a client makes within a specified
/// time window and limits how many requests are allowed. It can be customized with
/// options to handle specific client identification and responses when the rate limit
/// is exceeded.
///
/// ## Parameters:
///
/// - `maxRequests`: The maximum number of requests a client can make within the time window.
/// - `windowSize`: The duration for which requests are counted. After this window,
///   the count resets.
/// - `options` (optional): An instance of [RateLimiterOptions] to customize client
///   identification, exceeded limit responses, and headers.
///
/// ## Returns:
///
/// A `Middleware` that can be applied to a `Handler` to enforce rate limits.
///
/// ## Behavior:
///
/// The middleware extracts a unique identifier for each client (IP address by default),
/// tracks the number of requests they make within the specified `windowSize`, and rejects
/// further requests if the limit (`maxRequests`) is exceeded.
///
/// When the rate limit is exceeded, it can return a default 429 (Too Many Requests) response
/// with rate limiting headers, or a custom response if provided in the `RateLimiterOptions`.
///
/// ## Headers:
///
/// The middleware adds rate limiting headers to both the exceeded responses and normal
/// responses:
///
/// - `X-RateLimit-Limit`: The maximum number of allowed requests.
/// - `X-RateLimit-Remaining`: The number of remaining requests for the current window.
/// - `X-RateLimit-Reset`: Time (in seconds) until the rate limit count resets.
/// - `Retry-After`: The time (in seconds) after which the client can retry (only when
///   rate limit is exceeded).
///
/// ## Example:
///
/// ```dart
/// import 'package:shelf/shelf.dart';
/// import 'package:shelf/shelf_io.dart' as io;
///
/// void main() async {
///   final handler = const Pipeline()
///     .addMiddleware(shelfLimiter(
///       maxRequests: 5,
///       windowSize: Duration(minutes: 1),
///       options: RateLimiterOptions(
///         headers: {
///           'X-Custom-Header': 'Rate limited',
///         },
///         onRateLimitExceeded: (Request request) async {
///           return Response(429, body: 'Custom message: Too many requests!');
///         },
///       ),
///     ))
///     .addHandler(_echoRequest);
///
///   var server = await io.serve(handler, 'localhost', 8080);
///   print('Server listening on port ${server.port}');
/// }
///
/// Response _echoRequest(Request request) => Response.ok('Request received');
/// ```
///
/// In this example:
/// - The client is allowed 5 requests every 1 minute.
/// - The `clientIdentifierExtractor` extracts a custom client ID from the request header `X-Client-ID`.
/// - A custom 429 message is returned when the limit is exceeded.
/// - Custom headers (like `X-Custom-Header`) are added to the response.
/// Middleware to limit the rate of requests from clients.
Middleware shelfLimiter(RateLimiterOptions options) {
  final rateLimiter = _RateLimiter(
    maxRequests: options.maxRequests,
    rateLimitDuration: options.windowSize,
  );

  return (Handler innerHandler) {
    return (Request request) async {
      return _handleLimiting(
        rateLimiter: rateLimiter,
        options: options,
        request: request,
        innerHandler: innerHandler,
      );
    };
  };
}
