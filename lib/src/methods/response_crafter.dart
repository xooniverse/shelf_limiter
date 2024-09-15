part of '../../shelf_limiter.dart';

/// Adds rate limit related headers to the response.
///
/// [response] is the original response object.
/// [maxRequests] is the maximum number of requests allowed in the window.
/// [retryAfter] is the number of seconds after which the client can retry.
/// [remainingRequests] is the number of requests remaining in the current window.
Response _craftResponse(
  Response response,
  int maxRequests,
  int retryAfter, {
  int? remainingRequests,
}) {
  final responseHeaders = {
    ...response.headers,
    'Retry-After': retryAfter.toString(),
    'X-RateLimit-Limit': maxRequests.toString(),
    'X-RateLimit-Remaining': remainingRequests?.toString() ?? '0',
    'X-RateLimit-Reset': retryAfter.toString(),
  };
  return response.change(headers: responseHeaders);
}
