import 'package:clinic/features/doctor/home/domain/entity/doctor_appointment_entity.dart';
import 'package:flutter/material.dart';

/// Ixcham va oddiy dizayndagi appointment card
class AppointmentCard extends StatelessWidget {
  final DoctorAppointmentEntity appointment;
  final VoidCallback onTap;

  const AppointmentCard({
    super.key,
    required this.appointment,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Colors.grey.shade200,
          width: 1,
        ),
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
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Основная информация
                Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            appointment.patientFullName,
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: Colors.black87,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 2),
                          Text(
                            '${appointment.patientAge} лет',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Статус
                    _buildStatusChip(),
                  ],
                ),

                const SizedBox(height: 12),

                // Время приёма
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.grey.shade50,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: Colors.grey.shade200,
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        size: 16,
                        color: Colors.grey.shade600,
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          _getFormattedTimeRange(),
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: Colors.grey.shade700,
                          ),
                        ),
                      ),
                      Icon(
                        Icons.arrow_forward_ios,
                        size: 14,
                        color: Colors.grey.shade400,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Oddiy status chip
  Widget _buildStatusChip() {
    final color = _getStatusColor(appointment.sostoyanie);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: color.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Text(
        appointment.sostoyanie,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: color,
        ),
      ),
    );
  }

  /// Status ranglari - neytrual
  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'запланирована':
      case 'pending':
        return const Color(0xFF1976D2); // Material Blue
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

  /// Vaqt formatini ko'rsatish
  String _getFormattedTimeRange() {
    final startTime =
        '${appointment.dataNachalaZapisi.hour.toString().padLeft(2, '0')}:${appointment.dataNachalaZapisi.minute.toString().padLeft(2, '0')}';
    final endTime =
        '${appointment.dataOkonchaniyaZapisi.hour.toString().padLeft(2, '0')}:${appointment.dataOkonchaniyaZapisi.minute.toString().padLeft(2, '0')}';

    final now = DateTime.now();
    final appointmentDate = appointment.dataNachalaZapisi;

    // Bugun bo'lsa faqat vaqtni ko'rsatish
    if (appointmentDate.day == now.day &&
        appointmentDate.month == now.month &&
        appointmentDate.year == now.year) {
      return '$startTime - $endTime';
    }

    // Boshqa kunlar uchun sana ham
    final date =
        '${appointmentDate.day.toString().padLeft(2, '0')}.${appointmentDate.month.toString().padLeft(2, '0')}';
    return '$date • $startTime - $endTime';
  }
}
