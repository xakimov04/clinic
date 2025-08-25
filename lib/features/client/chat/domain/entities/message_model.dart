import 'package:equatable/equatable.dart';

class MessageEntity extends Equatable {
  final int id;
  final String content;
  final DateTime timestamp;
  final bool isRead;
  final int senderId;
  final String senderName;
  final MessageSenderType senderType;
  final String? file; // Yangi property - file URL
  final bool isTemporary;
  final bool isSending;

  const MessageEntity({
    required this.id,
    required this.content,
    required this.timestamp,
    required this.isRead,
    required this.senderId,
    required this.senderName,
    required this.senderType,
    this.file,
    this.isTemporary = false,
    this.isSending = false,
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
        file,
        isTemporary,
        isSending,
      ];

  // Helper methodlar
  bool get isFromCurrentUser => senderType == MessageSenderType.patient;
  bool get hasFile => file != null && file!.isNotEmpty;
  
  // File type checks
  bool get isImage {
    if (!hasFile) return false;
    final extension = file!.toLowerCase();
    return extension.contains('.jpg') ||
           extension.contains('.jpeg') ||
           extension.contains('.png') ||
           extension.contains('.gif') ||
           extension.contains('.webp');
  }

  bool get isDocument {
    if (!hasFile) return false;
    final extension = file!.toLowerCase();
    return extension.contains('.pdf') ||
           extension.contains('.doc') ||
           extension.contains('.docx') ||
           extension.contains('.txt');
  }

  String get formattedTime {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      return 'Kecha ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.day}.${timestamp.month}.${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  MessageEntity copyWith({
    int? id,
    String? content,
    DateTime? timestamp,
    bool? isRead,
    int? senderId,
    String? senderName,
    MessageSenderType? senderType,
    String? file,
    bool? isTemporary,
    bool? isSending,
  }) {
    return MessageEntity(
      id: id ?? this.id,
      content: content ?? this.content,
      timestamp: timestamp ?? this.timestamp,
      isRead: isRead ?? this.isRead,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderType: senderType ?? this.senderType,
      file: file ?? this.file,
      isTemporary: isTemporary ?? this.isTemporary,
      isSending: isSending ?? this.isSending,
    );
  }
}

enum MessageSenderType {
  patient('patient'),
  doctor('doctor');

  const MessageSenderType(this.value);
  final String value;

  static MessageSenderType fromString(String value) {
    switch (value.toLowerCase()) {
      case 'doctor':
        return MessageSenderType.doctor;
      case 'patient':
      default:
        return MessageSenderType.patient;
    }
  }
}