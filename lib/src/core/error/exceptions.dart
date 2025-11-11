import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  final String message;
  final StackTrace? stackTrace;

  const AppException(this.message, [this.stackTrace]);

  @override
  List<Object?> get props => [message, stackTrace];

  @override
  String toString() => message;
}

class ServerException extends AppException {
  const ServerException(String message, [StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class CacheException extends AppException {
  const CacheException(String message, [StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class NetworkException extends AppException {
  const NetworkException(String message, [StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class UnauthenticatedException extends AppException {
  const UnauthenticatedException([String message = 'No autenticado', StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class AuthException extends AppException {
  const AuthException(String message, [StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class ValidationException extends AppException {
  final Map<String, List<String>>? errors;
  
  const ValidationException(
    String message, {
    this.errors,
    StackTrace? stackTrace,
  }) : super(message, stackTrace);
  
  @override
  List<Object?> get props => [message, errors, stackTrace];
}

class NotFoundException extends AppException {
  const NotFoundException(String message, [StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class PermissionDeniedException extends AppException {
  const PermissionDeniedException(String message, [StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class TimeoutException extends AppException {
  const TimeoutException(String message, [StackTrace? stackTrace]) 
      : super(message, stackTrace);
}

class UnsupportedOperationException extends AppException {
  const UnsupportedOperationException(String message, [StackTrace? stackTrace]) 
      : super(message, stackTrace);
}
