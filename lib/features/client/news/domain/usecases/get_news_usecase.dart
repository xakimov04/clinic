import 'package:clinic/core/error/either.dart';
import 'package:clinic/core/error/failure.dart';
import 'package:clinic/features/client/news/domain/entities/news.dart';
import 'package:clinic/features/client/news/domain/repositories/news_repository.dart';

class GetNewsUseCase {
  final NewsRepository repository;

  GetNewsUseCase(this.repository);

  Future<Either<Failure, List<News>>> call() async {
    return await repository.getNews();
  }
}
