import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shimmer/shimmer.dart';

/// Custom cache manager - rasmlar uchun maxsus sozlamalar
class CustomImageCacheManager {
  static const key = 'customImageCache';

  static CacheManager instance = CacheManager(
    Config(
      key,
      stalePeriod: const Duration(days: 7), // 7 kun cache saqlash
      maxNrOfCacheObjects: 200, // maksimal 200 ta rasm
      repo: JsonCacheInfoRepository(databaseName: key),
      fileSystem: IOFileSystem(key),
      fileService: HttpFileService(),
    ),
  );
}

/// Shimmer placeholder widget
class ShimmerPlaceholder extends StatelessWidget {
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Color baseColor;
  final Color highlightColor;

  const ShimmerPlaceholder({
    super.key,
    this.width,
    this.height,
    this.borderRadius,
    this.baseColor = const Color(0xFFE0E0E0),
    this.highlightColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      period: const Duration(milliseconds: 1200),
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          color: baseColor,
          borderRadius: borderRadius ?? BorderRadius.zero,
        ),
      ),
    );
  }
}

/// Universal cache image widget
class CacheImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;
  final BoxFit fit;
  final Widget? placeholder;
  final Widget? errorWidget;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Duration fadeDuration;
  final bool enableMemoryCache;
  final Map<String, String>? httpHeaders;
  final bool useShimmer;
  final Color shimmerBaseColor;
  final Color shimmerHighlightColor;

  const CacheImageWidget({
    super.key,
    required this.imageUrl,
    this.width,
    this.height,
    this.fit = BoxFit.cover,
    this.placeholder,
    this.errorWidget,
    this.borderRadius,
    this.backgroundColor,
    this.fadeDuration = const Duration(milliseconds: 500),
    this.enableMemoryCache = true,
    this.httpHeaders,
    this.useShimmer = true,
    this.shimmerBaseColor = const Color(0xFFE0E0E0),
    this.shimmerHighlightColor = const Color(0xFFF5F5F5),
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius ?? BorderRadius.zero,
      child: Container(
        width: width,
        height: height,
        color: backgroundColor,
        child: CachedNetworkImage(
          imageUrl: imageUrl,
          width: width,
          height: height,
          fit: fit,
          cacheManager: CustomImageCacheManager.instance,
          fadeInDuration: fadeDuration,
          memCacheWidth: enableMemoryCache ? _getMemCacheSize(width) : null,
          memCacheHeight: enableMemoryCache ? _getMemCacheSize(height) : null,
          httpHeaders: httpHeaders,
          placeholder: (context, url) => _buildPlaceholder(),
          errorWidget: (context, url, error) => _buildErrorWidget(),
        ),
      ),
    );
  }

  /// Memory cache uchun optimal o'lcham hisoblash
  int? _getMemCacheSize(double? size) {
    if (size == null) return null;
    // Device pixel ratio ni hisobga olib optimal o'lcham qaytarish
    return (size * 2).round(); // Standard 2x scaling
  }

  /// Shimmer yoki default placeholder
  Widget _buildPlaceholder() {
    if (placeholder != null) return placeholder!;

    if (useShimmer) {
      return ShimmerPlaceholder(
        width: width,
        height: height,
        borderRadius: borderRadius,
        baseColor: shimmerBaseColor,
        highlightColor: shimmerHighlightColor,
      );
    }

    return Container(
      color: Colors.grey[200],
      child: const Center(
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(Colors.grey),
        ),
      ),
    );
  }

  /// Default error widget
  Widget _buildErrorWidget() {
    return errorWidget ??
        Container(
          color: Colors.grey[100],
          child: const Icon(
            Icons.broken_image_outlined,
            color: Colors.grey,
            size: 40,
          ),
        );
  }
}

/// Avatar uchun maxsus cache image
class CacheAvatarWidget extends StatelessWidget {
  final String imageUrl;
  final double radius;
  final Widget? placeholder;
  final Widget? errorWidget;
  final Color? backgroundColor;
  final bool useShimmer;

