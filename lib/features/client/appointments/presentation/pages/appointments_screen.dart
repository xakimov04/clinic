import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_bloc.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_event.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_state.dart';
import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _tabConfigs = TabConfig.tabConfigs;

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBloc>().add(GetAppointmentsEvent());
    _tabController = TabController(length: _tabConfigs.length, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _buildAppBar(),
      body: BlocConsumer<AppointmentBloc, AppointmentState>(
        listener: (context, state) {
          // Error handling
          if (state is AppointmentError) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text(state.message),
                backgroundColor: ColorConstants.errorColor,
                behavior: SnackBarBehavior.floating,
              ),
            );
          }
        },
        builder: (context, state) {
          return _buildBody(state);
        },
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Встречи'),
      backgroundColor: ColorConstants.backgroundColor,
      elevation: 0,
      centerTitle: true,
      actions: [
        IconButton(
          icon: const Icon(Icons.refresh),
          onPressed: () {
            context.read<AppointmentBloc>().add(GetAppointmentsEvent());
          },
        ),
      ],
    );
  }

  Widget _buildBody(AppointmentState state) {
    return Column(
      children: [
        _buildTabBar(),
        Expanded(
          child: _buildTabBarView(state),
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
        tabs: _tabConfigs.map((config) => Tab(text: config.label)).toList(),
      ),
    );
  }

  Widget _buildTabBarView(AppointmentState state) {
    return TabBarView(
      controller: _tabController,
      children: List.generate(_tabConfigs.length, (index) {
        return _AppointmentsList(
          state: state,
          tabIndex: index,
          tabConfigs: _tabConfigs,
          onRefresh: () {
            context.read<AppointmentBloc>().add(GetAppointmentsEvent());
          },
          onRetry: () {
            context.read<AppointmentBloc>().add(GetAppointmentsEvent());
          },
        );
      }),
    );
  }
}

class _AppointmentsList extends StatelessWidget {
  final AppointmentState state;
  final int tabIndex;
  final List<TabConfig> tabConfigs;
  final VoidCallback onRefresh;
  final VoidCallback onRetry;

  const _AppointmentsList({
    required this.state,
    required this.tabIndex,
    required this.tabConfigs,
    required this.onRefresh,
    required this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return switch (state) {
      AppointmentInitial() || AppointmentLoading() => const _LoadingView(),
      AppointmentError(message: final message) => _ErrorView(
          message: message,
          onRetry: onRetry,
        ),
      AppointmentsLoaded(appointments: final appointments) =>
        _buildLoadedView(appointments),

      // Boshqa state-lar uchun default
      _ => const _LoadingView(),
    };
  }

  Widget _buildLoadedView(List<AppointmentModel> appointments) {
    final filteredAppointments = _getFilteredAppointments(appointments);

    if (filteredAppointments.isEmpty) {
      return const _EmptyView();
    }

    return _AppointmentsListView(
      appointments: filteredAppointments,
      onRefresh: onRefresh,
      isRefreshing: false,
    );
  }

  List<AppointmentModel> _getFilteredAppointments(
      List<AppointmentModel> appointments) {
    final config = tabConfigs[tabIndex];
    return appointments
        .where((appointment) => config.statuses.contains(appointment.status))
        .toList();
  }
}

class _LoadingView extends StatelessWidget {
  const _LoadingView();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(
              ColorConstants.primaryColor,
            ),
          ),
          SizedBox(height: 16),
          Text(
            'Загрузка встреч...',
            style: TextStyle(
              fontSize: 16,
              color: ColorConstants.secondaryTextColor,
            ),
          ),
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

class _AppointmentsListView extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final VoidCallback onRefresh;
  final bool isRefreshing;

  const _AppointmentsListView({
    required this.appointments,
    required this.onRefresh,
    required this.isRefreshing,
  });

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () async {
        onRefresh();
        // BLoC state o'zgarishini kutish
        await Future.delayed(const Duration(milliseconds: 500));
      },
      child: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          final isLoading = state is AppointmentLoading;

          return ListView.builder(
            padding: 16.a,
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: appointments.length,
            itemBuilder: (context, index) {
              final appointment = appointments[index];
              return AnimatedOpacity(
                opacity: isLoading ? 0.6 : 1.0,
                duration: const Duration(milliseconds: 200),
                child: _AppointmentCard(appointment: appointment),
              );
            },
          );
        },
      ),
    );
  }
}

/// Appointment card widget
class _AppointmentCard extends StatelessWidget {
  final AppointmentModel appointment;

  const _AppointmentCard({
    required this.appointment,
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
        appointment.status.displayName,
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
            borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
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
            _buildStatusRow('Статус', appointment.status.displayName,
                appointment.status.icon),
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
    final statusColor = appointment.status.color;

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
}
