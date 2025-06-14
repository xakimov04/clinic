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
  final TextEditingController _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    context.read<AppointmentBookingBloc>().add(
          LoadDoctorClinics(
            doctorId: widget.doctor.id,
            doctor: widget.doctor,
          ),
        );
  }

  @override
  void dispose() {
    _notesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Запись к врачу'),
        backgroundColor: ColorConstants.backgroundColor,
        elevation: 0,
      ),
      backgroundColor: ColorConstants.backgroundColor,
      body: BlocConsumer<AppointmentBookingBloc, AppointmentBookingState>(
        listener: (context, state) {
          if (state.status == AppointmentBookingStatus.success) {
            CustomSnackbar.showSuccess(
              context: context,
              message: 'Запись успешно создана!',
            );
            context.read<AppointmentBookingBloc>().add(const ResetBooking());

            Navigator.pop(context, true);
          } else if (state.status == AppointmentBookingStatus.error) {
            CustomSnackbar.showError(
              context: context,
              message: state.errorMessage ?? 'Произошла ошибка',
            );
          }
        },
        builder: (context, state) => _buildBody(state),
      ),
    );
  }

  Widget _buildBody(AppointmentBookingState state) {
    if (state.status == AppointmentBookingStatus.loading ||
        state.doctor == null) {
      return const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(),
            SizedBox(height: 16),
            Text('Загрузка данных врача...'),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: 16.a,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _DoctorInfoCard(doctor: state.doctor!),
          24.h,
          _ClinicSelectionSection(state: state),
          if (state.selectedClinic != null) ...[
            24.h,
            _DateSelectionSection(
              state: state,
              onDateTap: (context, state) => _selectDate(context),
            ),
            if (state.selectedDate != null) ...[
              24.h,
              _TimeSelectionSection(state: state),
            ],
          ],
          24.h,
          _NotesInputSection(
            controller: _notesController,
            onChanged: (value) =>
                context.read<AppointmentBookingBloc>().add(UpdateNotes(value)),
          ),
          32.h,
          _BookingButton(state: state),
        ],
      ),
    );
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
        confirm:
            Text('Готово', style: TextStyle(color: CupertinoColors.activeBlue)),
        cancel:
            Text('Отмена', style: TextStyle(color: CupertinoColors.systemRed)),
      ),
      minDateTime: minDate,
      maxDateTime: maxDate,
      initialDateTime: initialDate,
      dateFormat: 'dd-MMMM-yyyy',
      onConfirm: (DateTime dateTime, List<int> index) {
        context.read<AppointmentBookingBloc>().add(SelectDate(dateTime));
      },
    );
  }
}

// Shifokor ma'lumotlari komponenti
class _DoctorInfoCard extends StatelessWidget {
  final DoctorEntity doctor;

  const _DoctorInfoCard({required this.doctor});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: 16.a,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.asset(
              'assets/images/doctor.jpg',
              width: 60,
              height: 60,
              fit: BoxFit.cover,
            ),
          ),
          16.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  doctor.fullName,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                4.h,
                Text(
                  doctor.specialization,
                  style: const TextStyle(
                    fontSize: 14,
                    color: ColorConstants.secondaryTextColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Klinika tanlash komponenti
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.h,
        _buildClinicsList(),
      ],
    );
  }

  Widget _buildClinicsList() {
    if (state.clinics.isEmpty) {
      return Container(
        padding: 16.a,
        decoration: BoxDecoration(
          color: Colors.grey.shade100,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Center(
          child: Text(
            'Клиники не найдены',
            style: TextStyle(
              color: ColorConstants.secondaryTextColor,
              fontSize: 14,
            ),
          ),
        ),
      );
    }

    return Column(
      children: state.clinics
          .map((clinic) => _ClinicCard(
                clinic: clinic,
                isSelected: state.selectedClinic?.id == clinic.id,
              ))
          .toList(),
    );
  }
}

// Klinika kartasi komponenti
class _ClinicCard extends StatelessWidget {
  final ClinicEntity clinic;
  final bool isSelected;

