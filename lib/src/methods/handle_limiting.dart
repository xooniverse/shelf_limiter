part of '../../shelf_limiter.dart';

Future<Response> _handleLimiting({
  required _RateLimiter rateLimiter,
  required RateLimiterOptions options,
  required Request request,
  required Handler innerHandler,
}) async {
  // Extract client identifier (IP by default)
  final clientIdentifier = options.clientIdentifierExtractor != null
      ? options.clientIdentifierExtractor!(request)
      : ((request.context['shelf.io.connection_info']) as dynamic)
          ?.remoteAddress
          .address;

  // Check if the client has exceeded the rate limit
  if (!rateLimiter.isAllowed(clientIdentifier)) {
    // Retry after the window resets
    final retryAfter = options.windowSize.inSeconds;

    // If a custom response is provided, apply rate limit headers to it
    if (options.onRateLimitExceeded != null) {
      final customResponse = await options.onRateLimitExceeded!(request);

      return _craftResponse(
        customResponse.change(
          headers: options.headers,
        ),
        options.maxRequests,
        retryAfter,
      );
    }

    // Default 429 response with custom rate limit headers
    return _craftResponse(
      Response(
        429,
        body: 'Too many requests, please try again later.',
        headers: options.headers,
      ),
      options.maxRequests,
      retryAfter,
    );
  }

  // Calculate remaining requests and reset time for rate limit headers
  final now = DateTime.now();
  final requestTimes = rateLimiter._clientRequestTimes[clientIdentifier]!;
  final resetTime = options.windowSize.inSeconds -
      now.difference(requestTimes.first).inSeconds;
  final remainingRequests = options.maxRequests - requestTimes.length;

  // Proceed with the request and attach rate limiting headers to the response
  final response = await innerHandler(request);

  return _craftResponse(
    response,
    options.maxRequests,
    resetTime,
    remainingRequests: remainingRequests,
  );
}
