import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';

class SendMessageRequestModel extends SendMessageRequest {
  const SendMessageRequestModel({
    required super.content,
  });

  factory SendMessageRequestModel.fromEntity(SendMessageRequest entity) {
    return SendMessageRequestModel(content: entity.content);
  }

  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}
