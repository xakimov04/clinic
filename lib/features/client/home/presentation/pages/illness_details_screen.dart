import 'package:clinic/core/di/export/di_export.dart';
import 'package:clinic/features/client/home/presentation/widgets/doctor_card.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';

class IllnessDetailsScreen extends StatelessWidget {
  final IllnessEntities illness;

  const IllnessDetailsScreen({
    super.key,
    required this.illness,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(illness.specialization),
      ),
      body: BlocBuilder<DoctorBloc, DoctorState>(
        builder: (context, state) {
          if (state is DoctorLoading) {
            return const Center(child: CupertinoActivityIndicator());
          }

          if (state is DoctorError) {
            return Center(child: Text(state.message));
          }

          if (state is DoctorLoaded) {
            final illnes = state.doctors
                .where((element) =>
                    element.specialization.toLowerCase() ==
                    illness.specialization.toLowerCase())
                .toList();
            if (illnes.isEmpty) {
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
                        'К сожалению, по данному заболеванию\nврачи временно недоступны',
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
              padding: EdgeInsets.all(16),
              itemCount: illnes.length,
              itemBuilder: (context, index) {
                final doctor = illnes[index];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: DoctorCard(
                    doctor: doctor,
                    heroKey: 'illness_screen',
                  ),
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
