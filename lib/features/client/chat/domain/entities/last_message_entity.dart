import 'package:equatable/equatable.dart';

class LastMessageEntity extends Equatable {
  final String content;
  final DateTime timestamp;

  const LastMessageEntity({
    required this.content,
    required this.timestamp,
  });

  @override
  List<Object?> get props => [content, timestamp];


  String get displayContent {
    if (content.length > 50) {
      return '${content.substring(0, 50)}...';
    }
    return content;
  }
}

