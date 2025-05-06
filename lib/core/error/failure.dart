import 'package:equatable/equatable.dart';

/// Базовый класс для всех ошибок в приложении
abstract class Failure extends Equatable {
  final String message;

  const Failure({required this.message});

  @override
  List<Object> get props => [message];

  @override
  String toString() => '$runtimeType: $message';
}

/// Ошибка сервера
class ServerFailure extends Failure {
  const ServerFailure({required super.message});
}

/// Ошибка кеширования
class CacheFailure extends Failure {
  const CacheFailure({required super.message});
}

/// Ошибка сети
class NetworkFailure extends Failure {
  const NetworkFailure({super.message = 'Отсутствует подключение к сети'});
}

/// Ошибка авторизации
class AuthFailure extends Failure {
  const AuthFailure({required super.message});
}

/// Непредвиденная ошибка
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({super.message = 'Произошла непредвиденная ошибка'});
}
