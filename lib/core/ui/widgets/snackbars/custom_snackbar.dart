import 'dart:io';
import 'package:clinic/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

enum SnackBarStyle {
  success,
  error,
  warning,
  info,
}

class CustomSnackbar {
  static final CustomSnackbar _instance = CustomSnackbar._internal();

  factory CustomSnackbar() {
    return _instance;
  }

  CustomSnackbar._internal();

  /// Platforma bo'yicha snackbarni ko'rsatish
  static void show({
    required BuildContext context,
    required String message,
    SnackBarStyle style = SnackBarStyle.info,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionTap,
    bool forceMaterial = false,
    bool dismissible = true,
  }) {
    // Platforma tekshirish
    if ((Platform.isIOS || Platform.isMacOS) && !forceMaterial) {
      _showCupertinoToast(
        context: context,
        message: message,
        style: style,
        duration: duration,
        actionLabel: actionLabel,
        onActionTap: onActionTap,
      );
    } else {
      _showMaterialSnackBar(
        context: context,
        message: message,
        style: style,
        duration: duration,
        actionLabel: actionLabel,
        onActionTap: onActionTap,
        dismissible: dismissible,
      );
    }
  }

  /// iOS uchun CupertinoToast
  static void _showCupertinoToast({
    required BuildContext context,
    required String message,
    required SnackBarStyle style,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionTap,
  }) {
    final overlay = Navigator.of(context).overlay;
    if (overlay == null) return;

    // Stil va ranglarni aniqlash
    final Color backgroundColor;
    final Color textColor = Colors.white;
    final IconData iconData;

    switch (style) {
      case SnackBarStyle.success:
        backgroundColor = ColorConstants.successColor;
        iconData = CupertinoIcons.check_mark_circled;
        break;
      case SnackBarStyle.error:
        backgroundColor = ColorConstants.errorColor;
        iconData = CupertinoIcons.exclamationmark_circle;
        break;
      case SnackBarStyle.warning:
        backgroundColor = ColorConstants.warningColor;
        iconData = CupertinoIcons.exclamationmark_triangle;
        break;
      case SnackBarStyle.info:
        backgroundColor = ColorConstants.infoColor;
        iconData = CupertinoIcons.info_circle;
        break;
    }

    // Toast widget
    final Widget toast = SafeArea(
      child: Material(
        type: MaterialType.transparency,
        child: Align(
          alignment: Alignment.topCenter,
          child: Padding(
            padding: const EdgeInsets.only(top: 8.0, left: 8.0, right: 8.0),
            child: Container(
              decoration: BoxDecoration(
                color: backgroundColor,
                borderRadius: BorderRadius.circular(10.0),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10.0),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16.0,
                    vertical: 12.0,
                  ),
                  child: IntrinsicHeight(
                    child: Row(
                      children: [
                        Icon(
                          iconData,
                          color: textColor,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            message,
                            style: TextStyle(
                              color: textColor,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                        if (actionLabel != null && onActionTap != null) ...[
                          const SizedBox(width: 8),
                          CupertinoButton(
                            padding: const EdgeInsets.symmetric(horizontal: 8),
                            minSize: 30,
                            onPressed: () {
                              onActionTap();
                              _removeToast(context);
                            },
                            child: Text(
                              actionLabel,
                              style: TextStyle(
                                color: textColor,
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Toast ni ko'rsatish
    final OverlayEntry entry = OverlayEntry(builder: (context) => toast);
    overlay.insert(entry);

    // Vaqt tugaganda yopish
    Future.delayed(duration, () {
      if (entry.mounted) {
        entry.remove();
      }
    });

    // Entry ni global o'zgaruvchida saqlash
    _lastOverlayEntry = entry;
  }

  /// Oxirgi toast overlay entryni saqlash
  static OverlayEntry? _lastOverlayEntry;

  /// Toast ni yopish
  static void _removeToast(BuildContext context) {
    if (_lastOverlayEntry != null && _lastOverlayEntry!.mounted) {
      _lastOverlayEntry!.remove();
      _lastOverlayEntry = null;
    }
  }

  /// Android uchun Material SnackBar
  static void _showMaterialSnackBar({
    required BuildContext context,
    required String message,
    required SnackBarStyle style,
    required Duration duration,
    String? actionLabel,
    VoidCallback? onActionTap,
    bool dismissible = true,
  }) {
    // Joriy snackbar ni yopish
    ScaffoldMessenger.of(context).hideCurrentSnackBar();

    // Stil va ranglarni aniqlash
    final Color backgroundColor;
    final Color textColor = Colors.white;
    final IconData iconData;

    switch (style) {
      case SnackBarStyle.success:
        backgroundColor = ColorConstants.successColor;
        iconData = Icons.check_circle_outline;
        break;
      case SnackBarStyle.error:
        backgroundColor = ColorConstants.errorColor;
        iconData = Icons.error_outline;
        break;
      case SnackBarStyle.warning:
        backgroundColor = ColorConstants.warningColor;
        iconData = Icons.warning_amber_outlined;
        break;
      case SnackBarStyle.info:
        backgroundColor = ColorConstants.infoColor;
        iconData = Icons.info_outline;
        break;
    }

    // Snackbar yaratish
    final snackBar = SnackBar(
      backgroundColor: backgroundColor,
      behavior: SnackBarBehavior.floating,
      elevation: 6,
      margin: const EdgeInsets.all(8),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      duration: duration,
      dismissDirection:
          dismissible ? DismissDirection.horizontal : DismissDirection.none,
      content: Row(
        children: [
          Icon(
            iconData,
            color: textColor,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: textColor,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
      action: actionLabel != null && onActionTap != null
          ? SnackBarAction(
              label: actionLabel,
              textColor: textColor,
              onPressed: onActionTap,
            )
          : null,
    );

    // Snackbar ni ko'rsatish
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }

  /// Muvaffaqiyat xabari
  static void showSuccess({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionTap,
    bool forceMaterial = false,
  }) {
    show(
      context: context,
      message: message,
      style: SnackBarStyle.success,
      duration: duration,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      forceMaterial: forceMaterial,
    );
  }

  /// Xatolik xabari
  static void showError({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onActionTap,
    bool forceMaterial = false,
  }) {
    show(
      context: context,
      message: message,
      style: SnackBarStyle.error,
      duration: duration,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      forceMaterial: forceMaterial,
    );
  }

  /// Ogohlantirish xabari
  static void showWarning({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionTap,
    bool forceMaterial = false,
  }) {
    show(
      context: context,
      message: message,
      style: SnackBarStyle.warning,
      duration: duration,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      forceMaterial: forceMaterial,
    );
  }

  /// Ma'lumot xabari
  static void showInfo({
    required BuildContext context,
    required String message,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onActionTap,
    bool forceMaterial = false,
  }) {
    show(
      context: context,
      message: message,
      style: SnackBarStyle.info,
      duration: duration,
      actionLabel: actionLabel,
      onActionTap: onActionTap,
      forceMaterial: forceMaterial,
    );
  }

  /// Internet yo'qligi xabari
  static void showNoInternet({
    required BuildContext context,
    VoidCallback? onRetry,
    bool forceMaterial = false,
  }) {
    show(
      context: context,
      message: 'Нет подключения к интернету',
      style: SnackBarStyle.error,
      duration: const Duration(seconds: 5),
      actionLabel: 'Повторить',
      onActionTap: onRetry,
      forceMaterial: forceMaterial,
    );
  }

  /// Server xatosi
  static void showServerError({
    required BuildContext context,
    String message = 'Произошла ошибка сервера. Пожалуйста, попробуйте позже.',
    VoidCallback? onRetry,
    bool forceMaterial = false,
  }) {
    show(
      context: context,
      message: message,
      style: SnackBarStyle.error,
      duration: const Duration(seconds: 4),
      actionLabel: onRetry != null ? 'Повторить' : null,
      onActionTap: onRetry,
      forceMaterial: forceMaterial,
    );
  }
}
