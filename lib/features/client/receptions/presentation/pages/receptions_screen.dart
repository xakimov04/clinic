import 'package:clinic/core/ui/widgets/images/custom_cached_image.dart';
import 'package:clinic/features/client/receptions/presentation/pages/receptions_list_screen.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
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
        buildWhen: (previous, current) {
          return current is ReceptionLoaded || current is ReceptionLoading;
        },
        builder: (context, state) {
          if (state is ReceptionLoading) {
            return const Center(
              child: CircularProgressIndicator(
                strokeWidth: 3,
                valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
              ),
            );
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
                  leading: SizedBox(
                    width: 60,
                    height: double.maxFinite,
                    child: ClipRRect(
                      borderRadius: BorderRadiusGeometry.circular(10),
                      child: CacheImageWidget(
                        imageUrl: r.photo!,
                        errorWidget:
                            SvgPicture.asset('assets/images/avatar.svg'),
                      ),
                    ),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                    side: BorderSide(color: Colors.grey.shade300),
                  ),
                  title: Text(
                    r.fullName,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  subtitle: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      r.clinic!.isEmpty ? SizedBox() : Text(r.clinic!),
                      Text(r.specialization),
                    ],
                  ),
                  onTap: () {
                    context
                        .read<ReceptionBloc>()
                        .add(GetReceptionsListEvent(r.id));
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => ReceptionListScreen(
                          clientName: r.fullName,
                          clientId: r.id,
                          photo: r.photo ?? "",
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
