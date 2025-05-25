import 'package:cached_network_image/cached_network_image.dart';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:flutter/material.dart';

enum CustomImageType {
  rectangle,
  circle,
  rounded,
}

class CustomCachedImage extends StatelessWidget {
  /// Rasm URL'i
  final String? imageUrl;
  
  /// Rasm o'lchami
  final double? width;
  final double? height;
  
  /// Rasm turi
  final CustomImageType type;
  
  /// Rasm joylashishi
  final BoxFit fit;
  
  /// Border radius (faqat rounded type uchun)
  final double borderRadius;
  
  /// Placeholder widget
  final Widget? placeholder;
  
  /// Xatolik widget'i
  final Widget? errorWidget;
  
  /// Loading indikatori rangi
  final Color? loadingColor;
  
  /// Default avatar text (agar rasm bo'lmasa)
  final String? fallbackText;
  
  /// Fallback icon
  final IconData? fallbackIcon;
  
  /// Background color
  final Color? backgroundColor;
  
  /// Text color (fallback uchun)
  final Color? textColor;
  
  /// Headers (autentifikatsiya uchun)
  final Map<String, String>? headers;
  
  /// Rasm bosilganda
  final VoidCallback? onTap;
  
  /// Cache kaliti (maxsus cache uchun)
  final String? cacheKey;
  
  /// Fade animatsiya davomiyligi
  final Duration fadeInDuration;
  
  /// Border
  final Border? border;
  
  /// Box shadow
  final List<BoxShadow>? boxShadow;
  
  /// Memory cache
  final bool memCacheEnabled;
  
  /// Disk cache
  final bool diskCacheEnabled;

  const CustomCachedImage({
    super.key,
    this.imageUrl,
    this.width,
    this.height,
    this.type = CustomImageType.rectangle,
    this.fit = BoxFit.cover,
    this.borderRadius = 12,
    this.placeholder,
    this.errorWidget,
    this.loadingColor,
    this.fallbackText,
    this.fallbackIcon,
    this.backgroundColor,
    this.textColor,
    this.headers,
    this.onTap,
    this.cacheKey,
    this.fadeInDuration = const Duration(milliseconds: 300),
    this.border,
    this.boxShadow,
    this.memCacheEnabled = true,
    this.diskCacheEnabled = true,
  });

  // Factory constructors - oson foydalanish uchun
  factory CustomCachedImage.avatar({
    String? imageUrl,
    double radius = 25,
    String? fallbackText,
    Color? backgroundColor,
    Color? textColor,
    Map<String, String>? headers,
    VoidCallback? onTap,
    Border? border,
  }) {
    return CustomCachedImage(
      imageUrl: imageUrl,
      width: radius * 2,
      height: radius * 2,
      type: CustomImageType.circle,
      fallbackText: fallbackText,
      backgroundColor: backgroundColor,
      textColor: textColor,
      headers: headers,
      onTap: onTap,
      border: border,
    );
  }

  factory CustomCachedImage.card({
    String? imageUrl,
    double? width,
    double? height,
    double borderRadius = 12,
    BoxFit fit = BoxFit.cover,
    Map<String, String>? headers,
    VoidCallback? onTap,
    List<BoxShadow>? boxShadow,
  }) {
    return CustomCachedImage(
      imageUrl: imageUrl,
      width: width,
      height: height,
      type: CustomImageType.rounded,
      borderRadius: borderRadius,
      fit: fit,
      headers: headers,
      onTap: onTap,
      boxShadow: boxShadow,
    );
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget = _buildImageWidget();

    // Container bilan o'rash (shadow, border uchun)
    if (boxShadow != null || border != null) {
      imageWidget = Container(
        decoration: BoxDecoration(
          borderRadius: _getBorderRadius(),
          boxShadow: boxShadow,
          border: border,
        ),
        child: ClipRRect(
          borderRadius: _getBorderRadius(),
          child: imageWidget,
        ),
      );
    }

    // Tap qo'shish
    if (onTap != null) {
      imageWidget = GestureDetector(
        onTap: onTap,
        child: imageWidget,
      );
    }

    return imageWidget;
  }

  Widget _buildImageWidget() {
    // Agar URL bo'sh bo'lsa, to'g'ridan-to'g'ri fallback ko'rsatish
    if (imageUrl == null || imageUrl!.isEmpty) {
      return _buildFallbackWidget();
    }

    return CachedNetworkImage(
      imageUrl: imageUrl!,
      width: width,
      height: height,
      fit: fit,
      cacheKey: cacheKey,
      fadeInDuration: fadeInDuration,
      memCacheHeight: _getMemCacheSize(),
      memCacheWidth: _getMemCacheSize(),
      httpHeaders: headers ?? _getDefaultHeaders(),
      imageBuilder: (context, imageProvider) => _buildImageContainer(imageProvider),
      placeholder: (context, url) => placeholder ?? _buildLoadingWidget(),
      errorWidget: (context, url, error) => errorWidget ?? _buildErrorWidget(),
      // Cache sozlamalari
      cacheManager: diskCacheEnabled ? null : null, // Default manager ishlatish
    );
  }

