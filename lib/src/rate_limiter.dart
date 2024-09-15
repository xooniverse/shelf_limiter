part of '../shelf_limiter.dart';

/// A simple rate limiter that tracks and enforces request limits for clients.
///
/// This class helps in limiting the number of requests that a client can make
/// within a specific time window (rate limit duration). It stores timestamps of
/// each client's request and checks whether the client has exceeded the allowed
/// number of requests within the specified window.
///
/// Each client is identified by a unique string (e.g., IP address, token).
///
/// Usage:
/// ```dart
/// final rateLimiter = _RateLimiter(
///   maxRequests: 10,
///   rateLimitDuration: Duration(minutes: 1),
/// );
///
/// bool isAllowed = rateLimiter.isAllowed(clientIdentifier);
/// if (isAllowed) {
///   // Proceed with request
/// } else {
///   // Reject request due to rate limiting
/// }
/// ```
class _RateLimiter {
  /// The maximum number of requests allowed within the [rateLimitDuration].
  final int maxRequests;

  /// The time window within which [maxRequests] are allowed. Requests
  /// exceeding this limit within the duration will be blocked.
  final Duration rateLimitDuration;

  /// A map that tracks the request timestamps for each client.
  ///
  /// The key is the client's identifier (e.g., IP address), and the value is a
  /// queue of [DateTime] objects representing the times at which the client made requests.
  final Map<String, Queue<DateTime>> _clientRequestTimes = {};

  /// Creates a [_RateLimiter] instance with the specified [maxRequests] and
  /// [rateLimitDuration].
  ///
  /// - [maxRequests]: The maximum number of requests a client can make within
  ///   the rate limit window.
  /// - [rateLimitDuration]: The duration in which the [maxRequests] limit applies.
  _RateLimiter({
    required this.maxRequests,
    required this.rateLimitDuration,
  });

  /// Checks whether a client identified by [clientIdentifier] is allowed to
  /// make a request based on the rate limits.
  ///
  /// - [clientIdentifier]: A unique identifier for the client (e.g., IP address).
  /// - Returns `true` if the client is allowed to make a request, or `false`
  ///   if they have exceeded the rate limit.
  bool isAllowed(String clientIdentifier) {
    var now = DateTime.now();

    // Initialize the request queue for this client if it doesn't exist.
    _clientRequestTimes.putIfAbsent(clientIdentifier, () => Queue<DateTime>());

    var requestTimes = _clientRequestTimes[clientIdentifier]!;

    // Remove requests that fall outside the rate limit window.
    while (requestTimes.isNotEmpty &&
        now.difference(requestTimes.first) > rateLimitDuration) {
      requestTimes.removeFirst();
    }

    // If the client has already made the maximum number of requests in the
    // time window, deny the request.
    if (requestTimes.length >= maxRequests) {
      return false;
    }

    // Otherwise, add the current request time to the queue and allow the request.
    requestTimes.addLast(now);
    return true;
  }
}
