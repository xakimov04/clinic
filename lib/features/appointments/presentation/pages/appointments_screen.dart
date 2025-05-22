import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';

class AppointmentsScreen extends StatelessWidget {
  const AppointmentsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Записи'),
        backgroundColor: ColorConstants.backgroundColor,
        elevation: 0,
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showNewAppointmentDialog(context);
            },
          ),
        ],
      ),
      backgroundColor: ColorConstants.backgroundColor,
      body: DefaultTabController(
        length: 3,
        child: Column(
          children: [
            Container(
              color: Colors.white,
              child: const TabBar(
                labelColor: ColorConstants.primaryColor,
                unselectedLabelColor: ColorConstants.secondaryTextColor,
                indicatorColor: ColorConstants.primaryColor,
                tabs: [
                  Tab(text: 'Активные'),
                  Tab(text: 'Завершенные'),
                  Tab(text: 'Отмененные'),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                children: [
                  _buildAppointmentsList(AppointmentStatus.active),
                  _buildAppointmentsList(AppointmentStatus.completed),
                  _buildAppointmentsList(AppointmentStatus.cancelled),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAppointmentsList(AppointmentStatus status) {
    final appointments = _getMockAppointments(status);

    if (appointments.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.event_busy_outlined,
              size: 64,
              color: Colors.grey.shade400,
            ),
            16.h,
            Text(
              'Нет записей',
              style: TextStyle(
                fontSize: 18,
                color: Colors.grey.shade600,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: 16.a,
      itemCount: appointments.length,
      itemBuilder: (context, index) {
        final appointment = appointments[index];
        return _AppointmentCard(appointment: appointment);
      },
    );
  }

  void _showNewAppointmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Новая запись'),
        content: const Text('Здесь будет форма для создания новой записи к врачу.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Создать'),
          ),
        ],
      ),
    );
  }

  List<AppointmentModel> _getMockAppointments(AppointmentStatus status) {
    switch (status) {
      case AppointmentStatus.active:
        return [
          AppointmentModel(
            id: '1',
            doctorName: 'Доктор Иванов',
            specialty: 'Терапевт',
            date: DateTime.now().add(const Duration(days: 1)),
            status: AppointmentStatus.active,
          ),
          AppointmentModel(
            id: '2',
            doctorName: 'Доктор Петрова',
            specialty: 'Кардиолог',
            date: DateTime.now().add(const Duration(days: 3)),
            status: AppointmentStatus.active,
          ),
        ];
      case AppointmentStatus.completed:
        return [
          AppointmentModel(
            id: '3',
            doctorName: 'Доктор Сидоров',
            specialty: 'Невролог',
            date: DateTime.now().subtract(const Duration(days: 7)),
            status: AppointmentStatus.completed,
          ),
        ];
      case AppointmentStatus.cancelled:
        return [
          AppointmentModel(
            id: '4',
            doctorName: 'Доктор Козлов',
            specialty: 'Хирург',
            date: DateTime.now().subtract(const Duration(days: 2)),
            status: AppointmentStatus.cancelled,
          ),
        ];
    }
  }
}

class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({required this.appointment});

  @override
  Widget build(BuildContext context) {
    Color statusColor = appointment.status.color;
    IconData statusIcon = appointment.status.icon;
    String statusText = appointment.status.text;

    return Card(
      margin: 8.v,
      child: ListTile(
        leading: Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: statusColor.withOpacity(0.1),
            borderRadius: 8.circular,
          ),
          child: Icon(
            statusIcon,
            color: statusColor,
          ),
        ),
        title: Text(
          appointment.doctorName,
          style: const TextStyle(
            fontWeight: FontWeight.w600,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(appointment.specialty),
            4.h,
            Text(
              '${appointment.date.day}.${appointment.date.month}.${appointment.date.year} в ${appointment.date.hour}:${appointment.date.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: ColorConstants.secondaryTextColor,
                fontSize: 12,
              ),
            ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              statusIcon,
              color: statusColor,
              size: 16,
            ),
            4.h,
            Text(
              statusText,
              style: TextStyle(
                color: statusColor,
                fontSize: 10,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        onTap: () {
          _showAppointmentDetails(context, appointment);
        },
      ),
    );
  }

  void _showAppointmentDetails(BuildContext context, AppointmentModel appointment) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        expand: false,
        builder: (context, scrollController) {
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: 16.verticalTop,
            ),
            child: Column(
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: 8.v,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade300,
                    borderRadius: 2.circular,
                  ),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    controller: scrollController,
                    padding: 16.a,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Детали записи',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        16.h,
                        _buildDetailRow('Врач:', appointment.doctorName),
                        _buildDetailRow('Специальность:', appointment.specialty),
                        _buildDetailRow('Дата:', '${appointment.date.day}.${appointment.date.month}.${appointment.date.year}'),
                        _buildDetailRow('Время:', '${appointment.date.hour}:${appointment.date.minute.toString().padLeft(2, '0')}'),
                        _buildDetailRow('Статус:', appointment.status.text),
                        16.h,
                        if (appointment.status == AppointmentStatus.active) ...[
                          Row(
                            children: [
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _cancelAppointment(context);
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: ColorConstants.errorColor,
                                  ),
                                  child: const Text('Отменить'),
                                ),
                              ),
                              8.w,
                              Expanded(
                                child: ElevatedButton(
                                  onPressed: () {
                                    Navigator.of(context).pop();
                                    _rescheduleAppointment(context);
                                  },
                                  child: const Text('Перенести'),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: 4.v,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(value),
          ),
        ],
      ),
    );
  }

  void _cancelAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Отменить запись'),
        content: const Text('Вы уверены, что хотите отменить эту запись?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Нет'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Да'),
          ),
        ],
      ),
    );
  }

  void _rescheduleAppointment(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Перенести запись'),
        content: const Text('Здесь будет календарь для выбора новой даты.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Отмена'),
          ),
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Сохранить'),
          ),
        ],
      ),
    );
  }
}

enum AppointmentStatus { active, completed, cancelled }

extension AppointmentStatusExtension on AppointmentStatus {
  Color get color {
    switch (this) {
      case AppointmentStatus.active:
        return ColorConstants.primaryColor;
      case AppointmentStatus.completed:
        return ColorConstants.successColor;
      case AppointmentStatus.cancelled:
        return ColorConstants.errorColor;
    }
  }

  IconData get icon {
    switch (this) {
      case AppointmentStatus.active:
        return Icons.access_time;
      case AppointmentStatus.completed:
        return Icons.check_circle;
      case AppointmentStatus.cancelled:
        return Icons.cancel;
    }
  }

  String get text {
    switch (this) {
      case AppointmentStatus.active:
        return 'Активна';
      case AppointmentStatus.completed:
        return 'Завершена';
      case AppointmentStatus.cancelled:
        return 'Отменена';
    }
  }
}

class AppointmentModel {
  final String id;
  final String doctorName;
  final String specialty;
  final DateTime date;
  final AppointmentStatus status;

  AppointmentModel({
    required this.id,
    required this.doctorName,
    required this.specialty,
    required this.date,
    required this.status,
  });
}