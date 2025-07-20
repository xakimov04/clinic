import 'package:clinic/features/client/receptions/presentation/pages/receptions_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/reception_bloc.dart';

class ReceptionsScreen extends StatefulWidget {
  const ReceptionsScreen({super.key});

  @override
  State<ReceptionsScreen> createState() => _ReceptionsScreenState();
}

class _ReceptionsScreenState extends State<ReceptionsScreen> {
  @override
  void initState() {
    context.read<ReceptionBloc>().add(GetReceptionsClientEvent());
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Медицинская карта")),
      body: BlocBuilder<ReceptionBloc, ReceptionState>(
        builder: (context, state) {
          if (state is ReceptionLoading) {
            return const Center(child: CircularProgressIndicator());
          } else if (state is ReceptionLoaded) {
            if (state.receptions.isEmpty) {
              return const Center(child: Text("Нет истории приёмов"));
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: state.receptions.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final r = state.receptions[i];
                return ListTile(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  title: Text(r.fullName),
                  subtitle: Text(r.specialization),
                  trailing: const Icon(Icons.arrow_forward_ios),
                  onTap: () {
                    context
                        .read<ReceptionBloc>()
                        .add(GetReceptionsListEvent(r.id));
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReceptionListScreen(
                          clientName: r.fullName,
                          clientId: r.id,
                        ),
                      ),
                    );
                  },
                );
              },
            );
          } else if (state is ReceptionError) {
            return Center(child: Text("Ошибка при загрузке данных"));
          }
          return const SizedBox();
        },
      ),
    );
  }
}
