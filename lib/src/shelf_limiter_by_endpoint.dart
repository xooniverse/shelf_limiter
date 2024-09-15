part of '../shelf_limiter.dart';

/// A middleware that applies rate limiting based on specific endpoint limits.
///
/// This middleware allows developers to set different rate limits for different
/// API endpoints. You can also provide a default rate limiter if some endpoints
/// don't have custom limits.
///
/// If the client exceeds the allowed requests for an endpoint, the middleware
/// responds with a `429 Too Many Requests` status or a custom response if specified.
///
/// ## Parameters:
/// - `endpointLimits`: A map where the keys are endpoint paths (as strings) and
///   the values are `RateLimiterOptions` specifying rate limits for each endpoint.
/// - `defaultOptions`: Optional. If provided, this applies rate limiting for any
///   endpoint that isn't explicitly listed in `endpointLimits`.
///
/// ## Returns:
/// - A `Middleware` that can be applied to your API handler.
///
/// ## Example - Basic Usage:
/// ```dart
/// // Apply a rate limit of 5 requests per minute for the `/api/resource` endpoint
/// // and 10 requests per minute for `/api/data`.
/// final limiterMiddleware = shelfLimiterByEndpoint(
///   endpointLimits: {
///     '/api/resource': RateLimiterOptions(
///       maxRequests: 5,
///       windowSize: Duration(minutes: 1),
///     ),
///     '/api/data': RateLimiterOptions(
///       maxRequests: 10,
///       windowSize: Duration(minutes: 1),
///     ),
///   },
/// );
///
/// // Apply the middleware to your handler
/// final handler = const Pipeline()
///   .addMiddleware(limiterMiddleware)
///   .addHandler(yourHandler);
/// ```
///
/// ## Example - Advanced Usage with Client Identifier and Custom Response:
/// ```dart
/// // Apply rate limits to multiple endpoints with custom client identification (by token)
/// // and a custom response when the rate limit is exceeded.
/// final limiterMiddleware = shelfLimiterByEndpoint(
///   endpointLimits: {
///     '/api/resource': RateLimiterOptions(
///       maxRequests: 5,
///       windowSize: Duration(minutes: 1),
///       clientIdentifierExtractor: (request) => request.headers['X-Client-Token']!,
///       onRateLimitExceeded: (request) async => Response.forbidden('Rate limit exceeded'),
///     ),
///     '/api/data': RateLimiterOptions(
///       maxRequests: 10,
///       windowSize: Duration(minutes: 1),
///     ),
///   },
///   defaultOptions: RateLimiterOptions(
///     maxRequests: 15,
///     windowSize: Duration(minutes: 5),
///   ),
/// );
///
/// // Apply the middleware to your handler
/// final handler = const Pipeline()
///   .addMiddleware(limiterMiddleware)
///   .addHandler(yourHandler);
/// ```
///
/// In this advanced example, a custom client identifier is extracted from the
/// `X-Client-Token` header, and a custom error message is returned when the
/// rate limit is exceeded for the `/api/resource` endpoint.
///
/// ## Notes:
/// - The `endpointLimits` map allows you to configure different rate limits for each endpoint.
/// - The `defaultOptions` is optional but useful for covering any endpoints that aren't listed in `endpointLimits`.
/// - If the `clientIdentifierExtractor` is not specified, the client's IP address is used by default.
Middleware shelfLimiterByEndpoint({
  required Map<String, RateLimiterOptions> endpointLimits,
  RateLimiterOptions? defaultOptions,
}) {
  // Create and store rate limiters for each endpoint when the middleware is initialized
  final rateLimiters = <String, _RateLimiter>{};

  endpointLimits.forEach((path, options) {
    rateLimiters[path] = _RateLimiter(
      maxRequests: options.maxRequests,
      rateLimitDuration: options.windowSize,
    );
  });

  final defaultRateLimiter = defaultOptions != null
      ? _RateLimiter(
          maxRequests: defaultOptions.maxRequests,
          rateLimitDuration: defaultOptions.windowSize,
        )
      : null;

  return (Handler innerHandler) {
    return (Request request) async {
      final path = '/${request.url.path}';
      final rateLimiter = rateLimiters[path] ?? defaultRateLimiter;

      if (rateLimiter == null) {
        // No rate limiter options available; proceed without rate limiting
        return await innerHandler(request);
      }

      // Get the appropriate RateLimiterOptions (used for client identifier and headers)
      final options = endpointLimits[path] ?? defaultOptions!;

      return _handleLimiting(
        rateLimiter: rateLimiter,
        options: options,
        request: request,
        innerHandler: innerHandler,
      );
    };
  };
}
