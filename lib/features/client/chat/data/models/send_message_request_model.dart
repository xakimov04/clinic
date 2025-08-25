import 'package:clinic/features/client/chat/domain/entities/send_message_request.dart';
import 'package:dio/dio.dart';

class SendMessageRequestModel extends SendMessageRequest {
  const SendMessageRequestModel({
    required super.content,
    super.file,
  });

  factory SendMessageRequestModel.fromEntity(SendMessageRequest entity) {
    return SendMessageRequestModel(
      content: entity.content,
      file: entity.file,
    );
  }

  // MultipartFile uchun FormData yaratish
  Future<FormData> toFormData() async {
    final formData = FormData();

    // Content qo'shish
    formData.fields.add(MapEntry('content', content));

    // File mavjud bo'lsa qo'shish
    if (file != null) {
      final fileName = file!.path.split('/').last;
      formData.files.add(
        MapEntry(
          'file',
          await MultipartFile.fromFile(
            file!.path,
            filename: fileName,
          ),
        ),
      );
    }

    return formData;
  }

  // JSON format (file bo'lmasa)
  Map<String, dynamic> toJson() {
    return {
      'content': content,
    };
  }
}