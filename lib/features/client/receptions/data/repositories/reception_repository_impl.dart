import 'package:clinic/core/error/either.dart';

import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/receptions/data/datasources/reception_remote_data_source.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_info_entity.dart';
import 'package:clinic/features/client/receptions/domain/entities/reception_list_entity.dart';
import 'package:dio/dio.dart';

import '../../domain/entities/reception_client_entity.dart';
import '../../domain/repositories/reception_repository.dart';

class ReceptionRepositoryImpl implements ReceptionRepository {
  final ReceptionRemoteDataSource receptionRemoteDataSource;
  ReceptionRepositoryImpl(this.receptionRemoteDataSource);

  @override
  Future<Either<Failure, List<ReceptionClientEntity>>>
      getReceptionsClient() async {
    try {
      final result = await receptionRemoteDataSource.getReceptionsClient();
      return Right(result);
    } on DioException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReceptionListEntity>>> getReceptionsList(
      String id) async {
    try {
      final result = await receptionRemoteDataSource.getReceptionsList(id);
      return Right(result);
    } on DioException {
      return Left(ServerFailure());
    } catch (e) {
      return Left(UnexpectedFailure());
    }
  }

  @override
  Future<Either<Failure, List<ReceptionInfoEntity>>> getReceptionsInfo(
      String id) async {
    try {
      final result = await receptionRemoteDataSource.getReceptionsInfo(id);
      return Right(result);
    } on DioException {
      return Left(ServerFailure());
    } catch (e) {
      print(e);
      return Left(UnexpectedFailure());
    }
  }
}
