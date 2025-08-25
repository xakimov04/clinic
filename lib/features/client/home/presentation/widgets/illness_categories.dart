import 'package:clinic/core/constants/color_constants.dart';
import 'package:clinic/features/client/home/presentation/bloc/illness/illness_bloc.dart';
import 'package:clinic/features/client/home/presentation/widgets/category_card.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class IllnessCategories extends StatefulWidget {
  const IllnessCategories({super.key});

  @override
  State<IllnessCategories> createState() => _IllnessCategoriesState();
}

class _IllnessCategoriesState extends State<IllnessCategories> {
  bool _isExpanded = false;

  // Responsive grid parametrlari
  int get _crossAxisCount {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 6; // Katta desktop
    if (screenWidth > 900) return 5; // Desktop/planshet landscape
    if (screenWidth > 600) return 4; // Planshet portrait
    return 3; // Telefon
  }

  int get _initialRowCount => 1;
  int get _itemsToShowInitially => _crossAxisCount * _initialRowCount;

  // Responsive styling
  EdgeInsetsGeometry get _containerPadding {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return const EdgeInsets.symmetric(horizontal: 32);
    if (screenWidth > 900) return const EdgeInsets.symmetric(horizontal: 24);
    return const EdgeInsets.symmetric(horizontal: 16);
  }

  double get _crossAxisSpacing {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) return 16;
    if (screenWidth > 600) return 12;
    return 10;
  }

  double get _mainAxisSpacing {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) return 16;
    if (screenWidth > 600) return 12;
    return 10;
  }

  double get _childAspectRatio {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 1200) return 1.05; // Katta ekranlarda biroz uzunroq
    if (screenWidth > 900) return 1.0; // Desktop/planshet landscape
    if (screenWidth > 600) return 0.95; // Planshet portrait
    return 0.9; // Telefon
  }

  double get _titleFontSize {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) return 20;
    if (screenWidth > 600) return 18;
    return 17;
  }

  double get _verticalSpacing {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) return 24;
    if (screenWidth > 600) return 20;
    return 16;
  }

  // Loading card parametrlari
  double get _loadingCardRadius {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) return 16;
    return 12;
  }

  double get _loadingCardPadding {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) return 16;
    return 12;
  }

  double get _loadingIconSize {
    final screenWidth = MediaQuery.of(context).size.width;
    if (screenWidth > 900) return 48;
    if (screenWidth > 600) return 44;
    return 40;
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header section
        Padding(
          padding: _containerPadding.add(const EdgeInsets.only(top: 16)),
          child: Row(
            children: [
              Text(
                'Категории заболеваний',
                style: TextStyle(
                  fontSize: _titleFontSize,
                  fontWeight: FontWeight.bold,
                  color: ColorConstants.textColor,
                ),
              ),
              const Spacer(),
              BlocBuilder<IllnessBloc, IllnessState>(
                buildWhen: (previous, current) => current is IllnessLoaded,
                builder: (context, state) {
                  if (state is IllnessLoaded &&
                      state.illnesses.length > _itemsToShowInitially) {
                    return _buildShowMoreButton();
                  }
                  return const SizedBox.shrink();
                },
              ),
            ],
          ),
        ),
        SizedBox(height: _verticalSpacing),

        // Content section
        BlocBuilder<IllnessBloc, IllnessState>(
          buildWhen: (previous, current) {
            return current is IllnessLoading ||
                current is IllnessLoaded ||
                current is IllnessEmpty ||
                current is IllnessError ||
                current is IllnessInitial;
          },
          builder: (context, state) {
            if (state is IllnessError || state is IllnessEmpty) {
              return const SizedBox.shrink();
            }

            if (state is IllnessLoading || state is IllnessInitial) {
              return _buildLoadingState();
            }

            if (state is IllnessLoaded) {
              return _buildLoadedState(state);
            }

            return _buildLoadingState();
          },
        ),
      ],
    );
  }

  Widget _buildLoadingState() {
    return Padding(
      padding: _containerPadding,
      child: SizedBox(
        height: _calculateGridHeight(_itemsToShowInitially),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            childAspectRatio: _childAspectRatio,
            crossAxisSpacing: _crossAxisSpacing,
            mainAxisSpacing: _mainAxisSpacing,
          ),
          itemCount: _itemsToShowInitially,
          itemBuilder: (context, index) => _buildLoadingCard(),
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey[100],
        borderRadius: BorderRadius.circular(_loadingCardRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(_loadingCardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon placeholder
            Container(
              width: _loadingIconSize,
              height: _loadingIconSize,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            const Spacer(),

            // Title placeholder
            Container(
              width: double.infinity,
              height: _loadingIconSize * 0.3,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(6),
              ),
            ),
            SizedBox(height: _loadingCardPadding * 0.5),

            // Subtitle placeholder
            Container(
              width: _loadingIconSize * 1.5,
              height: _loadingIconSize * 0.2,
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildLoadedState(IllnessLoaded state) {
    final itemCount = state.illnesses.length;
    final visibleItemCount =
        _isExpanded ? itemCount : _itemsToShowInitially.clamp(0, itemCount);

    return Padding(
      padding: _containerPadding,
      child: SizedBox(
        height: _calculateGridHeight(visibleItemCount),
        child: GridView.builder(
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: _crossAxisCount,
            childAspectRatio: _childAspectRatio,
            crossAxisSpacing: _crossAxisSpacing,
            mainAxisSpacing: _mainAxisSpacing,
          ),
          itemCount: visibleItemCount,
          itemBuilder: (context, index) {
            return CategoryCard(illness: state.illnesses[index]);
          },
        ),
      ),
    );
  }

  Widget _buildShowMoreButton() {
    final buttonPadding = MediaQuery.of(context).size.width > 600 ? 12.0 : 8.0;
    final iconSize = MediaQuery.of(context).size.width > 600 ? 24.0 : 20.0;

    return InkWell(
      onTap: _toggleExpanded,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: buttonPadding,
          vertical: buttonPadding * 0.5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              _isExpanded ? 'Скрыть' : 'Показать все',
              style: const TextStyle(
                color: ColorConstants.primaryColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
            const SizedBox(width: 4),
            Icon(
              _isExpanded ? Icons.keyboard_arrow_up : Icons.keyboard_arrow_down,
              color: ColorConstants.primaryColor,
              size: iconSize,
            ),
          ],
        ),
      ),
    );
  }

  double _calculateGridHeight(int itemCount) {
    if (itemCount <= 0) return 0;

    final rowCount = (itemCount / _crossAxisCount).ceil();
    final itemHeight = _getItemHeight();

    return (rowCount * itemHeight) + ((rowCount - 1) * _mainAxisSpacing);
  }

  double _getItemHeight() {
    final screenWidth = MediaQuery.of(context).size.width;
    final containerPaddingHorizontal = _containerPadding.horizontal;
    final totalSpacing = (_crossAxisCount - 1) * _crossAxisSpacing;

    final availableWidth =
        screenWidth - containerPaddingHorizontal - totalSpacing;
    final itemWidth = availableWidth / _crossAxisCount;

    return itemWidth / _childAspectRatio;
  }
}
