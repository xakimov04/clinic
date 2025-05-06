import 'package:equatable/equatable.dart';

abstract class AppException extends Equatable implements Exception {
  final String message;

  const AppException({required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

class ServerException extends AppException {
  const ServerException({required super.message});
}

class CacheException extends AppException {
  const CacheException({required super.message});
}

class AuthCancelledException extends AppException {
  const AuthCancelledException(String message) : super(message: message);
}

class NetworkException extends AppException {
  const NetworkException({super.message = 'Отсутствует подключение к сети'});
}