  const CacheAvatarWidget({
    super.key,
    required this.imageUrl,
    this.radius = 25,
    this.placeholder,
    this.errorWidget,
    this.backgroundColor,
    this.useShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    return CircleAvatar(
      radius: radius,
      backgroundColor: backgroundColor ?? Colors.grey[200],
      child: ClipOval(
        child: CacheImageWidget(
          imageUrl: imageUrl,
          width: radius * 2,
          height: radius * 2,
          fit: BoxFit.cover,
          useShimmer: useShimmer,
          borderRadius: BorderRadius.circular(radius),
          placeholder: placeholder ??
              (useShimmer
                  ? ShimmerPlaceholder(
                      width: radius * 2,
                      height: radius * 2,
                      borderRadius: BorderRadius.circular(radius),
                    )
                  : Icon(Icons.person, size: radius, color: Colors.grey)),
          errorWidget: errorWidget ??
              Icon(Icons.person, size: radius, color: Colors.grey),
        ),
      ),
    );
  }
}

class CacheThumbnailWidget extends StatelessWidget {
  final String imageUrl;
  final VoidCallback? onTap;
  final double size;
  final bool showOverlay;
  final bool useShimmer;

  const CacheThumbnailWidget({
    super.key,
    required this.imageUrl,
    this.onTap,
    this.size = 80,
    this.showOverlay = false,
    this.useShimmer = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Stack(
        children: [
          CacheImageWidget(
            imageUrl: imageUrl,
            width: size,
            height: size,
            borderRadius: BorderRadius.circular(8),
            fit: BoxFit.cover,
            useShimmer: useShimmer,
          ),
          if (showOverlay)
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(8),
                  color: Colors.black.withOpacity(0.3),
                ),
                child: const Icon(
                  Icons.zoom_in,
                  color: Colors.white,
                  size: 24,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

/// Image cache service - global boshqaruv uchun
class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  static ImageCacheService get instance => _instance;
  ImageCacheService._internal();

  /// Barcha cache ni tozalash
  Future<void> clearAllCache() async {
    await CustomImageCacheManager.instance.emptyCache();
  }

  /// Ma'lum bir rasmni cache dan o'chirish
  Future<void> evictFromCache(String imageUrl) async {
    await CustomImageCacheManager.instance.removeFile(imageUrl);
  }

  /// Cache o'lchamini olish
  Future<int> getCacheSize() async {
    final cacheDir = await getTemporaryDirectory();
    int totalSize = 0;

    await for (var entity in cacheDir.list(recursive: true)) {
      if (entity is File) {
        totalSize += await entity.length();
      }
    }

    return totalSize;
  }

  /// Cache statistikasini olish
  Future<Map<String, dynamic>> getCacheStats() async {
    final size = await getCacheSize();
    final cacheDir = await getTemporaryDirectory();
    final fileCount = await cacheDir.list().length;

    return {
      'size': size,
      'sizeFormatted': _formatBytes(size),
      'fileCount': fileCount,
    };
  }

  /// Bytes ni odam o'qiydigan formatga o'tkazish
  String _formatBytes(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1024 * 1024) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    if (bytes < 1024 * 1024 * 1024) {
      return '${(bytes / (1024 * 1024)).toStringAsFixed(1)} MB';
    }
    return '${(bytes / (1024 * 1024 * 1024)).toStringAsFixed(1)} GB';
  }

  /// Rasmni oldindan cache ga yuklash
  Future<void> preCache(String imageUrl) async {
    await CustomImageCacheManager.instance.downloadFile(imageUrl);
  }

  /// Bir nechta rasmlarni oldindan yuklash
  Future<void> preCacheMultiple(List<String> imageUrls) async {
    final futures = imageUrls.map((url) => preCache(url));
    await Future.wait(futures);
  }
}
