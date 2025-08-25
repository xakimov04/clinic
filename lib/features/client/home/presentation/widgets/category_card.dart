import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/routes/route_paths.dart';
import 'package:clinic/core/ui/widgets/images/custom_cached_image.dart';
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
      constraints: const BoxConstraints(
        minHeight: 140, 
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: ColorConstants.borderColor.withOpacity(0.5),
          width: 0.5,
        ),
        // Soya qo'shish zamonaviy ko'rinish uchun
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
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          borderRadius: BorderRadius.circular(16),
          splashColor: ColorConstants.primaryColor.withOpacity(0.1),
          highlightColor: ColorConstants.primaryColor.withOpacity(0.05),
          onTap: () => _handleCardTap(context),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildIllnessImage(illness.photo),
                8.h, // 4.h dan 8.h ga o'zgartirdim
                Expanded(
                  child: _buildOptimizedText(illness.specialization),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _handleCardTap(BuildContext context) {
    context.read<IllnessBloc>().add(IllnessGetDetails(illness.id));
    context.push(
      RoutePaths.illnessDetail.replaceAll(':illnessId', illness.id.toString()),
      extra: {'illness': illness},
    );
  }

  Widget _buildIllnessImage(String imageUrl) {
    const imageSize = 50.0;

    final fallback = Container(
      width: imageSize,
      height: imageSize,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.healing,
        size: 28,
        color: ColorConstants.activeColor,
      ),
    );

    if (imageUrl.isEmpty) return fallback;

    return ClipOval(
      child: SizedBox(
        width: imageSize,
        height: imageSize,
        child: CacheImageWidget(
          imageUrl: imageUrl,
          fit: BoxFit.cover,
          errorWidget: fallback,
        ),
      ),
    );
  }

  Widget _buildOptimizedText(String text) {
    return Center(
      // Expanded olib tashlandi
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textColor,
          height: 1.2,
        ),
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
      ),
    );
  }
}
