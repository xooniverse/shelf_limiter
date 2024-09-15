part of '../shelf_limiter.dart';

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
