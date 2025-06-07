import 'package:clinic/features/client/home/presentation/widgets/home_loading.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/features/client/home/domain/clinics/entities/clinics_entity.dart';
import 'package:clinic/features/client/home/presentation/bloc/clinics/clinics_bloc.dart';

class ClinicsItem extends StatefulWidget {
  const ClinicsItem({super.key});

  @override
  State<ClinicsItem> createState() => _ClinicsItemState();
}

class _ClinicsItemState extends State<ClinicsItem>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _loadClinics();
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

  void _loadClinics() {
    context.read<ClinicsBloc>().add(const GetClinicsEvent());
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ClinicsBloc, ClinicsState>(
      builder: (context, state) {
        return AnimatedSwitcher(
          duration: const Duration(milliseconds: 400),
          child: _buildStateWidget(state),
        );
      },
    );
  }

  Widget _buildStateWidget(ClinicsState state) {
    if (state is ClinicsLoading) {
      return HomeLoading(
        text: 'Загрузка клиник...',
      );
    } else if (state is ClinicsLoaded) {
      return SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: _buildLoadedState(state.clinics),
        ),
      );
    } else if (state is ClinicsEmpty) {
      return _buildEmptyState(state.message);
    } else if (state is ClinicsError) {
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
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildErrorIcon(),
          20.h,
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
        Icons.medical_services_outlined,
        color: ColorConstants.errorColor,
        size: 32,
      ),
    );
  }

  Widget _buildRetryButton() {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: _loadClinics,
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
                'Qayta urinish',
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

  Widget _buildEmptyState(String message) {
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
              Icons.local_hospital_outlined,
              size: 36,
              color: ColorConstants.primaryColor,
            ),
          ),
          20.h,
          Text(
            'Klinikalar topilmadi',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: ColorConstants.textColor,
            ),
          ),
          8.h,
          Text(
            message,
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

  Widget _buildLoadedState(List<ClinicsEntity> clinics) {
    return ListView.separated(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      itemCount: clinics.length,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      separatorBuilder: (context, index) => 12.h,
      itemBuilder: (context, index) {
        final clinic = clinics[index];
        return _buildAnimatedClinicCard(clinic, index);
      },
    );
  }

  Widget _buildAnimatedClinicCard(ClinicsEntity clinic, int index) {
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
      child: _buildClinicCard(clinic),
    );
  }

  Widget _buildClinicCard(ClinicsEntity clinic) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // Navigation logic
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
                _buildClinicLogo(clinic),
                16.w,
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        clinic.name,
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
                            Icons.location_on_outlined,
                            size: 14,
                            color: ColorConstants.secondaryTextColor,
                          ),
                          4.w,
                          Expanded(
                            child: Text(
                              clinic.address,
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
                _buildArrowIcon(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildArrowIcon() {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        color: ColorConstants.primaryColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Icon(
        Icons.arrow_forward_ios_rounded,
        size: 14,
        color: ColorConstants.primaryColor,
      ),
    );
  }

  Widget _buildClinicLogo(ClinicsEntity clinic) {
    return Hero(
      tag: 'clinic_logo_${clinic.id}',
      child: Container(
        width: 64,
        height: 64,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 8,
              spreadRadius: -1,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 4,
              spreadRadius: -1,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(16),
          child: Stack(
            children: [
              // Asosiy rasm
              Positioned.fill(
                child: Image.asset(
                  "assets/images/clinc.png",
                  fit: BoxFit.cover,
                ),
              ),
              Positioned.fill(
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.transparent,
                        Colors.black.withOpacity(0.1),
                      ],
                      stops: const [0.6, 1.0],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
