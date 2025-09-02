// core/errors/failures.dart
abstract class Failures extends Error {
  final List properties;
  Failures([this.properties = const <dynamic>[]]);
}

// Example concrete failures
class ServerFailure extends Failures {}

class CacheFailure extends Failures {}

class NetworkFailure extends Failures {}
