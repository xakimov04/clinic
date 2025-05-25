import 'package:clinic/features/client/main/data/model/nav_item.dart';
import 'package:clinic/features/doctor/main/widgets/navigation_config.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:clinic/core/constants/color_constants.dart';

class DoctorMainScreen extends StatefulWidget {
  final StatefulNavigationShell navigationShell;

  const DoctorMainScreen({
    super.key,
    required this.navigationShell,
  });

  @override
  State<DoctorMainScreen> createState() => _DoctorMainScreenState();
}

class _DoctorMainScreenState extends State<DoctorMainScreen>
    with TickerProviderStateMixin {
  late List<NavItem> _destinations;
  late AnimationController _animationController;

  // Animatsiya animatsiyadami
  bool _isAnimating = false;

  @override
  void initState() {
    super.initState();
    _destinations = DoctorNavigationConfig.getDestinations();

    // Animatsiya controllerni yaratamiz
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 400),
    );

    // Animatsiya tugaganda holat o'zgarishini to'xtatamiz
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        setState(() {
          _isAnimating = false;
        });
        _animationController.reset();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Tab tanlash logikasi
  void _onTap(int index) {
    // Agar bir xil tab bosilsa yoki animatsiya ketayotgan bo'lsa, hech narsa qilmaymiz
    if (index == widget.navigationShell.currentIndex || _isAnimating) return;

    setState(() {
      _isAnimating = true;
    });

    // Animatsiyani boshlaymiz
    _animationController.forward(from: 0.0);

    // Animatsiya boshlanganidan keyin sahifani almashtiramiz
    Future.delayed(Duration(milliseconds: 100), () {
      widget.navigationShell.goBranch(
        index,
        initialLocation: index == widget.navigationShell.currentIndex,
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: widget.navigationShell,
      bottomNavigationBar: _buildAnimatedNavigationBar(),
    );
  }

  Widget _buildAnimatedNavigationBar() {
    return Container(
      decoration: BoxDecoration(
        color: DoctorNavigationConfig.getBackgroundColor(),
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: ClipRRect(
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
        child: CupertinoTabBar(
          currentIndex: widget.navigationShell.currentIndex,
          activeColor: ColorConstants.primaryColor,
          inactiveColor: DoctorNavigationConfig.getInactiveColor(),
          backgroundColor: Colors.transparent,
          iconSize: 24.0,
          height: 50.0,
          onTap: _onTap,
          items: _destinations
              .map((destination) =>
                  _buildCupertinoNavigationBarItem(destination))
              .toList(),
        ),
      ),
    );
  }

  BottomNavigationBarItem _buildCupertinoNavigationBarItem(
      NavItem destination) {
    return BottomNavigationBarItem(
      icon: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Icon(destination.icon, size: 24),
      ),
      activeIcon: Padding(
        padding: const EdgeInsets.only(bottom: 2),
        child: Icon(destination.activeIcon, size: 24),
      ),
      label: destination.label,
    );
  }
}
