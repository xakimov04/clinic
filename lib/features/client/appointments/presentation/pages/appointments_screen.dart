import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/features/client/appointments/domain/repositories/appointment_repository.dart';

/// Appointments state enum
enum AppointmentsViewState { initial, loading, loaded, error, refreshing }

/// Tab configuration model
class _TabConfig {
  final AppointmentStatus status;
  final String label;
  final IconData icon;

  const _TabConfig({
    required this.status,
    required this.label,
    required this.icon,
  });
}

/// Main appointments screen with optimized architecture
class AppointmentsScreen extends StatefulWidget {
  final AppointmentRepository repository;

  const AppointmentsScreen({
    super.key,
    required this.repository,
  });

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  // State management
  List<AppointmentModel> _appointments = [];
  AppointmentsViewState _viewState = AppointmentsViewState.initial;
  String? _errorMessage;

  // Tab controller
  late TabController _tabController;

  // Tab configurations
  static const List<_TabConfig> _tabConfigs = [
    _TabConfig(
      status: AppointmentStatus.pending,
      label: 'Ожидает',
      icon: Icons.access_time_outlined,
    ),
    _TabConfig(
      status: AppointmentStatus.confirmed,
      label: 'Подтверждено',
      icon: Icons.check_circle_outline,
    ),
    _TabConfig(
      status: AppointmentStatus.completed,
      label: 'Завершено',
      icon: Icons.task_alt_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabConfigs.length, vsync: this);
    _tabController.addListener(_onTabChanged);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.removeListener(_onTabChanged);
    _tabController.dispose();
    super.dispose();
  }

  void _onTabChanged() {
    if (_tabController.indexIsChanging) {
      setState(() {});
    }
  }

  /// Appointments ni yuklash
  Future<void> _loadAppointments({bool isRefresh = false}) async {
    if (!mounted) return;

    setState(() {
      _viewState = isRefresh
          ? AppointmentsViewState.refreshing
          : AppointmentsViewState.loading;
      if (!isRefresh) _errorMessage = null;
    });

    try {
      final result = await widget.repository.getAppointments();

      if (!mounted) return;

      result.fold(
        (failure) {
          setState(() {
            _viewState = AppointmentsViewState.error;
            _errorMessage = failure.message;
          });
        },
        (appointments) {
          setState(() {
            _appointments = appointments.sortByDate();
            _viewState = AppointmentsViewState.loaded;
          });
        },
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _viewState = AppointmentsViewState.error;
        _errorMessage = 'Неожиданная ошибка: ${e.toString()}';
      });
    }
  }

  /// Refresh appointments
  Future<void> _onRefresh() async {
    await _loadAppointments(isRefresh: true);
  }

  /// Отмена записи
  Future<void> _cancelAppointment(AppointmentModel appointment) async {
    if (!appointment.status.canCancel) {
      _showSnackBar('Эту запись нельзя отменить', isError: true);
      return;
    }

    final confirmed = await _showConfirmationDialog(
      title: 'Отменить запись',
      content:
          'Вы уверены, что хотите отменить запись к ${appointment.doctorName}?',
      confirmText: 'Отменить',
      cancelText: 'Назад',
    );

    if (confirmed != true) return;

    try {
      await _loadAppointments();
      _showSnackBar('Запись успешно отменена');
    } catch (e) {
      _showSnackBar('Ошибка при отмене записи: ${e.toString()}', isError: true);
    }
  }

  /// Показать snackbar
  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? ColorConstants.errorColor : null,
        behavior: SnackBarBehavior.floating,
        action: isError
            ? SnackBarAction(
                label: 'Закрыть',
                onPressed: () =>
                    ScaffoldMessenger.of(context).hideCurrentSnackBar(),
              )
            : null,
      ),
    );
  }

  /// Показать диалог подтверждения
  Future<bool?> _showConfirmationDialog({
    required String title,
    required String content,
    required String confirmText,
    required String cancelText,
  }) {
    return showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(content),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text(cancelText),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(context).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: ColorConstants.errorColor,
              foregroundColor: Colors.white,
            ),
            child: Text(confirmText),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: _buildBody(),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Записи'),
      backgroundColor: ColorConstants.backgroundColor,
      elevation: 0,
      centerTitle: true,
    );
  }

  Widget _buildBody() {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: _buildTabBarView(),
        ),
      ],
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: Colors.white,
      child: TabBar(
        controller: _tabController,
        labelColor: ColorConstants.primaryColor,
        unselectedLabelColor: ColorConstants.secondaryTextColor,
        indicatorColor: ColorConstants.primaryColor,
        indicatorWeight: 3,
        tabs: _tabConfigs
            .map((config) => Tab(
                  text: config.label,
                ))
            .toList(),
      ),
    );
  }

  Widget _buildTabBarView() {
    return TabBarView(
      controller: _tabController,
      children: _tabConfigs
          .map(
            (config) => _AppointmentsList(
              appointments: _appointments.filterByStatus(config.status),
              viewState: _viewState,
              errorMessage: _errorMessage,
              onRefresh: _onRefresh,
              onRetry: _loadAppointments,
              onCancel: _cancelAppointment,
            ),
          )
          .toList(),
    );
  }
}

