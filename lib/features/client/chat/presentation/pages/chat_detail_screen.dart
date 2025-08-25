import 'dart:io';
import 'package:clinic/core/ui/widgets/controls/russian_text_selection_controls.dart';
import 'package:clinic/core/ui/widgets/images/custom_cached_image.dart';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:file_picker/file_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/presentation/bloc/chat_detail/chat_detail_bloc.dart';

class ChatDetailScreen extends StatefulWidget {
  final ChatEntity chat;

  const ChatDetailScreen({
    super.key,
    required this.chat,
  });

  @override
  State<ChatDetailScreen> createState() => _ChatDetailScreenState();
}

class _ChatDetailScreenState extends State<ChatDetailScreen>
    with TickerProviderStateMixin {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FocusNode _messageFocusNode = FocusNode();
  final ImagePicker _imagePicker = ImagePicker();

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isComposing = false;
  bool _showScrollToBottom = false;
  bool _isInitialLoad = true;
  File? _selectedFile;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadMessages();
    _setupScrollListener();
    _messageController.addListener(_onMessageChanged);
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _loadMessages() {
    context.read<ChatDetailBloc>().add(LoadMessagesEvent(widget.chat.id));
  }

  void _setupScrollListener() {
    _scrollController.addListener(() {
      final isScrolledUp = _scrollController.hasClients &&
          _scrollController.offset >
              _scrollController.position.maxScrollExtent - 1000;

      if (isScrolledUp != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = !isScrolledUp;
        });
      }
    });
  }

  void _onMessageChanged() {
    final isComposing = _messageController.text.trim().isNotEmpty;
    if (isComposing != _isComposing) {
      setState(() {
        _isComposing = isComposing;
      });
    }
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    _messageFocusNode.dispose();
    _animationController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: Stack(
        children: [
          BlocConsumer<ChatDetailBloc, ChatDetailState>(
            listener: (context, state) {
              if (state is MessageSendError) {
                CustomSnackbar.showError(
                  context: context,
                  message: state.error,
                );
              } else if (state is ChatDetailError) {
                CustomSnackbar.showError(
                  context: context,
                  message: state.message,
                );
              } else if (state is ChatDetailLoaded) {
                if (_isInitialLoad && state.messages.isNotEmpty) {
                  _isInitialLoad = false;
                  WidgetsBinding.instance.addPostFrameCallback((_) {
                    _scrollToBottomInstant();
                  });
                }
              }
            },
            builder: (context, state) {
              return Column(
                children: [
                  Expanded(
                    child: FadeTransition(
                      opacity: _fadeAnimation,
                      child: _buildMessagesList(state),
                    ),
                  ),
                  _buildInputArea(state),
                ],
              );
            },
          ),
          if (_showScrollToBottom)
            Positioned(
              right: 16,
              bottom: 100,
              child: _buildScrollToBottomButton(),
            ),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      surfaceTintColor: Colors.white,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: ColorConstants.textColor),
        onPressed: () {
          context.read<ChatDetailBloc>().close();
          Navigator.of(context).pop();
        },
      ),
      title: Row(
        children: [
          _buildDoctorAvatar(),
          12.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.chat.doctorName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorAvatar() {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstants.primaryColor,
            ColorConstants.primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Text(
          widget.chat.doctorName.isNotEmpty
              ? widget.chat.doctorName[0].toUpperCase()
              : 'Д',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildMessagesList(ChatDetailState state) {
    if (state is ChatDetailLoading) {
      return _buildLoadingState();
    } else if (state is ChatDetailLoaded) {
      if (state.messages.isEmpty) {
        return _buildEmptyState();
      }
      return _buildOptimizedMessagesListView(state.messages);
    } else if (state is ChatDetailError) {
      return _buildErrorState(state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildOptimizedMessagesListView(List<MessageEntity> messages) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        top: 8,
        bottom: 8,
      ),
      itemCount: messages.length,
      physics: const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      ),
      itemBuilder: (context, index) {
        final reversedIndex = messages.length - 1 - index;
        final message = messages[reversedIndex];
        final nextMessage =
            reversedIndex > 0 ? messages[reversedIndex - 1] : null;
        final previousMessage = reversedIndex < messages.length - 1
            ? messages[reversedIndex + 1]
            : null;

        final showDateDivider =
            _shouldShowDateDivider(message, previousMessage);
        final showAvatar = _shouldShowAvatar(message, nextMessage);

        return Column(
          children: [
            if (showDateDivider) _buildDateDivider(message.timestamp),
            _MessageBubble(
              message: message,
              showAvatar: showAvatar,
              isLast: reversedIndex == messages.length - 1,
            ),
          ],
        );
      },
    );
  }

  Widget _buildScrollToBottomButton() {
    return AnimatedOpacity(
      opacity: _showScrollToBottom ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Container(
        width: 44,
        height: 44,
        decoration: BoxDecoration(
          color: ColorConstants.primaryColor,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: _scrollToBottomAnimated,
            child: const Icon(
              Icons.keyboard_arrow_down_rounded,
              color: Colors.white,
              size: 24,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: SizedBox(
        height: 40,
        width: 40,
        child: Platform.isIOS
            ? const CupertinoActivityIndicator(
                animating: true,
                color: ColorConstants.primaryColor,
              )
            : const CircularProgressIndicator(
                strokeWidth: 2,
                valueColor:
                    AlwaysStoppedAnimation<Color>(ColorConstants.primaryColor),
              ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorConstants.primaryColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.chat_bubble_outline_rounded,
                size: 40,
                color: ColorConstants.primaryColor,
              ),
            ),
            24.h,
            const Text(
              'Начните беседу',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textColor,
              ),
            ),
            8.h,
            const Text(
              'Отправьте первое сообщение врачу',
              style: TextStyle(
                fontSize: 14,
                color: ColorConstants.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline_rounded,
              size: 64,
              color: ColorConstants.errorColor,
            ),
            16.h,
            const Text(
              'Произошла ошибка',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textColor,
              ),
            ),
            8.h,
            Text(
              message,
              style: const TextStyle(
                fontSize: 14,
                color: ColorConstants.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
            24.h,
            ElevatedButton.icon(
              onPressed: _loadMessages,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Попробовать снова'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _shouldShowDateDivider(MessageEntity current, MessageEntity? previous) {
    if (previous == null) return true;

    final currentDate = DateTime(
      current.timestamp.year,
      current.timestamp.month,
      current.timestamp.day,
    );
    final previousDate = DateTime(
      previous.timestamp.year,
      previous.timestamp.month,
      previous.timestamp.day,
    );

    return currentDate != previousDate;
  }

  bool _shouldShowAvatar(MessageEntity message, MessageEntity? nextMessage) {
    if (message.isFromCurrentUser) return false;
    if (nextMessage == null) return true;

    return nextMessage.isFromCurrentUser ||
        nextMessage.senderType != message.senderType;
  }

  Widget _buildDateDivider(DateTime date) {
    // Har doim to'liq sana formatini ko'rsatish
    final dateText =
        '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: ColorConstants.secondaryColor.withOpacity(0.3),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              dateText,
              style: const TextStyle(
                fontSize: 12,
                color: ColorConstants.secondaryTextColor,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }

  Widget _buildInputArea(ChatDetailState state) {
    final isSending = state is ChatDetailLoaded && state.isSendingMessage;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 8,
            offset: const Offset(0, -1),
          ),
        ],
      ),
      child: SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // File preview
            if (_selectedFile != null) _buildFilePreview(),

            // Input row
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Attach file button
                Container(
                  width: 44,
                  height: 44,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor.withOpacity(0.1),
                    shape: BoxShape.circle,
                  ),
                  child: Material(
                    color: Colors.transparent,
                    child: InkWell(
                      borderRadius: BorderRadius.circular(22),
                      onTap: isSending ? null : _showAttachmentOptions,
                      child: const Icon(
                        Icons.attach_file_rounded,
                        color: ColorConstants.primaryColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),

                // Text input
                Expanded(
                  child: Container(
                    constraints: const BoxConstraints(
                      minHeight: 44,
                      maxHeight: 120,
                    ),
                    decoration: BoxDecoration(
                      color: ColorConstants.backgroundColor,
                      borderRadius: BorderRadius.circular(22),
                      border: Border.all(
                        color: _messageFocusNode.hasFocus
                            ? ColorConstants.primaryColor.withOpacity(0.3)
                            : ColorConstants.borderColor.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: TextField(
                      contextMenuBuilder: RussianContextMenu.build,
                      controller: _messageController,
                      focusNode: _messageFocusNode,
                      enabled: !isSending,
                      maxLines: null,
                      minLines: 1,
                      textCapitalization: TextCapitalization.sentences,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.4,
                      ),
                      decoration: const InputDecoration(
                        hintText: 'Напишите сообщение...',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        isDense: true,
                      ),
                      onSubmitted: (_) => _sendMessage(),
                    ),
                  ),
                ),

                8.w,
                _buildSendButton(isSending),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFilePreview() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: ColorConstants.primaryColor.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.primaryColor.withOpacity(0.2),
        ),
      ),
      child: Row(
        children: [
          // File preview or icon
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: ColorConstants.primaryColor.withOpacity(0.1),
            ),
            child: _isImageFile(_selectedFile!)
                ? ClipRRect(
                    borderRadius: BorderRadius.circular(8),
                    child: Image.file(
                      _selectedFile!,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) => Icon(
                        Icons.image_rounded,
                        color: ColorConstants.primaryColor,
                        size: 24,
                      ),
                    ),
                  )
                : Icon(
                    _getFileIcon(_selectedFile!.path),
                    color: ColorConstants.primaryColor,
                    size: 24,
                  ),
          ),

          12.w,

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _selectedFile!.path.split('/').last,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                    fontSize: 14,
                    color: ColorConstants.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                4.h,
                Text(
                  _formatFileSize(_selectedFile!.lengthSync()),
                  style: const TextStyle(
                    color: ColorConstants.secondaryTextColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Remove button
          IconButton(
            onPressed: () {
              setState(() {
                _selectedFile = null;
              });
            },
            icon: const Icon(
              Icons.close_rounded,
              color: ColorConstants.secondaryTextColor,
            ),
            iconSize: 20,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 32,
              minHeight: 32,
            ),
          ),
        ],
      ),
    );
  }

  bool _isImageFile(File file) {
    final extension = file.path.toLowerCase();
    return extension.endsWith('.jpg') ||
        extension.endsWith('.jpeg') ||
        extension.endsWith('.png') ||
        extension.endsWith('.gif') ||
        extension.endsWith('.webp');
  }

  IconData _getFileIcon(String filePath) {
    final extension = filePath.toLowerCase();

    if (_isImageFile(File(filePath))) {
      return Icons.image_rounded;
    } else if (extension.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (extension.endsWith('.doc') || extension.endsWith('.docx')) {
      return Icons.description_rounded;
    } else if (extension.endsWith('.txt')) {
      return Icons.text_snippet_rounded;
    } else {
      return Icons.insert_drive_file_rounded;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes Б';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} КБ';
    return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} МБ';
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Handle bar
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: ColorConstants.borderColor,
                borderRadius: BorderRadius.circular(2),
              ),
            ),

            16.h,

            const Text(
              'Выберите файл',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textColor,
              ),
            ),

            20.h,

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildAttachmentOption(
                  icon: Icons.camera_alt_rounded,
                  label: 'Камера',
                  color: Colors.blue,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromCamera();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.photo_library_rounded,
                  label: 'Галерея',
                  color: Colors.green,
                  onTap: () {
                    Navigator.pop(context);
                    _pickImageFromGallery();
                  },
                ),
                _buildAttachmentOption(
                  icon: Icons.insert_drive_file_rounded,
                  label: 'Документ',
                  color: Colors.orange,
                  onTap: () {
                    Navigator.pop(context);
                    _pickDocument();
                  },
                ),
              ],
            ),

            20.h,
          ],
        ),
      ),
    );
  }

  Widget _buildAttachmentOption({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: color,
              size: 28,
            ),
          ),
          8.h,
          Text(
            label,
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.textColor,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
        });
      }
    } catch (e) {
      _showError('Ошибка при съемке с камеры');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.gallery,
        maxWidth: 1920,
        maxHeight: 1080,
        imageQuality: 85,
      );

      if (image != null) {
        setState(() {
          _selectedFile = File(image.path);
        });
      }
    } catch (e) {
      _showError('Ошибка при выборе изображения из галереи');
    }
  }

  Future<void> _pickDocument() async {
    try {
      final FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['pdf', 'doc', 'docx', 'txt'],
        allowMultiple: false,
      );

      if (result != null && result.files.single.path != null) {
        final file = File(result.files.single.path!);

        // File size check (10MB)
        final fileSize = await file.length();
        const maxSize = 10 * 1024 * 1024;

        if (fileSize > maxSize) {
          _showError('Размер файла не должен превышать 10 МБ');
          return;
        }

        setState(() {
          _selectedFile = file;
        });
      }
    } catch (e) {
      _showError('Ошибка при выборе документа');
    }
  }

  bool _canSend() {
    return _isComposing || _selectedFile != null;
  }

  Widget _buildSendButton(bool isSending) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _canSend() && !isSending
            ? ColorConstants.primaryColor
            : ColorConstants.primaryColor.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
          onTap: _canSend() && !isSending ? _sendMessage : null,
          child: Center(
            child: isSending
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        Colors.white.withOpacity(0.8),
                      ),
                    ),
                  )
                : Icon(
                    Icons.send_rounded,
                    color: _canSend()
                        ? Colors.white
                        : Colors.white.withOpacity(0.6),
                    size: 20,
                  ),
          ),
        ),
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();

    if (!_canSend()) return;

    HapticFeedback.lightImpact();

    // Agar faqat file bo'lsa, bo'sh string yuboramiz
    final messageContent =
        content.isEmpty && _selectedFile != null ? '' : content;

    context.read<ChatDetailBloc>().add(
          SendMessageEvent(
            chatId: widget.chat.id,
            content: messageContent.isEmpty ? "string" : messageContent,
            file: _selectedFile,
          ),
        );

    _messageController.clear();
    setState(() {
      _isComposing = false;
      _selectedFile = null;
    });

    _scrollToBottomAnimated();
  }

  void _showError(String message) {
    CustomSnackbar.showError(
      context: context,
      message: message,
    );
  }

  void _scrollToBottomAnimated() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  void _scrollToBottomInstant() {
    if (_scrollController.hasClients) {
      _scrollController.jumpTo(0);
    }
  }
}

