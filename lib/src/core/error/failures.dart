import 'package:equatable/equatable.dart';

abstract class Failure extends Equatable {
  final String message;
  final StackTrace? stackTrace;

  const Failure(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => 'Failure(message: $message, stackTrace: $stackTrace)';
}

class ServerFailure extends Failure {
  const ServerFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class CacheFailure extends Failure {
  const CacheFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class NetworkFailure extends Failure {
  const NetworkFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class AuthenticationFailure extends Failure {
  const AuthenticationFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class PermissionFailure extends Failure {
  const PermissionFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class ValidationFailure extends Failure {
  final Map<String, List<String>>? errors;

  const ValidationFailure(
    String message, {
    this.errors,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);

  @override
  List<Object?> get props => [message, errors, stackTrace];

  @override
  String toString() =>
      'ValidationFailure(message: $message, errors: $errors, stackTrace: $stackTrace)';
}

class NotFoundFailure extends Failure {
  const NotFoundFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class AlreadyExistsFailure extends Failure {
  const AlreadyExistsFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class UnauthorizedFailure extends Failure {
  const UnauthorizedFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class ForbiddenFailure extends Failure {
  const ForbiddenFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class TimeoutFailure extends Failure {
  const TimeoutFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class NoInternetFailure extends Failure {
  const NoInternetFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class UnknownFailure extends Failure {
  const UnknownFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}

class NotInitializedFailure extends Failure {
  const NotInitializedFailure(String message, [StackTrace? stackTrace])
      : super(message, stackTrace);
}
