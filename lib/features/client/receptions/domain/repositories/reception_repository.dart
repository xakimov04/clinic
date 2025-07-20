import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_info_entity.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_list_entity.dart';

import '../entities/reception_client_entity.dart';

abstract class ReceptionRepository {
  Future<Either<Failure,List<ReceptionClientEntity>>> getReceptionsClient();
  Future<Either<Failure,List<ReceptionListEntity>>> getReceptionsList(String id);
  Future<Either<Failure,List<ReceptionInfoEntity>>> getReceptionsInfo(String id);
}
