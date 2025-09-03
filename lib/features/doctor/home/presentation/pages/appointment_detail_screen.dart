import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:clinic/features/doctor/home/domain/entity/doctor_appointment_entity.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final DoctorAppointmentEntity appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  late DoctorAppointmentEntity _currentAppointment;

  @override
  void initState() {
    super.initState();
    _currentAppointment = widget.appointment;
  }

  @override
  Widget build(BuildContext context) {
    return MultiBlocListener(
      listeners: [
        BlocListener<ChatListBloc, ChatListState>(
          listener: (context, state) {
            if (state is ChatCreatedSuccessfully) {
              context.read<ChatListBloc>().add(const GetChatsListEvent());
              _navigateToChatDetail(context, state.chatEntity);
            } else if (state is ChatListError) {
              CustomSnackbar.showError(
                  context: context, message: state.message);
            }
          },
        ),
      ],
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: _buildAppBar(),
        body: _buildBody(),
      ),
    );
  }

  AppBar _buildAppBar() {
    return AppBar(
      surfaceTintColor: Colors.white,
      backgroundColor: Colors.white,
      elevation: 0,
      title: const Text(
        'Детали записи',
        style: TextStyle(
          color: Colors.black,
          fontSize: 18,
          fontWeight: FontWeight.w500,
        ),
      ),
      actions: [
        _currentAppointment.chatGuid.isNotEmpty
            ? BlocBuilder<ChatListBloc, ChatListState>(
                builder: (context, state) {
                  final isCreatingChat = state is ChatCreating;

                  return IconButton(
                    onPressed:
                        isCreatingChat ? null : () => _createChat(context),
                    icon: isCreatingChat
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation<Color>(
                                ColorConstants.primaryColor,
                              ),
                            ),
                          )
                        : Icon(
                            CupertinoIcons.chat_bubble_2_fill,
                            color: ColorConstants.primaryColor,
                          ),
                  );
                },
              )
            : SizedBox(),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Пациент (Полное имя)
            _buildInfoRow('Пациент', _currentAppointment.patientFullName),

            // Имя пациента
            _buildInfoRow('Имя', _currentAppointment.patientFirstName),

            // Фамилия пациента
            _buildInfoRow('Фамилия', _currentAppointment.patientLastname),

            // Возраст
            _buildInfoRow('Возраст', '${_currentAppointment.patientAge} лет'),

            // Дата рождения
            _buildInfoRow('Дата рождения',
                _formatDate(_currentAppointment.patientBirthDate)),

            // Телефон
            _buildInfoRow('Телефон', _currentAppointment.patientPhoneNumber),

            // Дата подачи заявки
            _buildInfoRow(
                'Дата подачи заявки', _currentAppointment.formattedDataZayavki),

            // Время приёма
            _buildInfoRow(
                'Время приёма', _currentAppointment.formattedAppointmentTime),

            // Статус
            _buildStatusRow('Статус', _currentAppointment.sostoyanie),
          ],
        ),
      ),
    );
  }

  void _createChat(BuildContext context) {
    context
        .read<ChatListBloc>()
        .add(CreateChatEvent(_currentAppointment.chatGuid));
  }

  void _navigateToChatDetail(BuildContext context, ChatEntity chat) {
    context.push(
      '/doctor-chat/${chat.id}',
      extra: {'chat': chat},
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          value,
          style: const TextStyle(
            fontSize: 16,
            color: Colors.black,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        Divider(
          color: Colors.grey[200],
          thickness: 1,
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Container(
              width: 8,
              height: 8,
              decoration: BoxDecoration(
                color: _getStatusColor(value),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: _getStatusColor(value),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        Divider(
          color: Colors.grey[200],
          thickness: 1,
        ),
      ],
    );
  }

  /// Helper metodlar
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}.${date.month.toString().padLeft(2, '0')}.${date.year}';
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'запланирована':
      case 'pending':
        return const Color(0xFF1976D2);
      case 'завершена':
      case 'completed':
        return const Color(0xFF388E3C); // Material Green
      case 'отменена':
      case 'cancelled':
        return const Color(0xFFD32F2F); // Material Red
      case 'в процессе':
      case 'in_progress':
        return const Color(0xFFF57C00); // Material Orange
      case 'подтверждена':
      case 'confirmed':
        return const Color(0xFF7B1FA2); // Material Purple
      default:
        return const Color(0xFF616161); // Material Grey
    }
  }
}
