import 'package:clinic/features/client/news/domain/entities/news.dart';
import 'package:clinic/features/client/news/domain/usecases/get_news_usecase.dart';
import 'package:equatable/equatable.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
part 'news_event.dart';
part 'news_state.dart';

class NewsBloc extends Bloc<NewsEvent, NewsState> {
  final GetNewsUseCase getNewsUseCase;

  NewsBloc({required this.getNewsUseCase}) : super(NewsInitial()) {
    on<GetNewsEvent>(_onGetNews);
  }

  Future<void> _onGetNews(GetNewsEvent event, Emitter<NewsState> emit) async {
    emit(NewsLoading());

    final result = await getNewsUseCase();

    result.fold(
      (failure) => emit(NewsError(failure.message)),
      (news) => emit(NewsLoaded(news)),
    );
  }
}
