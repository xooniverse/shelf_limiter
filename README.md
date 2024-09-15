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

`shelf_limiter` is a powerful and highly customizable middleware package for the [Shelf](https://pub.dev/packages/shelf) library in Dart that enables efficient rate limiting. Protect your API from abuse and ensure fair usage with ease.

## 🌟 Features

| **Feature**                     | **Description**  |
|---------------------------------|------------------|
| **🔧 Customizable Rate Limits** | Effortlessly set the maximum number of requests and time window to suit your needs. Define global limits or different limits for specific endpoints to control how often clients can access your API. |
| **📜 Custom Headers**           | Add and manage custom headers in your responses to enhance control and transparency. |
| **🚀 Custom Responses**         | Looking for more control? You’ve got it! Customize and send your own response when the API limit is exceeded. |
| **🔗 Easy Integration**         | Integrate seamlessly into your existing Shelf pipeline with minimal setup. Quickly apply rate limiting and focus on building the features that matter most without worrying about complex configurations. |
| **🌐 Endpoint-Specific Limits** | Set different rate limits for different endpoints. Use wildcard patterns (e.g., `/api/v1/*`) to apply rate limits to multiple routes, allowing you to protect high-traffic routes with stricter limits while allowing more leniency on less critical parts of your API. |

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

### 🔧 Basic Usage

Implement rate limiting in your Shelf application quickly and effectively. Here’s a straightforward example using the `shelfLimiter` middleware:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_limiter/shelf_limiter.dart';

void main() async {
  final limiter = shelfLimiter(
    RateLimiterOptions(
      maxRequests: 5,
      windowSize: const Duration(minutes: 1),
    ),
  );

  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request received');
```

In this example, any client is limited to 5 requests per minute. If a client exceeds this limit, they will receive a `429 Too Many Requests` response.

### 🛠️ Enhance Your API with Custom Headers

Add extra details to your responses with custom headers using `shelfLimiter`:

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
    RateLimiterOptions(
      maxRequests: 5,
      windowSize: const Duration(minutes: 1),
      headers: options.headers,
    ),
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
          'message': "Uh, hm! Wait a minute, that's a lot of requests.",
        }),
        headers: {
          'Content-Type': 'application/json',
        },
      );
    },
  );

  final limiter = shelfLimiter(
    RateLimiterOptions(
      maxRequests: 5,
      windowSize: const Duration(minutes: 1),
      headers: options.headers,
      onRateLimitExceeded: options.onRateLimitExceeded,
    ),
  );

  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request received');
```

## 📌 Advanced Usage with Endpoint-Specific Limits

When you want to fine-tune your rate limiting strategy and avoid a one-size-fits-all approach, `shelfLimiterByEndpoint` is your best friend. This middleware allows you to set unique rate limits for different endpoints, giving you the power to tailor restrictions based on the needs of each route. Think of it as customizing speed limits for different roads in your neighborhood—some streets are just busier than others!

### Example - Custom Limits for Different Routes:

Here's how you can make your API as efficient as a well-oiled machine with `shelfLimiterByEndpoint`:

```dart
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as io;
import 'package:shelf_limiter/shelf_limiter.dart';

void main() async {
  final limiter = shelfLimiterByEndpoint(
    endpointLimits: {
      '/auth': RateLimiterOptions(
        maxRequests: 5,
        windowSize: const Duration(minutes: 1),
      ),
      '/data': RateLimiterOptions(
        maxRequests: 20,
        windowSize: const Duration(minutes: 1),
      ),
      '/api/v1/*': RateLimiterOptions( // Wildcard path matching
        maxRequests: 15,
        windowSize: const Duration(minutes: 2),
      ),
    },
    defaultOptions: RateLimiterOptions(
      maxRequests: 100,
      windowSize: const Duration(minutes: 1),
    ),
  );

  final handler =
      const Pipeline().addMiddleware(limiter).addHandler(_echoRequest);

  var server = await io.serve(handler, 'localhost', 8080);
  print('Server listening on port ${server.port}');
}

Response _echoRequest(Request request) => Response.ok('Request received');
```

In this advanced example, the `/auth` endpoint has a rate limit of 5 requests per minute, the `/data` endpoint allows up to 20 requests, and all other endpoints following the `/api/v1/*` pattern are limited to 15 requests per 2 minutes. Any endpoint not explicitly listed follows the default limit of 100 requests per minute.

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