  Widget _buildImageContainer(ImageProvider imageProvider) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        borderRadius: _getBorderRadius(),
        image: DecorationImage(
          image: imageProvider,
          fit: fit,
        ),
      ),
    );
  }

  Widget _buildLoadingWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? Colors.grey.shade100,
        borderRadius: _getBorderRadius(),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: _getLoadingSize(),
              height: _getLoadingSize(),
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(
                  loadingColor ?? ColorConstants.primaryColor,
                ),
              ),
            ),
            if (_shouldShowLoadingText()) ...[
              const SizedBox(height: 8),
              Text(
                'Загрузка...',
                style: TextStyle(
                  fontSize: _getLoadingTextSize(),
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildErrorWidget() {
    return _buildFallbackWidget();
  }

  Widget _buildFallbackWidget() {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor ?? 
               (type == CustomImageType.circle 
                   ? ColorConstants.primaryColor.withOpacity(0.1)
                   : Colors.grey.shade100),
        borderRadius: _getBorderRadius(),
        border: type != CustomImageType.circle 
            ? Border.all(color: Colors.grey.shade300)
            : null,
      ),
      child: Center(
        child: _buildFallbackContent(),
      ),
    );
  }

  Widget _buildFallbackContent() {
    // Agar fallback text berilgan bo'lsa
    if (fallbackText != null && fallbackText!.isNotEmpty) {
      return Text(
        fallbackText!.substring(0, 1).toUpperCase(),
        style: TextStyle(
          fontSize: _getFallbackTextSize(),
          fontWeight: FontWeight.bold,
          color: textColor ?? ColorConstants.primaryColor,
        ),
      );
    }

    // Icon ko'rsatish
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          fallbackIcon ?? 
          (type == CustomImageType.circle 
              ? Icons.person_outline_rounded
              : Icons.image_not_supported_outlined),
          size: _getFallbackIconSize(),
          color: textColor ?? Colors.grey.shade400,
        ),
        if (_shouldShowErrorText()) ...[
          const SizedBox(height: 4),
          Text(
            'Rasm yo\'q',
            style: TextStyle(
              fontSize: _getErrorTextSize(),
              color: Colors.grey.shade500,
            ),
          ),
        ],
      ],
    );
  }

  // Helper methodlar
  BorderRadius _getBorderRadius() {
    switch (type) {
      case CustomImageType.circle:
        final radius = (width ?? height ?? 50) / 2;
        return BorderRadius.circular(radius);
      case CustomImageType.rounded:
        return BorderRadius.circular(borderRadius);
      case CustomImageType.rectangle:
        return BorderRadius.zero;
    }
  }

  Map<String, String> _getDefaultHeaders() {
    return {
      'User-Agent': 'Flutter App',
      'Accept': 'image/*',
    };
  }

  int? _getMemCacheSize() {
    if (!memCacheEnabled) return null;
    
    final size = (width ?? height ?? 100).toInt();
    return size > 300 ? 300 : size; // Max 300px cache
  }

  double _getLoadingSize() {
    final containerSize = width ?? height ?? 60;
    return containerSize > 100 ? 24 : 16;
  }

  double _getLoadingTextSize() {
    final containerSize = width ?? height ?? 60;
    return containerSize > 100 ? 12 : 10;
  }

  double _getFallbackTextSize() {
    final containerSize = width ?? height ?? 60;
    if (type == CustomImageType.circle) {
      return containerSize / 3;
    }
    return containerSize > 100 ? 24 : 16;
  }

  double _getFallbackIconSize() {
    final containerSize = width ?? height ?? 60;
    if (type == CustomImageType.circle) {
      return containerSize / 2.5;
    }
    return containerSize > 100 ? 32 : 24;
  }

  double _getErrorTextSize() {
    final containerSize = width ?? height ?? 60;
    return containerSize > 100 ? 10 : 8;
  }

  bool _shouldShowLoadingText() {
    final containerSize = width ?? height ?? 60;
    return containerSize >= 80;
  }

  bool _shouldShowErrorText() {
    final containerSize = width ?? height ?? 60;
    return containerSize >= 80 && type != CustomImageType.circle;
  }
}