/// Appointments list widget
class _AppointmentsList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final AppointmentsViewState viewState;
  final String? errorMessage;
  final VoidCallback onRefresh;
  final VoidCallback onRetry;
  final Function(AppointmentModel) onCancel;

  const _AppointmentsList({
    required this.appointments,
    required this.viewState,
    required this.errorMessage,
    required this.onRefresh,
    required this.onRetry,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    switch (viewState) {
      case AppointmentsViewState.loading:
        return const _LoadingView();
      case AppointmentsViewState.error:
        return _ErrorView(
          message: errorMessage ?? 'Неизвестная ошибка',
          onRetry: onRetry,
        );
      case AppointmentsViewState.loaded:
      case AppointmentsViewState.refreshing:
        if (appointments.isEmpty) {
          return const _EmptyView();
        }
        return _AppointmentsListView(
          appointments: appointments,
          onRefresh: onRefresh,
          onCancel: onCancel,
          isRefreshing: viewState == AppointmentsViewState.refreshing,
        );
      default:
        return const SizedBox.shrink();
    }
  }
}

/// Loading view
class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text('Загрузка записей...'),
        ],
      ),
    );
  }
}

/// Error view
class _ErrorView extends StatelessWidget {
  final String message;
  final VoidCallback onRetry;

  const _ErrorView({
    required this.message,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: ColorConstants.errorColor,
            ),
            16.h,
            Text(
              'Ошибка',
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: ColorConstants.errorColor,
              ),
            ),
            8.h,
            Text(
              message,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: ColorConstants.secondaryTextColor,
              ),
            ),
            24.h,
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
            ),
          ],
        ),
      ),
    );
  }
}

/// Empty view
class _EmptyView extends StatelessWidget {
  const _EmptyView();

  @override
  Widget build(BuildContext context) {
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
              fontWeight: FontWeight.w500,
              color: Colors.grey.shade600,
            ),
          ),
          8.h,
          Text(
            'Здесь будут отображаться ваши записи',
            style: TextStyle(
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ),
    );
  }
}

/// Appointments list view
class _AppointmentsListView extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final VoidCallback onRefresh;
  final Function(AppointmentModel) onCancel;
  final bool isRefreshing;

  const _AppointmentsListView({
    required this.appointments,
    required this.onRefresh,
    required this.onCancel,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      child: ListView.builder(
        padding: 16.a,
        physics: const AlwaysScrollableScrollPhysics(),
        itemCount: appointments.length,
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _AppointmentCard(
            appointment: appointment,
            onCancel: () => onCancel(appointment),
          );
        },
      ),
    );
  }
}

