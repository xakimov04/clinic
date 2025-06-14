import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/news/data/models/news_model.dart';

abstract class NewsRemoteDataSource {
  Future<Either<Failure, List<NewsModel>>> getNews();
}

class NewsRemoteDataSourceImpl implements NewsRemoteDataSource {
  final NetworkManager networkManager;
  NewsRemoteDataSourceImpl({required this.networkManager});

  @override
  Future<Either<Failure, List<NewsModel>>> getNews() async {
    try {
      final response = await networkManager.fetchData(url: '/banners');

      final List<dynamic> jsonList = response is List ? response : [response];
      final news = jsonList.map((json) => NewsModel.fromJson(json)).toList();
      return Right(news);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}
