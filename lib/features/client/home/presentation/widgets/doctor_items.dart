import 'package:clinic/features/client/home/presentation/widgets/doctor_card.dart';
import 'package:clinic/features/client/home/presentation/widgets/home_loading.dart';
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
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadDoctors();
  }

  void _initAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.0, 0.7, curve: Curves.easeOut),
      ),
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.3),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: const Interval(0.2, 1.0, curve: Curves.elasticOut),
      ),
    );

    _animationController.forward();
  }

  void _loadDoctors() {
    context.read<DoctorBloc>().add(const GetDoctorEvent());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<DoctorBloc, DoctorState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildStateWidget(state),
        );
      },
    );
  }

  Widget _buildStateWidget(DoctorState state) {
    if (state is DoctorLoading) {
      return HomeLoading(
        text: 'Загрузка специалистов...',
      );
    } else if (state is DoctorLoaded) {
      return SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildLoadedState(state.doctors),
        ),
      );
    } else if (state is DoctorError) {
      return _buildErrorState(state.message);
    }
    return const SizedBox.shrink();
  }

  Widget _buildErrorState(String message) {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 20,
            spreadRadius: -2,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildErrorIcon(),
          20.h,
          Text(
            'Не удалось загрузить данные',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ColorConstants.textColor,
            ),
          ),
          8.h,
          Text(
            message,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: ColorConstants.secondaryTextColor,
              height: 1.4,
            ),
          ),
          24.h,
          _buildRetryButton(),
        ],
      ),
    );
  }

  Widget _buildErrorIcon() {
    return Container(
      width: 72,
      height: 72,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            ColorConstants.errorColor.withOpacity(0.15),
            ColorConstants.errorColor.withOpacity(0.05),
          ],
        ),
        shape: BoxShape.circle,
      ),
      child: Icon(
        Icons.person_outline_rounded,
        color: ColorConstants.errorColor,
        size: 32,
      ),
    );
  }

  Widget _buildRetryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loadDoctors,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 14),
          decoration: BoxDecoration(
            gradient: ColorConstants.primaryGradient,
            borderRadius: BorderRadius.circular(14),
            boxShadow: [
              BoxShadow(
                color: ColorConstants.primaryColor.withOpacity(0.4),
                blurRadius: 12,
                spreadRadius: -3,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.refresh_rounded,
                color: Colors.white,
                size: 18,
              ),
              8.w,
              Text(
                'Повторить',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.2,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadedState(List<DoctorEntity> doctors) {
    if (doctors.isEmpty) {
      return _buildEmptyState();
    }

    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: doctors.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => 12.h,
      itemBuilder: (context, index) {
        final doctor = doctors[index];
        return _buildAnimatedDoctorCard(doctor, index);
      },
    );
  }

  Widget _buildEmptyState() {
    return Container(
      margin: const EdgeInsets.all(20),
      padding: const EdgeInsets.all(32),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: ColorConstants.borderColor.withOpacity(0.3),
          width: 1,
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  ColorConstants.primaryColor.withOpacity(0.15),
                  ColorConstants.primaryColor.withOpacity(0.05),
                ],
              ),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off_rounded,
              size: 36,
              color: ColorConstants.primaryColor,
            ),
          ),
          20.h,
          Text(
            'Специалисты не найдены',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ColorConstants.textColor,
            ),
          ),
          8.h,
          Text(
            'Попробуйте изменить критерии поиска',
            style: TextStyle(
              fontSize: 14,
              color: ColorConstants.secondaryTextColor,
              height: 1.4,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildAnimatedDoctorCard(DoctorEntity doctor, int index) {
    return TweenAnimationBuilder<double>(
      tween: Tween<double>(begin: 1.0, end: 0.0),
      duration: Duration(milliseconds: 400 + (index * 80)),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Transform.translate(
          offset: Offset(0, 60 * value),
          child: Opacity(
            opacity: 1 - value,
            child: child,
          ),
        );
      },
      child: DoctorCard(doctor: doctor),
    );
  }
}
