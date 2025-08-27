import 'package:equatable/equatable.dart';

abstract class Failures extends Equatable {
  final String messages;

  const Failures(this.messages);

  @override
  List<Object?> get props => [];
}

class ServerFailure extends Failures {
  const ServerFailure(String message) : super(message);

  @override
  List<Object?> get props => [messages];
}

class CacheFailure extends Failures {
  const CacheFailure(String message) : super(message);

  @override
  List<Object?> get props => [messages];
}

class NetworkFailure extends Failures {
  const NetworkFailure(String message) : super(message);

  @override
  List<Object?> get props => [messages];
}
