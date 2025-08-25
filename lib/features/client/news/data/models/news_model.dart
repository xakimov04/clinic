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
      id: json['id'] ?? "",
      name: json['name'] ?? "",
      description: json['description'] ?? "",
      file: json['file'] ?? "",
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
