import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';
import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final int id;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final int senderId;
  final String senderName;
  final MessageSenderType senderType;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.senderId,
    required this.senderName,
    required this.senderType,
  });

  @override
  List<Object?> get props => [
        id,
        content,
        timestamp,
        isRead,
        senderId,
        senderName,
        senderType,
      ];

  // Helper metodlar
  bool get isFromCurrentUser => senderType == MessageSenderType.patient;

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      // Bugun
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Kecha
      return 'Вчера ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      // Boshqa kunlar
      return '${timestamp.day}.${timestamp.month}.${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  bool get isToday {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);
    return messageDate == today;
  }

  // Copy with method
  MessageEntity copyWith({
    int? id,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    int? senderId,
    String? senderName,
    MessageSenderType? senderType,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
    );
  }
}
