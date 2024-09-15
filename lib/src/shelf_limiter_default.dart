part of '../shelf_limiter.dart';

/// A middleware that applies rate limiting to all incoming requests using the provided options.
///
/// This middleware enforces a global rate limit on all requests. If the number of
/// requests from a client exceeds the specified `maxRequests` within the `windowSize`
/// time frame, the middleware will block further requests until the time window resets.
///
/// ## Parameters:
/// - `options`: An instance of `RateLimiterOptions` that defines the rate limiting behavior.
///   This includes the maximum number of requests, the time window for the rate limit,
///   and optional custom behavior for identifying clients and handling rate limit violations.
///
/// ## Returns:
/// - A `Middleware` that can be applied to your API handler.
///
/// ## Example - Basic Usage:
/// ```dart
/// // Apply a rate limit of 10 requests per minute for all incoming requests.
/// final limiterMiddleware = shelfLimiter(
///   RateLimiterOptions(
///     maxRequests: 10,
///     windowSize: Duration(minutes: 1),
///   ),
/// );
///
/// // Use the middleware in your request pipeline.
/// final handler = const Pipeline()
///   .addMiddleware(limiterMiddleware)
///   .addHandler(yourHandler);
/// ```
///
/// In this basic example, the middleware allows up to 10 requests per minute
/// from each client. Any requests beyond that within the same minute will be blocked,
/// and the client will receive a `429 Too Many Requests` response.
///
/// ## Example - Advanced Usage with Custom Response and Headers:
/// ```dart
/// final options = RateLimiterOptions(
///   maxRequests: 5, // Maximum number of requests allowed
///   windowSize: const Duration(minutes: 1), // Duration of the rate limit window
///   headers: {
///     'X-Custom-Header': 'Rate limited', // Custom header to add to all responses
///   },
///   onRateLimitExceeded: (request) async {
///     // Custom response when the rate limit is exceeded
///     return Response(
///       429,
///       body: jsonEncode({
///         'status': false,
///         'message': "Uh, hm! Wait a minute, that's a lot of requests.",
///       }),
///       headers: {
///         'Content-Type': 'application/json',
///         'X-Custom-Response-Header': 'CustomValue', // Additional custom header
///       },
///     );
///   },
/// );
///
/// // Apply the rate limiter middleware with custom options.
/// final limiterMiddleware = shelfLimiter(options);
///
/// // Use the middleware in your request pipeline.
/// final handler = const Pipeline()
///   .addMiddleware(limiterMiddleware)
///   .addHandler(yourHandler);
/// ```
///
/// In the advanced example, the rate limit allows up to 5 requests per minute.
/// If the limit is exceeded, a custom response is returned with a custom message and headers.
/// Additionally, all responses (whether rate-limited or not) will include a custom header
/// (`X-Custom-Header: Rate limited`).
///
/// ## Notes:
/// - **Client identification**: By default, the client is identified by their IP address.
///   You can customize this behavior by providing a `clientIdentifierExtractor` in the options
///   to identify clients based on other criteria, like API tokens or session IDs.
/// - **Custom response on limit exceed**: You can provide a custom response to be returned when
///   the rate limit is exceeded using the `onRateLimitExceeded` option. This is useful when you
///   want to return more user-friendly or detailed error messages.
/// - **Rate limit headers**: The middleware automatically attaches rate limiting headers, such as
///   how many requests remain and how long until the rate limit resets.
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