// Enhanced Message Bubble Widget with File Support
class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool showAvatar;
  final bool isLast;

  const _MessageBubble({
    required this.message,
    required this.showAvatar,
    required this.isLast,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.only(
        top: 2,
        bottom: isLast ? 8 : 2,
      ),
      child: Row(
        mainAxisAlignment: message.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromCurrentUser) ...[
            _buildAvatar(),
            8.w,
          ] else if (!message.isFromCurrentUser) ...[
            40.w,
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
                minWidth: 60,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isFromCurrentUser
                    ? ColorConstants.primaryColor
                    : Colors.white,
                borderRadius: _getBorderRadius(),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.04),
                    blurRadius: 6,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  // File content
                  if (message.hasFile) ...[
                    _buildFileContent(context),
                    if (message.content.trim().isNotEmpty) 8.h,
                  ],

                  // Text content - показываем только если есть текст
                  if (message.content.trim().isNotEmpty &&
                      message.content != 'string')
                    Text(
                      message.content,
                      style: TextStyle(
                        color: message.isFromCurrentUser
                            ? Colors.white
                            : ColorConstants.textColor,
                        fontSize: 15,
                        height: 1.35,
                      ),
                    ),

                  // Spacing только если есть контент
                  if (message.hasFile || message.content.trim().isNotEmpty) 4.h,

                  // Message info
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _getFormattedTime(message.timestamp),
                        style: TextStyle(
                          color: message.isFromCurrentUser
                              ? Colors.white.withOpacity(0.7)
                              : ColorConstants.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                      if (message.isFromCurrentUser) ...[
                        4.w,
                        if (message.isSending)
                          SizedBox(
                            width: 12,
                            height: 12,
                            child: CircularProgressIndicator(
                              strokeWidth: 1.5,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                Colors.white.withOpacity(0.7),
                              ),
                            ),
                          )
                        else
                          Icon(
                            message.isRead
                                ? Icons.done_all_rounded
                                : Icons.done_rounded,
                            size: 14,
                            color: message.isRead
                                ? ColorConstants.successColor
                                : Colors.white.withOpacity(0.7),
                          ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Исправленный метод форматирования времени
  String _getFormattedTime(DateTime timestamp) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate =
        DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate == today) {
      // Сегодня - показываем только время
      return '${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      // Вчера
      return 'Вчера ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      // Другие дни
      return '${timestamp.day.toString().padLeft(2, '0')}.${timestamp.month.toString().padLeft(2, '0')}.${timestamp.year} ${timestamp.hour.toString().padLeft(2, '0')}:${timestamp.minute.toString().padLeft(2, '0')}';
    }
  }

  Widget _buildFileContent(BuildContext context) {
    if (message.isImage) {
      return _buildImageContent(context);
    } else {
      return _buildDocumentContent(context);
    }
  }

  Widget _buildImageContent(BuildContext context) {
    return GestureDetector(
      onTap: () => _openFile(context),
      child: Container(
        constraints: const BoxConstraints(
          maxWidth: 200,
          maxHeight: 200,
          minWidth: 150,
          minHeight: 100,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(12),
          color: Colors.grey[200],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: message.isTemporary && message.file != null
              ? Image.file(
                  File(message.file!),
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      _buildFileError(),
                )
              : message.file != null
                  ? CacheImageWidget(
                      imageUrl: message.file!,
                      fit: BoxFit.cover,
                      errorWidget: Icon(
                        Icons.error_outline_rounded,
                        color: Colors.white,
                        size: 64,
                      ),
                    )
                  : _buildFileError(),
        ),
      ),
    );
  }

  Widget _buildDocumentContent(BuildContext context) {
    final fileName = message.file?.split('/').last ?? 'Файл';

    return GestureDetector(
      onTap: () => _openFile(context),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: message.isFromCurrentUser
              ? Colors.white.withOpacity(0.1)
              : ColorConstants.primaryColor.withOpacity(0.05),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: message.isFromCurrentUser
                ? Colors.white.withOpacity(0.3)
                : ColorConstants.primaryColor.withOpacity(0.2),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: message.isFromCurrentUser
                    ? Colors.white.withOpacity(0.2)
                    : ColorConstants.primaryColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(
                _getFileIcon(fileName),
                color: message.isFromCurrentUser
                    ? Colors.white
                    : ColorConstants.primaryColor,
                size: 20,
              ),
            ),
            12.w,
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    fileName,
                    style: TextStyle(
                      color: message.isFromCurrentUser
                          ? Colors.white
                          : ColorConstants.textColor,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  2.h,
                  Text(
                    'Нажмите для открытия',
                    style: TextStyle(
                      color: message.isFromCurrentUser
                          ? Colors.white.withOpacity(0.7)
                          : ColorConstants.secondaryTextColor,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            8.w,
            Icon(
              Icons.open_in_new_rounded,
              size: 16,
              color: message.isFromCurrentUser
                  ? Colors.white.withOpacity(0.7)
                  : ColorConstants.secondaryTextColor,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFileError() {
    return Container(
      height: 150,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline_rounded,
              color: Colors.grey[400],
              size: 32,
            ),
            8.h,
            Text(
              'Не удалось загрузить файл',
              style: TextStyle(
                color: Colors.grey[600],
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.toLowerCase();

    if (extension.endsWith('.pdf')) {
      return Icons.picture_as_pdf_rounded;
    } else if (extension.endsWith('.doc') || extension.endsWith('.docx')) {
      return Icons.description_rounded;
    } else if (extension.endsWith('.txt')) {
      return Icons.text_snippet_rounded;
    } else {
      return Icons.insert_drive_file_rounded;
    }
  }

  Future<void> _openFile(BuildContext context) async {
    if (message.file == null) return;

    try {
      if (message.isTemporary && message.isImage) {
        // Local image - show full screen
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _FullScreenImageViewer(
              imagePath: message.file!,
              isNetworkImage: false,
            ),
          ),
        );
        return;
      }

      // Network file
      if (message.isImage) {
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => _FullScreenImageViewer(
              imagePath: message.file!,
              isNetworkImage: true,
            ),
          ),
        );
      } else {
        // Document - open with external app
        final uri = Uri.parse(message.file!);
        if (await canLaunchUrl(uri)) {
          await launchUrl(uri, mode: LaunchMode.externalApplication);
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Не удалось открыть файл'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ошибка при открытии файла'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  BorderRadius _getBorderRadius() {
    const radius = Radius.circular(18);
    const smallRadius = Radius.circular(4);

    if (message.isFromCurrentUser) {
      return BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: radius,
        bottomRight: showAvatar ? smallRadius : radius,
      );
    } else {
      return BorderRadius.only(
        topLeft: radius,
        topRight: radius,
        bottomLeft: showAvatar ? smallRadius : radius,
        bottomRight: radius,
      );
    }
  }

  Widget _buildAvatar() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstants.primaryColor,
            ColorConstants.primaryColor.withOpacity(0.7),
          ],
        ),
      ),
      child: Center(
        child: Text(
          message.senderName.isNotEmpty
              ? message.senderName[0].toUpperCase()
              : 'Д',
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}

// Full Screen Image Viewer
class _FullScreenImageViewer extends StatelessWidget {
  final String imagePath;
  final bool isNetworkImage;

  const _FullScreenImageViewer({
    required this.imagePath,
    required this.isNetworkImage,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        iconTheme: const IconThemeData(color: Colors.white),
        elevation: 0,
        systemOverlayStyle: const SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),
      body: Center(
        child: InteractiveViewer(
          panEnabled: true,
          boundaryMargin: const EdgeInsets.all(20),
          minScale: 0.5,
          maxScale: 4,
          child: isNetworkImage
              ? CacheImageWidget(
                  imageUrl: imagePath,
                  fit: BoxFit.cover,
                  errorWidget: Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                )
              : Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) => const Icon(
                    Icons.error_outline_rounded,
                    color: Colors.white,
                    size: 64,
                  ),
                ),
        ),
      ),
    );
  }
}
