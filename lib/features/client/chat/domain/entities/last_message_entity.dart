import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';
import 'package:equatable/equatable.dart';

class LastMessageEntity extends Equatable {
  final String content;
  final DateTime timestamp;
  final MessageSenderType senderType;

  const LastMessageEntity({
    required this.content,
    required this.timestamp,
    required this.senderType,
  });

  @override
  List<Object?> get props => [content, timestamp, senderType];

  bool get isFromCurrentUser => senderType == MessageSenderType.patient;

  String get displayContent {
    if (content.length > 50) {
      return '${content.substring(0, 50)}...';
    }
    return content;
  }
}

