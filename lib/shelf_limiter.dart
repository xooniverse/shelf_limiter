///  # Shelf Limiter
///
///  A powerful and highly customizable rate limiter for shelf library, allowing you to easily manage and control request rates in your Dart server.
///
/// `shelf_limiter` is a middleware package for the [Shelf](https://pub.dev/packages/shelf)
/// library in Dart that provides rate limiting capabilities. It allows you to restrict
/// the number of requests a client can make to your server within a specified time window,
/// making it useful for preventing abuse and ensuring fair usage of your API.
///
/// This package offers several customization options to suit your needs, including custom
/// headers and responses. It integrates seamlessly into your existing Shelf pipeline.
///
/// ## Example
///
/// ```dart
/// import 'dart:convert';
/// import 'package:shelf/shelf.dart';
/// import 'package:shelf/shelf_io.dart' as io;
/// import 'package:shelf_limiter/shelf_limiter.dart';
///
/// void main() async {
///   final options = RateLimiterOptions(
///     headers: {
///       'X-Custom-Header': 'Rate limited',
///     },
///     onRateLimitExceeded: (request) async {
///       return Response(
///         429,
///         body: jsonEncode({
///           'status': false,
///           'message': "Uh, hm! Wait a minute, that's a lot of request.",
///         }),
///         headers: {
///           'Content-Type': 'application/json',
///         },
///       );
///     },
///   );
///
///   final limiter = shelfLimiter(
///     maxRequests: 5,
///     windowSize: const Duration(minutes: 1),
///     options: options,
///   );
///
///   final handler =
///       const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);
///
///   var server = await io.serve(handler, 'localhost', 8080);
///   print('Server listening on port ${server.port}');
/// }
///
/// Response _echoRequest(Request request) => Response.ok('Request received');
/// ```
library;

import 'dart:async';
import 'dart:collection';
import 'package:shelf/shelf.dart';

part 'src/shelf_limiter_base.dart';
part 'src/rate_limiter.dart';
part 'src/options.dart';
