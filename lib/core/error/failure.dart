import 'package:equatable/equatable.dart';

/// Ilovadagi barcha xatoliklar uchun asosiy abstract klass
abstract class Failure extends Equatable {
  final String message;
  final String code;

  const Failure({
    required this.message,
    this.code = '',
  });

  @override
  List<Object> get props => [message, code];

  @override
  String toString() => '$runtimeType: $message (code: $code)';
}

/// 🔥 Server bilan bog‘liq xatoliklar
class ServerFailure extends Failure {
  const ServerFailure({
    super.message = 'Произошла ошибка сервера. Пожалуйста, попробуйте позже.',
    super.code = 'SERVER_ERROR',
  });
}

/// 💾 Kesh (cache) bilan bog‘liq xatoliklar
class CacheFailure extends Failure {
  const CacheFailure({
    super.message = 'Ошибка кеширования. Пожалуйста, попробуйте позже.',
    super.code = 'CACHE_ERROR',
  });
}

/// 🌐 Internet yo‘qligi yoki tarmoq xatoliklari
class NetworkFailure extends Failure {
  const NetworkFailure({
    super.message = 'Отсутствует подключение к сети',
    super.code = 'NO_INTERNET',
  });
}

/// 🔐 Login yoki token xatoliklari
class AuthFailure extends Failure {
  const AuthFailure({
    super.message = 'Ошибка авторизации. Проверьте данные и попробуйте снова.',
    super.code = 'AUTH_ERROR',
  });
}

/// ❓ Oldindan kutilmagan, noma’lum xatoliklar
class UnexpectedFailure extends Failure {
  const UnexpectedFailure({
    super.message = 'Произошла непредвиденная ошибка',
    super.code = 'UNEXPECTED_ERROR',
  });
}
