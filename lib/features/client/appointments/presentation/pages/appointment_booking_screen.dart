import 'package:clinic/core/ui/widgets/images/custom_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/snackbars/custom_snackbar.dart';
import 'package:clinic/features/client/appointments/domain/entities/clinic_entity.dart';
import 'package:clinic/features/client/appointments/domain/entities/time_slot_entity.dart';
import 'package:clinic/features/client/appointments/presentation/bloc/appointment_booking/appointment_booking_bloc.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:flutter_cupertino_date_picker_fork/flutter_cupertino_date_picker_fork.dart';
import 'package:flutter_svg/svg.dart';

class AppointmentBookingScreen extends StatefulWidget {
  final DoctorEntity doctor;

  const AppointmentBookingScreen({
    super.key,
    required this.doctor,
  });

  @override
  State<AppointmentBookingScreen> createState() =>
      _AppointmentBookingScreenState();
}

class _AppointmentBookingScreenState extends State<AppointmentBookingScreen> {
  late final TextEditingController _notesController;
  late final AppointmentBookingBloc _bloc;
  bool _hasShownSnackbar = false;

  @override
  void initState() {
    super.initState();
    _notesController = TextEditingController();
    _bloc = context.read<AppointmentBookingBloc>();

    // Сбросить состояние при входе на страницу
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bloc.add(const ResetBooking());
      _bloc.add(LoadDoctorClinics(
        doctorId: widget.doctor.id,
        doctor: widget.doctor,
      ));
    });
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<AppointmentBookingBloc, AppointmentBookingState>(
        listener: _handleBlocListener,
        builder: (context, state) {
          return Scaffold(
            appBar: _buildAppBar(),
            bottomNavigationBar: SafeArea(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: _BookingButton(state: state),
              ),
            ),
            backgroundColor: ColorConstants.backgroundColor,
            body: _buildBody(state),
          );
        });
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      title: const Text('Запись к врачу'),
      backgroundColor: ColorConstants.backgroundColor,
      elevation: 0,
      centerTitle: true,
    );
  }

  void _handleBlocListener(
      BuildContext context, AppointmentBookingState state) {
    // Предотвращаем дублирование снэкбаров
    if (_hasShownSnackbar) return;

    switch (state.status) {
      case AppointmentBookingStatus.success:
        _hasShownSnackbar = true;
        CustomSnackbar.showSuccess(
          context: context,
          message: 'Запись успешно создана!',
        );

        // Задержка перед возвратом для показа снэкбара
        Future.delayed(const Duration(milliseconds: 500), () {
          if (mounted) {
            Navigator.pop(context, true);
          }
        });
        break;

      case AppointmentBookingStatus.error:
        _hasShownSnackbar = true;
        final errorMessage = state.errorCode == "400"
            ? 'В это время доктор занят'
            : state.errorMessage ?? 'Произошла ошибка';

        CustomSnackbar.showError(
          context: context,
          message: errorMessage,
        );

        // Сбросить флаг через некоторое время для возможности показа следующих ошибок
        Future.delayed(const Duration(seconds: 3), () {
          _hasShownSnackbar = false;
        });
        break;

      default:
        break;
    }
  }

  Widget _buildBody(AppointmentBookingState state) {
    if (state.status == AppointmentBookingStatus.loading ||
        state.doctor == null) {
      return const _LoadingWidget();
    }

    return SingleChildScrollView(
      padding: 16.a,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DoctorInfoCard(doctor: state.doctor!),
          24.h,
          _ClinicSelectionSection(state: state),
          if (state.selectedClinic != null) ..._buildBookingSteps(state),
          32.h,
        ],
      ),
    );
  }

  List<Widget> _buildBookingSteps(AppointmentBookingState state) {
    return [
      24.h,
      _DateSelectionSection(
        state: state,
        onDateTap: () => _selectDate(context),
      ),
      if (state.selectedDate != null) ...[
        24.h,
        _TimeSelectionSection(state: state),
      ],
      24.h,
      _NotesInputSection(
        controller: _notesController,
        onChanged: (value) => _bloc.add(UpdateNotes(value)),
      ),
    ];
  }

  Future<void> _selectDate(BuildContext context) async {
    final now = DateTime.now();
    final initialDate = now.add(const Duration(days: 1));
    final minDate = now;
    final maxDate = now.add(const Duration(days: 90));

    DatePicker.showDatePicker(
      context,
      locale: DateTimePickerLocale.ru,
      pickerTheme: const DateTimePickerTheme(
        showTitle: true,
        confirm: Text(
          'Готово',
          style: TextStyle(color: CupertinoColors.activeBlue),
        ),
        cancel: Text(
          'Отмена',
          style: TextStyle(color: CupertinoColors.systemRed),
        ),
      ),
      minDateTime: minDate,
      maxDateTime: maxDate,
      initialDateTime: initialDate,
      dateFormat: 'dd-MMMM-yyyy',
      onConfirm: (DateTime dateTime, List<int> index) {
        _bloc.add(SelectDate(dateTime, widget.doctor.specialization));
      },
    );
  }
}

