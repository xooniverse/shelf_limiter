<div align="center">

# `shelf_limiter`

![Dart](https://img.shields.io/badge/Dart-0175C2?logo=dart&logoColor=white)
![Pub Version](https://img.shields.io/pub/v/shelf_limiter)
![License](https://img.shields.io/github/license/xooniverse/shelf_limiter)

<a href="https://github.com/xooniverse/shelf_limiter/">
  <img src="https://img.shields.io/badge/Shoot%20A%20Star%20/%20GitHub%20Repo-100000?style=for-the-badge&logo=github&logoColor=white"/>
</a>

</div>

--- 

`shelf_limiter` is a powerful and highly customizable middleware package for the [shelf](https://pub.dev/packages/shelf) library in Dart that enables efficient rate limiting. Protect your API from abuse and ensure fair usage with ease.

## 🌟 Features

- **🔧 Customizable Rate Limits**: Effortlessly set the maximum number of requests and time window to suit your needs.
- **📜 Custom Headers**: Add and manage custom headers in your responses to enhance control and transparency.
- **🚀 Custom Responses**: Craft personalized responses when the rate limit is exceeded, improving user feedback.
- **🔗 Easy Integration**: Integrate seamlessly into your existing Shelf pipeline with minimal setup, so you can focus on building features.

## Installation

Add `shelf_limiter` to your `pubspec.yaml` file:

```yaml
dependencies:
  shelf_limiter: ^1.0.0
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

### 🔧 Basic Usage

Implement rate limiting in your Shelf application quickly and effectively. Here’s a straightforward example:

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

### 🛠️ Enhance Your API with Custom Headers

Add extra details to your responses with custom headers. Here’s how:

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

### 💡 Customize Rate Limit Exceeded Responses

Provide meaningful feedback by customizing the response when the rate limit is exceeded:

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

## ⚙️ Configuration

### Rate Limiter Options

- **`maxRequests`**: Maximum number of requests allowed within the specified window size.
- **`windowSize`**: Duration of the time window for rate limiting.
- **`headers`**: Custom headers to include in responses.
- **`onRateLimitExceeded`**: Callback function to define custom behavior when the rate limit is exceeded.

## 🧑🏻‍💻 Contributing

We welcome contributions! Check out our [GitHub repository](https://github.com/xooniverse/shelf_limiter) to get started. Feel free to open issues, submit pull requests, or ask questions.

## ❤️ Support Us

If `shelf_limiter` has been useful to you, consider supporting further development:

- [Buy Me a Coffee](https://buymeacoffee.com/heysreelal) ☕
- [PayPal](https://paypal.me/sreelalts) 💸

# Thank you!