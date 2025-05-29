import 'dart:io';

import 'package:clinic/core/ui/widgets/images/custom_cached_image.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:clinic/features/client/home/presentation/bloc/doctor/doctor_bloc.dart';

class DoctorItems extends StatefulWidget {
  const DoctorItems({super.key});

  @override
  State<DoctorItems> createState() => _DoctorItemsState();
}

class _DoctorItemsState extends State<DoctorItems>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDoctors();
  }

  void _initAnimations() {
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeOut),
    );

    _controller.forward();
  }

  void _loadDoctors() {
    context.read<DoctorBloc>().add(const GetDoctorEvent());
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        if (state is DoctorLoading) {
          return _buildLoadingState();
        } else if (state is DoctorLoaded) {
          return FadeTransition(
            opacity: _fadeAnimation,
            child: _buildLoadedState(state.doctors),
          );
        } else if (state is DoctorError) {
          return _buildErrorState(state.message);
        }
        return const SizedBox.shrink();
      },
    );
  }

  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: 40,
            width: 40,
            child: Platform.isIOS
                ? CupertinoActivityIndicator(
                    animating: true,
                    color: ColorConstants.primaryColor,
                  )
                : CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                        ColorConstants.primaryColor.withOpacity(0.8)),
                  ),
          ),
          16.h,
          const Text(
            'Загрузка специалистов...',
            style: TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: ColorConstants.secondaryTextColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 15,
            spreadRadius: 1,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildErrorIcon(),
          16.h,
          const Text(
            'Не удалось загрузить данные',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: ColorConstants.textColor,
            ),
          ),
          8.h,
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 12,
              color: ColorConstants.secondaryTextColor,
            ),
          ),
          20.h,
          _buildRetryButton(),
        ],
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        color: ColorConstants.errorColor.withOpacity(0.1),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.error_outline_rounded,
        color: ColorConstants.errorColor,
        size: 28,
      ),
    );
  }

  Widget _buildRetryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loadDoctors,
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            gradient: ColorConstants.primaryGradient,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.primaryColor.withOpacity(0.3),
                blurRadius: 10,
                spreadRadius: -2,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.refresh_rounded,
                  color: Colors.white,
                  size: 16,
                ),
                SizedBox(width: 8),
                Text(
                  'Повторить',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 0.3,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(List<DoctorEntity> doctors) {
    if (doctors.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      itemCount: doctors.length,
      physics: const NeverScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return _buildAnimatedDoctorCard(doctor, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 12,
              spreadRadius: 0,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: Colors.teal.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.search_off_rounded,
                size: 28,
                color: Colors.teal,
              ),
            ),
            16.h,
            const Text(
              'Специалисты не найдены',
              style: TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w600,
                color: ColorConstants.textColor,
              ),
            ),
            8.h,
            const Text(
              'Попробуйте изменить критерии поиска',
              style: TextStyle(
                fontSize: 12,
                color: ColorConstants.secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAnimatedDoctorCard(DoctorEntity doctor, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: Duration(milliseconds: 500 + (index * 100)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 100 * value),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: _buildDoctorCard(doctor),
    );
  }

  Widget _buildDoctorCard(DoctorEntity doctor) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () {
            // Действие при нажатии на врача
          },
          borderRadius: BorderRadius.circular(16),
          child: Ink(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Column(
              children: [
                _buildDoctorCardContent(doctor),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDoctorCardContent(DoctorEntity doctor) {
    return Padding(
      padding: const EdgeInsets.all(12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildDoctorAvatar(doctor),
          12.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildDoctorName(doctor),
                10.h,
                _buildDoctorDescription(doctor),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDoctorAvatar(DoctorEntity doctor) {
    return Stack(
      children: [
        CustomCachedImage(
          imageUrl: doctor.avatar,
          width: 70,
          height: 70,
          type: CustomImageType.circle,
          backgroundColor: ColorConstants.primaryColor.withOpacity(0.2),
          fit: BoxFit.cover,
        ),
        Positioned(
          right: 0,
          bottom: 0,
          child: Container(
            padding: const EdgeInsets.all(4),
            decoration: const BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(8),
                bottomRight: Radius.circular(14),
              ),
            ),
            child: Icon(
              Icons.medical_services_rounded,
              size: 14,
              color: ColorConstants.primaryColor,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDoctorName(DoctorEntity doctor) {
    return Text(
      doctor.fullName,
      style: const TextStyle(
        fontSize: 15,
        fontWeight: FontWeight.w600,
        color: ColorConstants.textColor,
      ),
      maxLines: 1,
      overflow: TextOverflow.ellipsis,
    );
  }

  Widget _buildDoctorDescription(DoctorEntity doctor) {
    return Text(
      doctor.specialization,
      style: TextStyle(
        fontSize: 11,
        color: Colors.grey[600],
      ),
      maxLines: 2,
      overflow: TextOverflow.ellipsis,
    );
  }
}
