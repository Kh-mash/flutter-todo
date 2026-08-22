import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_todo/core/error/failures.dart';

void main() {
  group('Failure hierarchy', () {
    test('CacheFailure is equatable with same message', () {
      expect(const CacheFailure('msg'), const CacheFailure('msg'));
    });

    test('CacheFailure uses default message when omitted', () {
      expect(const CacheFailure(), isNotNull);
    });

    test('Different subtypes are not equal', () {
      expect(const CacheFailure('x') == const ValidationFailure('x'), isFalse);
    });

    test('Failure is sealed - subtypes are exhaustive', () {
      const CacheFailure cache = CacheFailure();
      const ValidationFailure validation = ValidationFailure('msg');
      const NotFoundFailure notFound = NotFoundFailure();

      expect(cache, isA<Failure>());
      expect(validation, isA<Failure>());
      expect(notFound, isA<Failure>());
    });
  });
}
