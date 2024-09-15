# `shelf_limiter`

![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Pub Version](https://img.shields.io/pub/v/shelf_limiter)
![License](https://img.shields.io/github/license/xooniverse/shelf_limiter)

`shelf_limiter` is a middleware package for the [Shelf](https://pub.dev/packages/shelf) library in Dart that provides rate limiting capabilities. This allows you to restrict the number of requests a client can make to your server within a specified time window. It’s useful for preventing abuse and ensuring fair usage of your API.

## 🌟 Features

- **🔧 Customizable Rate Limits**: Effortlessly set the maximum number of requests and time window to fit your needs.
- **📜 Custom Headers**: Add and manage custom headers in your responses for enhanced control.
- **🚀 Custom Responses**: Craft personalized responses when the rate limit is exceeded, making error handling more user-friendly.
- **🔗 Easy Integration**: Seamlessly integrate into your existing Shelf pipeline with minimal setup, so you can focus on building features. 

## Installation

Add `shelf_limiter` to your `pubspec.yaml` file: 

```yaml
dependencies:
  shelf_limiter: <latest>
```

Then run:

```sh
dart pub get
```

Or simply run:

```sh
dart pub add shelf_limiter
```

## Usage

### Basic Usage

Implementing rate limiting in your Shelf application has never been easier. With shelf_limiter, you can quickly add rate limiting to protect your API from abuse and ensure fair usage. Here’s a straightforward example to get you started:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_limiter/shelf_limiter.dart';

void main() async {
  final limiter = shelfLimiter(
    maxRequests: 5,
    windowSize: const Duration(minutes: 1),
  );

  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request received');
```

### Enhance Your API with Custom Headers

Want to include additional information in your responses? Customize your headers with ease. Here’s how you can add a custom header to indicate rate limitin

```dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_limiter/shelf_limiter.dart';

void main() async {
  final options = RateLimiterOptions(
    headers: {
      'X-Custom-Header': 'Rate limited',
    },
  );

  final limiter = shelfLimiter(
    maxRequests: 5,
    windowSize: const Duration(minutes: 1),
    options: options,
  );

  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request received');
```

### Customize Your Rate Limit Exceeded Responses

Take control of the response when the rate limit is exceeded. Provide your users with meaningful feedback by customizing the response body and headers:

```dart
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_limiter/shelf_limiter.dart';

void main() async {
  final options = RateLimiterOptions(
    headers: {
      'X-Custom-Header': 'Rate limited',
    },
    onRateLimitExceeded: (request) async {
      return Response(
        429,
        body: jsonEncode({
          'status': false,
          'message': "Uh, hm! Wait a minute, that's a lot of request.",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    },
  );

  final limiter = shelfLimiter(
    maxRequests: 5,
    windowSize: const Duration(minutes: 1),
    options: options,
  );

  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request received');
```

## Configuration

### Rate Limiter Options

- **`maxRequests`**: The maximum number of requests allowed in the specified window size.
- **`windowSize`**: The duration of the time window for rate limiting.
- **`headers`**: Custom headers to include in responses.
- **`onRateLimitExceeded`**: A callback function to define custom behavior when the rate limit is exceeded.

## Contributing

Contributions are welcome! Please check out our [GitHub repository](https://github.com/xooniverse/shelf_limiter) to get started. Open issues, submit pull requests, or simply raise a question.

## Support Us

If you find `shelf_limiter` useful, consider supporting further development:

- [Buy Me a Coffee](https://buymeacoffee.com/heysreelal)
- [PayPal](https://paypal.me/sreelalts)

## License

This project is licensed under the MIT License. See the [LICENSE](https://github.com/xooniverse/shelf_limiter/blob/main/LICENSE) file for details.
