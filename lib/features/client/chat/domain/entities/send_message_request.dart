import 'package:equatable/equatable.dart';

class SendMessageRequest extends Equatable {
  final String content;

  const SendMessageRequest({
    required this.content,
  });

  @override
  List<Object?> get props => [content];
}

enum MessageSenderType {
  patient,
  doctor;

  factory MessageSenderType.fromString(String value) {
    switch (value.toLowerCase()) {
      case 'patient':
        return MessageSenderType.patient;
      case 'doctor':
        return MessageSenderType.doctor;
      default:
        return MessageSenderType.patient;
    }
  }

  String get value {
    switch (this) {
      case MessageSenderType.patient:
        return 'patient';
      case MessageSenderType.doctor:
        return 'doctor';
    }
  }

  String get displayName {
    switch (this) {
      case MessageSenderType.patient:
        return 'Пациент';
      case MessageSenderType.doctor:
        return 'Врач';
    }
  }
}
