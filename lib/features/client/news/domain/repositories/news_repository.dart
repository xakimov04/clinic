import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/news/domain/entities/news.dart';

abstract class NewsRepository {
  Future<Either<Failure, List<News>>> getNews();
}
