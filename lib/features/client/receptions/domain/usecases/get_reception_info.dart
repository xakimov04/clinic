import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_info_entity.dart';
import '../repositories/reception_repository.dart';

class GetReceptionInfo
    implements UseCase<List<ReceptionInfoEntity>, String> {
  final ReceptionRepository repository;

  GetReceptionInfo(this.repository);

  @override
  Future<Either<Failure, List<ReceptionInfoEntity>>> call(
      String id) async {
    return await repository.getReceptionsInfo(id);
  }
}