/// Appointment card widget
class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;
  final VoidCallback onCancel;

  const _AppointmentCard({
    required this.appointment,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: 8.v,
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: InkWell(
        onTap: () => _showAppointmentDetails(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: 12.a,
          child: Column(
            children: [
              _buildCardHeader(),
              12.h,
              _buildCardContent(),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCardHeader() {
    return Row(
      children: [
        _buildStatusIcon(),
        12.w,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                appointment.doctorName,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              4.h,
              Text(
                appointment.clinicName,
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorConstants.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
        _buildStatusBadge(),
      ],
    );
  }

  Widget _buildStatusIcon() {
    return Container(
      width: 48,
      height: 48,
      decoration: BoxDecoration(
        color: appointment.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Icon(
        appointment.status.icon,
        color: appointment.status.color,
        size: 24,
      ),
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: appointment.status.color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        appointment.status.displayText,
        style: TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w600,
          color: appointment.status.color,
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: Colors.grey.shade600,
        ),
        4.w,
        Text(
          '${appointment.formattedDate} в ${appointment.appointmentTime}',
          style: TextStyle(
            fontSize: 12,
            color: Colors.grey.shade600,
          ),
        ),
        if (appointment.isToday) ...[
          8.w,
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              'Сегодня',
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: ColorConstants.primaryColor,
              ),
            ),
          ),
        ],
      ],
    );
  }

  void _showAppointmentDetails(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _AppointmentDetailsSheet(appointment: appointment),
    );
  }
}

class _AppointmentDetailsSheet extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentDetailsSheet({
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return DraggableScrollableSheet(
      expand: false,
      initialChildSize: 0.6,
      maxChildSize: 0.9,
      minChildSize: 0.4,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: 16.verticalTop,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 20,
                offset: const Offset(0, -5),
              ),
            ],
          ),
          child: Column(
            children: [
              _buildHandle(),
              Expanded(
                child: SingleChildScrollView(
                  controller: scrollController,
                  padding: 20.a,
                  child: _buildContent(),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildHandle() {
    return Container(
      width: 50,
      height: 5,
      margin: const EdgeInsets.symmetric(vertical: 12),
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(3),
      ),
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Text(
            'Подробности записи',
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.w700,
              color: Colors.grey.shade800,
              letterSpacing: -0.5,
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildDetailCard(),
        if (appointment.notes?.isNotEmpty ?? false) ...[
          const SizedBox(height: 20),
          _buildNotesCard(),
        ],
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildDetailCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade100,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDetailRow(
                'Врач', appointment.doctorName, Icons.person_outline),
            const SizedBox(height: 16),
            _buildDetailRow('Клиника', appointment.clinicName,
                Icons.local_hospital_outlined),
            const SizedBox(height: 16),
            _buildDetailRow('Дата', appointment.formattedDate,
                Icons.calendar_today_outlined),
            const SizedBox(height: 16),
            _buildDetailRow('Время', appointment.appointmentTime,
                Icons.access_time_outlined),
            const SizedBox(height: 16),
            _buildStatusRow(
                'Статус', appointment.status.displayText, _getStatusIcon()),
          ],
        ),
      ),
    );
  }

  Widget _buildNotesCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.blue.shade100,
          width: 1,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade100,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.note_outlined,
                    size: 20,
                    color: Colors.blue.shade600,
                  ),
                ),
                const SizedBox(width: 12),
                Text(
                  'Заметки',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    color: Colors.blue.shade700,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.shade100,
                  width: 1,
                ),
              ),
              child: Text(
                appointment.notes!,
                style: TextStyle(
                  fontSize: 15,
                  height: 1.5,
                  color: Colors.grey.shade700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value, IconData icon) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: Colors.grey.shade50,
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(
            icon,
            size: 22,
            color: Colors.grey.shade600,
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey.shade500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                value,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.grey.shade800,
                  height: 1.3,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildStatusRow(String label, String value, IconData icon) {
    final statusColor = _getStatusColor();

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            statusColor.withOpacity(0.05),
            statusColor.withOpacity(0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: statusColor.withOpacity(0.2),
          width: 1.5,
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: statusColor.withOpacity(0.15),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: statusColor.withOpacity(0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Icon(
              icon,
              size: 24,
              color: statusColor,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    color: Colors.grey.shade600,
                    letterSpacing: 0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 8,
                        ),
                        decoration: BoxDecoration(
                          color: statusColor,
                          borderRadius: BorderRadius.circular(25),
                          boxShadow: [
                            BoxShadow(
                              color: statusColor.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: Text(
                          value,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor() {
    switch (appointment.status.name.toString().toLowerCase()) {
      case 'pending':
        return const Color(0xFFFF9800); // Amber/Orange
      case 'confirmed':
        return const Color(0xFF4CAF50); // Green
      case 'cancelled':
        return const Color(0xFFF44336); // Red
      case 'completed':
        return const Color(0xFF2196F3); // Blue
      default:
        return const Color(0xFF9E9E9E); // Grey
    }
  }

  IconData _getStatusIcon() {
    switch (appointment.status.name.toString().toLowerCase()) {
      case 'pending':
        return Icons.schedule_outlined;
      case 'confirmed':
        return Icons.check_circle_outline;
      case 'cancelled':
        return Icons.cancel_outlined;
      case 'completed':
        return Icons.task_alt_outlined;
      default:
        return Icons.info_outline;
    }
  }
}
