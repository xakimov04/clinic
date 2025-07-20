import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/client/chat/domain/entities/chat_entity.dart';
import 'package:clinic/features/client/chat/presentation/bloc/chat_list/chat_list_bloc.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/appointments/data/models/put_appointment_model.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_bloc.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_event.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_state.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class AppointmentDetailScreen extends StatefulWidget {
  final AppointmentModel appointment;

  const AppointmentDetailScreen({
    super.key,
    required this.appointment,
  });

  @override
  State<AppointmentDetailScreen> createState() =>
      _AppointmentDetailScreenState();
}

class _AppointmentDetailScreenState extends State<AppointmentDetailScreen> {
  /// Local state da appointment ni saqlash
  late AppointmentModel _currentAppointment;

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
        BlocListener<AppointmentBloc, AppointmentState>(
          listener: (context, state) {
            if (state is AppointmentUpdated) {
              // Success message
              CustomSnackbar.showSuccess(
                  context: context, message: 'Статус записи успешно обновлен');

              // Local state ni yangilash - ORTGA QAYTMASDAN
              setState(() {
                _currentAppointment = _currentAppointment.copyWith(
                  status: _getUpdatedStatus(state),
                  updatedAt: DateTime.now(),
                );
              });

              // Parent list ni yangilash uchun
              context.read<AppointmentBloc>().add(GetAppointmentsEvent());
            } else if (state is AppointmentError) {
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

  /// Updated status ni aniqlash
  AppointmentStatus _getUpdatedStatus(AppointmentUpdated state) {
    return AppointmentStatus.fromString(state.putAppointmentModel.status);
  }

  AppBar _buildAppBar() {
    return AppBar(
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
        // Chat tugmasi faqat confirmed status uchun ko'rsatiladi
        if (_currentAppointment.status == AppointmentStatus.confirmed)
          BlocBuilder<ChatListBloc, ChatListState>(
            builder: (context, state) {
              final isCreatingChat = state is ChatCreating;

              return IconButton(
                onPressed: isCreatingChat ? null : () => _createChat(context),
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
          ),
      ],
      iconTheme: const IconThemeData(color: Colors.black),
    );
  }

  Widget _buildBody() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Пациент
          _buildInfoRow('Пациент', _currentAppointment.patientName),
          const SizedBox(height: 20),

          // Дата
          _buildInfoRow('Дата', _currentAppointment.formattedDate),
          const SizedBox(height: 20),

          // Время
          _buildInfoRow('Время', _currentAppointment.appointmentTime),
          const SizedBox(height: 20),

          // Клиника
          _buildInfoRow('Клиника', _currentAppointment.clinicName),
          const SizedBox(height: 20),

          // Статус - YANGILANUVCHI
          _buildStatusRow('Статус', _currentAppointment.status.displayText),

          // Заметки
          if (_currentAppointment.notes?.isNotEmpty == true) ...[
            const SizedBox(height: 30),
            _buildNotesSection(),
          ],

          const Spacer(),

          // Action buttons - STATUS GA QARAB DINAMIK
          _buildActionButtonsForCurrentStatus(),
        ],
      ),
    );
  }

  /// Current status ga qarab button larni ko'rsatish
  Widget _buildActionButtonsForCurrentStatus() {
    switch (_currentAppointment.status) {
      case AppointmentStatus.pending:
        return _buildActionButtons(context);
      case AppointmentStatus.confirmed:
        return _buildCompleteButton(context);
      case AppointmentStatus.completed:
      case AppointmentStatus.cancelled:
        return _buildCompletedStatusInfo();
    }
  }

  /// Tugallangan yoki bekor qilingan status uchun info
  Widget _buildCompletedStatusInfo() {
    final isCompleted =
        _currentAppointment.status == AppointmentStatus.completed;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isCompleted
            ? ColorConstants.successColor.withOpacity(0.1)
            : ColorConstants.errorColor.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isCompleted
              ? ColorConstants.successColor.withOpacity(0.3)
              : ColorConstants.errorColor.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Icon(
            isCompleted ? Icons.check_circle : Icons.cancel,
            color: isCompleted
                ? ColorConstants.successColor
                : ColorConstants.errorColor,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              isCompleted ? 'Прием успешно завершен' : 'Запись была отменена',
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: isCompleted
                    ? ColorConstants.successColor
                    : ColorConstants.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _createChat(BuildContext context) {
    context
        .read<ChatListBloc>()
        .add(CreateChatEvent(_currentAppointment.patientId));
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
                color: _currentAppointment.status.color,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              value,
              style: TextStyle(
                fontSize: 16,
                color: _currentAppointment.status.color,
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

  Widget _buildNotesSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Заметки',
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[600],
            fontWeight: FontWeight.w400,
          ),
        ),
        const SizedBox(height: 10),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.grey[50],
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: Colors.grey[200]!),
          ),
          child: Text(
            _currentAppointment.notes!,
            style: const TextStyle(
              fontSize: 15,
              color: Colors.black87,
              height: 1.4,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final isUpdating = state is AppointmentLoading;

        return Column(
          children: [
            // Qabul qilish tugmasi
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isUpdating
                    ? null
                    : () => _updateAppointmentStatus(
                          context,
                          AppointmentStatus.confirmed.value,
                        ),
                icon: isUpdating
                    ? const SizedBox(
                        width: 16,
                        height: 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation<Color>(Colors.white),
                        ),
                      )
                    : const Icon(Icons.check_circle_outline),
                label: Text(isUpdating ? 'Обновление...' : 'Подтвердить'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: ColorConstants.primaryColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 12),

            // Rad etish tugmasi
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed:
                    isUpdating ? null : () => _showCancelConfirmDialog(context),
                icon: const Icon(Icons.cancel_outlined),
                label: const Text('Отменить'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  side: BorderSide(color: Colors.red[300]!),
                  foregroundColor: Colors.red[600],
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildCompleteButton(BuildContext context) {
    return BlocBuilder<AppointmentBloc, AppointmentState>(
      builder: (context, state) {
        final isUpdating = state is AppointmentLoading;

        return SizedBox(
          width: double.infinity,
          child: ElevatedButton.icon(
            onPressed:
                isUpdating ? null : () => _showCompleteConfirmDialog(context),
            icon: isUpdating
                ? const SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Icon(Icons.task_alt_outlined),
            label: Text(isUpdating ? 'Завершение...' : 'Завершить'),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.primaryColor,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        );
      },
    );
  }

  void _showCancelConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Отменить запись'),
          content: Text(
              'Вы уверены, что хотите отменить запись пациента ${_currentAppointment.patientName}?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Назад'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateAppointmentStatus(
                  context,
                  AppointmentStatus.cancelled.value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.red,
                foregroundColor: Colors.white,
              ),
              child: const Text('Отменить'),
            ),
          ],
        );
      },
    );
  }

  void _showCompleteConfirmDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Завершить прием'),
          content: Text(
              'Вы уверены, что хотите завершить прием пациента ${_currentAppointment.patientName}?'),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Назад'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _updateAppointmentStatus(
                  context,
                  AppointmentStatus.completed.value,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
              ),
              child: const Text('Завершить'),
            ),
          ],
        );
      },
    );
  }

  void _updateAppointmentStatus(BuildContext context, String status) {
    context.read<AppointmentBloc>().add(
          UpdateAppointmentEvent(
            request: PutAppointmentModel(
              doctor: _currentAppointment.doctorId,
              clinic: _currentAppointment.clinicId,
              status: status,
            ),
            id: _currentAppointment.id.toString(),
          ),
        );
  }
}
