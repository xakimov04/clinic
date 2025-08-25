import 'dart:io';
import 'package:equatable/equatable.dart';

class SendMessageRequest extends Equatable {
  final String content;
  final File? file;

  const SendMessageRequest({
    this.content = 's',
    this.file,
  });

  @override
  List<Object?> get props => [content, file];

  // Validation methodlari
  bool get hasFile => file != null;
  bool get hasContent => content.trim().isNotEmpty;
  bool get isValid => hasContent || hasFile;

  // File type checks
  bool get isImage {
    if (!hasFile) return false;
    final extension = file!.path.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.gif') ||
        extension.endsWith('.webp');
  }

  bool get isDocument {
    if (!hasFile) return false;
    final extension = file!.path.toLowerCase();
    return extension.endsWith('.pdf') ||
        extension.endsWith('.doc') ||
        extension.endsWith('.docx') ||
        extension.endsWith('.txt');
  }

  // File size validation (MB)
  bool isFileSizeValid(double maxMB) {
    if (!hasFile) return true;
    final sizeInMB = file!.lengthSync() / (1024 * 1024);
    return sizeInMB <= maxMB;
  }
}
