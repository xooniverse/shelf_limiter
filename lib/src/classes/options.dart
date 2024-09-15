part of '../../shelf_limiter.dart';

/// Configuration options for the rate limiter middleware.
///
/// This class allows you to customize the rate limiting behavior, including
/// the maximum number of requests allowed, the time window for rate limiting,
/// and how to handle exceeded rate limits.
class RateLimiterOptions {
  /// The maximum number of requests a client can make within the [windowSize].
  ///
  /// If the client exceeds this limit, further requests will be blocked
  /// until the window resets.
  final int maxRequests;

  /// The duration in which the client can make [maxRequests] requests.
  ///
  /// Once this window expires, the request count for the client will reset.
  final Duration windowSize;

  /// A function that extracts a unique identifier for the client, typically
  /// based on the request. By default, it uses the client's IP address.
  ///
  /// You can provide a custom function to extract a different identifier,
  /// such as an API key or a user ID from the request.
  final String Function(Request request)? clientIdentifierExtractor;

  /// A callback function that is triggered when a client exceeds the rate limit.
  ///
  /// This function allows you to customize the response sent when a client
  /// exceeds the rate limit. If this is not provided, a default 429 "Too many
  /// requests" response will be used.
  final FutureOr<Response> Function(Request request)? onRateLimitExceeded;

  /// Custom headers to include in the response when a rate limit is exceeded.
  ///
  /// These headers can be used to provide additional information, such as
  /// rate limit reset times or remaining requests. Defaults to an empty map.
  final Map<String, String> headers;

  /// Constructs a set of options for the rate limiter middleware.
  ///
  /// - [maxRequests]: The maximum number of requests allowed in the [windowSize].
  /// - [windowSize]: The time duration for the rate limit window.
  /// - [clientIdentifierExtractor]: Optional function to extract a client identifier from the request.
  /// - [onRateLimitExceeded]: Optional function to provide a custom response when the rate limit is exceeded.
  /// - [headers]: Optional custom headers to include in the rate limit response.
  const RateLimiterOptions({
    required this.maxRequests,
    required this.windowSize,
    this.clientIdentifierExtractor,
    this.onRateLimitExceeded,
    this.headers = const {},
  });

  /// Returns a string representation of the rate limiter options.
  ///
  /// Useful for logging and debugging purposes.
  @override
  String toString() {
    return 'RateLimiterOptions(maxRequests: $maxRequests, windowSize: $windowSize, clientIdentifierExtractor: $clientIdentifierExtractor, onRateLimitExceeded: $onRateLimitExceeded, headers: $headers)';
  }
}
