import 'package:flutter/material.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/features/client/appointments/domain/entities/appointment_entity.dart';
import 'package:intl/intl.dart';

class AppointmentSuccessDialog extends StatelessWidget {
  final AppointmentEntity appointment;

  const AppointmentSuccessDialog({
    super.key,
    required this.appointment,
  });

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      child: Padding(
        padding: 24.a,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: ColorConstants.successColor.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.check_circle,
                size: 48,
                color: ColorConstants.successColor,
              ),
            ),
            24.h,
            const Text(
              'Успешно!',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: ColorConstants.textColor,
              ),
            ),
            8.h,
            const Text(
              'Ваш приём успешно создан',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: ColorConstants.secondaryTextColor,
              ),
            ),
            24.h,
            Container(
              padding: 16.a,
              decoration: BoxDecoration(
                color: Colors.grey.shade50,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildInfoRow(
                    'Врач',
                    appointment.doctorName ?? 'Неизвестно',
                    Icons.person_outline,
                  ),
                  12.h,
                  _buildInfoRow(
                    'Клиника',
                    appointment.clinicName ?? 'Неизвестно',
                    Icons.local_hospital_outlined,
                  ),
                  12.h,
                  _buildInfoRow(
                    'Дата',
                    DateFormat('dd MMMM yyyy', 'uz').format(appointment.date),
                    Icons.calendar_today_outlined,
                  ),
                  12.h,
                  _buildInfoRow(
                    'Время',
                    appointment.time,
                    Icons.access_time,
                  ),
                ],
              ),
            ),
            24.h,
            Row(
              children: [
                Expanded(
                  child: TextButton(
                    onPressed: () => Navigator.of(context).pop(),
                    child: const Text(
                      'Закрыть',
                      style: TextStyle(
                        color: ColorConstants.secondaryTextColor,
                      ),
                    ),
                  ),
                ),
                12.w,
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
                      // Navigate to appointments screen
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: ColorConstants.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: const Text(
                      'Мои приёмы',
                      style: TextStyle(color: Colors.white),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          size: 18,
          color: ColorConstants.primaryColor,
        ),
        12.w,
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  color: ColorConstants.secondaryTextColor,
                ),
              ),
              2.h,
              Text(
                value,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: ColorConstants.textColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
