part of '../../shelf_limiter.dart';

/// Handles rate limiting for a specific client based on the provided options.
///
/// If the client exceeds the allowed requests within the time window, it responds
/// with a 429 status code, or a custom response if provided. Otherwise, it proceeds
/// with the request and attaches rate limit headers to the response.
Future<Response> _handleLimiting({
  required _RateLimiter rateLimiter,
  required RateLimiterOptions options,
  required Request request,
  required Handler innerHandler,
}) async {
  // Extract the client's identifier (usually their IP address by default).
  final clientIdentifier = options.clientIdentifierExtractor != null
      ? options.clientIdentifierExtractor!(request)
      : ((request.context['shelf.io.connection_info']) as dynamic)
          ?.remoteAddress
          .address;

  // Check if the client has exceeded their request limit.
  if (!rateLimiter.isAllowed(clientIdentifier)) {
    // Time in seconds until the rate limit resets.
    final retryAfter = options.windowSize.inSeconds;

    // If a custom response is set when the limit is exceeded, use it.
    if (options.onRateLimitExceeded != null) {
      final customResponse = await options.onRateLimitExceeded!(request);

      // Add rate limit headers to the custom response.
      return _craftResponse(
        customResponse.change(
          headers: options.headers,
        ),
        options.maxRequests,
        retryAfter,
      );
    }

    // Default response: 429 Too Many Requests, with custom headers if provided.
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

  // Calculate how many requests the client has left and the time until the limit resets.
  final now = DateTime.now();
  final requestTimes = rateLimiter._clientRequestTimes[clientIdentifier]!;
  final resetTime = options.windowSize.inSeconds -
      now.difference(requestTimes.first).inSeconds;
  final remainingRequests = options.maxRequests - requestTimes.length;

  // Continue processing the request and attach rate limiting headers to the response.
  final response = await innerHandler(request);

  return _craftResponse(
    response,
    options.maxRequests,
    resetTime,
    remainingRequests: remainingRequests,
  );
}
