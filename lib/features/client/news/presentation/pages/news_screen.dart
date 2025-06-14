import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/features/client/news/domain/entities/news.dart';
import 'package:clinic/features/client/news/presentation/bloc/news_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Новости',
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 18,
          ),
        ),
        backgroundColor: ColorConstants.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: ColorConstants.backgroundColor,
      body: BlocBuilder<NewsBloc, NewsState>(
        builder: (context, state) {
          if (state is NewsLoading) {
            return const Center(
              child: CupertinoActivityIndicator(),
            );
          }

          if (state is NewsError) {
            return _buildErrorWidget(context, state.message);
          }

          if (state is NewsLoaded) {
            if (state.news.isEmpty) {
              return _buildEmptyWidget();
            }

            return RefreshIndicator(
              onRefresh: () => _refreshNews(context),
              color: ColorConstants.primaryColor,
              child: _buildNewsList(state.news),
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: 24.a,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            16.h,
            Text(
              'Произошла ошибка',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.red.shade600,
              ),
            ),
            8.h,
            Text(
              message,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey.shade600,
                height: 1.4,
              ),
            ),
            24.h,
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _refreshNews(context),
                icon: const Icon(Icons.refresh),
                label: const Text('Повторить попытку'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  padding: 16.v,
                  shape: RoundedRectangleBorder(
                    borderRadius: 12.circular,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.article_outlined,
            size: 64,
            color: Colors.grey.shade400,
          ),
          16.h,
          Text(
            'Новости отсутствуют',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          8.h,
          Text(
            'На данный момент нет доступных новостей',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNewsList(List<News> newsList) {
    return ListView.builder(
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: newsList.length,
      itemBuilder: (context, index) {
        final news = newsList[index];
        return _buildNewsCard(news, context);
      },
    );
  }

  Widget _buildNewsCard(News news, BuildContext context) {
    return Container(
      margin: 8.v,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: 16.circular,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _showNewsDetails(news, context),
          borderRadius: 16.circular,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Image section
              ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
                child: CachedNetworkImage(
                  imageUrl: news.file,
                  width: double.infinity,
                  height: 200,
                  fit: BoxFit.cover,
                  placeholder: (context, url) => Container(
                    color: ColorConstants.primaryColor.withOpacity(0.1),
                    child: Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          ColorConstants.primaryColor,
                        ),
                      ),
                    ),
                  ),
                  errorWidget: (context, url, error) => Container(
                    color: ColorConstants.primaryColor.withOpacity(0.1),
                    child: const Center(
                      child: Icon(
                        Icons.image_not_supported_outlined,
                        size: 48,
                        color: ColorConstants.primaryColor,
                      ),
                    ),
                  ),
                ),
              ),

              // Content section
              Padding(
                padding: 16.a,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      news.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                        color: Colors.black87,
                      ),
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    8.h,
                    Text(
                      news.description,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey.shade600,
                        height: 1.5,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                    12.h,
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Читать далее',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorConstants.primaryColor,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        Icon(
                          Icons.arrow_forward_ios,
                          size: 14,
                          color: ColorConstants.primaryColor,
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _refreshNews(BuildContext context) async {
    context.read<NewsBloc>().add(GetNewsEvent());
  }

  void _showNewsDetails(News news, BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      enableDrag: true,
      builder: (context) => _buildNewsDetailsModal(news),
    );
  }

  Widget _buildNewsDetailsModal(News news) {
    return DraggableScrollableSheet(
      initialChildSize: 0.9,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      expand: false,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(20),
            ),
          ),
          child: Column(
            children: [
              // Handle indicator
              Container(
                width: 40,
                height: 4,
                margin: 12.v,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: 2.circular,
                ),
              ),

              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Image
                      ClipRRect(
                        borderRadius: BorderRadius.zero,
                        child: CachedNetworkImage(
                          imageUrl: news.file,
                          width: double.infinity,
                          height: 250,
                          fit: BoxFit.cover,
                          placeholder: (context, url) => Container(
                            color: ColorConstants.primaryColor.withOpacity(0.1),
                            child: const Center(
                              child: CircularProgressIndicator(),
                            ),
                          ),
                          errorWidget: (context, url, error) => Container(
                            color: ColorConstants.primaryColor.withOpacity(0.1),
                            child: const Center(
                              child: Icon(
                                Icons.image_not_supported_outlined,
                                size: 64,
                                color: ColorConstants.primaryColor,
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Content
                      Padding(
                        padding: 20.a,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              news.name,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                                height: 1.3,
                                color: Colors.black87,
                              ),
                            ),
                            16.h,
                            Text(
                              news.description,
                              style: const TextStyle(
                                fontSize: 16,
                                height: 1.6,
                                color: Colors.black87,
                              ),
                            ),
                            32.h,
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
