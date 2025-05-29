import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:go_router/go_router.dart';

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _loadChats();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  void _loadChats() {
    context.read<ChatListBloc>().add(const GetChatsListEvent());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: BlocConsumer<ChatListBloc, ChatListState>(
        listener: (context, state) {
          if (state is ChatListError) {
            CustomSnackbar.showError(
              context: context,
              message: state.message,
            );
          }
        },
        builder: (context, state) {
          return RefreshIndicator.adaptive(
            onRefresh: () async {
              context.read<ChatListBloc>().add(const RefreshChatsListEvent());
            },
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: _buildContent(state),
            ),
          );
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      centerTitle: true,
      title: BlocBuilder<ChatListBloc, ChatListState>(
        builder: (context, state) {
          return Column(
            children: [
              const Text(
                'Чаты',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.textColor,
                ),
              ),
              if (state is ChatListLoaded && state.hasUnreadMessages) ...[
                2.h,
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Text(
                    '${state.totalUnreadCount} новых',
                    style: const TextStyle(
                      fontSize: 10,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(ChatListState state) {
    if (state is ChatListLoading) {
      return _buildLoadingState();
    } else if (state is ChatListLoaded || state is ChatListRefreshing) {
      final chats = state is ChatListLoaded
          ? state.chats
          : (state as ChatListRefreshing).currentChats;

      return _buildLoadedState(chats, state is ChatListRefreshing);
    } else if (state is ChatListEmpty) {
      return _buildEmptyState(state.message);
    } else if (state is ChatListError) {
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
            'Загружаем чаты...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ColorConstants.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadedState(List<ChatEntity> chats, bool isRefreshing) {
    return Stack(
      children: [
        ListView.builder(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          itemCount: chats.length,
          physics: const BouncingScrollPhysics(),
          itemBuilder: (context, index) {
            final chat = chats[index];
            return _buildAnimatedChatItem(chat, index);
          },
        ),

        // Refresh indicator
        if (isRefreshing)
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(8),
              color: ColorConstants.primaryColor.withOpacity(0.1),
              child: const Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                          ColorConstants.primaryColor),
                    ),
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Обновляем...',
                    style: TextStyle(
                      fontSize: 12,
                      color: ColorConstants.primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnimatedChatItem(ChatEntity chat, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: Duration(milliseconds: 300 + (index * 50)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 30 * value),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: _ChatListItem(
        chat: chat,
        onTap: () => _openChat(chat),
        onMarkAsRead:
            chat.hasUnreadMessages ? () => _markAsRead(chat.id) : null,
      ),
    );
  }

  Widget _buildEmptyState(String message) {
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
            Text(
              'Нет активных чатов',
              style: TextStyle(
                fontSize: 20,
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
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorConstants.errorColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.error_outline_rounded,
                size: 40,
                color: ColorConstants.errorColor,
              ),
            ),
            24.h,
            const Text(
              'Ошибка загрузки',
              style: TextStyle(
                fontSize: 20,
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
            32.h,
            ElevatedButton.icon(
              onPressed: _loadChats,
              icon: const Icon(Icons.refresh_rounded),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                padding:
                    const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _openChat(ChatEntity chat) {
    // Go Router orqali chat detail sahifasiga o'tish
    context.push(
      '/chat/${chat.id}',
      extra: {
        'chat': chat,
      },
    );
  }

  void _markAsRead(int chatId) {
    context.read<ChatListBloc>().add(MarkChatAsReadEvent(chatId));
  }
}

class _ChatListItem extends StatelessWidget {
  final ChatEntity chat;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsRead;

  const _ChatListItem({
    required this.chat,
    required this.onTap,
    this.onMarkAsRead,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: chat.hasUnreadMessages ? 2 : 1,
        shadowColor: chat.hasUnreadMessages
            ? ColorConstants.primaryColor.withOpacity(0.2)
            : Colors.black.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: chat.hasUnreadMessages
                  ? Border.all(
                      color: ColorConstants.primaryColor.withOpacity(0.3),
                      width: 1,
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildAvatar(),
                12.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      6.h,
                      _buildLastMessage(),
                    ],
                  ),
                ),
                _buildTrailing(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return Stack(
      children: [
        Container(
          width: 52,
          height: 52,
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
            boxShadow: [
              BoxShadow(
                color: ColorConstants.primaryColor.withOpacity(0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Text(
              chat.doctorName.isNotEmpty
                  ? chat.doctorName[0].toUpperCase()
                  : 'Д',
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),

        // Online indicator
        if (chat.isActive)
          Positioned(
            bottom: 2,
            right: 2,
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                color: ColorConstants.successColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            'Др. ${chat.doctorName}',
            style: TextStyle(
              fontSize: 16,
              fontWeight:
                  chat.hasUnreadMessages ? FontWeight.w600 : FontWeight.w500,
              color: ColorConstants.textColor,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        Text(
          chat.formattedTime,
          style: TextStyle(
            fontSize: 12,
            color: chat.hasUnreadMessages
                ? ColorConstants.primaryColor
                : ColorConstants.secondaryTextColor,
            fontWeight:
                chat.hasUnreadMessages ? FontWeight.w500 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildLastMessage() {
    final lastMessage = chat.lastMessage;

    if (lastMessage == null) {
      return Text(
        'Нет сообщений',
        style: TextStyle(
          fontSize: 14,
          color: ColorConstants.secondaryTextColor,
          fontStyle: FontStyle.italic,
        ),
      );
    }

    return Row(
      children: [
        if (lastMessage.isFromCurrentUser) ...[
          Icon(
            Icons.reply_rounded,
            size: 14,
            color: ColorConstants.secondaryTextColor,
          ),
          4.w,
        ],
        Expanded(
          child: Text(
            lastMessage.displayContent,
            style: TextStyle(
              fontSize: 14,
              color: chat.hasUnreadMessages
                  ? ColorConstants.textColor
                  : ColorConstants.secondaryTextColor,
              fontWeight:
                  chat.hasUnreadMessages ? FontWeight.w500 : FontWeight.normal,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  Widget _buildTrailing() {
    return Column(
      children: [
        if (chat.hasUnreadMessages) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              chat.unreadCount > 99 ? '99+' : chat.unreadCount.toString(),
              style: const TextStyle(
                color: Colors.white,
                fontSize: 12,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          if (onMarkAsRead != null) ...[
            8.h,
            GestureDetector(
              onTap: onMarkAsRead,
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(
                  Icons.done_all_rounded,
                  size: 16,
                  color: ColorConstants.primaryColor,
                ),
              ),
            ),
          ],
        ] else ...[
          const Icon(
            Icons.arrow_forward_ios_rounded,
            size: 16,
            color: ColorConstants.secondaryTextColor,
          ),
        ],
      ],
    );
  }
}
