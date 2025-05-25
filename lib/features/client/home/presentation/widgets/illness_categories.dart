import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/core/extension/spacing_extension.dart';
import 'package:clinic/features/client/home/domain/illness/entities/illness_entities.dart';
import 'package:clinic/features/client/home/presentation/bloc/illness/illness_bloc.dart';
import 'package:clinic/features/client/home/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IllnessCategories extends StatefulWidget {
  const IllnessCategories({
    super.key,
  });

  @override
  State<IllnessCategories> createState() => _IllnessCategoriesState();
}

class _IllnessCategoriesState extends State<IllnessCategories>
    with TickerProviderStateMixin {
  late AnimationController _mainController;

  final ScrollController _scrollController = ScrollController();
  final Map<int, bool> _visibleItems = {};

  // Animatsiya yaratilganmi?
  bool _animationsCreated = false;

  @override
  void initState() {
    super.initState();

    // Asosiy animatsiya kontrolleri
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Scroll listener qo'shish
    _scrollController.addListener(_checkVisibleItems);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scrollController.removeListener(_checkVisibleItems);
    _scrollController.dispose();
    super.dispose();
  }

  // Scroll paytida ko'rinadigan elementlarni aniqlash
  void _checkVisibleItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Bu animatsiyalarni refresh qilish uchun
      if (mounted) {
        setState(() {});
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 16, top: 16),
          child: const Text(
            'Категории заболеваний',
            style: TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.bold,
              color: ColorConstants.textColor,
            ),
          ),
        ),
        16.h,
        BlocBuilder<IllnessBloc, IllnessState>(
          builder: (context, state) {
            if (state is IllnessError) {
              return SizedBox();
            } else if (state is IllnessEmpty) {
              return SizedBox();
            } else if (state is IllnessLoaded) {
              if (!_animationsCreated) {
                _animationsCreated = true;

                _mainController.forward();
              }
              return _buildLoadedState(state);
            }
            return SizedBox(
              height: 140,
            );
          },
        ),
      ],
    );
  }

  Widget _buildLoadedState(IllnessLoaded state) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        controller: _scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: state.illnesses.length,
        itemBuilder: (context, index) {
          // Elementni visible qilib belgilash
          _visibleItems[index] = true;

          return Padding(
            padding: EdgeInsets.only(
                right: index == state.illnesses.length - 1 ? 0 : 12),
            child: _buildCardWithAnimation(
                state.illnesses[index], index, state.illnesses.length),
          );
        },
      ),
    );
  }

  // Animatsiyali kartani yaratish
  Widget _buildCardWithAnimation(
      IllnessEntities illness, int index, int totalCount) {
    // Kartaning asosiy content
    final card = CategoryCard(illness: illness);

    // Boshlang'ich animatsiya (loading tugagandan keyin)
    if (_mainController.isAnimating || _mainController.value < 1.0) {
      // Har bir karta uchun o'z kechikishi
      final startDelay = index * 0.1;
      final visibleDuration = 0.6; // Animatsiya davomiyligi

      return AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          // Karta uchun progress hisoblash
          final progress = _mainController.value;

          // Kechikishni hisobga olgan holda kartalar animatsiyasi
          var individualProgress = (progress - startDelay) / visibleDuration;
          individualProgress = individualProgress.clamp(0.0, 1.0);

          // Karta animatsiyalari
          if (individualProgress <= 0) {
            return const SizedBox(width: 120); // Ko'rinmas joy saqlash
          }

          // 3D transformatsiyalar
          final scale = 0.7 + (0.3 * individualProgress);
          final opacity = individualProgress;
          final angle = (1.0 - individualProgress) * 0.5; // radians

          return Transform.translate(
            offset: Offset(120 * (1 - individualProgress), 0),
            child: Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001) // Perspektiva
                ..rotateY(angle) // Y o'qi bo'yicha aylanish
                ..scale(scale),
              alignment: Alignment.centerRight,
              child: Opacity(
                opacity: opacity,
                child: card,
              ),
            ),
          );
        },
      );
    }
    // Scroll animatsiyasi (kartalar orqadan kelishi)
    else {
      // ScrollController dan foydalanib, card pozitsiyasini aniqlash
      final itemPosition = index * (120 + 12); // card width + margin
      final screenPosition =
          _scrollController.hasClients ? _scrollController.offset : 0.0;

      // Ekranning o'ng tomonida qancha masofada?
      final rightEdge = MediaQuery.of(context).size.width;
      final visibleRight = itemPosition - screenPosition;

      // Karta ekranning o'ng chekkasidan ko'rinadimi?
      final isAppearingOnScreen =
          visibleRight >= rightEdge - 120 && visibleRight <= rightEdge + 20;

      // Agar ekranning o'ng chekkasidan paydo bo'layotgan bo'lsa
      if (isAppearingOnScreen) {
        // Qancha masofada ekanligini hisoblash (0.0 dan 1.0 gacha)
        final appearProgress =
            (rightEdge + 20 - visibleRight) / 140; // 120 + 20 (extra margin)
        final normalizedProgress = appearProgress.clamp(0.0, 1.0);

        // 3D effekt parametrlari
        final angle =
            (1.0 - normalizedProgress) * 0.5; // Y o'qi bo'yicha aylanish
        final scale = 0.8 + (0.2 * normalizedProgress); // Masshtab
        final offset = 40 * (1.0 - normalizedProgress); // O'ngdan surilish

        return Transform.translate(
          offset: Offset(offset, 0),
          child: Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // Perspektiva
              ..rotateY(angle) // Y o'qi bo'yicha aylanish
              ..scale(scale),
            alignment: Alignment.centerRight,
            child: card,
          ),
        );
      }

      // Normal holatdagi karta
      return card;
    }
  }
}
