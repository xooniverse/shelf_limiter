import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_limiter/shelf_limiter.dart';

void main() async {
  // Define custom rate limiter options
  final options = RateLimiterOptions(
    maxRequests: 5, // Maximum number of requests allowed
    windowSize: const Duration(minutes: 1), // Duration of the rate limit window
    headers: {
      'X-Custom-Header': 'Rate limited', // Custom header to add to responses
    },
    onRateLimitExceeded: (request) async {
      // Custom response when the rate limit is exceeded
      return Response(
        429,
        body: jsonEncode({
          'status': false,
          'message': "Uh, hm! Wait a minute, that's a lot of requests.",
        }),
        headers: {
          'Content-Type': 'application/json',
          'X-Custom-Response-Header': 'CustomValue', // Additional custom header
        },
      );
    },
  );

  // Create the rate limiter middleware with the custom options
  final limiter = shelfLimiter(options);

  // Add the rate limiter to the pipeline and define a handler for incoming requests
  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  // Start the server on localhost and listen for incoming requests on port 8080
  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

// Basic request handler that responds with 'Request received'
Response _echoRequest(Request request) => Response.ok('Request received');
