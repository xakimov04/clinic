import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/features/client/home/presentation/bloc/clinics/clinics_bloc.dart';
import 'package:clinic/features/client/home/presentation/bloc/doctor/doctor_bloc.dart';
import 'package:clinic/features/client/home/presentation/bloc/illness/illness_bloc.dart';
import 'package:clinic/features/client/home/presentation/widgets/clinics_item.dart';
import 'package:clinic/features/client/home/presentation/widgets/doctor_items.dart';
import 'package:clinic/features/client/home/presentation/widgets/illness_categories.dart';
import 'package:clinic/features/client/notification/notification_page.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Основной ScrollController
  final ScrollController _scrollController = ScrollController();

  // Активный индекс вкладки
  int _currentIndex = 0;

  // Состояние загрузки данных
  bool _doctorsLoaded = false;
  bool _clinicsLoaded = false;

  @override
  void initState() {
    super.initState();
    context.read<IllnessBloc>().add(IllnessGetAll());

    // Dastlab birinchi tabdagi ma'lumotlarni yuklash
    _loadDoctorsData();
  }

  // Загрузка данных для первой вкладки
  void _loadDoctorsData() {
    if (!_doctorsLoaded) {
      context.read<DoctorBloc>().add(const GetDoctorEvent());
      _doctorsLoaded = true;
    }
  }

  // Загрузка данных о врачах
  void _loadClinicsData() {
    if (!_clinicsLoaded) {
      context.read<ClinicsBloc>().add(const GetClinicsEvent());
      _clinicsLoaded = true;
    }
  }

  // Логика переключения вкладок
  void _switchTab(int index) {
    if (_currentIndex != index) {
      setState(() {
        _currentIndex = index;
      });

      // Загрузка данных при необходимости
      if (index == 0) {
        _loadDoctorsData();
      } else if (index == 1) {
        _loadClinicsData();
      }
    }
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        surfaceTintColor: Colors.white,
        elevation: 0,
        centerTitle: false,
        title: Text(
          'МедЦентр',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.bold,
                color: ColorConstants.primaryColor,
              ),
        ),
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: ColorConstants.shadowColor.withOpacity(0.08),
                  blurRadius: 6,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(
                Icons.notifications_outlined,
                color: ColorConstants.primaryColor,
              ),
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => NotificationPage(),
                    ));
              },
            ),
          ),
        ],
      ),
      body: RefreshIndicator.adaptive(
        backgroundColor: ColorConstants.backgroundColor,
        color: ColorConstants.primaryColor,
        onRefresh: () async {
          // Refresh qilish uchun ma'lumotlarni qayta yuklash
          if (_currentIndex == 0) {
            context.read<DoctorBloc>().add(const GetDoctorEvent());
            context.read<IllnessBloc>().add(IllnessGetAllNotLoading());
          } else if (_currentIndex == 1) {
            context.read<ClinicsBloc>().add(const GetClinicsEvent());
            context.read<IllnessBloc>().add(IllnessGetAllNotLoading());
          }
        },
        child: CustomScrollView(
          controller: _scrollController,
          slivers: [
            // Kasalliklar kategoriyalari
            SliverToBoxAdapter(
              child: IllnessCategories(),
            ),

            // Custom Tab Bar
            SliverToBoxAdapter(
              child: _buildTabBar(context),
            ),

            // ASOSIY O'ZGARISH: SliverToBoxAdapter orqali content ko'rsatish
            SliverToBoxAdapter(
              child: _currentIndex == 0
                  ? const DoctorItems()
                  : const ClinicsItem(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 14, 16, 8),
      height: 40,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: ColorConstants.shadowColor.withOpacity(0.08),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Stack(
        children: [
          // Siljuvchi background animatsiyasi
          AnimatedPositioned(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOutQuint,
            left: _currentIndex * (MediaQuery.of(context).size.width - 32) / 2,
            top: 0,
            bottom: 0,
            width: (MediaQuery.of(context).size.width - 32) / 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                gradient: ColorConstants.primaryGradient,
                boxShadow: [
                  BoxShadow(
                    color: ColorConstants.primaryColor.withOpacity(0.3),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
            ),
          ),

          // Tab tugmalari
          Row(
            children: [
              _buildTabButton("Врачи", 0, Icons.medical_services_outlined),
              _buildTabButton("Клиники", 1, Icons.local_hospital_outlined),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String text, int index, IconData icon) {
    final isSelected = _currentIndex == index;

    return Expanded(
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(10),
          onTap: () => _switchTab(index),
          splashColor: Colors.white.withOpacity(0.1),
          highlightColor: Colors.transparent,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  color: isSelected
                      ? Colors.white
                      : ColorConstants.secondaryTextColor,
                  size: isSelected ? 22 : 18,
                ),
                const SizedBox(width: 8),
                AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 200),
                  style: TextStyle(
                    fontSize: isSelected ? 16 : 15,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                    color: isSelected
                        ? Colors.white
                        : ColorConstants.secondaryTextColor,
                  ),
                  child: Text(text),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
