import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/news/data/datasources/news_remote_data_source.dart';
import 'package:clinic/features/client/news/domain/entities/news.dart';
import 'package:clinic/features/client/news/domain/repositories/news_repository.dart';

class NewsRepositoryImpl implements NewsRepository {
  final NewsRemoteDataSource remoteDataSource;

  NewsRepositoryImpl({required this.remoteDataSource});

  @override
  Future<Either<Failure, List<News>>> getNews() async {
    try {
      final result = await remoteDataSource.getNews();
      return result;
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
