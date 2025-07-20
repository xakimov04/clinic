import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/core/ui/widgets/images/custom_cached_image.dart';
import 'package:clinic/features/client/appointments/presentation/pages/appointment_booking_screen.dart';
import 'package:clinic/features/client/home/domain/doctors/entities/doctor_entity.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';

class DoctorDetailScreen extends StatefulWidget {
  final DoctorEntity doctor;
  final String heroKey;
  const DoctorDetailScreen({
    super.key,
    required this.doctor,
    this.heroKey = 'doctor_screen_',
  });

  @override
  State<DoctorDetailScreen> createState() => _DoctorDetailScreenState();
}

class _DoctorDetailScreenState extends State<DoctorDetailScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  int _selectedTabIndex = 0;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  void _initializeAnimations() {
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: ColorConstants.backgroundColor,
      appBar: _buildAppBar(),
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SingleChildScrollView(
          child: Column(
            children: [
              _buildDoctorHeader(),
              _buildActionButtons(),
              _buildTabSection(),
              _buildTabContent(),
            ],
          ),
        ),
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.white,
      elevation: 0,
      leading: Container(
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: ColorConstants.backgroundColor,
          shape: BoxShape.circle,
        ),
        child: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new,
              color: ColorConstants.textColor, size: 18),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      title: const Text(
        'Врач',
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ColorConstants.textColor,
        ),
      ),
      centerTitle: true,
    );
  }

  Widget _buildDoctorHeader() {
    return Container(
      color: Colors.white,
      padding: 20.a,
      child: Row(
        children: [
          _buildDoctorAvatar(widget.doctor),
          16.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Name
                Text(
                  widget.doctor.fullName,
                  style: const TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: ColorConstants.textColor,
                  ),
                ),

                8.h,

                Wrap(
                  spacing: 8,
                  runSpacing: 6,
                  children: [
                    _buildSpecializationTag(widget.doctor.specialization,
                        ColorConstants.primaryColor),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecializationTag(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 12,
          color: color,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Container(
      color: Colors.white,
      padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
      child: Column(
        children: [
          Container(
            width: double.infinity,
            height: 48,
            decoration: BoxDecoration(
              border:
                  Border.all(color: ColorConstants.primaryColor, width: 1.5),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _makeAppointment(),
                borderRadius: BorderRadius.circular(24),
                child: const Center(
                  child: Text(
                    'Записаться на прием к врачу офлайн',
                    style: TextStyle(
                      fontSize: 15,
                      color: ColorConstants.primaryColor,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabSection() {
    return Container(
      color: Colors.white,
      margin: const EdgeInsets.only(top: 8),
      child: Row(
        children: [
          _buildTabItem('Контакты', 0),
          _buildTabItem('Лицензия', 1),
        ],
      ),
    );
  }

  Widget _buildTabItem(String title, int index) {
    final isSelected = _selectedTabIndex == index;

    return Expanded(
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedTabIndex = index;
          });
          HapticFeedback.selectionClick();
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(
                color: isSelected
                    ? ColorConstants.primaryColor
                    : Colors.transparent,
                width: 2,
              ),
            ),
          ),
          child: Text(
            title,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
              color: isSelected
                  ? ColorConstants.primaryColor
                  : ColorConstants.secondaryTextColor,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTabContent() {
    return Container(
      color: Colors.white,
      padding: 20.a,
      child: _getTabContent(),
    );
  }

  Widget _getTabContent() {
    switch (_selectedTabIndex) {
      case 0:
        return _buildContactContent();
      case 1:
        return _buildLicenseContent();
      default:
        return SizedBox();
    }
  }

  Widget _buildLicenseContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Медицинская лицензия',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorConstants.textColor,
          ),
        ),
        16.h,
        Container(
          padding: 16.a,
          decoration: BoxDecoration(
            color: ColorConstants.primaryColor.withOpacity(0.05),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: ColorConstants.primaryColor.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.verified,
                    color: ColorConstants.successColor,
                    size: 20,
                  ),
                  8.w,
                  const Text(
                    'Лицензия подтверждена',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: ColorConstants.successColor,
                    ),
                  ),
                ],
              ),
              12.h,
              Text(
                'Номер лицензии: ${widget.doctor.medicalLicense}',
                style: const TextStyle(
                  fontSize: 15,
                  color: ColorConstants.textColor,
                  fontWeight: FontWeight.w500,
                ),
              ),
              8.h,
              Text(
                'Специализация: ${widget.doctor.specialization}',
                style: const TextStyle(
                  fontSize: 14,
                  color: ColorConstants.secondaryTextColor,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContactContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          'Контактная информация',
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: ColorConstants.textColor,
          ),
        ),
        16.h,
        _buildContactItem(
          icon: Icons.person,
          title: 'Полное имя',
          value: widget.doctor.fullName,
        ),
        _buildContactItem(
          icon: Icons.medical_services,
          title: 'Специализация',
          value: widget.doctor.specialization,
        ),
      ],
    );
  }

  Widget _buildContactItem({
    required IconData icon,
    required String title,
    required String value,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: ColorConstants.primaryColor.withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: ColorConstants.primaryColor, size: 18),
          ),
          12.w,
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 13,
                    color: ColorConstants.secondaryTextColor,
                  ),
                ),
                2.h,
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    color: ColorConstants.textColor,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _makeAppointment() {
    HapticFeedback.lightImpact();
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => AppointmentBookingScreen(doctor: widget.doctor),
      ),
    );
  }

  Widget _buildDoctorAvatar(DoctorEntity doctor) {
    return Hero(
      tag: 'doctor_screen_${doctor.hashCode}',
      child: SizedBox(
        width: 80,
        height: 80,
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
    );
  }
}
