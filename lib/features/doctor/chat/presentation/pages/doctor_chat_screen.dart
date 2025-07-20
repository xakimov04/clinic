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

class DoctorChatScreen extends StatefulWidget {
  const DoctorChatScreen({super.key});

  @override
  State<DoctorChatScreen> createState() => _DoctorChatScreenState();
}

class _DoctorChatScreenState extends State<DoctorChatScreen>
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
                'Пациенты',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: ColorConstants.textColor,
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildContent(ChatListState state) {
    if (state is ChatListLoading) {
      return _buildLoadingState();
    } else if (state is ChatListLoaded ||
        state is ChatListRefreshing ||
        state is ChatCreating) {
      // Barcha holatlarda chatlarni olish
      List<ChatEntity> chats = [];
      bool isRefreshing = false;
      bool isCreatingChat = false;

      if (state is ChatListLoaded) {
        chats = state.chats;
      } else if (state is ChatListRefreshing) {
        chats = state.currentChats;
        isRefreshing = true;
      } else if (state is ChatCreating) {
        chats = state.currentChats;
        isCreatingChat = true;
      }

      return _buildLoadedState(chats, isRefreshing, isCreatingChat);
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
            'Загружаем пациентов...',
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

  Widget _buildLoadedState(
      List<ChatEntity> chats, bool isRefreshing, bool isCreatingChat) {
    // Doctor uchun chatlarni kategoriyalarga bo'lamiz
    final activeChats = chats.where((chat) => chat.hasUnreadMessages).toList();
    final regularChats =
        chats.where((chat) => !chat.hasUnreadMessages).toList();

    return Stack(
      children: [
        SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          physics: const BouncingScrollPhysics(),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Aktiv chatlar (yangi xabarlar bilan)
              if (activeChats.isNotEmpty) ...[
                8.h,
                ...activeChats.asMap().entries.map((entry) {
                  return _buildAnimatedChatItem(entry.value, entry.key,
                      isUrgent: true);
                }),
                24.h,
              ],

              // Oddiy chatlar
              if (regularChats.isNotEmpty) ...[
                8.h,
                ...regularChats.asMap().entries.map((entry) {
                  return _buildAnimatedChatItem(entry.value, entry.key);
                }),
              ],

              // Agar hech qanday chat yo'q bo'lsa
              if (chats.isEmpty) ...[
                Center(
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
                            Icons.people_outline_rounded,
                            size: 40,
                            color: ColorConstants.primaryColor,
                          ),
                        ),
                        24.h,
                        const Text(
                          'Нет пациентов',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            color: ColorConstants.textColor,
                          ),
                        ),
                        8.h,
                        const Text(
                          'Новые чаты появятся здесь',
                          style: TextStyle(
                            fontSize: 14,
                            color: ColorConstants.secondaryTextColor,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
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

        // Creating chat indicator
        if (isCreatingChat)
          Positioned(
            bottom: 20,
            left: 0,
            right: 0,
            child: Center(
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  color: ColorConstants.primaryColor,
                  borderRadius: BorderRadius.circular(25),
                  boxShadow: [
                    BoxShadow(
                      color: ColorConstants.primaryColor.withOpacity(0.3),
                      blurRadius: 10,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Создаем чат...',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.white,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildAnimatedChatItem(ChatEntity chat, int index,
      {bool isUrgent = false}) {
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
      child: _DoctorChatListItem(
        chat: chat,
        onTap: () => _openChat(chat),
        onMarkAsRead:
            chat.hasUnreadMessages ? () => _markAsRead(chat.id) : null,
        isUrgent: isUrgent,
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
                Icons.people_outline_rounded,
                size: 40,
                color: ColorConstants.primaryColor,
              ),
            ),
            24.h,
            const Text(
              'Нет пациентов',
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
    context.push(
      '/doctor-chat/${chat.id}',
      extra: {
        'chat': chat,
      },
    ).then(
      (value) {
        context.read<ChatListBloc>().add( GetChatsListEventNotLoading());
      },
    );
  }

  void _markAsRead(int chatId) {
    context.read<ChatListBloc>().add(MarkChatAsReadEvent(chatId));
  }
}

class _DoctorChatListItem extends StatelessWidget {
  final ChatEntity chat;
  final VoidCallback onTap;
  final VoidCallback? onMarkAsRead;
  final bool isUrgent;

  const _DoctorChatListItem({
    required this.chat,
    required this.onTap,
    this.onMarkAsRead,
    this.isUrgent = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        elevation: chat.hasUnreadMessages ? 3 : 1,
        shadowColor: isUrgent
            ? ColorConstants.primaryColor.withOpacity(0.3)
            : Colors.black.withOpacity(0.05),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(16),
              border: isUrgent
                  ? Border.all(
                      color: ColorConstants.primaryColor.withOpacity(0.4),
                      width: 1.5,
                    )
                  : null,
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildPatientAvatar(),
                12.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      6.h,
                      _buildLastMessage(),
                      if (isUrgent) ...[
                        8.h,
                        _buildUrgentIndicator(),
                      ],
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

  Widget _buildPatientAvatar() {
    return Container(
      width: 52,
      height: 52,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstants.accentGreen,
            ColorConstants.accentGreen.withOpacity(0.7),
          ],
        ),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.accentGreen.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          chat.patientName.isNotEmpty ? chat.patientName[0].toUpperCase() : 'П',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            chat.patientName,
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
        // Doctor tomonidan yuborilgan xabar uchun icon
        if (!lastMessage.isFromCurrentUser) ...[
          Icon(
            Icons.reply_rounded,
            size: 14,
            color: ColorConstants.primaryColor,
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

  Widget _buildUrgentIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: ColorConstants.accentRed.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: ColorConstants.accentRed.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.priority_high_rounded,
            size: 12,
            color: ColorConstants.accentRed,
          ),
          4.w,
          Text(
            'Требует внимания',
            style: TextStyle(
              fontSize: 10,
              color: ColorConstants.accentRed,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
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
