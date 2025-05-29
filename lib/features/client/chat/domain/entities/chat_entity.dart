import 'package:clinic/features/client/chat/domain/entities/last_message_entity.dart';
import 'package:equatable/equatable.dart';

class ChatEntity extends Equatable {
  final int id;
  final int patientId;
  final int doctorId;
  final String patientName;
  final String doctorName;
  final DateTime createdAt;
  final bool isActive;
  final DateTime lastMessageAt;
  final LastMessageEntity? lastMessage;
  final int unreadCount;

  const ChatEntity({
    required this.id,
    required this.patientId,
    required this.doctorId,
    required this.patientName,
    required this.doctorName,
    required this.createdAt,
    required this.isActive,
    required this.lastMessageAt,
    this.lastMessage,
    required this.unreadCount,
  });

  @override
  List<Object?> get props => [
        id,
        patientId,
        doctorId,
        patientName,
        doctorName,
        createdAt,
        isActive,
        lastMessageAt,
        lastMessage,
        unreadCount,
      ];

  // Helper metodlar
  bool get hasUnreadMessages => unreadCount > 0;
  
  String get displayName {
    // Agar user patient bo'lsa doctor nomini, aks holda patient nomini qaytaradi
    return doctorName; // Default holatda doktor nomini ko'rsatamiz
  }
  
  String get formattedTime {
    final now = DateTime.now();
    final difference = now.difference(lastMessageAt);
    
    if (difference.inMinutes < 60) {
      return '${difference.inMinutes} мин назад';
    } else if (difference.inHours < 24) {
      return '${difference.inHours} ч назад';
    } else if (difference.inDays == 1) {
      return 'Вчера';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} дн назад';
    } else {
      return '${lastMessageAt.day}.${lastMessageAt.month}.${lastMessageAt.year}';
    }
  }
}