// Виджет загрузки
class _LoadingWidget extends StatelessWidget {
  const _LoadingWidget();

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(),
          SizedBox(height: 16),
          Text(
            'Загрузка данных врача...',
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

// Карточка информации о докторе
class _DoctorInfoCard extends StatelessWidget {
  final DoctorEntity doctor;

  const _DoctorInfoCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.a,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          _buildDoctorAvatar(),
          16.w,
          Expanded(child: _buildDoctorInfo()),
        ],
      ),
    );
  }

  Widget _buildDoctorAvatar() {
    return Container(
      width: 64,
      height: 64,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.primaryColor.withOpacity(0.2),
          width: 2,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(14),
        child: doctor.avatar.isEmpty
            ? SvgPicture.asset(
                "assets/images/avatar.svg",
                fit: BoxFit.cover,
              )
            : CacheImageWidget(imageUrl: doctor.avatar),
      ),
    );
  }

  Widget _buildDoctorInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          doctor.fullName,
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textColor,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        6.h,
        Text(
          doctor.specialization,
          style: const TextStyle(
            fontSize: 14,
            color: ColorConstants.secondaryTextColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

// Секция выбора клиники
class _ClinicSelectionSection extends StatelessWidget {
  final AppointmentBookingState state;

  const _ClinicSelectionSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Выберите клинику',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textColor,
          ),
        ),
        16.h,
        _buildClinicsList(context),
      ],
    );
  }

  Widget _buildClinicsList(BuildContext context) {
    if (state.clinics.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: state.clinics.asMap().entries.map((entry) {
        final index = entry.key;
        final clinic = entry.value;
        final isSelected = state.selectedClinic?.id == clinic.id;
        final isFirstClinic = index == 0;

        return _ClinicCard(
          clinic: clinic,
          isSelected: isSelected,
          isFirstClinic: isFirstClinic,
        );
      }).toList(),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      padding: 24.a,
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade200),
      ),
      child: const Center(
        child: Column(
          children: [
            Icon(
              Icons.business_outlined,
              size: 48,
              color: ColorConstants.secondaryTextColor,
            ),
            SizedBox(height: 12),
            Text(
              'Клиники не найдены',
              style: TextStyle(
                color: ColorConstants.secondaryTextColor,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Карточка клиники
class _ClinicCard extends StatefulWidget {
  final ClinicEntity clinic;
  final bool isSelected;
  final bool isFirstClinic;

  const _ClinicCard({
    required this.clinic,
    required this.isSelected,
    required this.isFirstClinic,
  });

  @override
  State<_ClinicCard> createState() => _ClinicCardState();
}

class _ClinicCardState extends State<_ClinicCard> {
  @override
  void initState() {
    super.initState();
    // Автоматический выбор первой клиники
    if (widget.isFirstClinic && !widget.isSelected) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) {
          context
              .read<AppointmentBookingBloc>()
              .add(SelectClinic(widget.clinic));
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => context
              .read<AppointmentBookingBloc>()
              .add(SelectClinic(widget.clinic)),
          borderRadius: BorderRadius.circular(16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: 16.a,
            decoration: BoxDecoration(
              color: widget.isSelected
                  ? ColorConstants.primaryColor.withOpacity(0.1)
                  : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: widget.isSelected
                    ? ColorConstants.primaryColor
                    : Colors.grey.shade300,
                width: widget.isSelected ? 2 : 1,
              ),
              boxShadow: widget.isSelected
                  ? [
                      BoxShadow(
                        color: ColorConstants.primaryColor.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.02),
                        blurRadius: 4,
                        offset: const Offset(0, 1),
                      ),
                    ],
            ),
            child: _buildClinicContent(),
          ),
        ),
      ),
    );
  }

  Widget _buildClinicContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildClinicHeader(),
        if (widget.clinic.address.isNotEmpty) ...[
          12.h,
          _buildAddressRow(),
        ],
        if (widget.clinic.phone.isNotEmpty) ...[
          8.h,
          _buildPhoneRow(),
        ],
      ],
    );
  }

  Widget _buildClinicHeader() {
    return Row(
      children: [
        Expanded(
          child: Text(
            widget.clinic.name,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: widget.isSelected
                  ? ColorConstants.primaryColor
                  : ColorConstants.textColor,
            ),
          ),
        ),
        if (widget.isSelected) ...[
          8.w,
          Container(
            padding: const EdgeInsets.all(2),
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor,
              borderRadius: BorderRadius.circular(12),
            ),
            child: const Icon(
              Icons.check,
              color: Colors.white,
              size: 16,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildAddressRow() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Icon(
          Icons.location_on_outlined,
          size: 16,
          color: ColorConstants.secondaryTextColor,
        ),
        8.w,
        Expanded(
          child: Text(
            widget.clinic.address,
            style: const TextStyle(
              fontSize: 14,
              color: ColorConstants.secondaryTextColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPhoneRow() {
    return Row(
      children: [
        const Icon(
          Icons.phone_outlined,
          size: 16,
          color: ColorConstants.secondaryTextColor,
        ),
        8.w,
        Text(
          widget.clinic.phone,
          style: const TextStyle(
            fontSize: 14,
            color: ColorConstants.secondaryTextColor,
          ),
        ),
      ],
    );
  }
}

// Секция выбора даты
class _DateSelectionSection extends StatelessWidget {
  final AppointmentBookingState state;
  final VoidCallback onDateTap;

  const _DateSelectionSection({
    required this.state,
    required this.onDateTap,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Выберите дату',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textColor,
          ),
        ),
        16.h,
        _buildDateSelector(context),
      ],
    );
  }

  Widget _buildDateSelector(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.grey.shade300),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.02),
            blurRadius: 4,
            offset: const Offset(0, 1),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onDateTap,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: 20.a,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: const Icon(
                    CupertinoIcons.calendar,
                    color: ColorConstants.primaryColor,
                    size: 20,
                  ),
                ),
                16.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        state.selectedDate != null
                            ? _formatDate(state.selectedDate!)
                            : 'Выберите дату',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: state.selectedDate != null
                              ? ColorConstants.textColor
                              : ColorConstants.secondaryTextColor,
                        ),
                      ),
                      if (state.selectedDate == null) ...[
                        4.h,
                        const Text(
                          'Нажмите для выбора даты',
                          style: TextStyle(
                            fontSize: 12,
                            color: ColorConstants.secondaryTextColor,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                const Icon(
                  CupertinoIcons.chevron_right,
                  size: 16,
                  color: ColorConstants.secondaryTextColor,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  String _formatDate(DateTime date) {
    const months = [
      'января',
      'февраля',
      'марта',
      'апреля',
      'мая',
      'июня',
      'июля',
      'августа',
      'сентября',
      'октября',
      'ноября',
      'декабря'
    ];

    const weekdays = [
      'Понедельник',
      'Вторник',
      'Среда',
      'Четверг',
      'Пятница',
      'Суббота',
      'Воскресенье'
    ];

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final selectedDay = DateTime(date.year, date.month, date.day);

    if (selectedDay == today) {
      return 'Сегодня, ${date.day} ${months[date.month - 1]}';
    } else if (selectedDay == today.add(const Duration(days: 1))) {
      return 'Завтра, ${date.day} ${months[date.month - 1]}';
    } else {
      final weekday = weekdays[date.weekday - 1];
      return '$weekday, ${date.day} ${months[date.month - 1]} ${date.year}';
    }
  }
}

// Секция выбора времени
class _TimeSelectionSection extends StatelessWidget {
  final AppointmentBookingState state;

  const _TimeSelectionSection({required this.state});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Выберите время',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textColor,
          ),
        ),
        16.h,
        Container(
          padding: 20.a,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.shade300),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 4,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: state.timeSlots.isNotEmpty
              ? _buildTimeSlots()
              : _buildEmptyTimeSlots(),
        ),
      ],
    );
  }

  Widget _buildTimeSlots() {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 2.2,
      ),
      itemCount: state.timeSlots.length,
      itemBuilder: (context, index) => _TimeSlotCard(
        timeSlot: state.timeSlots[index],
      ),
    );
  }

  Widget _buildEmptyTimeSlots() {
    return const Center(
      child: Column(
        children: [
          Icon(
            Icons.access_time_outlined,
            size: 48,
            color: ColorConstants.secondaryTextColor,
          ),
          SizedBox(height: 12),
          Text(
            'Доступное время не найдено',
            style: TextStyle(
              color: ColorConstants.secondaryTextColor,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}

// Карточка временного слота
class _TimeSlotCard extends StatelessWidget {
  final TimeSlotEntity timeSlot;

  const _TimeSlotCard({required this.timeSlot});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: timeSlot.isAvailable
            ? () => context
                .read<AppointmentBookingBloc>()
                .add(SelectTime(timeSlot.time))
            : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          decoration: BoxDecoration(
            color: _getBackgroundColor(),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: _getBorderColor(),
              width: timeSlot.isSelected ? 2 : 1,
            ),
          ),
          child: Center(
            child: Text(
              timeSlot.time,
              style: TextStyle(
                fontSize: 14,
                fontWeight:
                    timeSlot.isSelected ? FontWeight.w600 : FontWeight.w500,
                color: _getTextColor(),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (timeSlot.isSelected) return ColorConstants.primaryColor;
    if (timeSlot.isAvailable) return Colors.grey.shade50;
    return Colors.grey.shade200;
  }

  Color _getBorderColor() {
    if (timeSlot.isSelected) return ColorConstants.primaryColor;
    if (timeSlot.isAvailable) return Colors.grey.shade300;
    return Colors.grey.shade400;
  }

  Color _getTextColor() {
    if (timeSlot.isSelected) return Colors.white;
    if (timeSlot.isAvailable) return ColorConstants.textColor;
    return ColorConstants.secondaryTextColor;
  }
}

// Секция ввода примечаний
class _NotesInputSection extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;

  const _NotesInputSection({
    required this.controller,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Дополнительная информация',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w600,
            color: ColorConstants.textColor,
          ),
        ),
        4.h,
        const Text(
          'Необязательно',
          style: TextStyle(
            fontSize: 14,
            color: ColorConstants.secondaryTextColor,
          ),
        ),
        16.h,
        TextField(
          controller: controller,
          maxLines: 4,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Опишите жалобы или дополнительную информацию...',
            hintStyle: TextStyle(
              color: Colors.grey.shade500,
              fontSize: 14,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: ColorConstants.primaryColor,
                width: 2,
              ),
            ),
            filled: true,
            fillColor: Colors.white,
            contentPadding: 16.a,
          ),
        ),
      ],
    );
  }
}

