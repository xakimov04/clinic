import 'package:clinic/core/constants/color_constants.dart';
import 'package:flutter/material.dart';
import 'dart:async';

class CustomButton extends StatefulWidget {
  final String text;
  final Function() onPressed;
  final bool isLoading;
  final bool isOutlined;
  final Color? backgroundColor;
  final Color? textColor;
  final double height;
  final double? width;
  final double radius;
  final EdgeInsetsGeometry? padding;
  final Widget? prefixIcon;
  final Widget? suffixIcon;
  final Duration debounceTime;
  final bool fullWidth;
  final double? fontSize;
  final FontWeight? fontWeight;
  final bool disableOnLoading;
  final bool showLoadingText;
  final String? loadingText;
  final Color? loadingIndicatorColor;
  final BoxShadow? boxShadow;
  final double elevation;
  final VoidCallback? onLongPress;
  final FocusNode? focusNode;
  final bool autofocus;
  final Size? minimumSize;
  final Size? maximumSize;
  final MaterialTapTargetSize? tapTargetSize;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isOutlined = false,
    this.backgroundColor,
    this.textColor,
    this.height = 56,
    this.width,
    this.radius = 12,
    this.padding,
    this.prefixIcon,
    this.suffixIcon,
    this.debounceTime = const Duration(milliseconds: 500),
    this.fullWidth = false,
    this.fontSize,
    this.fontWeight,
    this.disableOnLoading = true,
    this.showLoadingText = false,
    this.loadingText,
    this.loadingIndicatorColor,
    this.boxShadow,
    this.elevation = 1,
    this.onLongPress,
    this.focusNode,
    this.autofocus = false,
    this.minimumSize,
    this.maximumSize,
    this.tapTargetSize,
  });

  @override
  State<CustomButton> createState() => _CustomButtonState();
}

class _CustomButtonState extends State<CustomButton> {
  bool _isPressed = false;
  late Timer? _debounceTimer;
  
  @override
  void initState() {
    super.initState();
    _debounceTimer = null;
  }
  
  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }
  
  void _handleTap() {
    // Agar buttonni ikkinchi marta juda tez bosilishini oldini olish
    if (_isPressed || (widget.disableOnLoading && widget.isLoading)) {
      return;
    }
    
    setState(() => _isPressed = true);
    
    // Debounce timer ishga tushirish
    _debounceTimer?.cancel();
    _debounceTimer = Timer(widget.debounceTime, () {
      if (mounted) {
        setState(() => _isPressed = false);
      }
    });
    
    // Callback'ni chaqirish
    widget.onPressed();
  }
  
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    
    // Rang logikasi
    final bgColor = widget.backgroundColor ?? 
      (widget.isOutlined ? Colors.transparent : ColorConstants.primaryColor);
    
    final txtColor = widget.textColor ?? 
      (widget.isOutlined ? ColorConstants.primaryColor : Colors.white);
    
    // Chegara logikasi
    final border = widget.isOutlined 
      ? BorderSide(color: ColorConstants.primaryColor, width: 1.5)
      : BorderSide.none;
    
    // Loading indikator rangi
    final loadingColor = widget.loadingIndicatorColor ?? 
      (widget.isOutlined ? ColorConstants.primaryColor : Colors.white);
    
    // Button Container
    return Container(
      height: widget.height,
      width: widget.fullWidth ? double.infinity : widget.width,
      decoration: widget.boxShadow != null ? BoxDecoration(
        borderRadius: BorderRadius.circular(widget.radius),
        boxShadow: [widget.boxShadow!],
      ) : null,
      child: ElevatedButton(
        onPressed: (_isPressed || widget.isLoading && widget.disableOnLoading) ? null : _handleTap,
        onLongPress: widget.onLongPress,
        focusNode: widget.focusNode,
        autofocus: widget.autofocus,
        style: ElevatedButton.styleFrom(
          backgroundColor: bgColor,
          foregroundColor: txtColor,
          disabledBackgroundColor: widget.isOutlined 
              ? Colors.transparent 
              : bgColor.withValues(alpha: 0.7),
          disabledForegroundColor: txtColor.withValues(alpha: 0.7),
          padding: widget.padding ?? const EdgeInsets.symmetric(horizontal: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(widget.radius),
            side: _isPressed || (widget.isLoading && widget.disableOnLoading)
                ? (widget.isOutlined 
                    ? BorderSide(color: ColorConstants.primaryColor.withValues(alpha: 0.7), width: 1.5)
                    : BorderSide.none)
                : border,
          ),
          elevation: widget.isOutlined ? 0 : widget.elevation,
          minimumSize: widget.minimumSize,
          maximumSize: widget.maximumSize,
          tapTargetSize: widget.tapTargetSize,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 200),
          child: widget.isLoading
            ? _buildLoadingWidget(loadingColor)
            : _buildContentWidget(theme, txtColor),
        ),
      ),
    );
  }
  
  Widget _buildLoadingWidget(Color loadingColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(loadingColor),
          ),
        ),
        if (widget.showLoadingText) ...[
          const SizedBox(width: 12),
          Text(
            widget.loadingText ?? 'Yuklanmoqda...',
            style: TextStyle(
              color: loadingColor,
              fontSize: widget.fontSize ?? 16,
              fontWeight: widget.fontWeight ?? FontWeight.w600,
            ),
          ),
        ]
      ],
    );
  }
  
  Widget _buildContentWidget(ThemeData theme, Color txtColor) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        if (widget.prefixIcon != null) ...[
          widget.prefixIcon!,
          const SizedBox(width: 8),
        ],
        Flexible(
          child: Text(
            widget.text,
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.titleMedium?.copyWith(
              color: txtColor,
              fontSize: widget.fontSize,
              fontWeight: widget.fontWeight ?? FontWeight.w600,
            ),
          ),
        ),
        if (widget.suffixIcon != null) ...[
          const SizedBox(width: 8),
          widget.suffixIcon!,
        ],
      ],
    );
  }
}