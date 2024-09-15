/// # Shelf Limiter
///
/// A powerful and highly customizable rate limiter for the [Shelf](https://pub.dev/packages/shelf) library, designed to help you control request rates and prevent abuse on your Dart server.
///
/// `shelf_limiter` offers middleware to manage how frequently clients can make requests, allowing you to define and enforce rate limits across your API. Whether you're building a public API, protecting resources from overuse, or ensuring fair distribution of server resources, `shelf_limiter` is built to handle it seamlessly.
///
/// ## Features:
/// - Set a rate limit for your entire API or different limits for specific endpoints.
/// - Customize how clients are identified (by IP address, API token, or custom logic).
/// - Add custom responses when clients exceed the rate limit.
/// - Easily attach headers to responses indicating rate limit status (remaining requests, reset time).
///
/// ## Installation:
/// Add `shelf_limiter` to your `pubspec.yaml`:
///
/// ```yaml
/// dependencies:
///   shelf_limiter: ^1.0.0
/// ```
///
/// Import the package:
/// ```dart
/// import 'package:shelf_limiter/shelf_limiter.dart';
/// ```
///
/// ## Middleware Options:
///
/// ### 1. `shelfLimiter`
///
/// `shelfLimiter` applies a global rate limit across all incoming requests. It's a simple middleware for enforcing a single rate limit across your API.
///
/// #### Example Usage:
///
/// ```dart
/// final limiterMiddleware = shelfLimiter(
///   RateLimiterOptions(
///     maxRequests: 10,
///     windowSize: Duration(minutes: 1),
///   ),
/// );
///
/// final handler = const Pipeline()
///   .addMiddleware(limiterMiddleware)
///   .addHandler(yourHandler);
/// ```
///
/// In this example, any client is limited to 10 requests per minute. If a client exceeds this limit, they will receive a `429 Too Many Requests` response.
///
/// ### 2. `shelfLimiterByEndpoint`
///
/// `shelfLimiterByEndpoint` allows you to define different rate limits for different endpoints. This is useful if you want tighter restrictions on certain routes, like authentication or resource-heavy operations, while keeping more lenient limits on less critical parts of your API.
///
/// #### Example Usage:
///
/// ```dart
/// final limiterMiddleware = shelfLimiterByEndpoint(
///   endpointLimits: {
///     '/auth': RateLimiterOptions(
///       maxRequests: 5,
///       windowSize: Duration(minutes: 1),
///     ),
///     '/data': RateLimiterOptions(
///       maxRequests: 20,
///       windowSize: Duration(minutes: 1),
///     ),
///   },
///   defaultOptions: RateLimiterOptions(
///     maxRequests: 100,
///     windowSize: Duration(minutes: 1),
///   ),
/// );
///
/// final handler = const Pipeline()
///   .addMiddleware(limiterMiddleware)
///   .addHandler(yourHandler);
/// ```
///
/// In this example, the `/auth` route has a rate limit of 5 requests per minute, while the `/data` route allows up to 20 requests. Any other endpoints follow the default limit of 100 requests per minute.
///
/// ## Customization:
///
/// Both middlewares are highly customizable:
/// - **Client Identification**: By default, clients are identified by their IP address, but you can customize this with your own logic (e.g., based on API tokens).
/// - **Custom Response**: You can define a custom response that is returned when a client exceeds the rate limit, including headers or a more user-friendly message.
/// - **Rate Limit Headers**: The middlewares automatically add headers to indicate the remaining requests and the reset time, giving clients clear feedback about their rate limit status.
///
/// ## Source Code and Contributions:
/// If you want to dive deeper into the code or contribute, check out the project on GitHub:
///
/// <a href="https://github.com/xooniverse/shelf_limiter">
///   <img src="https://img.shields.io/badge/GitHub%20Repository-100000?style=for-the-badge&logo=github&logoColor=white"/>
/// </a>
///
/// Contributions are welcome! Feel free to open issues or submit pull requests.
library;

import 'dart:async';
import 'dart:collection';
import 'package:shelf/shelf.dart';

part 'src/shelf_limiter_default.dart';
part 'src/shelf_limiter_by_endpoint.dart';
part 'src/classes/rate_limiter.dart';
part 'src/classes/options.dart';
part 'src/methods/response_crafter.dart';
part 'src/methods/handle_limiting.dart';
part 'src/methods/path_matcher.dart';
part 'src/utils/utils.dart';
