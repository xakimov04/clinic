import 'package:clinic/features/client/home/domain/clinics/entities/clinics_entity.dart';
import 'package:clinic/features/client/home/presentation/bloc/clinics_doctor/clinics_doctors_bloc.dart';
import 'package:clinic/features/client/home/presentation/widgets/doctor_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ClinicDetailsScreen extends StatelessWidget {
  final ClinicsEntity clinic;

  const ClinicDetailsScreen({
    super.key,
    required this.clinic,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(clinic.name),
      ),
      body: BlocBuilder<ClinicsDoctorsBloc, ClinicsDoctorsState>(
        builder: (context, state) {
          if (state is ClinicsDoctorsLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is ClinicsDoctorsError) {
            return Center(child: Text(state.message));
          }

          if (state is ClinicsDoctorsLoaded) {
            print(state.doctors);
            if (state.doctors.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(60),
                        ),
                        child: Icon(
                          Icons.medical_services_outlined,
                          size: 60,
                          color: Colors.grey[400],
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        'Врачи не найдены',
                        style:
                            Theme.of(context).textTheme.headlineSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800],
                                ),
                      ),
                      const SizedBox(height: 12),
                      Text(
                        'Извините, в настоящее время\nв этой клинике нет врачей',
                        textAlign: TextAlign.center,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                              color: Colors.grey[600],
                              height: 1.5,
                            ),
                      ),
                    ],
                  ),
                ),
              );
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.doctors.length,
              itemBuilder: (context, index) {
                final doctor = state.doctors[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DoctorCard(doctor: doctor),
                );
              },
            );
          }

          return const SizedBox.shrink();
        },
      ),
    );
  }
}
