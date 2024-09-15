import 'dart:convert';

import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_limiter/shelf_limiter.dart';

void main() async {
  // Define rate limiter options for specific endpoints with wildcard support
  final endpointLimits = {
    '/auth/*': RateLimiterOptions(
      maxRequests: 3,
      windowSize: const Duration(minutes: 1),
      headers: {'X-Custom-Header': 'Auth Rate Limited'},
      onRateLimitExceeded: (request) async {
        return Response(
          429,
          body: jsonEncode({
            'status': false,
            'message': 'Rate limit exceeded for authentication endpoint',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      },
    ),
    '/data/*/shit': RateLimiterOptions(
      maxRequests: 10,
      windowSize: const Duration(minutes: 1),
      headers: {'X-Custom-Header': 'Data Rate Limited'},
      onRateLimitExceeded: (request) async {
        return Response(
          429,
          body: jsonEncode({
            'status': false,
            'message': 'Rate limit exceeded for data endpoint',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      },
    ),
    '/': RateLimiterOptions(
      maxRequests: 20,
      windowSize: const Duration(minutes: 1),
      headers: {'X-Custom-Header': 'Global Rate Limited'},
      onRateLimitExceeded: (request) async {
        return Response(
          429,
          body: jsonEncode({
            'status': false,
            'message': 'Rate limit exceeded for global endpoint',
          }),
          headers: {'Content-Type': 'application/json'},
        );
      },
    ),
  };

  // Create the rate limiter middleware with endpoint-specific options
  final limiter = shelfLimiterByEndpoint(
    endpointLimits: endpointLimits,
  );

  // Add the rate limiter to the pipeline and define a handler for incoming requests
  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  // Start the server on localhost and listen for incoming requests on port 8080
  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

// Basic request handler that responds with 'Request received'
Response _echoRequest(Request request) {
  return Response.ok('Request received for ${request.url.path}');
}
