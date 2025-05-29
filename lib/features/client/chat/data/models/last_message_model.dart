import 'package:clinic/features/client/chat/domain/entities/last_message_entity.dart';
import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';

class LastMessageModel extends LastMessageEntity {
  const LastMessageModel({
    required super.content,
    required super.timestamp,
    required super.senderType,
  });

  factory LastMessageModel.fromJson(Map<String, dynamic> json) {
    return LastMessageModel(
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      senderType:
          MessageSenderType.fromString(json['sender_type'] ?? 'patient'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'sender_type': senderType.value,
    };
  }
}
