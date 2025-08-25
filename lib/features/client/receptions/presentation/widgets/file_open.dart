import 'dart:convert';
import 'dart:typed_data';
import 'package:clinic/features/client/receptions/domain/entities/reception_info_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter_pdfview/flutter_pdfview.dart';
import 'package:photo_view/photo_view.dart';
import 'package:webview_flutter/webview_flutter.dart';

// File viewer service klassi
class FileViewerService {
  static void openFile(BuildContext context, AttachedFile file) {
    final extension = _getFileExtension(file.name).toLowerCase();

    switch (extension) {
      case 'pdf':
        _openPDFViewer(context, file);
        break;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        _openImageViewer(context, file);
        break;
      case 'txt':
      case 'csv':
        _openTextViewer(context, file);
        break;
      case 'html':
      case 'htm':
        _openHTMLViewer(context, file);
        break;
      case 'doc':
      case 'docx':
        _openDocumentViewer(context, file);
        break;
      default:
        _openGenericViewer(context, file);
    }
  }

  static String _getFileExtension(String fileName) {
    return fileName.split('.').last;
  }

  // PDF Viewer
  static void _openPDFViewer(BuildContext context, AttachedFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => PDFViewerScreen(file: file),
      ),
    );
  }

  // Image Viewer
  static void _openImageViewer(BuildContext context, AttachedFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ImageViewerScreen(file: file),
      ),
    );
  }

  // Text Viewer
  static void _openTextViewer(BuildContext context, AttachedFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TextViewerScreen(file: file),
      ),
    );
  }

  // HTML Viewer
  static void _openHTMLViewer(BuildContext context, AttachedFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => HTMLViewerScreen(file: file),
      ),
    );
  }

  // Document Viewer
  static void _openDocumentViewer(BuildContext context, AttachedFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DocumentViewerScreen(file: file),
      ),
    );
  }

  // Generic Viewer
  static void _openGenericViewer(BuildContext context, AttachedFile file) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => GenericFileViewerScreen(file: file),
      ),
    );
  }
}

// PDF Viewer Screen
class PDFViewerScreen extends StatefulWidget {
  final AttachedFile file;

  const PDFViewerScreen({Key? key, required this.file}) : super(key: key);

  @override
  _PDFViewerScreenState createState() => _PDFViewerScreenState();
}

class _PDFViewerScreenState extends State<PDFViewerScreen> {
  late Uint8List pdfBytes;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadPDF();
  }

  void _loadPDF() async {
    try {
      final cleanBase64 =
          widget.file.base64.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
      pdfBytes = base64Decode(cleanBase64);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Ошибка при загрузке PDF';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.file.name,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorWidget()
              : PDFView(
                  pdfData: pdfBytes,
                  enableSwipe: true,
                  swipeHorizontal: false,
                  autoSpacing: true,
                  pageFling: true,
                  pageSnap: true,
                  defaultPage: 0,
                  fitPolicy: FitPolicy.BOTH,
                  preventLinkNavigation: false,
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadPDF,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }
}

// Image Viewer Screen
class ImageViewerScreen extends StatelessWidget {
  final AttachedFile file;

  const ImageViewerScreen({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    late Uint8List imageBytes;

    try {
      final cleanBase64 =
          file.base64.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
      imageBytes = base64Decode(cleanBase64);
    } catch (e) {
      return _buildErrorScreen(context);
    }

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(
          file.name,
          style: const TextStyle(color: Colors.white, fontSize: 16),
        ),
        backgroundColor: Colors.black,
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: PhotoView(
        imageProvider: MemoryImage(imageBytes),
        backgroundDecoration: const BoxDecoration(color: Colors.black),
        minScale: PhotoViewComputedScale.contained,
        maxScale: PhotoViewComputedScale.covered * 3,
        initialScale: PhotoViewComputedScale.contained,
        heroAttributes: PhotoViewHeroAttributes(tag: file.name),
      ),
    );
  }

  Widget _buildErrorScreen(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(file.name)),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('Ошибка при загрузке изображения'),
          ],
        ),
      ),
    );
  }
}

