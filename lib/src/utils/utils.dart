part of '../../shelf_limiter.dart';

extension _FirstWhereOrNull<K> on Iterable<K> {
  K? firstWhereOrNull(bool Function(K) test) {
    try {
      for (K element in this) {
        if (test(element)) {
          return element;
        }
      }
      return null;
    } catch (_) {
      return null;
    }
  }
}
