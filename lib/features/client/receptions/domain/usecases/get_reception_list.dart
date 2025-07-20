import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/core/usecase/usecase.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_list_entity.dart';
import '../repositories/reception_repository.dart';

class GetReceptionList
    implements UseCase<List<ReceptionListEntity>, String> {
  final ReceptionRepository repository;

  GetReceptionList(this.repository);

  @override
  Future<Either<Failure, List<ReceptionListEntity>>> call(
      String id) async {
    return await repository.getReceptionsList(id);
  }
}
