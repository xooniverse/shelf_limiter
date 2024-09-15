// ignore_for_file: public_member_api_docs, sort_constructors_first
part of '../../shelf_limiter.dart';

class RateLimiterOptions {
  final int maxRequests;
  final Duration windowSize;
  final String Function(Request request)? clientIdentifierExtractor;
  final FutureOr<Response> Function(Request request)? onRateLimitExceeded;
  final Map<String, String> headers;

  const RateLimiterOptions({
    required this.maxRequests,
    required this.windowSize,
    this.clientIdentifierExtractor,
    this.onRateLimitExceeded,
    this.headers = const {},
  });

  @override
  String toString() {
    return 'RateLimiterOptions(maxRequests: $maxRequests, windowSize: $windowSize, clientIdentifierExtractor: $clientIdentifierExtractor, onRateLimitExceeded: $onRateLimitExceeded, headers: $headers)';
  }
}
