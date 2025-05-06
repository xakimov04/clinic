/// Generic Either class to handle success/failure cases
abstract class Either<L, R> {
  const Either();

  /// Execute functions based on left/right value
  T fold<T>(
    T Function(L left) leftFn,
    T Function(R right) rightFn,
  );

  /// Transform right value while preserving left
  Either<L, T> map<T>(T Function(R right) fn) {
    return fold(
      (left) => Left(left),
      (right) => Right(fn(right)),
    );
  }

  /// Transform right value with function that returns Either
  Either<L, T> flatMap<T>(Either<L, T> Function(R right) fn) {
    return fold(
      (left) => Left(left),
      (right) => fn(right),
    );
  }

  /// Check if this is a left instance
  bool get isLeft;

  /// Check if this is a right instance
  bool get isRight;

  /// Get left value if present
  L? getLeftOrNull() => fold((l) => l, (r) => null);

  /// Get right value if present
  R? getRightOrNull() => fold((l) => null, (r) => r);

  /// Get right value or default
  R getRightOrElse(R Function() dflt) => fold((l) => dflt(), (r) => r);
}

/// Left (Failure) case of Either
class Left<L, R> extends Either<L, R> {
  final L value;

  const Left(this.value);

  @override
  T fold<T>(
    T Function(L left) leftFn,
    T Function(R right) rightFn,
  ) =>
      leftFn(value);

  @override
  bool get isLeft => true;

  @override
  bool get isRight => false;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Left && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Left($value)';
}

/// Right (Success) case of Either
class Right<L, R> extends Either<L, R> {
  final R value;

  const Right(this.value);

  @override
  T fold<T>(
    T Function(L left) leftFn,
    T Function(R right) rightFn,
  ) =>
      rightFn(value);

  @override
  bool get isLeft => false;

  @override
  bool get isRight => true;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Right && other.value == value;
  }

  @override
  int get hashCode => value.hashCode;

  @override
  String toString() => 'Right($value)';
}

/// Extension methods for nullable values
extension EitherNullableExtension<T> on T? {
  /// Convert nullable to Either with error message
  Either<String, T> toEither([String? error]) =>
      this == null ? Left(error ?? 'Value is null') : Right(this as T);
}

/// Helper extension for Either to get values safely
extension EitherGetters<L, R> on Either<L, R> {
  /// Get left value or throw
  L getLeft() => fold(
        (left) => left,
        (right) => throw Exception('getLeft called on Right'),
      );

  /// Get right value or throw
  R getRight() => fold(
        (left) => throw Exception('getRight called on Left'),
        (right) => right,
      );
}
