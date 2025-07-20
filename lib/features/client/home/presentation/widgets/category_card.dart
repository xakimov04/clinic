import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/routes/route_paths.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';
import 'package:clinic/features/client/home/presentation/bloc/illness/illness_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';

class CategoryCard extends StatelessWidget {
  final IllnessEntities illness;

  const CategoryCard({
    super.key,
    required this.illness,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 120,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.borderColor.withOpacity(0.5),
          width: 0.5,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          children: [
            // Card content
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Center(
                    child: SizedBox(
                      width: 50,
                      height: 50,
                      child: Image.asset("assets/images/illness.png"),
                    ),
                  ),

                  8.h,

                  // Illness name
                  Text(
                    illness.specialization,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.textColor,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),

                  4.h,
                ],
              ),
            ),

            Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(16),
                splashColor: ColorConstants.primaryColor.withOpacity(0.1),
                highlightColor: ColorConstants.primaryColor.withOpacity(0.05),
                onTap: () {
                  context
                      .read<IllnessBloc>()
                      .add(IllnessGetDetails(illness.id));
                  context.push(
                    RoutePaths.illnessDetail
                        .replaceAll(':illnessId', illness.id.toString()),
                    extra: {'illness': illness},
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
