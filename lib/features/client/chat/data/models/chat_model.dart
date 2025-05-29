import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/data/models/last_message_model.dart';

class ChatModel extends ChatEntity {
  const ChatModel({
    required super.id,
    required super.patientId,
    required super.doctorId,
    required super.patientName,
    required super.doctorName,
    required super.createdAt,
    required super.isActive,
    required super.lastMessageAt,
    super.lastMessage,
    required super.unreadCount,
  });

  factory ChatModel.fromJson(Map<String, dynamic> json) {
    return ChatModel(
      id: json['id'] ?? 0,
      patientId: json['patient'] ?? 0,
      doctorId: json['doctor'] ?? 0,
      patientName: json['patient_name'] ?? '',
      doctorName: json['doctor_name'] ?? '',
      createdAt: DateTime.tryParse(json['created_at'] ?? '') ?? DateTime.now(),
      isActive: json['is_active'] ?? true,
      lastMessageAt:
          DateTime.tryParse(json['last_message_at'] ?? '') ?? DateTime.now(),
      lastMessage: json['last_message'] != null
          ? LastMessageModel.fromJson(json['last_message'])
          : null,
      unreadCount: json['unread_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'patient': patientId,
      'doctor': doctorId,
      'patient_name': patientName,
      'doctor_name': doctorName,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
      'last_message_at': lastMessageAt.toIso8601String(),
      'last_message': lastMessage != null
          ? (lastMessage as LastMessageModel).toJson()
          : null,
      'unread_count': unreadCount,
    };
  }
}
