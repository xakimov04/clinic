import 'dart:io';
import 'package:clinic/features/client/chat/domain/entities/message_model.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
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

  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  bool _isComposing = false;
  bool _showScrollToBottom = false;

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
      final showButton = _scrollController.offset > 200;
      if (showButton != _showScrollToBottom) {
        setState(() {
          _showScrollToBottom = showButton;
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

    // BLoC'dagi stream'ni tozalash
    context.read<ChatDetailBloc>().disposeChat();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatDetailBloc, ChatDetailState>(
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
          } else if (state is ChatDetailLoaded && state.messages.isNotEmpty) {
            // Yangi xabar kelganda pastga scroll qilish
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _scrollToBottom();
            });
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
      floatingActionButton:
          _showScrollToBottom ? _buildScrollToBottomButton() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 1,
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: ColorConstants.textColor),
        onPressed: () => Navigator.of(context).pop(),
      ),
      title: Row(
        children: [
          Container(
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
          ),
          12.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Др. ${widget.chat.doctorName}',
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: ColorConstants.textColor,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                if (widget.chat.isActive)
                  const Text(
                    'В сети',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorConstants.successColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
              ],
            ),
          ),
        ],
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
      return _buildMessagesListView(state.messages);
    } else if (state is ChatDetailError) {
      return _buildErrorState(state.message);
    }

    return const SizedBox.shrink();
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: Platform.isIOS
                ? const CupertinoActivityIndicator(
                    animating: true,
                    color: ColorConstants.primaryColor,
                  )
                : const CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.primaryColor),
                  ),
          ),
          16.h,
          const Text(
            'Загружаем сообщения...',
            style: TextStyle(
              fontSize: 14,
              color: ColorConstants.secondaryTextColor,
            ),
          ),
        ],
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
              'Начните общение',
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
              'Ошибка загрузки',
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
              label: const Text('Повторить'),
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

  Widget _buildMessagesListView(List<MessageEntity> messages) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: messages.length,
      physics: const BouncingScrollPhysics(),
      itemBuilder: (context, index) {
        final message = messages[index];
        final previousMessage = index > 0 ? messages[index - 1] : null;
        final showDateDivider =
            _shouldShowDateDivider(message, previousMessage);

        return Column(
          children: [
            if (showDateDivider) _buildDateDivider(message.timestamp),
            _MessageBubble(
              message: message,
              showAvatar: _shouldShowAvatar(message, index, messages),
            ),
          ],
        );
      },
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

  bool _shouldShowAvatar(
      MessageEntity message, int index, List<MessageEntity> messages) {
    if (message.isFromCurrentUser) return false;
    if (index == messages.length - 1) return true;

    final nextMessage = messages[index + 1];
    return nextMessage.isFromCurrentUser ||
        nextMessage.senderType != message.senderType;
  }

  Widget _buildDateDivider(DateTime date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Сегодня';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Вчера';
    } else {
      dateText = '${date.day}.${date.month}.${date.year}';
    }

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
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: ColorConstants.backgroundColor,
                  borderRadius: BorderRadius.circular(24),
                  border: Border.all(
                    color: ColorConstants.borderColor.withOpacity(0.5),
                  ),
                ),
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  enabled: !isSending,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: const InputDecoration(
                    hintText: 'Введите сообщение...',
                    border: InputBorder.none,
                    contentPadding: EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _sendMessage(),
                ),
              ),
            ),
            12.w,
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: _isComposing && !isSending
                    ? ColorConstants.primaryColor
                    : ColorConstants.primaryColor.withOpacity(0.3),
                shape: BoxShape.circle,
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(24),
                  onTap: _isComposing && !isSending ? _sendMessage : null,
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
                            color: _isComposing
                                ? Colors.white
                                : Colors.white.withOpacity(0.6),
                            size: 20,
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildScrollToBottomButton() {
    return FloatingActionButton.small(
      onPressed: _scrollToBottom,
      backgroundColor: ColorConstants.primaryColor,
      child: const Icon(
        Icons.keyboard_arrow_down_rounded,
        color: Colors.white,
      ),
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty) return;

    // Haptic feedback
    HapticFeedback.lightImpact();

    context.read<ChatDetailBloc>().add(
          SendMessageEvent(
            chatId: widget.chat.id,
            content: content,
          ),
        );

    _messageController.clear();
    _scrollToBottom();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }
}

// Message Bubble Widget
class _MessageBubble extends StatelessWidget {
  final MessageEntity message;
  final bool showAvatar;

  const _MessageBubble({
    required this.message,
    required this.showAvatar,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: message.isFromCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!message.isFromCurrentUser && showAvatar) ...[
            _buildAvatar(),
            8.w,
          ] else if (!message.isFromCurrentUser) ...[
            40.w, // Avatar space placeholder
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: BoxDecoration(
                color: message.isFromCurrentUser
                    ? ColorConstants.primaryColor
                    : Colors.white,
                borderRadius: BorderRadius.circular(18).copyWith(
                  bottomLeft: message.isFromCurrentUser
                      ? const Radius.circular(18)
                      : showAvatar
                          ? const Radius.circular(4)
                          : const Radius.circular(18),
                  bottomRight: message.isFromCurrentUser
                      ? showAvatar
                          ? const Radius.circular(4)
                          : const Radius.circular(18)
                      : const Radius.circular(18),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    message.content,
                    style: TextStyle(
                      color: message.isFromCurrentUser
                          ? Colors.white
                          : ColorConstants.textColor,
                      fontSize: 15,
                      height: 1.4,
                    ),
                  ),
                  4.h,
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        message.formattedTime,
                        style: TextStyle(
                          color: message.isFromCurrentUser
                              ? Colors.white.withOpacity(0.7)
                              : ColorConstants.secondaryTextColor,
                          fontSize: 11,
                        ),
                      ),
                      if (message.isFromCurrentUser) ...[
                        4.w,
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
          if (message.isFromCurrentUser) 8.w,
        ],
      ),
    );
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
