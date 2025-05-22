import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';

class NewsScreen extends StatelessWidget {
  const NewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Новости'),
        backgroundColor: ColorConstants.backgroundColor,
        elevation: 0,
        centerTitle: true,
      ),
      backgroundColor: ColorConstants.backgroundColor,
      body: ListView.builder(
        padding: 16.a,
        itemCount: 10,
        itemBuilder: (context, index) {
          return Card(
            margin: 8.v,
            child: ListTile(
              leading: Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  borderRadius: 8.circular,
                ),
                child: const Icon(
                  Icons.article_outlined,
                  color: ColorConstants.primaryColor,
                ),
              ),
              title: Text(
                'Новость ${index + 1}',
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: const Text(
                'Описание новости и полезная информация для пациентов...',
              ),
              trailing: const Icon(
                Icons.arrow_forward_ios,
                size: 16,
              ),
              onTap: () {
                // Показать подробности новости
                _showNewsDetails(context, index + 1);
              },
            ),
          );
        },
      ),
    );
  }

  void _showNewsDetails(BuildContext context, int newsId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: 16.verticalTop,
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: 8.v,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: 2.circular,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: 16.a,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Новость $newsId',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        8.h,
                        Text(
                          'Дата публикации: ${DateTime.now().day}.${DateTime.now().month}.${DateTime.now().year}',
                          style: const TextStyle(
                            color: ColorConstants.secondaryTextColor,
                          ),
                        ),
                        16.h,
                        const Text(
                          'Полное описание новости и подробная информация о медицинских услугах, новых технологиях, специальных предложениях и важных объявлениях клиники.',
                          style: TextStyle(
                            fontSize: 16,
                            height: 1.6,
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
      ),
    );
  }
}