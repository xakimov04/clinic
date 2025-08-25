import 'package:clinic/features/client/chat/domain/entities/last_message_entity.dart';

class LastMessageModel extends LastMessageEntity {
  const LastMessageModel({
    required super.content,
    required super.timestamp,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'timestamp': timestamp.toIso8601String(),
    };
  }
}