  const _ClinicCard({
    required this.clinic,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: () =>
            context.read<AppointmentBookingBloc>().add(SelectClinic(clinic)),
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: 16.a,
          decoration: BoxDecoration(
            color: isSelected
                ? ColorConstants.primaryColor.withOpacity(0.1)
                : Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isSelected
                  ? ColorConstants.primaryColor
                  : Colors.grey.shade300,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      clinic.name,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: isSelected
                            ? ColorConstants.primaryColor
                            : ColorConstants.textColor,
                      ),
                    ),
                  ),
                  if (isSelected)
                    const Icon(
                      Icons.check_circle,
                      color: ColorConstants.primaryColor,
                      size: 20,
                    ),
                ],
              ),
              if (clinic.address.isNotEmpty) ...[
                8.h,
                Row(
                  children: [
                    const Icon(
                      Icons.location_on_outlined,
                      size: 16,
                      color: ColorConstants.secondaryTextColor,
                    ),
                    4.w,
                    Expanded(
                      child: Text(
                        clinic.address,
                        style: const TextStyle(
                          fontSize: 14,
                          color: ColorConstants.secondaryTextColor,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
              if (clinic.phone.isNotEmpty) ...[
                4.h,
                Row(
                  children: [
                    const Icon(
                      Icons.phone_outlined,
                      size: 16,
                      color: ColorConstants.secondaryTextColor,
                    ),
                    4.w,
                    Text(
                      clinic.phone,
                      style: const TextStyle(
                        fontSize: 14,
                        color: ColorConstants.secondaryTextColor,
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}

// Sana tanlash komponenti
class _DateSelectionSection extends StatelessWidget {
  final AppointmentBookingState state;
  final Function(BuildContext, AppointmentBookingState) onDateTap;

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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.h,
        Container(
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () => onDateTap(context, state),
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: 16.a,
                child: Row(
                  children: [
                    Icon(
                      CupertinoIcons.calendar,
                      color: ColorConstants.primaryColor,
                      size: 22,
                    ),
                    16.w,
                    Expanded(
                      child: Text(
                        state.selectedDate != null
                            ? _formatDate(state.selectedDate!)
                            : 'Выберите дату',
                        style: TextStyle(
                          fontSize: 16,
                          color: state.selectedDate != null
                              ? ColorConstants.textColor
                              : ColorConstants.secondaryTextColor,
                        ),
                      ),
                    ),
                    Icon(
                      CupertinoIcons.chevron_right,
                      size: 16,
                      color: ColorConstants.secondaryTextColor,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  String _formatDate(DateTime date) {
    final months = [
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

    final weekdays = [
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

// Vaqt tanlash komponenti
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
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.h,
        Container(
          padding: 16.a,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.grey.shade300),
          ),
          child: state.timeSlots.isNotEmpty
              ? GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3,
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                    childAspectRatio: 2.5,
                  ),
                  itemCount: state.timeSlots.length,
                  itemBuilder: (context, index) => _TimeSlotCard(
                    timeSlot: state.timeSlots[index],
                  ),
                )
              : const Center(
                  child: Text(
                    'Доступное время не найдено',
                    style: TextStyle(
                      color: ColorConstants.secondaryTextColor,
                      fontSize: 14,
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

// Vaqt sloti komponenti
class _TimeSlotCard extends StatelessWidget {
  final TimeSlotEntity timeSlot;

  const _TimeSlotCard({required this.timeSlot});

  @override
  Widget build(BuildContext context) {
    return Material(
      color: _getBackgroundColor(),
      borderRadius: BorderRadius.circular(8),
      child: InkWell(
        onTap: timeSlot.isAvailable
            ? () => context
                .read<AppointmentBookingBloc>()
                .add(SelectTime(timeSlot.time))
            : null,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          alignment: Alignment.center,
          child: Text(
            timeSlot.time,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: _getTextColor(),
            ),
          ),
        ),
      ),
    );
  }

  Color _getBackgroundColor() {
    if (timeSlot.isSelected) return ColorConstants.primaryColor;
    if (timeSlot.isAvailable) return Colors.grey.shade100;
    return Colors.grey.shade300;
  }

  Color _getTextColor() {
    if (timeSlot.isSelected) return Colors.white;
    if (timeSlot.isAvailable) return ColorConstants.textColor;
    return ColorConstants.secondaryTextColor;
  }
}

// Eslatma kiritish komponenti
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
          'Дополнительная информация (необязательно)',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
        12.h,
        TextField(
          controller: controller,
          maxLines: 3,
          onChanged: onChanged,
          decoration: InputDecoration(
            hintText: 'Опишите жалобы или дополнительную информацию...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(color: Colors.grey.shade300),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: ColorConstants.primaryColor),
            ),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ],
    );
  }
}

// Booking tugmasi komponenti
class _BookingButton extends StatelessWidget {
  final AppointmentBookingState state;

  const _BookingButton({required this.state});

  @override
  Widget build(BuildContext context) {
    final isLoading = state.status == AppointmentBookingStatus.creating;
    final canBook = _canBookAppointment(state) && !isLoading;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: canBook
            ? () => context
                .read<AppointmentBookingBloc>()
                .add(const CreateAppointment())
            : null,
        style: ElevatedButton.styleFrom(
          backgroundColor: ColorConstants.primaryColor,
          disabledBackgroundColor: Colors.grey.shade300,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: isLoading
            ? const SizedBox(
                width: 24,
                height: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : const Text(
                'Записаться на прием',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }

  // Majburiy maydonlar to'ldirilganligini tekshirish
  bool _canBookAppointment(AppointmentBookingState state) {
    return state.selectedClinic != null &&
        state.selectedDate != null &&
        state.timeSlots.any((slot) => slot.isSelected);
  }
}
