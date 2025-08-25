import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/images/custom_cached_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:go_router/go_router.dart';

import '../../domain/doctors/entities/doctor_entity.dart';

class DoctorCard extends StatelessWidget {
  const DoctorCard({
    super.key,
    required this.doctor,
    this.heroKey = 'doctor_screen_',
  });
  final String heroKey;
  final DoctorEntity doctor;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          context.push(
            '/doctor/${doctor.id}',
            extra: {
              'doctor': doctor,
            },
          );
        },
        borderRadius: BorderRadius.circular(18),
        splashColor: ColorConstants.primaryColor.withOpacity(0.1),
        highlightColor: ColorConstants.primaryColor.withOpacity(0.05),
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: ColorConstants.borderColor.withOpacity(0.2),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 12,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
              BoxShadow(
                color: Colors.black.withOpacity(0.02),
                blurRadius: 6,
                spreadRadius: -1,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Hero(
                  tag: '$heroKey${doctor.hashCode}',
                  child: SizedBox(
                    width: 64,
                    height: 64,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: doctor.avatar.isEmpty
                          ? SvgPicture.asset(
                              "assets/images/avatar.svg",
                              fit: BoxFit.cover,
                            )
                          : CacheImageWidget(
                              imageUrl: doctor.avatar,
                            ),
                    ),
                  ),
                ),
                16.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doctor.fullName,
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: ColorConstants.textColor,
                          height: 1.2,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      6.h,
                      Row(
                        children: [
                          Icon(
                            Icons.medical_services_outlined,
                            size: 14,
                            color: ColorConstants.secondaryTextColor,
                          ),
                          4.w,
                          Expanded(
                            child: Text(
                              doctor.specialization.isEmpty
                                  ? "Доктор"
                                  : doctor.specialization,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                                color: ColorConstants.secondaryTextColor,
                                height: 1.2,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                12.w,
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: ColorConstants.primaryColor.withOpacity(0.08),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 14,
                    color: ColorConstants.primaryColor,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
