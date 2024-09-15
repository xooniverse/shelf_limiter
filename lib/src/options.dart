part of '../shelf_limiter.dart';

/// A class to provide additional configuration options for the rate limiter middleware.
///
/// This allows the you to customize the behavior of the rate limiter by providing
/// custom functions and headers, making it flexible and adaptable to different use cases.
class RateLimiterOptions {
  /// A function to extract a unique client identifier from the [Request].
  ///
  /// By default, the middleware will use the client's IP address as the identifier.
  /// However, you can provide your own logic to extract a custom identifier, such as
  /// a token, API key, or user ID from the request headers or body.
  ///
  /// Example:
  /// ```dart
  /// clientIdentifierExtractor: (Request request) => request.headers['X-Client-ID'] ?? 'unknown',
  /// ```
  final String Function(Request request)? clientIdentifierExtractor;

  /// A function that handles the response when the client exceeds the rate limit.
  ///
  /// This allows you to provide a custom response when a rate limit violation occurs.
  /// You can return a different status code, message, or even a custom JSON response.
  ///
  /// If not provided, the middleware will return a default 429 (Too Many Requests)
  /// response with a simple text message.
  ///
  /// Example:
  /// ```dart
  /// onRateLimitExceeded: (Request request) async {
  ///   return Response(429, body: 'Custom rate limit message.');
  /// },
  /// ```
  final FutureOr<Response> Function(Request request)? onRateLimitExceeded;

  /// Custom headers to be added to the response when the rate limit is exceeded.
  ///
  /// You can use this to add additional headers to the rate limit exceeded response,
  /// such as specific metadata or information about the rate limiting policy.
  ///
  /// These headers will be merged with the default rate limit headers, such as
  /// `X-RateLimit-Limit`, `X-RateLimit-Remaining`, and `Retry-After`.
  ///
  /// Example:
  /// ```dart
  /// headers: {
  ///   'X-Custom-Header': 'SomeValue',
  /// },
  /// ```
  final Map<String, String> headers;

  /// Creates an instance of [RateLimiterOptions].
  ///
  /// All parameters are optional. If not provided, default behavior is used:
  /// - The client identifier is extracted from the IP address.
  /// - A default 429 response is returned when the rate limit is exceeded.
  /// - No additional custom headers are added.
  RateLimiterOptions({
    this.clientIdentifierExtractor,
    this.onRateLimitExceeded,
    this.headers = const {},
  });
}
