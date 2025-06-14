import 'package:clinic/features/client/news/domain/entities/news.dart';

class NewsModel extends News {
  const NewsModel({
    required super.id,
    required super.name,
    required super.description,
    required super.file,
  });

  factory NewsModel.fromJson(Map<String, dynamic> json) {
    return NewsModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      file: json['file'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'description': description,
      'file': file,
    };
  }
}
