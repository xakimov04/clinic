import 'package:clinic/features/client/appointments/data/models/appointment_filter.dart';
import 'package:clinic/features/doctor/home/presentation/widgets/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_bloc.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_event.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment/appointment_state.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_model.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic/core/routes/route_paths.dart';

class _TabConfig {
  final AppointmentStatus? status;
  final String label;
  final IconData icon;

  const _TabConfig({
    this.status,
    required this.label,
    required this.icon,
  });

  bool get isAllTab => status == null;
}

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  AppointmentFilters _currentFilters = AppointmentFilters.empty;

  static const List<_TabConfig> _tabConfigs = [
    _TabConfig(
      status: null,
      label: 'Все',
      icon: Icons.list_outlined,
    ),
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
    _TabConfig(
      status: AppointmentStatus.cancelled,
      label: 'Отменено',
      icon: Icons.cancel_outlined,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _tabConfigs.length, vsync: this);
    _loadAppointments();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  /// Appointmentlarni yuklash (filter bilan)
  void _loadAppointments() {
    context.read<AppointmentBloc>().add(
          GetAppointmentsEvent(filters: _currentFilters),
        );
  }

  /// Filter ochish
  void _showFilterDialog() async {
    final result = await showDialog<AppointmentFilters>(
      context: context,
      barrierDismissible: true,
      builder: (context) => FilterDialog(currentFilters: _currentFilters),
    );

    if (result != null && mounted) {
      setState(() {
        _currentFilters = result;
      });
      _loadAppointments();
    }
  }

  /// Filterlarni tozalash
  void _clearFilters() {
    if (!_currentFilters.isEmpty) {
      setState(() {
        _currentFilters = AppointmentFilters.empty;
      });
      _loadAppointments();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Записи пациентов',
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 20,
            color: Colors.black87,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        actions: [
          // Filter tugmasi
          Stack(
            children: [
              IconButton(
                onPressed: _showFilterDialog,
                icon: const Icon(
                  Icons.filter_list,
                  color: Colors.black87,
                ),
                tooltip: 'Фильтр',
              ),
              // Filter faol ekanligini ko'rsatish
              if (!_currentFilters.isEmpty)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: ColorConstants.primaryColor,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          // Filter tozalash tugmasi
          if (!_currentFilters.isEmpty)
            IconButton(
              onPressed: _clearFilters,
              icon: const Icon(
                Icons.clear,
                color: Colors.black87,
              ),
              tooltip: 'Очистить фильтр',
            ),
        ],
        bottom: _buildTabBar(),
      ),
      backgroundColor: Colors.grey[50],
      body: BlocBuilder<AppointmentBloc, AppointmentState>(
        builder: (context, state) {
          if (state is AppointmentLoading) {
            return const Center(
              child: CircularProgressIndicator(
                color: ColorConstants.primaryColor,
              ),
            );
          } else if (state is AppointmentsLoaded) {
            return _buildTabBarView(state.appointments);
          } else if (state is AppointmentError) {
            return _buildError(state.message);
          }
          return _buildEmpty();
        },
      ),
    );
  }

  PreferredSizeWidget _buildTabBar() {
    return TabBar(
      controller: _tabController,
      tabAlignment: TabAlignment.start,
      isScrollable: true,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      labelColor: ColorConstants.primaryColor,
      unselectedLabelColor: Colors.grey[600],
      indicatorColor: ColorConstants.primaryColor,
      indicatorWeight: 3,
      indicatorSize: TabBarIndicatorSize.tab,
      labelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
      ),
      unselectedLabelStyle: const TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
      ),
      tabs: _tabConfigs.map((config) => Tab(text: config.label)).toList(),
    );
  }

  Widget _buildTabBarView(List<AppointmentModel> allAppointments) {
    return TabBarView(
      controller: _tabController,
      children: _tabConfigs
          .map((config) => _AppointmentsList(
                appointments:
                    _filterAppointmentsByStatus(allAppointments, config),
                onRefresh: _loadAppointments,
                onAppointmentTap: _onAppointmentTap,
              ))
          .toList(),
    );
  }

  List<AppointmentModel> _filterAppointmentsByStatus(
    List<AppointmentModel> appointments,
    _TabConfig config,
  ) {
    if (config.isAllTab) return appointments;

    return appointments
        .where((appointment) => appointment.status == config.status)
        .toList();
  }

  void _onAppointmentTap(AppointmentModel appointment) {
    context.push(
      RoutePaths.appointmentDetailScreen,
      extra: {'appointment': appointment},
    );
  }

  Widget _buildEmpty() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.calendar_today_outlined,
              size: 40,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Записей не найдено',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            _currentFilters.isEmpty
                ? 'Пока нет записей на прием'
                : 'Нет записей с такими параметрами',
            style: TextStyle(
              fontSize: 16,
              color: Colors.grey[600],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildError(String message) {
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
              child: Icon(
                Icons.error_outline,
                size: 40,
                color: ColorConstants.errorColor,
              ),
            ),
            const SizedBox(height: 24),
            const Text(
              'Произошла ошибка',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w600,
                color: Colors.black87,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _loadAppointments,
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: ColorConstants.primaryColor,
                foregroundColor: Colors.white,
                elevation: 2,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
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
}

/// Appointments list widget (o'zgarishsiz)
class _AppointmentsList extends StatelessWidget {
  final List<AppointmentModel> appointments;
  final VoidCallback onRefresh;
  final ValueChanged<AppointmentModel> onAppointmentTap;

  const _AppointmentsList({
    required this.appointments,
    required this.onRefresh,
    required this.onAppointmentTap,
  });

  @override
  Widget build(BuildContext context) {
    if (appointments.isEmpty) {
      return _buildEmptyState();
    }

    return RefreshIndicator(
      onRefresh: () async => onRefresh(),
      color: ColorConstants.primaryColor,
      child: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: appointments.length,
        physics: const AlwaysScrollableScrollPhysics(),
        itemBuilder: (context, index) {
          final appointment = appointments[index];
          return _buildAppointmentCard(context, appointment);
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.grey[100],
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.event_note_outlined,
              size: 32,
              color: Colors.grey[400],
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Записей нет',
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w500,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'В данной категории пока нет записей',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAppointmentCard(
      BuildContext context, AppointmentModel appointment) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          onTap: () => onAppointmentTap(appointment),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: ColorConstants.primaryColor.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.person,
                        color: ColorConstants.primaryColor,
                        size: 22,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patientName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Icon(
                                Icons.access_time,
                                size: 14,
                                color: Colors.grey[600],
                              ),
                              const SizedBox(width: 4),
                              Text(
                                appointment.appointmentTime,
                                style: TextStyle(
                                  fontSize: 13,
                                  color: Colors.grey[600],
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: appointment.status.color.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            appointment.status.icon,
                            size: 12,
                            color: appointment.status.color,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            appointment.status.displayText,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: appointment.status.color,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.grey[50],
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.location_on_outlined,
                        size: 16,
                        color: Colors.grey[600],
                      ),
                      const SizedBox(width: 6),
                      Expanded(
                        child: Text(
                          appointment.clinicName,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey[700],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                if (appointment.notes?.isNotEmpty == true) ...[
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.blue[100]!),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.note_outlined,
                          size: 16,
                          color: Colors.blue[600],
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            appointment.notes!,
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.blue[700],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
