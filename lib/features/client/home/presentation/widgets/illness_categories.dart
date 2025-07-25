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

  // Создана ли анимация?
  bool _animationsCreated = false;

  @override
  void initState() {
    super.initState();

    // Основной контроллер анимации
    _mainController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    // Добавление scroll listener
    _scrollController.addListener(_checkVisibleItems);
  }

  @override
  void dispose() {
    _mainController.dispose();
    _scrollController.removeListener(_checkVisibleItems);
    _scrollController.dispose();
    super.dispose();
  }

  // При прокрутке определяем видимые элементы
  void _checkVisibleItems() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      // Для обновления анимаций
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
          buildWhen: (previous, current) {
            return current is IllnessLoading ||
                current is IllnessLoaded ||
                current is IllnessEmpty ||
                current is IllnessError ||
                current is IllnessInitial;
          },
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
      // Для каждой карты своя задержка
      final startDelay = index * 0.1;
      final visibleDuration = 0.6; // Animatsiya davomiyligi

      return AnimatedBuilder(
        animation: _mainController,
        builder: (context, child) {
          // Прогресс для карты
          final progress = _mainController.value;

          // Анимация для каждой карты с учётом задержки
          var individualProgress = (progress - startDelay) / visibleDuration;
          individualProgress = individualProgress.clamp(0.0, 1.0);

          // Анимация для невидимых карт сохраняем место
          if (individualProgress <= 0) {
            return const SizedBox(width: 120); // Ko'rinmas joy saqlash
          }

          // 3D трансформации
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
    // Анимация прокрутки (карты появляются справа)
    else {
      // Определяем позицию карты с помощью ScrollController
      final itemPosition = index * (120 + 12); // card width + margin
      final screenPosition =
          _scrollController.hasClients ? _scrollController.offset : 0.0;

      // На каком расстоянии от правого края экрана?
      final rightEdge = MediaQuery.of(context).size.width;
      final visibleRight = itemPosition - screenPosition;

      // Карта появляется с правого края экрана?
      final isAppearingOnScreen =
          visibleRight >= rightEdge - 120 && visibleRight <= rightEdge + 20;

      // Если появляется, рассчитываем прогресс (от 0.0 до 1.0)
      if (isAppearingOnScreen) {
        // 3D параметры эффекта
        final appearProgress =
            (rightEdge + 20 - visibleRight) / 140; // 120 + 20 (extra margin)
        final normalizedProgress = appearProgress.clamp(0.0, 1.0);

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

      // Обычная карта
      return card;
    }
  }
}