// Text Viewer Screen
class TextViewerScreen extends StatefulWidget {
  final AttachedFile file;

  const TextViewerScreen({Key? key, required this.file}) : super(key: key);

  @override
  _TextViewerScreenState createState() => _TextViewerScreenState();
}

class _TextViewerScreenState extends State<TextViewerScreen> {
  String? textContent;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadText();
  }

  void _loadText() async {
    try {
      final cleanBase64 =
          widget.file.base64.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
      final bytes = base64Decode(cleanBase64);
      textContent = utf8.decode(bytes);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Ошибка при загрузке текста';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.file.name,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorWidget()
              : Container(
                  padding: const EdgeInsets.all(16),
                  child: SingleChildScrollView(
                    child: SelectableText(
                      textContent!,
                      style: const TextStyle(
                        fontSize: 14,
                        height: 1.5,
                        fontFamily: 'monospace',
                      ),
                    ),
                  ),
                ),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}

// HTML Viewer Screen
class HTMLViewerScreen extends StatefulWidget {
  final AttachedFile file;

  const HTMLViewerScreen({Key? key, required this.file}) : super(key: key);

  @override
  _HTMLViewerScreenState createState() => _HTMLViewerScreenState();
}

class _HTMLViewerScreenState extends State<HTMLViewerScreen> {
  late WebViewController controller;
  String? htmlContent;
  bool isLoading = true;
  String? error;

  @override
  void initState() {
    super.initState();
    _loadHTML();
  }

  void _loadHTML() async {
    try {
      final cleanBase64 =
          widget.file.base64.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
      final bytes = base64Decode(cleanBase64);
      htmlContent = utf8.decode(bytes);

      controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..loadHtmlString(htmlContent!);

      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        error = 'Ошибка при загрузке HTML';
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.file.name,
          style: const TextStyle(fontSize: 16),
        ),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : error != null
              ? _buildErrorWidget()
              : WebViewWidget(controller: controller),
    );
  }

  Widget _buildErrorWidget() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.error_outline, size: 64, color: Colors.red[400]),
          const SizedBox(height: 16),
          Text(error!, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: _loadHTML,
            child: const Text('Попробовать снова'),
          ),
        ],
      ),
    );
  }
}

// Document Viewer Screen
class DocumentViewerScreen extends StatelessWidget {
  final AttachedFile file;

  const DocumentViewerScreen({Key? key, required this.file}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.description,
              size: 80,
              color: Colors.blue[400],
            ),
            const SizedBox(height: 16),
            Text(
              file.name,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Документ',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Предварительный просмотр недоступен',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

// Generic File Viewer
class GenericFileViewerScreen extends StatelessWidget {
  final AttachedFile file;

  const GenericFileViewerScreen({Key? key, required this.file})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    final extension = file.name.split('.').last.toUpperCase();
    final fileSize = _calculateFileSize(file.base64);

    return Scaffold(
      appBar: AppBar(
        title: Text(file.name),
        backgroundColor: Colors.white,
        foregroundColor: Colors.black87,
        elevation: 1,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey[300]!),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.insert_drive_file,
                      size: 48,
                      color: Colors.grey[600],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      extension,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                file.name,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 8),
              Text(
                fileSize,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Предварительный просмотр недоступен',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _calculateFileSize(String base64) {
    try {
      final cleanBase64 = base64.replaceAll(RegExp(r'[^A-Za-z0-9+/=]'), '');
      final padding = cleanBase64.endsWith('==')
          ? 2
          : cleanBase64.endsWith('=')
              ? 1
              : 0;
      final bytes = (cleanBase64.length * 3 / 4) - padding;

      if (bytes < 1024) {
        return '${bytes.round()} Б';
      } else if (bytes < 1024 * 1024) {
        return '${(bytes / 1024).toStringAsFixed(1)} КБ';
      } else {
        return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
      }
    } catch (e) {
      return 'Неизвестный размер';
    }
  }
}
