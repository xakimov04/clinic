import 'dart:io';
import 'package:clinic/core/ui/widgets/controls/russian_text_selection_controls.dart';
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
  bool _isInitialLoad = true;

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
      // Scroll to bottom tugmasini ko'rsatish mantiqini optimallashtiramiz
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
    context.read<ChatDetailBloc>().disposeChat();
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
                // Telegram uslubida - faqat yangi xabar yuborganimizda scroll qilamiz
                // yoki birinchi yuklanishda
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
          // Scroll to bottom button
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
      elevation: 1,
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back_ios, color: ColorConstants.textColor),
        onPressed: () => Navigator.of(context).pop(),
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
                Text(
                  'online', // Bu statusni real ma'lumotdan olish kerak
                  style: TextStyle(
                    fontSize: 12,
                    color: ColorConstants.primaryColor.withOpacity(0.8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: const Icon(Icons.more_vert, color: ColorConstants.textColor),
          onPressed: () {
            // Chat options
          },
        ),
      ],
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
    // Telegram uslubida - reversed ListView
    return ListView.builder(
      controller: _scrollController,
      reverse: true, // Bu muhim! Telegram kabi pastdan boshlanadi
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
        // reverse bo'lgani uchun index'ni teskarisiga aylantiramiz
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
              'Suhbatni boshlang',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textColor,
              ),
            ),
            8.h,
            const Text(
              'Shifokorga birinchi xabaringizni yuboring',
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
              'Xatolik yuz berdi',
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
              label: const Text('Qayta urinish'),
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
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String dateText;
    if (messageDate == today) {
      dateText = 'Bugun';
    } else if (messageDate == today.subtract(const Duration(days: 1))) {
      dateText = 'Kecha';
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
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
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
                    hintText: 'Xabar yozing...',
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
      ),
    );
  }

  Widget _buildSendButton(bool isSending) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      width: 44,
      height: 44,
      decoration: BoxDecoration(
        color: _isComposing && !isSending
            ? ColorConstants.primaryColor
            : ColorConstants.primaryColor.withOpacity(0.3),
        shape: BoxShape.circle,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(22),
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
    );
  }

  void _sendMessage() {
    final content = _messageController.text.trim();
    if (content.isEmpty || !_isComposing) return;

    HapticFeedback.lightImpact();

    context.read<ChatDetailBloc>().add(
          SendMessageEvent(
            chatId: widget.chat.id,
            content: content,
          ),
        );

    _messageController.clear();
    setState(() {
      _isComposing = false;
    });

    // Xabar yuborganda darhol pastga scroll qilamiz
    _scrollToBottomAnimated();
  }

  void _scrollToBottomAnimated() {
    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0, // reverse=true bo'lgani uchun 0 eng pastki pozitsiya
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

// Optimallashtirilgan Message Bubble Widget
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
        bottom: isLast ? 8 : 2, // Oxirgi xabar uchun ko'proq margin
      ),
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
        ],
      ),
    );
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
