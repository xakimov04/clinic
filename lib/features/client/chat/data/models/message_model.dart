import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';

class MessageModel extends MessageEntity {
  const MessageModel({
    required super.id,
    required super.content,
    required super.timestamp,
    required super.isRead,
    required super.senderId,
    required super.senderName,
    required super.senderType,
  });

  factory MessageModel.fromJson(Map<String, dynamic> json) {
    return MessageModel(
      id: json['id'] ?? 0,
      content: json['content'] ?? '',
      timestamp: DateTime.tryParse(json['timestamp'] ?? '') ?? DateTime.now(),
      isRead: json['is_read'] ?? false,
      senderId: json['sender'] ?? 0,
      senderName: json['sender_name'] ?? '',
      senderType:
          MessageSenderType.fromString(json['sender_type'] ?? 'patient'),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'content': content,
      'timestamp': timestamp.toIso8601String(),
      'is_read': isRead,
      'sender': senderId,
      'sender_name': senderName,
      'sender_type': senderType.value,
    };
  }
}
