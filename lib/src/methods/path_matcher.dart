part of '../../shelf_limiter.dart';

bool _pathMatchesPattern(String path, String pattern) {
  final patternSegments = pattern.split('/');
  final pathSegments = path.split('/');

  if (patternSegments.length != pathSegments.length) {
    return false;
  }

  for (var i = 0; i < patternSegments.length; i++) {
    if (patternSegments[i] != '*' && patternSegments[i] != pathSegments[i]) {
      return false;
    }
  }

  return true;
}
