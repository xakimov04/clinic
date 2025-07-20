import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/features/client/receptions/presentation/bloc/reception_bloc.dart';

class ReceptionInfoScreen extends StatelessWidget {
  final DateTime date;

  const ReceptionInfoScreen({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Приём: ${date.toLocal()}".split(' ')[0])),
      body: BlocBuilder<ReceptionBloc, ReceptionState>(
        builder: (context, state) {
          if (state is ReceptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReceptionInfoLoaded) {
            final infos =
                state.info; // <- Bu List<ReceptionInfoEntity> bo‘lishi kerak

            if (infos.isEmpty) {
              return const Center(child: Text("Нет подробной информации"));
            }

            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: infos.length,
              separatorBuilder: (_, __) => const Divider(height: 32),
              itemBuilder: (context, index) {
                final info = infos[index];
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text("Диагноз:",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(info.diagnosis ?? "Не указан"),
                    const SizedBox(height: 16),
                    Text("План лечения:",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(info.treatmentPlan ?? "Не указан"),
                    const SizedBox(height: 16),
                    Text("Файл:",
                        style: Theme.of(context).textTheme.titleMedium),
                    const SizedBox(height: 8),
                    Text(info.attachedFile ?? "Нет файла"),
                  ],
                );
              },
            );
          } else if (state is ReceptionError) {
            return Center(child: Text("Ошибка: ${state.message}"));
          }

          return const SizedBox();
        },
      ),
    );
  }
}
