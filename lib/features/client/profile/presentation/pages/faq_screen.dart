import 'package:clinic/core/di/modules/receptions_module.dart';
import 'package:clinic/features/client/profile/data/model/faq_model.dart';
import 'package:flutter/material.dart';
import 'package:clinic/core/di/export/di_export.dart'; // NetworkManager

class FaqScreen extends StatefulWidget {
  const FaqScreen({super.key});

  @override
  State<FaqScreen> createState() => _FaqScreenState();
}

class _FaqScreenState extends State<FaqScreen> {
  late Future<List<FaqModel>> _faqFuture;

  @override
  void initState() {
    super.initState();
    _faqFuture = _fetchFaqs();
  }

  Future<List<FaqModel>> _fetchFaqs() async {
    try {
      final response = await sl<NetworkManager>().fetchData(url: '/faq/');
      final List<dynamic> data = response;
      return data.map((e) => FaqModel.fromJson(e)).toList();
    } catch (e) {
      throw Exception('Ошибка при загрузке данных: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Часто задаваемые вопросы'),
        centerTitle: true,
      ),
      body: FutureBuilder<List<FaqModel>>(
        future: _faqFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(
              child: Text(
                'Произошла ошибка: ${snapshot.error}',
                style: const TextStyle(color: Colors.red),
              ),
            );
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text(
                'Пока данных нет.',
                style: TextStyle(fontSize: 16),
              ),
            );
          }

          final faqs = snapshot.data!;

          return ListView.separated(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            itemCount: faqs.length,
            separatorBuilder: (context, index) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final faq = faqs[index];
              return ExpansionTile(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide.none,
                ),
                collapsedShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                  side: BorderSide.none,
                ),
                title: Text(
                  faq.question,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 8,
                    ),
                    child: Text(
                      faq.answer,
                      style: const TextStyle(
                        fontSize: 15,
                        color: Colors.black87,
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }
}
