import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/routes/route_paths.dart';
import 'package:clinic/features/doctor/home/domain/entity/doctor_appointment_entity.dart';
import 'package:clinic/features/doctor/home/presentation/bloc/doctor_appointment_bloc.dart';
import 'package:clinic/features/doctor/home/presentation/widgets/appointment_card.dart';
import 'package:clinic/features/client/appointments/data/models/appointment_filter.dart';
import 'package:clinic/features/doctor/home/presentation/widgets/filter_dialog.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class DoctorHomeScreen extends StatefulWidget {
  const DoctorHomeScreen({super.key});

  @override
  State<DoctorHomeScreen> createState() => _DoctorHomeScreenState();
}

class _DoctorHomeScreenState extends State<DoctorHomeScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  final TextEditingController _searchController = TextEditingController();

  // Filter uchun state
  AppointmentFilters _currentFilters = const AppointmentFilters();
  bool _hasActiveFilters = false;

  // Statuslar ro'yxati
  final List<String> _statusTabs = [
    'Все',
    'Запланирована',
    'Оформлена продажа',
    'Проведен прием',
    'Выполнена',
    'Отменена',
  ];

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: _statusTabs.length, vsync: this);

    // Animation listener qo'shish - bu swipe va tap larni tutadi
    _tabController.animation!.addListener(() {
      setState(() {});
    });

    // Index o'zgarganida ham yangilash
    _tabController.addListener(() {
      if (_tabController.indexIsChanging) {
        setState(() {});
      }
    });

    context.read<DoctorAppointmentBloc>().add(LoadDoctorAppointmentsEvent());
  }

  @override
  void dispose() {
    _searchController.dispose();
    _tabController.dispose();
    super.dispose();
  }

  /// Current tab index ni olish (animation bilan)
  int get _currentTabIndex => _tabController.animation!.value.round();

  /// Filter bo'yicha uchrashuvlarni filterlash
  List<DoctorAppointmentEntity> _applyFilters(
      List<DoctorAppointmentEntity> appointments) {
    if (!_hasActiveFilters) return appointments;

    return appointments.where((appointment) {
      // Yaratilgan sana bo'yicha filter
      if (_currentFilters.createdAt?.isNotEmpty == true) {
        try {
          final filterDate = DateTime.parse(_currentFilters.createdAt!);
          final appointmentDate = DateTime(
            appointment.dataZayavki.year,
            appointment.dataZayavki.month,
            appointment.dataZayavki.day,
          );
          final filterDateOnly = DateTime(
            filterDate.year,
            filterDate.month,
            filterDate.day,
          );
          if (appointmentDate != filterDateOnly) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }

      // Bemorning ismi bo'yicha filter
      if (_currentFilters.patientFirstName?.isNotEmpty == true) {
        final firstName = appointment.patientFirstName.toLowerCase();
        final filterName = _currentFilters.patientFirstName!.toLowerCase();
        if (!firstName.contains(filterName)) {
          return false;
        }
      }

      // Bemorning familiyasi bo'yicha filter
      if (_currentFilters.patientLastName?.isNotEmpty == true) {
        final lastName = appointment.patientLastname.toLowerCase();
        final filterLastName = _currentFilters.patientLastName!.toLowerCase();
        if (!lastName.contains(filterLastName)) {
          return false;
        }
      }

      // Telefon raqami bo'yicha filter
      if (_currentFilters.patientPhoneNumber?.isNotEmpty == true) {
        final phone = appointment.patientPhoneNumber;
        if (!phone.contains(_currentFilters.patientPhoneNumber!)) {
          return false;
        }
      }

      // Tug'ilgan sana bo'yicha filter
      if (_currentFilters.patientBirthDate?.isNotEmpty == true) {
        try {
          final filterBirthDate =
              DateTime.parse(_currentFilters.patientBirthDate!);
          final appointmentBirthDate = DateTime(
            appointment.patientBirthDate.year,
            appointment.patientBirthDate.month,
            appointment.patientBirthDate.day,
          );
          final filterBirthDateOnly = DateTime(
            filterBirthDate.year,
            filterBirthDate.month,
            filterBirthDate.day,
          );
          if (appointmentBirthDate != filterBirthDateOnly) {
            return false;
          }
        } catch (e) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Status bo'yicha filterlash
  List<DoctorAppointmentEntity> _filterAppointmentsByStatus(
      List<DoctorAppointmentEntity> appointments, String status) {
    final filteredByFilters = _applyFilters(appointments);

    if (status == 'Все') {
      return filteredByFilters;
    }
    return filteredByFilters
        .where((appointment) => appointment.sostoyanie == status)
        .toList();
  }

  /// Status uchun soni hisoblash
  int _getStatusCount(
      List<DoctorAppointmentEntity> appointments, String status) {
    final filteredByFilters = _applyFilters(appointments);

    if (status == 'Все') return filteredByFilters.length;
    return filteredByFilters
        .where((appointment) => appointment.sostoyanie == status)
        .length;
  }

  /// Filter dialogini ochish
  Future<void> _showFilterDialog() async {
    final result = await showDialog<AppointmentFilters>(
      context: context,
      barrierDismissible: true,
      builder: (context) => FilterDialog(currentFilters: _currentFilters),
    );

    if (result != null) {
      setState(() {
        _currentFilters = result;
        _hasActiveFilters = _checkIfFiltersActive(result);
      });
    }
  }

  /// Filterlar faol ekanligini tekshirish
  bool _checkIfFiltersActive(AppointmentFilters filters) {
    return filters.createdAt?.isNotEmpty == true ||
        filters.patientFirstName?.isNotEmpty == true ||
        filters.patientLastName?.isNotEmpty == true ||
        filters.patientPhoneNumber?.isNotEmpty == true ||
        filters.patientBirthDate?.isNotEmpty == true;
  }

  /// Barcha filterlarni tozalash
  void _clearAllFilters() {
    setState(() {
      _currentFilters = const AppointmentFilters();
      _hasActiveFilters = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        title: const Text(
          'Заявки пациентов',
          style: TextStyle(
            color: Colors.black87,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 0,
        shadowColor: Colors.grey.withOpacity(0.1),
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
                tooltip: 'Фильтры',
              ),
              if (_hasActiveFilters)
                Positioned(
                  right: 8,
                  top: 8,
                  child: Container(
                    width: 8,
                    height: 8,
                    decoration: const BoxDecoration(
                      color: Colors.red,
                      shape: BoxShape.circle,
                    ),
                  ),
                ),
            ],
          ),
          if (_hasActiveFilters)
            IconButton(
              onPressed: _clearAllFilters,
              icon: const Icon(
                Icons.clear,
                color: Colors.black87,
              ),
              tooltip: 'Очистить фильтры',
            ),
          const SizedBox(width: 8),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(50.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.08),
                  blurRadius: 1,
                  offset: const Offset(0, 1),
                ),
              ],
            ),
            child: BlocBuilder<DoctorAppointmentBloc, DoctorAppointmentState>(
              builder: (context, state) {
                final appointments = state is DoctorAppointmentLoaded
                    ? state.data.cast<DoctorAppointmentEntity>()
                    : <DoctorAppointmentEntity>[];

                return TabBar(
                  controller: _tabController,
                  isScrollable: true,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  tabAlignment: TabAlignment.start,
                  indicatorColor: Colors.transparent,
                  dividerColor: Colors.transparent,
                  labelPadding: const EdgeInsets.symmetric(horizontal: 4),
                  tabs: _statusTabs.asMap().entries.map((entry) {
                    final index = entry.key;
                    final status = entry.value;
                    final count = _getStatusCount(appointments, status);

                    // Animation bilan current tab ni aniqlash
                    final isSelected = _currentTabIndex == index;

                    return Tab(
                      height: 45,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          color: isSelected
                              ? ColorConstants.primaryColor
                              : Colors.transparent,
                          border: Border.all(
                            color: isSelected
                                ? ColorConstants.primaryColor
                                : Colors.grey.shade300,
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Flexible(
                              child: Text(
                                status,
                                style: TextStyle(
                                  color: isSelected
                                      ? Colors.white
                                      : Colors.grey.shade600,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                                overflow: TextOverflow.ellipsis,
                                maxLines: 1,
                              ),
                            ),
                            if (count > 0) ...[
                              const SizedBox(width: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 5, vertical: 1),
                                decoration: BoxDecoration(
                                  color: isSelected
                                      ? Colors.white.withOpacity(0.2)
                                      : Colors.grey.shade400,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  count.toString(),
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : Colors.white,
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // Faol filterlar haqida ma'lumot
          if (_hasActiveFilters)
            Container(
              width: double.infinity,
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.info_outline,
                    size: 16,
                    color: Colors.blue.shade700,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Применены фильтры поиска',
                      style: TextStyle(
                        fontSize: 13,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _clearAllFilters,
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 8),
                      minimumSize: Size.zero,
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    ),
                    child: Text(
                      'Сбросить',
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.blue.shade700,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          Expanded(
            child: BlocBuilder<DoctorAppointmentBloc, DoctorAppointmentState>(
              builder: (context, state) {
                if (state is DoctorAppointmentLoading) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (state is DoctorAppointmentError) {
                  return _buildErrorWidget(context, state.error);
                }

                if (state is DoctorAppointmentLoaded) {
                  final appointments =
                      state.data.cast<DoctorAppointmentEntity>();

                  return TabBarView(
                    controller: _tabController,
                    children: _statusTabs.map((status) {
                      final filteredAppointments =
                          _filterAppointmentsByStatus(appointments, status);

                      if (filteredAppointments.isEmpty) {
                        return _buildEmptyWidget(context, status);
                      }

                      return RefreshIndicator(
                        onRefresh: () async {
                          context
                              .read<DoctorAppointmentBloc>()
                              .add(const LoadDoctorAppointmentsEvent());
                        },
                        child: ListView.builder(
                          padding: const EdgeInsets.symmetric(horizontal: 16),
                          itemCount: filteredAppointments.length,
                          itemBuilder: (context, index) {
                            final appointment = filteredAppointments[index];
                            return AppointmentCard(
                              appointment: appointment,
                              onTap: () => context.push(
                                  RoutePaths.appointmentDetailScreen,
                                  extra: {
                                    "appointment": appointment,
                                  }),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  );
                }

                return const SizedBox.expand();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorWidget(BuildContext context, String message) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.red.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Ошибка загрузки',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.red.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<DoctorAppointmentBloc>()
                    .add(const LoadDoctorAppointmentsEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Повторить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyWidget(BuildContext context, String status) {
    String emptyMessage;
    IconData emptyIcon;

    switch (status) {
      case 'Все':
        emptyMessage = _hasActiveFilters
            ? 'По заданным фильтрам результатов не найдено'
            : 'Нет заявок от пациентов';
        emptyIcon = Icons.calendar_today_outlined;
        break;
      case 'Запланирована':
        emptyMessage = _hasActiveFilters
            ? 'Нет запланированных приемов по фильтрам'
            : 'Нет запланированных приемов';
        emptyIcon = Icons.schedule_outlined;
        break;
      case 'Оформлена продажа':
        emptyMessage = _hasActiveFilters
            ? 'Нет оформленных продаж по фильтрам'
            : 'Нет оформленных продаж';
        emptyIcon = Icons.shopping_cart_outlined;
        break;
      case 'Проведен прием':
        emptyMessage = _hasActiveFilters
            ? 'Нет проведенных приемов по фильтрам'
            : 'Нет проведенных приемов';
        emptyIcon = Icons.check_circle_outline;
        break;
      case 'Выполнена':
        emptyMessage = _hasActiveFilters
            ? 'Нет выполненных процедур по фильтрам'
            : 'Нет выполненных процедур';
        emptyIcon = Icons.task_alt_outlined;
        break;
      case 'Отменена':
        emptyMessage = _hasActiveFilters
            ? 'Нет отмененных заявок по фильтрам'
            : 'Нет отмененных заявок';
        emptyIcon = Icons.cancel_outlined;
        break;
      default:
        emptyMessage = 'Нет данных';
        emptyIcon = Icons.inbox_outlined;
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              emptyIcon,
              size: 64,
              color: Colors.grey.shade400,
            ),
            const SizedBox(height: 16),
            Text(
              'Пусто',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 8),
            Text(
              emptyMessage,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.grey.shade600,
                  ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                context
                    .read<DoctorAppointmentBloc>()
                    .add(const LoadDoctorAppointmentsEvent());
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Обновить'),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue.shade600,
                foregroundColor: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
