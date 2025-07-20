import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';

import '../entities/reception_client_entity.dart';
import '../repositories/reception_repository.dart';

class GetReceptionClient
    implements UseCase<List<ReceptionClientEntity>, NoParams> {
  final ReceptionRepository repository;

  GetReceptionClient(this.repository);

  @override
  Future<Either<Failure, List<ReceptionClientEntity>>> call(
      NoParams params) async {
    return await repository.getReceptionsClient();
  }
}