// Кнопка записи с валидацией
class _BookingButton extends StatelessWidget {
  final AppointmentBookingState state;

  const _BookingButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AppointmentBookingStatus.creating;
    final isFormValid = _isFormValid();

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Индикатор прогресса заполнения формы
        if (!isFormValid) _buildProgressIndicator(),

        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: (isLoading || !isFormValid)
                ? null
                : () => context
                    .read<AppointmentBookingBloc>()
                    .add(const CreateAppointment()),
            style: ElevatedButton.styleFrom(
              backgroundColor: isFormValid
                  ? ColorConstants.primaryColor
                  : Colors.grey.shade300,
              disabledBackgroundColor: Colors.grey.shade300,
              foregroundColor:
                  isFormValid ? Colors.white : Colors.grey.shade500,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              elevation: (isLoading || !isFormValid) ? 0 : 2,
              shadowColor: ColorConstants.primaryColor.withOpacity(0.3),
            ),
            child: isLoading
                ? const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (isFormValid) ...[
                        const Icon(Icons.check_circle_outline, size: 20),
                        8.w,
                      ],
                      Text(
                        _getButtonText(),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
          ),
        ),
      ],
    );
  }

  /// Проверяет валидность формы
  bool _isFormValid() {
    return state.selectedClinic != null &&
        state.selectedDate != null &&
        state.selectedTime != null;
  }

  /// Возвращает текст для кнопки в зависимости от состояния
  String _getButtonText() {
    if (!_isFormValid()) {
      if (state.selectedClinic == null) {
        return 'Выберите клинику';
      } else if (state.selectedDate == null) {
        return 'Выберите дату';
      } else if (state.selectedTime == null) {
        return 'Выберите время';
      }
    }
    return 'Записаться на прием';
  }

  /// Строит индикатор прогресса заполнения
  Widget _buildProgressIndicator() {
    final steps = [
      state.selectedClinic != null,
      state.selectedDate != null,
      state.selectedTime != null,
    ];

    final completedSteps = steps.where((step) => step).length;
    final totalSteps = steps.length;

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Заполнено: $completedSteps из $totalSteps',
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorConstants.secondaryTextColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const Spacer(),
              Text(
                '${((completedSteps / totalSteps) * 100).round()}%',
                style: TextStyle(
                  fontSize: 12,
                  color: completedSteps == totalSteps
                      ? ColorConstants.primaryColor
                      : ColorConstants.secondaryTextColor,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          8.h,
          LinearProgressIndicator(
            value: completedSteps / totalSteps,
            backgroundColor: Colors.grey.shade200,
            valueColor: AlwaysStoppedAnimation<Color>(
              completedSteps == totalSteps
                  ? ColorConstants.primaryColor
                  : Colors.orange,
            ),
            minHeight: 4,
            borderRadius: BorderRadius.circular(2),
          ),
        ],
      ),
    );
  }
}
