import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_limiter/shelf_limiter.dart';

void main() async {
  // Additional customization (optional)
  // Here we define custom headers and a custom response message for when the rate limit is exceeded
  final options = RateLimiterOptions(
    headers: {
      'X-Custom-Header': 'Rate limited', // Custom header to add to responses
    },
    onRateLimitExceeded: (Request request) async {
      // Custom message to return when the client exceeds the rate limit
      // Customize it as much as you want :)
      return Response(
        429,
        body: jsonEncode({
          "status": false,
          "message": "Uh, hm! Wait a minute, that's a lot of request.",
        }),
        headers: {
          "Content-Type": "application/json",
        },
      );
    },
  );

  // Create the rate limiter middleware with a max of 5 requests per 1 minute window
  final limiter = shelfLimiter(
    maxRequests: 5,
    windowSize: Duration(minutes: 1),
    options: options, // Apply custom options
  );

  // Add the rate limiter to the pipeline and define a handler for incoming requests
  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  // Start the server on localhost and listen for incoming requests on port 8080
  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

// Basic request handler that responds with 'Request received'
Response _echoRequest(Request request) => Response.ok('Request received');
