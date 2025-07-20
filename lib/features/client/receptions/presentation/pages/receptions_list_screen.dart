import 'package:clinic/features/client/receptions/presentation/bloc/reception_bloc.dart';
import 'package:clinic/features/client/receptions/presentation/pages/reception_info_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class ReceptionListScreen extends StatelessWidget {
  final String clientName;
  final String clientId;

  const ReceptionListScreen({
    super.key,
    required this.clientName,
    required this.clientId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(clientName)),
      body: BlocBuilder<ReceptionBloc, ReceptionState>(
        builder: (context, state) {
          if (state is ReceptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReceptionListLoaded) {
            if (state.receptionList.isEmpty) {
              return const Center(child: Text("Нет записей по приёмам"));
            }
            return ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: state.receptionList.length,
              itemBuilder: (context, i) {
                final reception = state.receptionList[i];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8),
                  child: ListTile(
                    title: Text(reception.serviceName),
                    subtitle: Text(
                      "${reception.visitDate.toLocal()}".split(' ')[0],
                    ),
                    trailing: const Icon(Icons.arrow_forward_ios),
                    onTap: () {
                      context
                          .read<ReceptionBloc>()
                          .add(GetReceptionsInfoEvent(reception.id));
                      Navigator.of(context).push(
                        MaterialPageRoute(
                          builder: (_) => ReceptionInfoScreen(
                            date: reception.visitDate,
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            );
          }
          return const SizedBox();
        },
      ),
    );
  }
}
